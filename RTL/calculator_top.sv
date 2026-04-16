module calculator_top(
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] row,
    input  logic       clear,
    output logic [3:0] col,
    output logic [7:0] result
);

    logic       key_valid;
    logic [3:0] decoded_key;
    logic [2:0] key_type;

    keypad_FSM dut0(
        .clk(clk),
        .reset(reset),
        .row(row),
        .col(col),
        .decoded_key(decoded_key),
        .key_type(key_type),
        .key_valid(key_valid)
    );

    calculator_control dut1(
        .clk(clk),
        .reset(reset),
        .key_valid(key_valid),
        .decoded_key(decoded_key),
        .key_type(key_type),
        .clear(clear),
        .result(result)
    );

endmodule
