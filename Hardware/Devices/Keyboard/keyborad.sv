`define CTRL  8'h14
`define SHIFT 8'h12
`define CAPS  8'h58

module keyboard(
    input ps2_clk,
    input ps2_data,
    input clk,
    output reg [7:0] key_code,
    output reg key_down
); 

    reg nextdata_n;
    wire ready;
    wire overflow;
    wire [7:0] keydata;
    reg [7:0] ignore_next;
    
    ps2_keyboard ps(
        .clk(clk),
        .clrn(clr),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .nextdata_n(nextdata_n),
        .data(keydata),
        .ready(ready),
        .overflow(overflow)
    );

    always @(posedge clk)
    begin
        if(ready == 1'b1 && nextdata_n == 1'b1)
        begin
            if(keydata == 8'hF0) // break code
            begin
                ignore_next <= 8'hF0;
                key_code <= 8'b0; // clear the key
            end
            else if(keydata == 8'hE0) // special key ignore
            begin
                ignore_next <= 8'hE0;
            end
            else if(ignore_next == 8'hF0 || ignore_next == 8'hE0) //after F0 or E0
            begin
                ignore_next <= 8'h00; // ignore, but we will look at the next key
                if(ignore_next == 8'hF0) // E0 is not supported now
                begin
                    key_code <= keydata;
                    key_down <= 1'b0;
                end
            end
            else //normal key
            begin
                if(keydata != key_code) // not continous key
                begin
                    key_code <= keydata;
                    key_down <= 1'b1;
                end
            end

            nextdata_n <= 1'b0;
        end
        else
            nextdata_n <= 1'b1;
    end
    
endmodule
