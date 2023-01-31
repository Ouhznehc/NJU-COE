`define CTRL  8'h14
`define SHIFT 8'h12
`define CAPS  8'h58

module deal_with_keyboard(
    input ps2_clk,
    input ps2_data,
    input clk,
    input clr,
    output reg ctrl_led,
    output reg shift_led,
    output reg caps_led,
    output reg [7:0] screen_en,
    output wire [7:0][3:0] screen_display,
    output reg [7:0] current_key,
    output reg key_down
); 

    reg nextdata_n;
    wire ready;
    wire overflow;
    wire [7:0] keydata;
    reg [7:0] key_count;
    reg [7:0] ignore_next;
    reg pressing;
    reg last_caps;
    
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
    
    
    assign screen_display[7:6] = key_count;
    assign screen_display[3:2] = current_key;

    always @(posedge clk)
    begin
        if(ready == 1'b1 && nextdata_n == 1'b1)
        begin
            if(keydata == 8'hF0) // break code
            begin
                ignore_next <= 8'hF0;
                pressing <= 1'b0;    // always clear pressing state
                current_key <= 8'b0; // clear the key
            end
            else if(keydata == 8'hE0) // special key ignore
            begin
                ignore_next <= 8'hE0;
            end
            else if(ignore_next == 8'hF0 || ignore_next == 8'hE0) //after F0 or E0
            begin
                ignore_next <= 8'h00; // ignore, but we will look at the next key
                if(ignore_next == 8'hF0)
                begin
                if(keydata == `CTRL)  ctrl_led <= 1'b0;
                if(keydata == `SHIFT) shift_led <= 1'b0;
                current_key <= keydata;
                key_down <= 1'b0;
                end
                // E0 is not supported now
            end
            else //normal key
            begin
                pressing <= 1'b1;
                if(keydata != current_key) // not continous key
                begin
                    if(keydata == `CAPS)
                    begin
                       if(last_caps) begin caps_led <= 1'b0; last_caps <= 1'b0; end
                       else begin caps_led <= 1'b1; last_caps <= 1'b1; end
                    end
                    if(keydata == `CTRL)  ctrl_led <= 1'b1;
                    if(keydata == `SHIFT) shift_led <= 1'b1;
                    key_count <= key_count + 8'd1;
                    current_key <= keydata;
                    key_down <= 1'b1;
                end
            end

            nextdata_n <= 1'b0;
        end
        else
            begin nextdata_n <= 1'b1 end
        if(pressing) screen_en <= 8'b11001100; else screen_en <= 8'b11000000;
        if(clr == 1'b1) //reset
        begin
            key_count <= 8'h00;
            current_key <= 8'h00;
            pressing <= 1'b0;
            ignore_next <= 8'h00;
            screen_en <= 8'b11000000;
        end
    end
    
endmodule
