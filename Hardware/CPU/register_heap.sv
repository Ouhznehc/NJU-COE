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

    reg [31:0] heap [31:0];
    assign busA = heap[Ra];
    assign busB = heap[Rb];
    always @(posedge WrClk) 
    begin
        if(RegWr && Rw)
            heap[Rw] <= busW;
    end
    
endmodule