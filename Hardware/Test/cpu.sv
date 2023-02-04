`ifndef CPU_SV
`define CPU_SV

`include "alu.sv"
`include "control_signal_generator.sv"
`include "imm_generator.sv"
`include "jump_control.sv"
`include "pc_generator.sv"
`include "register_heap.sv"


module cpu(
	input   wire                clock,
    input   wire                reset,
	input   wire    [31:0]      instr,
	output  wire    [31:0]      data_addr,
	input   wire    [31:0]      data_read,
	output  wire    [31:0]      data_write,
	output  wire    [2:0]       MemOp,
	output	wire                MemWe,
    output  wire    [31:0]      instr_addr,
    output  wire    [31:0]      dbgdata
);

    reg [31:0] pc = 32'b0;
    reg [31:0] next_pc = 32'b0;
    wire [4:0]  rs1, rs2, rd;
    wire [31:0] Ra, Rb, imm;
    wire        PCAsrc, PCBsrc;
    wire        RegWr, ALUAsrc, MemtoReg;
    wire [2:0]  Branch, ExtOp;
    wire [1:0]  ALUBsrc;
    wire [3:0]  ALUctr;
    wire [31:0] aluresult;
    wire [31:0] dataa = ALUAsrc ? pc : Ra;
    reg  [31:0] datab;
    wire less, zero;
 
    assign dbgdata = pc;
    assign instr_addr = next_pc;
    assign data_write = Rb;
    assign data_addr  = aluresult;

    always @(negedge clock)
        pc <= next_pc;
    always @(*)
        case (ALUBsrc)
            2'b01: datab = imm;
            2'b10: datab = 4;
            2'b00: datab = Rb;
            default: begin end
        endcase

    wire [31:0] pc_source = PCBsrc ? Ra : pc;
    wire [31:0] pc_offset = PCAsrc ? imm : 4;
    always @(*)
    begin
        if(reset) next_pc <= 0;
        else next_pc <= pc_source + pc_offset;
    end

    control_signal_generator CSG(
        .instr(instr),
        .ALUAsrc(ALUAsrc),
        .ALUBsrc(ALUBsrc),
        .ALUctr(ALUctr),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .MemWr(MemWe),
        .MemOp(MemOp),
        .ExtOp(ExtOp),
        .RegWr(RegWr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    imm_generator IG(
        .instr(instr),
        .ExtOp(ExtOp),
        .imm(imm)
    );

    register_heap myregfile(
        .WrClk(~clock),
        .RegWr(RegWr),
        .Ra(rs1),
        .Rb(rs2),
        .Rw(rd),
        .busW(MemtoReg ? data_read : aluresult),
        .busA(Ra),
        .busB(Rb)
    );

    alu ALU(
        .dataa(dataa),
        .datab(datab),
        .ALUctr(ALUctr),
        .less(less),
        .zero(zero),
        .aluresult(aluresult)
    );

    jump_control JC(
        .branch(Branch),
        .less(less),
        .zero(zero),
        .PCAsrc(PCAsrc),
        .PCBsrc(PCBsrc)
    );
endmodule

`endif

