module deal_with_input(
    input  wire mainclk,
    input  wire vga_clk,
    input  wire reset,
    output reg  [6:0] h_cur,
    output reg  [4:0] v_cur,
    output reg  [1:0]state,
    output reg [4:0] line_offset,
    output reg [6:0] clear_point,
    output reg [7:0] char_buf,
    output reg [11:0] write_addr,
    output reg [6:0] line_end[31:0],
    input  wire [7:0] ascii_key,
    input  wire new_key,
    output reg  is_write,
    input  wire current_key,
    output reg char,
    output reg char_out
);
always @(posedge mainclk)
begin
    if(reset == 1'b1) //reset
    begin
        h_cur <= 7'h0;
        v_cur <= 6'h0;
        state <= 2'd0;
        line_offset <= 5'd0;
        clear_point = 7'd0;
        char_buf <= 8'h00;
        write_addr <= {clear_point, 5'd31};
    end
    else
    //================================================================================================================================
    //in fact, state always jump between 0 and 1, just to wait some time for scancode to translate(if there are some input signals)
    //state 0 is used to deal with something when not writing
    //state 1 is used to deal with something when writing
    //================================================================================================================================
    begin
        case(state)
        2'd0:
            begin
                if(new_key == 1'b1) state <= 2'd3;
                is_write <= ~vga_clk;
                if(~is_write) //not writing //todo
                begin
                    char_buf <= 8'h00; //clear the unused lines
                    clear_point <= clear_point + 1'd1;
                    write_addr <= {clear_point, (5'd31 + line_offset)};
                    line_end[5'd31 + line_offset] = 7'd0;
                end
            end
        2'd1:
            begin
                state <= 2'd0;
                if(current_key == 8'h66) //backspace
                begin
                    char_buf <= 8'h0;
                    is_write <= 1'b1;
                    if(h_cur == 7'd0) //beginning of a line
                    begin
                        if(v_cur == 5'd0) // beginning of a page
                        begin
                            h_cur <= 7'd0;
                            v_cur <= 5'd0;
                            write_addr <= 12'd0 + {7'd0, line_offset}; //todo
                        end
                        else // mid of a page
                        begin
                            h_cur <= line_end[v_cur - 5'd1 + line_offset];
                            v_cur <= v_cur - 5'd1;
                            write_addr <= {7'd69, (v_cur - 5'd1 + line_offset)}; //todo
                        end
                    end
                    else //mid of a line
                    begin
                        write_addr <= {(h_cur - 7'd1), v_cur + line_offset};
                        h_cur <= h_cur - 7'd1;
                    end
                end
                else if(current_key == 8'h5a) //enter
                begin
                    if(v_cur == 5'd29) // end of a page
                        line_offset <= line_offset + 1'd1; // v_cur stays in the bottom of the page
                    else
                        v_cur <= v_cur + 5'd1;
                    line_end[v_cur + line_offset] <= h_cur;// record the end position of this line 
                    h_cur <= 7'd0;// new line position
                end
                else if(ascii_key != 8'h00)//normal input
                begin
                    char_buf <= ascii_key;
                    write_addr <= {h_cur, (v_cur + line_offset)};
                    is_write <= 1'b1;
                    h_cur <= h_cur + 7'd1;
                    if(h_cur >= 7'd69)//end of a line
                    begin
                        if(v_cur == 5'd29)// end of a page
                            line_offset <= line_offset + 1'd1; // v_cur stays in the bottom of the page
                        else
                            v_cur <= v_cur + 5'd1;
                        line_end[v_cur + line_offset] <= h_cur; // record the end position of this line 
                        h_cur <= 7'd0;// new line position
                    end
                end
            end
        2'd2: begin state <= 2'd1; is_write <= ~vga_clk; end
        2'd3: begin state <= 2'd2; is_write <= ~vga_clk; end
        endcase
        char <= char_out; //always lock the readings //todo
    end
end
endmodule