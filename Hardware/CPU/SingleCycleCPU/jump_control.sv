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
            5'b000xx: pc_select = 2'b00;
            5'b001xx: pc_select = 2'b01;
            5'b010xx: pc_select = 2'b11;
            5'b1000x: pc_select = 2'b00;
            5'b1001x: pc_select = 2'b01;
            5'b1010x: pc_select = 2'b01;
            5'b1011x: pc_select = 2'b00;
            //to-do
            5'b110x0: pc_select = 2'b00;
            5'b110x1: pc_select = 2'b01;
            5'b111x0: pc_select = 2'b01;
            5'b111x1: pc_select = 2'b00;
        endcase

endmodule