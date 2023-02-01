module seg7(
    input wire [3:0] N,
    input wire dot,
    output wire [7:0] target
);
    reg [6:0] body;

    always @(N, dot) begin
        casex(N)
            4'hf: body = 7'b0001110;
            4'he: body = 7'b0000110;
            4'hd: body = 7'b0100001;
            4'hc: body = 7'b1000110;
            4'hb: body = 7'b0000011;
            4'ha: body = 7'b0001000;
            4'h9: body = 7'b0010000;
            4'h8: body = 7'b0000000;
            4'h7: body = 7'b1111000;
            4'h6: body = 7'b0000010;
            4'h5: body = 7'b0010010;
            4'h4: body = 7'b0011001;
            4'h3: body = 7'b0110000;
            4'h2: body = 7'b0100100;
            4'h1: body = 7'b1111001;
            4'h0: body = 7'b1000000;
            default: body = 7'b1111111;
        endcase
    end

    assign target = {~dot, body};
endmodule

module digital_screen(
    input wire clk,
    input wire clr,
    input wire [7:0] en,
    input wire [7:0][3:0] display,
    input wire [7:0] dots,
    output wire [7:0] AN,
    output wire [7:0] HEX
);
    wire [7:0][7:0] monitorDisplay;
    seg7 myseg7_0(.N(display[0]), .dot(dots[0]),.target(monitorDisplay[0]));
    seg7 myseg7_1(.N(display[1]), .dot(dots[1]),.target(monitorDisplay[1]));
    seg7 myseg7_2(.N(display[2]), .dot(dots[2]),.target(monitorDisplay[2]));
    seg7 myseg7_3(.N(display[3]), .dot(dots[3]),.target(monitorDisplay[3]));
    seg7 myseg7_4(.N(display[4]), .dot(dots[4]),.target(monitorDisplay[4]));
    seg7 myseg7_5(.N(display[5]), .dot(dots[5]),.target(monitorDisplay[5]));
    seg7 myseg7_6(.N(display[6]), .dot(dots[6]),.target(monitorDisplay[6]));
    seg7 myseg7_7(.N(display[7]), .dot(dots[7]),.target(monitorDisplay[7]));

    reg [2:0] select;
    assign AN = (8'b11111111 ^ (8'b1 << select)) | (~en);
    assign HEX = monitorDisplay[select];

    always @(posedge clk)
    begin
        if(clr)
            select <= 0;
        else
        begin
            if(select == 7)
                select <= 0;
            else
                select <= (select + 1);
        end
    end

endmodule
