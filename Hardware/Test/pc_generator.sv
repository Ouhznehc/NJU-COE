`ifndef PC_GEN_SV
`define PC_GEN_SV

module pc_generator(
    input   wire    [31:0]    pc,
    input   wire              PCBsrc,
    input   wire              PCAsrc,
    input   wire    [31:0]    Ra,
    input   wire    [31:0]    imm,
    output  wire    [31:0]    next_pc
);
    wire [31:0] pc_source = PCBsrc ? Ra : pc;
    wire [31:0] pc_offset = PCAsrc ? imm : 4;

    assign next_pc = pc_source + pc_offset;

endmodule

`endif