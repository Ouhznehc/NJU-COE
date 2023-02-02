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