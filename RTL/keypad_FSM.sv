module keypad_FSM(
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] row,

    output logic [3:0] col,
    output logic [3:0] decoded_key,
    output logic [2:0] key_type,
    output logic       key_valid
);

    typedef enum logic [2:0] {
        IDLE,
        SCAN_COL0,
        SCAN_COL1,
        SCAN_COL2,
        SCAN_COL3,
        DEBOUNCE,
        DECODE,
        WAIT_RELEASE
    } state_t;

    state_t state, next_state;

    logic [1:0]  col_index, col_index_next;
    logic [3:0]  row_sample, row_sample_next;
    logic [15:0] debounce_counter, debounce_counter_next;

    logic [2:0] TYPE_DIGIT  = 0;
    logic [2:0] TYPE_OP     = 3'd1;
    logic [2:0] TYPE_EQUALS = 3'd2;
    logic [2:0] TYPE_CLEAR  = 3'd3;

    int DEBOUNCE_MAX = 16'd5000;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state            <= IDLE;
            col_index        <= 2'd0;
            row_sample       <= 4'b1111;
            debounce_counter <= 16'd0;
        end
        else begin
            state            <= next_state;
            col_index        <= col_index_next;
            row_sample       <= row_sample_next;
            debounce_counter <= debounce_counter_next;
        end
    end

    always_comb begin
        next_state            = state;
        col_index_next        = col_index;
        row_sample_next       = row_sample;
        debounce_counter_next = debounce_counter;

        col         = 4'b1111;
        key_valid   = 1'b0;
        decoded_key = 4'd0;
        key_type    = TYPE_DIGIT;

        case (state)
            IDLE: begin
                next_state = SCAN_COL0;
            end

            SCAN_COL0: begin
                col = 4'b1110;
                if (row != 4'b1111) begin
                    col_index_next        = 2'd0;
                    row_sample_next       = row;
                    debounce_counter_next = 16'd0;
                    next_state            = DEBOUNCE;
                end
                else begin
                    next_state = SCAN_COL1;
                end
            end

            SCAN_COL1: begin
                col = 4'b1101;
                if (row != 4'b1111) begin
                    col_index_next        = 2'd1;
                    row_sample_next       = row;
                    debounce_counter_next = 16'd0;
                    next_state            = DEBOUNCE;
                end
                else begin
                    next_state = SCAN_COL2;
                end
            end

            SCAN_COL2: begin
                col = 4'b1011;
                if (row != 4'b1111) begin
                    col_index_next        = 2'd2;
                    row_sample_next       = row;
                    debounce_counter_next = 16'd0;
                    next_state            = DEBOUNCE;
                end
                else begin
                    next_state = SCAN_COL3;
                end
            end

            SCAN_COL3: begin
                col = 4'b0111;
                if (row != 4'b1111) begin
                    col_index_next        = 2'd3;
                    row_sample_next       = row;
                    debounce_counter_next = 16'd0;
                    next_state            = DEBOUNCE;
                end
                else begin
                    next_state = SCAN_COL0;
                end
            end

            DEBOUNCE: begin
                case (col_index)
                    2'd0: col = 4'b1110;
                    2'd1: col = 4'b1101;
                    2'd2: col = 4'b1011;
                    2'd3: col = 4'b0111;
                    default: col = 4'b1111;
                endcase

                if (row == row_sample) begin
                    if (debounce_counter == DEBOUNCE_MAX) begin
                        next_state = DECODE;
                    end
                    else begin
                        debounce_counter_next = debounce_counter + 16'd1;
                    end
                end
                else begin
                    next_state = SCAN_COL0;
                end
            end

            DECODE: begin
                key_valid = 1'b1;

                case ({col_index, row_sample})
                    {2'd0,4'b1110}: begin decoded_key = 4'd1; key_type = TYPE_DIGIT;  end
                    {2'd0,4'b1101}: begin decoded_key = 4'd4; key_type = TYPE_DIGIT;  end
                    {2'd0,4'b1011}: begin decoded_key = 4'd7; key_type = TYPE_DIGIT;  end
                    {2'd0,4'b0111}: begin decoded_key = 4'd0; key_type = TYPE_CLEAR;  end

                    {2'd1,4'b1110}: begin decoded_key = 4'd2; key_type = TYPE_DIGIT;  end
                    {2'd1,4'b1101}: begin decoded_key = 4'd5; key_type = TYPE_DIGIT;  end
                    {2'd1,4'b1011}: begin decoded_key = 4'd8; key_type = TYPE_DIGIT;  end
                    {2'd1,4'b0111}: begin decoded_key = 4'd0; key_type = TYPE_DIGIT;  end

                    {2'd2,4'b1110}: begin decoded_key = 4'd3; key_type = TYPE_DIGIT;  end
                    {2'd2,4'b1101}: begin decoded_key = 4'd6; key_type = TYPE_DIGIT;  end
                    {2'd2,4'b1011}: begin decoded_key = 4'd9; key_type = TYPE_DIGIT;  end
                    {2'd2,4'b0111}: begin decoded_key = 4'd0; key_type = TYPE_EQUALS; end

                    {2'd3,4'b1110}: begin decoded_key = 4'd0; key_type = TYPE_OP;     end
                    {2'd3,4'b1101}: begin decoded_key = 4'd1; key_type = TYPE_OP;     end
                    {2'd3,4'b1011}: begin decoded_key = 4'd2; key_type = TYPE_OP;     end
                    {2'd3,4'b0111}: begin decoded_key = 4'd3; key_type = TYPE_OP;     end

                    default: begin
                        decoded_key = 4'd0;
                        key_type    = TYPE_CLEAR;
                    end
                endcase

                next_state = WAIT_RELEASE;
            end

            WAIT_RELEASE: begin
                col = 4'b1111;
                if (row == 4'b1111)
                    next_state = SCAN_COL0;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule

