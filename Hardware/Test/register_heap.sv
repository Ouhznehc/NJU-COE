`ifndef REG_HEAP_SV
`define REG_HEAP_SV

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

`endif