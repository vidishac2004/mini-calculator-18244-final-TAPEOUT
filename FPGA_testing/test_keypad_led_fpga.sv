module keypad_fsm_to_led(
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] row,

    output logic [3:0] col,
    output logic [3:0] decoded_key,
    output logic [2:0] key_type,
    output logic       key_valid
)

keypad_FSM u_keypad (
        .clk(clk),
        .reset(reset),
        .row(row),
        .col(col),
        .decoded_key(decoded_key),
        .key_type(key_type),
        .key_valid(key_valid)
    );
endmodule
