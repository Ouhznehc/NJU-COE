module cpu(
	input   wire                colck,
	input   wire    [31:0]      instr,
	output  wire    [31:0]      data_addr,
	input   wire    [31:0]      data_read,
	output  wire    [31:0]      data_write,
	output  wire    [2:0]       MemOp,
	output	wire                MemWe,
    output  wire    [31:0]      next_pc
);

    reg [31:0] pc = 32'b0;
    wire [4:0]  rs1, rs2, rd;
    wire [31:0] Ra, Rb, imm;
    wire        PCAsrc, PCBsrc;
    wire        RegWr, ALUAsrc, MemtoReg, MemWr;
    wire [2:0]  Branch, ExtOp;
    wire [1:0]  ALUBsrc;
    wire [3:0]  ALUctr;
    wire [31:0] aluresult;
    wire [31:0] dataa = ALUAsrc ? pc : Ra;
    reg  [31:0] datab;
    wire less, zero;
 
    assign data_write = Rb;
    assign data_addr  = aluresult;

    always @(negedge clk)
        pc <= next_pc;
    always @(*)
        case (ALUBsrc)
            2'b01: datab = imm;
            2'b10: datab = 4;
            2'b00: datab = Rb;
        endcase

    pc_generator PG(
        .pc(pc),
        .PCBsrc(PCBsrc),
        .PCAsrc(PCAsrc),
        .Ra(Ra),
        .imm(imm),
        .next_pc(next_pc)
    );

    control_signal_generator CSG(
        .instr(instr),
        .ALUAsrc(ALUAsrc),
        .ALUBsrc(ALUBsrc),
        .ALUctr(ALUctr),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .MemWr(MemWr),
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
        .WrClk(~clk),
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

