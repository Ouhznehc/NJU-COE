`ifndef KEYBOARD_SV
`define KEYBOARD_SV

`include "ps2_keyboard.sv"
`include "scancode_to_ascii.sv"

`define CTRL  8'h14
`define SHIFT 8'h12
`define CAPS  8'h58

module keyboard(
    input ps2_clk,
    input ps2_data,
    input clk,
    output reg [7:0] ascii_key
); 

    reg nextdata_n;
    wire ready;
    wire overflow;
    wire [7:0] keydata;
    reg [7:0] ignore_next, current_key;
    reg ctrl, shift, caps, last_caps, new_key, pressing;

    ps2_keyboard ps(
        .clk(clk),
        .clrn(1'b0),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .nextdata_n(nextdata_n),
        .data(keydata),
        .ready(ready),
        .overflow(overflow)
    );

    scancode_to_ascii map({shift ^ (caps & ~ctrl), ctrl, current_key}, ascii_key);

    always @(posedge clk)
    begin
        if(ready == 1'b1 && nextdata_n == 1'b1)
        begin
            if(keydata == 8'hF0) // break code
            begin
                ignore_next <= 8'hF0;
                pressing <= 1'b0;
                current_key <= 8'b0;
            end
            else if(keydata == 8'hE0) // special key ignore
                ignore_next <= 8'hE0;
            else if(ignore_next == 8'hF0 || ignore_next == 8'hE0) //after F0 or E0
            begin
                ignore_next <= 8'h00; // ignore, but we will look at the next key
                if(keydata == `CTRL)     ctrl <= 1'b0;
                if(keydata == `SHIFT)    shift <= 1'b0;
            end
            else //normal key
            begin
                pressing <= 1'b1;
                new_key <= 1'b1;
                if(keydata != current_key)
                begin
                    if(keydata == `CAPS)
                    begin
                       if(last_caps) begin caps <= 1'b0; last_caps <= 1'b0; end
                       else begin caps <= 1'b1; last_caps <= 1'b1; end
                    end
                    if(keydata == `CTRL)  ctrl <= 1'b1;
                    if(keydata == `SHIFT) shift <= 1'b1;
                    current_key <= keydata;
                end
            end
            nextdata_n <= 1'b0;
        end
        else
            nextdata_n <= 1'b1;
    end
    
endmodule

`endif
