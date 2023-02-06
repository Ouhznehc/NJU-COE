module debounce(clk, button, out);
    input clk;
    input button;
    output out;
    reg delay1;
    reg delay2;
    reg clk_100ms;
    reg [31:0] cnt;
    always@(clk)
    begin
        if((cnt + 1) % 5000000 == 0)
        begin
            clk_100ms <= ~clk_100ms;
            cnt <= 0;
        end
        else
            cnt <= cnt + 1;
    end
    always@(clk_100ms)
    begin
        delay1 <= button;
        delay2 <= delay1;
    end
    assign out = delay1 & delay2;
endmodule