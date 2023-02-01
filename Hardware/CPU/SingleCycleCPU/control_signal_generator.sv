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
// ======== Decode ======
    wire [6:0] op    = instr[6:0];
    assign     rs1   = instr[19:15];
    assign     rs2   = instr[24:20];
    assign     rd    = instr[11:7];
    wire [2:0] func3 = instr[14:12];
    wire [6:0] func7 = instr[31:25];
// ======================    
    
    reg [18:0] control_signal;
    assign {ExtOp, RegWr, Branch, MemtoReg, MemWr, MemOp, ALUAsrc, ALUBsrc, ALUctr} = control_signal;

    always @(*)
    begin
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