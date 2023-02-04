`ifndef INSTR_MEM
`define INSTR_MEM

module instr_mem (
    input  wire clock,
    input  wire [31:0] addr,
    output reg [31:0] instr
);
    reg [31:0] instr_mem [1000:0];
    initial 
    begin
        $readmemh("C:/Users/24421/Desktop/lab12/only_led/software/main.txt", instr_mem, 0, 1000);
    end
    always @(posedge clock)
        instr <= instr_mem[addr];
endmodule

`endif