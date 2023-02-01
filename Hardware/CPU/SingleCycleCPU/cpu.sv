module cpu(
    input   wire            clk,
    input   wire            rst,
    output  wire    [31:0]  instr_addr,
    input   wire    [31:0]  instr,
    output  wire    [31:0]  data_addr,
    output  wire    [31:0]  data_write,
    input   wire    [31:0]  data_read,
    output  wire            data_we,
    output  wire    [2:0]   MemOp,
    output  reg     [31:0]  pc
);
// =================== wire/reg declarations =====================
 
    wire [31:0] next_pc;
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

// ===============================================================

// ===================== wire assign =============================

    assign instr_addr = next_pc;    
    assign data_we    = MemWr;
    assign data_write = Rb;
    assign data_addr  = aluresult;
// ===============================================================

// ===================== reg assign ==============================

    always @(negedge clk, posedge rst)
        if(rst) pc <= 0;
        else pc <= next_pc;
    always @(*)
        case (ALUBsrc)
            2'b01: datab = imm;
            2'b10: datab = 4;
            2'b00: datab = Rb;
        endcase

// ===============================================================


    pc_generator PG(
        .next_pc(next_pc),
        .PCAsrc(PCAsrc),
        .PCBsrc(PCBsrc),
        .pc(pc),
        .rs1(Ra),
        .imm(imm)
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

    
    register_heap RH(
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