module calculator_FSM(
    input  logic       clk,
    input  logic       reset,
    input  logic       key_valid,
    input  logic       alu_done,
    input  logic       alu_error,
    input  logic       clear,
    input  logic [3:0] decoded_key,
    input  logic [2:0] key_type,

    output logic       load_A,
    output logic       load_B,
    output logic       load_result,
    output logic       load_op,
    output logic       en_buffer,
    output logic       clr_input_buffer,
    output logic       start_alu,
    output logic [2:0] op_sel
);

    typedef enum logic [3:0] {
        IDLE,
        INPUT_A,
        OP_SEL,
        INPUT_B,
        LOAD_B,
        START_ALU,
        EXECUTE,
        LOAD_RESULT,
        DISPLAY,
        ERROR_STATE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state       = state;
        load_A           = 1'b0;
        load_B           = 1'b0;
        load_result      = 1'b0;
        load_op          = 1'b0;
        start_alu        = 1'b0;
        clr_input_buffer = 1'b0;
        en_buffer        = 1'b0;
        op_sel           = 3'b000;

        if (clear) begin
            next_state       = IDLE;
            clr_input_buffer = 1'b1;
        end
        else begin
            case (state)
                IDLE: begin
                    if (key_valid && key_type == 0)
                        next_state = INPUT_A;
                end

                INPUT_A: begin
                    if (key_valid && key_type == 0)
                        next_state = INPUT_A;
                    else if (key_valid && key_type == 3'd1)
                        next_state = OP_SEL;
                end

                OP_SEL: begin
                    next_state = INPUT_B;
                end

                INPUT_B: begin
                    if (key_valid && key_type == 0)
                        next_state = INPUT_B;
                    else if (key_valid && key_type == 3'd2)
                        next_state = LOAD_B;
                end

                LOAD_B: begin
                    next_state = START_ALU;
                end

                START_ALU: begin
                    next_state = EXECUTE;
                end

                EXECUTE: begin
                    if (alu_done) begin
                        if (alu_error)
                            next_state = ERROR_STATE;
                        else
                            next_state = LOAD_RESULT;
                    end
                end

                LOAD_RESULT: begin
                    next_state = DISPLAY;
                end

                DISPLAY: begin
                    if (key_valid && key_type == 0)
                        next_state = INPUT_A;
                end

                ERROR_STATE: begin
                    if (clear)
                        next_state = IDLE;
                end

                default: begin
                    next_state = IDLE;
                end
            endcase

            case (state)
                IDLE: begin
                   if (key_valid && key_type == 0)
                         en_buffer = 1'b1;
                end

                INPUT_A: begin
                    en_buffer = 1'b1;
                end

                OP_SEL: begin
                    load_A           = 1;
                    load_op          = 1;
                    clr_input_buffer = 1;
                    op_sel           = decoded_key[2:0];
                end

                INPUT_B: begin
                    en_buffer = 1'b1;
                end

                LOAD_B: begin
                    load_B = 1'b1;
                end

                START_ALU: begin
                    start_alu = 1'b1;
                end

                EXECUTE: begin
                end

                LOAD_RESULT: begin
                    load_result = 1'b1;
                end

                DISPLAY: begin
                end

                ERROR_STATE: begin
                end

                default: begin
                end
            endcase
        end
    end

endmodule
