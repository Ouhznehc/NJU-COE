module rv32is(
	input 	        clock,
	input 	        reset,
	output [31:0]   imemaddr,
	input  [31:0]   imemdataout,
	output 	        imemclk,
	output [31:0]   dmemaddr,
	input  [31:0]   dmemdataout,
	output [31:0]   dmemdatain,
	output 	        dmemrdclk,
	output	        dmemwrclk,
	output [2:0]    dmemop,
	output	        dmemwe,
	output [31:0]   dbgdata
);

    assign imemclk   = ~clock;
    assign dmemrdclk = clock;
    assign dmemwrclk = ~clock;

    wire clk = clock;
    wire rst = reset;
    wire [31:0] instr, data_read;
    assign instr = imemdataout;
    assign data_read = dmemdataout;
    wire [31:0] instr_addr, data_addr, data_write;
    assign imemaddr = instr_addr;
    assign dmemaddr = data_addr;
    assign dmemdatain = data_write;
    wire data_we;
    assign dmemwe = data_we;
    
    wire [2:0] MemOp;
    assign dmemop = MemOp;
    reg [31:0] pc = 32'b0;
    assign dbgdata = pc;

    reg [31:0] next_pc = 0;
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


    assign instr_addr = next_pc;    
    assign data_we    = MemWr;
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

    wire [31:0] pc_source = PCBsrc ? Ra : pc;
    wire [31:0] pc_offset = PCAsrc ? imm : 4;
    always @(*)
    begin
        if(rst) begin pc <= 0; next_pc <= 0; end
        next_pc = pc_source + pc_offset;
    end

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

module control_signal_generator (
    input  wire [31:0] instr,
    output wire [2:0]  ExtOp,
    output wire        RegWr,
    output wire        ALUAsrc,
    output wire [1:0]  ALUBsrc,
    output wire [3:0]  ALUctr,
    output wire [2:0]  Branch,
    output wire        MemtoReg,
    output wire        MemWr,
    output wire [2:0]  MemOp,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd
    );
    wire [6:0] op    = instr[6:0];
    assign     rs1   = instr[19:15];
    assign     rs2   = instr[24:20];
    assign     rd    = instr[11:7];
    wire [2:0] func3 = instr[14:12];
    wire [6:0] func7 = instr[31:25];    
    
    reg [18:0] control_signal;
    assign {ExtOp, RegWr, Branch, MemtoReg, MemWr, MemOp, ALUAsrc, ALUBsrc, ALUctr} = control_signal;

    always @(*) begin
        casex ({op[6:2], func3, func7[5]})
        /* lui   */    9'b01101_xxx_x: control_signal = 19'b001_1_000_0_0_000_0_01_0011;
        /* auipc */    9'b00101_xxx_x: control_signal = 19'b001_1_000_0_0_000_1_01_0000;
        /* addi  */    9'b00100_000_x: control_signal = 19'b000_1_000_0_0_000_0_01_0000;
        /* slti  */    9'b00100_010_x: control_signal = 19'b000_1_000_0_0_000_0_01_0010;
        /* sltiu */    9'b00100_011_x: control_signal = 19'b000_1_000_0_0_000_0_01_1010;
        /* xori  */    9'b00100_100_x: control_signal = 19'b000_1_000_0_0_000_0_01_0100;
        /* ori   */    9'b00100_110_x: control_signal = 19'b000_1_000_0_0_000_0_01_0110;
        /* andi  */    9'b00100_111_x: control_signal = 19'b000_1_000_0_0_000_0_01_0111;
        /* slli  */    9'b00100_001_0: control_signal = 19'b000_1_000_0_0_000_0_01_0001;
        /* srli  */    9'b00100_101_0: control_signal = 19'b000_1_000_0_0_000_0_01_0101;
        /* srai  */    9'b00100_101_1: control_signal = 19'b000_1_000_0_0_000_0_01_1101;
        /* add   */    9'b01100_000_0: control_signal = 19'b000_1_000_0_0_000_0_00_0000;
        /* sub   */    9'b01100_000_1: control_signal = 19'b000_1_000_0_0_000_0_00_1000;
        /* sll   */    9'b01100_001_0: control_signal = 19'b000_1_000_0_0_000_0_00_0001;
        /* slt   */    9'b01100_010_0: control_signal = 19'b000_1_000_0_0_000_0_00_0010;
        /* sltu  */    9'b01100_011_0: control_signal = 19'b000_1_000_0_0_000_0_00_1010;
        /* xor   */    9'b01100_100_0: control_signal = 19'b000_1_000_0_0_000_0_00_0100;
        /* srl   */    9'b01100_101_0: control_signal = 19'b000_1_000_0_0_000_0_00_0101;
        /* sra   */    9'b01100_101_1: control_signal = 19'b000_1_000_0_0_000_0_00_1101;
        /* or    */    9'b01100_110_0: control_signal = 19'b000_1_000_0_0_000_0_00_0110;
        /* and   */    9'b01100_111_0: control_signal = 19'b000_1_000_0_0_000_0_00_0111;
        /*       */    
        /* jal   */    9'b11011_xxx_x: control_signal = 19'b100_1_001_0_0_000_1_10_0000;
        /* jalr  */    9'b11001_000_x: control_signal = 19'b000_1_010_0_0_000_1_10_0000;
        /* beq   */    9'b11000_000_x: control_signal = 19'b011_0_100_0_0_000_0_00_0010;
        /* bne   */    9'b11000_001_x: control_signal = 19'b011_0_101_0_0_000_0_00_0010;
        /* blt   */    9'b11000_100_x: control_signal = 19'b011_0_110_0_0_000_0_00_0010;
        /* bge   */    9'b11000_101_x: control_signal = 19'b011_0_111_0_0_000_0_00_0010;
        /* bltu  */    9'b11000_110_x: control_signal = 19'b011_0_110_0_0_000_0_00_1010;
        /* bgeu  */    9'b11000_111_x: control_signal = 19'b011_0_111_0_0_000_0_00_1010;
        /*       */    
        /* lb    */    9'b00000_000_x: control_signal = 19'b000_1_000_1_0_000_0_01_0000;
        /* lh    */    9'b00000_001_x: control_signal = 19'b000_1_000_1_0_001_0_01_0000;
        /* lw    */    9'b00000_010_x: control_signal = 19'b000_1_000_1_0_010_0_01_0000;
        /* lbu   */    9'b00000_100_x: control_signal = 19'b000_1_000_1_0_100_0_01_0000;
        /* lhu   */    9'b00000_101_x: control_signal = 19'b000_1_000_1_0_101_0_01_0000;
        /* sb    */    9'b01000_000_x: control_signal = 19'b010_0_000_0_1_000_0_01_0000;
        /* sh    */    9'b01000_001_x: control_signal = 19'b010_0_000_0_1_001_0_01_0000;
        /* sw    */    9'b01000_010_x: control_signal = 19'b010_0_000_0_1_010_0_01_0000;
        endcase 
    end
endmodule

module imm_generator (
    input  wire [31:0] instr,
    input  wire [2:0]  ExtOp,
    output reg  [31:0] imm
    );
    always @(*) 
    case(ExtOp)
        3'b000: imm = {{20{instr[31]}}, instr[31:20]};                                 //I
        3'b001: imm = {instr[31:12], 12'b0};                                           //U
        3'b010: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};                    //S
        3'b011: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};    //B
        3'b100: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};  //J
    endcase    
endmodule

module jump_control(
    input   wire    [2:0]   branch,
    input   wire            zero,
    input   wire            less, 
    output  wire            PCBsrc,
    output  wire            PCAsrc
    );

    reg [1:0] pc_select;
    assign {PCBsrc, PCAsrc} = pc_select;

    always @(*)
        casex ({branch, zero, less})
            5'b000_x_x: pc_select = 2'b00;
            5'b001_x_x: pc_select = 2'b01;
            5'b010_x_x: pc_select = 2'b11;
            5'b100_0_x: pc_select = 2'b00;
            5'b100_1_x: pc_select = 2'b01;
            5'b101_0_x: pc_select = 2'b01;
            5'b101_1_x: pc_select = 2'b00;
            5'b110_x_0: pc_select = 2'b00;
            5'b110_x_1: pc_select = 2'b01;
            5'b111_x_0: pc_select = 2'b01;
            5'b111_x_1: pc_select = 2'b00;
        endcase
endmodule


module alu(
	input   wire    [31:0]  dataa,
	input   wire    [31:0]  datab,
	input   wire    [3:0]   ALUctr,
	output  reg             less,
	output  reg             zero,
	output  reg     [31:0]  aluresult
    );
//add your code here
    reg [31:0] reverse;
    reg [31:0] temp;
    reg carry;
    reg of;
    wire [4:0] offset;
    assign offset = datab[4:0];
    always @(*)
    begin
        case(ALUctr[2:0])
        3'b000:
            begin
                if(ALUctr[3] == 1'b0)
                begin
                    {carry, aluresult} = dataa + datab;
                    zero = (!aluresult);
                end
                else 
                begin
                    {carry, aluresult} = dataa + ~datab + 1;
                    zero = (!aluresult);
                end
            end
        3'b001:
            begin
                aluresult = dataa << datab[4:0];
                zero = (!aluresult);
            end
        3'b010:
            begin
                if(ALUctr[3] == 1'b0)
                begin
                    reverse = ~datab;
                    {carry, aluresult} = dataa + reverse + 1;
                    of = (dataa[31] == reverse[31]) && (aluresult [31] != dataa[31]);
                    less = (aluresult[31] ^ of) ? 1'b1 : 1'b0;
                    aluresult = less;
                end
                else
                begin
                    reverse = ~datab;
                    {carry, aluresult} = dataa + reverse + 1;
                    less = (carry ^ 1) ? 1'b1 : 1'b0;
                    aluresult = less;
                end
                zero = (dataa == datab);
            end
        3'b011:
            begin 
                aluresult = datab;
                zero = (!aluresult);
            end
        3'b100:
            begin 
                aluresult = dataa ^ datab;
                zero = (!aluresult);
            end
        3'b101:
            begin 
                if(ALUctr[3] == 1'b0)
                begin
                    temp = offset[0] ? {32'b0, dataa[31:1]} : dataa;
                    temp = offset[1] ? {32'b0, temp[31:2]} : temp;
                    temp = offset[2] ? {32'b0, temp[31:4]} : temp;
                    temp = offset[3] ? {32'b0, temp[31:8]} : temp;
                    temp = offset[4] ? {32'b0, temp[31:16]} : temp;
                end
                else
                begin
                    temp = offset[0] ? {dataa[31], dataa[31:1]} : dataa;
                    temp = offset[1] ? {{2{temp[31]}}, temp[31:2]} : temp;
                    temp = offset[2] ? {{4{temp[31]}}, temp[31:4]} : temp;
                    temp = offset[3] ? {{8{temp[31]}}, temp[31:8]} : temp;
                    temp = offset[4] ? {{16{temp[31]}}, temp[31:16]} : temp;
                end
                aluresult = temp;
                zero = (!aluresult);
            end
        3'b110:
            begin 
                aluresult = dataa | datab;
                zero = (!aluresult);
            end
        3'b111:
            begin 
                aluresult = dataa & datab;
                zero = (!aluresult);
            end
        endcase 
    end
endmodule

module register_heap (
    input  wire        WrClk,
    input  wire [4:0]  Ra,
    input  wire [4:0]  Rb,
    input  wire [4:0]  Rw,
    input  wire        RegWr,
    input  wire [31:0] busW,
    output wire [31:0] busA,
    output wire [31:0] busB
    );
    reg [31:0] regs [31:0];
    initial
    begin
        for(integer i = 0; i < 32; i = i + 1) regs[i] = 32'b0;
    end
    assign busA = regs[Ra];
    assign busB = regs[Rb];
    always @(posedge WrClk) 
    begin
        if(RegWr && Rw)
            regs[Rw] = busW;
    end    
endmodule