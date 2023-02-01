module clkgen(
    input wire clkin,
    output reg clkout
);
    parameter freq = 10000;
    parameter timeout = 50000000/freq - 1;
    reg [31:0] cnt = 32'b0;
    always @(posedge clkin)
    begin
        if (cnt >= timeout)
        begin
            cnt <= 0;
            clkout <= ~clkout;
        end
        else
            cnt <= cnt + 1;
    end

endmodule
