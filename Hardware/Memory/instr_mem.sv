`ifndef INSTR_MEM
`define INSTR_MEM

module instr_mem (
    input  wire clock,
    input  wire [31:0] addr,
    output reg [31:0] instr
);
    parameter instr_size = 1000;
    reg [31:0] instr_mem [instr_size:0];
    // initial 
    // begin
    //     $readmemh("", instr_mem);
    // end
    always @(negedge clock)
        instr <= instr_mem[addr];
endmodule

`endif