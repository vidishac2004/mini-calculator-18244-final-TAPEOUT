
module calculator_control(
    input  logic       clk,
    input  logic       reset,
    input  logic       key_valid,
    input  logic [3:0] decoded_key,
    input  logic [2:0] key_type,
    input  logic       clear,
    output logic [7:0] result
);

    logic load_A, load_B, load_result, en_buffer, clr_input_buffer, start_alu;
    logic load_op;
    logic [2:0] op_sel_fsm;
    logic [2:0] op_sel_reg;

    logic [7:0] buffer_value;
    logic [7:0] A, B;
    logic [7:0] alu_result;
    logic       alu_done, alu_error;

    calculator_FSM calc_fsm (
        .clk(clk),
        .reset(reset),
        .key_valid(key_valid),
        .alu_done(alu_done),
        .alu_error(alu_error),
        .clear(clear),
        .decoded_key(decoded_key),
        .key_type(key_type),
        .load_A(load_A),
        .load_B(load_B),
        .load_result(load_result),
        .load_op(load_op),
        .en_buffer(en_buffer),
        .clr_input_buffer(clr_input_buffer),
        .start_alu(start_alu),
        .op_sel(op_sel_fsm)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            op_sel_reg <= 0;
        else if (clear)
            op_sel_reg <= 0;
        else if (load_op)
            op_sel_reg <= op_sel_fsm;
    end

    input_buffer inst_input_buffer (
        .clk(clk),
        .reset(reset),
        .en_buffer(en_buffer),
        .key_valid(key_valid),
        .decoded_key(decoded_key),
        .key_type(key_type),
        .clr_input_buffer(clr_input_buffer),
        .buffer_value(buffer_value)
    );

    operand_regs inst_operand_regs (
        .clk(clk),
        .reset(reset),
        .clr_regs(clear),
        .load_A(load_A),
        .load_B(load_B),
        .load_result(load_result),
        .buffer_value(buffer_value),
        .alu_result(alu_result),
        .A(A),
        .B(B),
        .result(result)
    );

    alu inst_alu (
        .clk(clk),
        .reset(reset),
        .start_alu(start_alu),
        .A(A),
        .B(B),
        .op_sel(op_sel_reg),
        .alu_result(alu_result),
        .alu_done(alu_done),
        .alu_error(alu_error)
    );

endmodule
