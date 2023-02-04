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
        integer i;
        for(i = 0; i <= 1000; i = i + 1)
            instr_mem[i] = 32'b0; 
    end
    // initial 
    // begin
    //     $readmemh("", instr_mem);
    // end
    always @(negedge clock)
        instr <= instr_mem[addr];
endmodule

`endif