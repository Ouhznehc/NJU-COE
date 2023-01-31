module bus(
    input   wire    clk,
    input   wire    rst
);
// ======== wire declarations =============
    wire instr_addr, instr;
    wire data_addr, data_we, data_read, data_write;
    wire MemOp;
// ========================================
    cpu CPU(
        .clk(clk),
        .rst(rst),
        .instr_addr(instr_addr),
        .instr(instr),
        .data_addr(data_addr),
        .data_in(data_write),
        .data_out(data_read),
        .data_we(data_we),
        .MemOp(MemOp)
    );

    data_memory DM(
        .addr(data_we),
        .rdclk(clk),
        .wrclk(~clk),
        .memop(MemOp),
        .we(data_we),
        .datain(data_write),
        .dataout(data_read)
    );

    instr_memory IM(
        .clk(clk),
        .addr(instr_addr),
        .instr(instr)
    );

endmodule