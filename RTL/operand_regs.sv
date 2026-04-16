module operand_regs(
    input  logic       clk,
    input  logic       reset,
    input  logic       clr_regs,
    input  logic       load_A,
    input  logic       load_B,
    input  logic       load_result,
    input  logic [7:0] buffer_value,
    input  logic [7:0] alu_result,
    output logic [7:0] A,
    output logic [7:0] B,
    output logic [7:0] result
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            A <= 8'd0;
            B <= 8'd0;
            result<=8'd0;
        end
        else if (clr_regs) begin
            A <=8'd0;
            B <= 8'd0;
            result <= 8'd0;
        end
        else begin
            if (load_A)
                A <=buffer_value;
            if (load_B)
                B <=buffer_value;
            if (load_result)
                result <=alu_result;
        end
    end

endmodule
