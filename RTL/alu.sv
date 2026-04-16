module alu(
    input  logic       clk,
    input  logic       reset,
    input  logic       start_alu,
    input  logic [7:0] A,
    input  logic [7:0] B,
    input  logic [2:0] op_sel,

    output logic [7:0] alu_result,
    output logic       alu_done,
    output logic       alu_error
);

    typedef enum logic [2:0] {
        ALU_IDLE,
        ADD,
        SUB,
        MUL,
        DIV,
        ALU_DONE,
        ALU_ERROR
    } alu_state_t;

    alu_state_t state, next_state;

    logic [7:0] A_reg, B_reg, result_reg;
    logic [7:0] A_next, B_next, result_next;
    logic [3:0] count, count_next;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= ALU_IDLE;
            A_reg      <= 8'd0;
            B_reg      <= 8'd0;
            result_reg <= 8'd0;
            count      <= 4'd0;
        end else begin
            state      <= next_state;
            A_reg      <= A_next;
            B_reg      <= B_next;
            result_reg <= result_next;
            count      <= count_next;
        end
    end

    always_comb begin
        next_state  = state;
        alu_done    = 1'b0;
        alu_error   = 1'b0;

        A_next      = A_reg;
        B_next      = B_reg;
        result_next = result_reg;
        count_next  = count;

        case (state)
            ALU_IDLE: begin
                if (start_alu) begin
                    A_next      = A;
                    B_next      = B;
                    result_next = 8'd0;
                    count_next  = 4'd0;

                    case (op_sel)
                        3'd0: next_state = ADD;
                        3'd1: next_state = SUB;
                        3'd2: next_state = MUL;
                        3'd3: next_state = DIV;
                        default: next_state = ALU_ERROR;
                    endcase
                end
            end

            ADD: begin
                result_next = A_reg + B_reg;
                next_state  = ALU_DONE;
            end

            SUB: begin
                result_next = A_reg - B_reg;
                next_state  = ALU_DONE;
            end

            MUL: begin
                if (count < 8) begin
                    if (B_reg[0])
                        result_next = result_reg + A_reg;
                    A_next     = A_reg << 1;
                    B_next     = B_reg >> 1;
                    count_next = count + 1;
                    next_state = MUL;
                end else begin
                    next_state = ALU_DONE;
                end
            end

            DIV: begin
                if (B_reg == 0) begin
                    next_state = ALU_ERROR;
                end
                else if (A_reg >= B_reg) begin
                    A_next      = A_reg - B_reg;
                    result_next = result_reg + 1;
                    next_state  = DIV;
                end
                else begin
                    next_state = ALU_DONE;
                end
            end

            ALU_DONE: begin
                alu_done   = 1'b1;
                next_state = ALU_IDLE;
            end

            ALU_ERROR: begin
                alu_done   = 1'b1;
                alu_error  = 1'b1;
                next_state = ALU_IDLE;
            end

            default: begin
                next_state = ALU_IDLE;
            end
        endcase
    end

    assign alu_result = result_reg;

endmodule
