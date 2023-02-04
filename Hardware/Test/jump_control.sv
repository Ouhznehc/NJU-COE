`ifndef JUMP_CONTROL_SV
`define JUMP_CONTROL_SV


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
            default:begin end
        endcase
endmodule

`endif