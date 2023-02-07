module scancode_to_ascii(addr, out);
    input [9:0] addr;
    output [7:0] out;
    reg [7:0] rom [0:127][0:3];
    initial
    begin
        $readmemh("C:/Users/24421/Desktop/Digital-Design/Hardware/Common/scancode-ascii.txt", rom);
    end
    assign out = rom[addr[7:0]][addr[9:8]];
endmodule
