module input_buffer(
    input  logic       clk,
    input  logic       reset,
    input  logic       en_buffer,
    input  logic       key_valid,
    input  logic [3:0] decoded_key,
    input  logic [2:0] key_type,
    input  logic       clr_input_buffer,
    output logic [7:0] buffer_value
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            buffer_value <= 8'd0;
        else if (clr_input_buffer)
            buffer_value <= 8'd0;
        else if (en_buffer && key_valid && key_type == 0)
            buffer_value <= (buffer_value << 3) + (buffer_value << 1) + decoded_key; //decimal numbers
    end

endmodule
