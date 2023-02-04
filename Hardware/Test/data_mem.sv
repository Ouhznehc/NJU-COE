`ifndef DATA_MEM_SV
`define DATA_MEM_SV


module data_mem(
	input  [31:0] addr,
	output reg [31:0] dataout,
	input  [31:0] datain,
	input  rdclk,
	input  wrclk,
	input [2:0] memop,
	input we
    );
//add your code here
    wire [31:0] unit;
    wire [1:0] offset;
    wire [31:0] data;
    reg [31:0] mem [1000:0];
    initial 
    begin
        $readmemh("", data_mem, 0, 1000);
    end
    assign unit = addr / 4;
    assign offset = addr % 4;
    assign data = mem[unit];
    integer i;
    always @(posedge rdclk)
    begin
        if(we == 1'b0)
        begin
            case(memop)
            3'b000:
                begin
                    if(data[offset * 8 + 7] == 1'b1)
                        dataout[31:8] = {24{1'b1}};
                    else
                        dataout[31:8] = {24{1'b0}};
                    case(offset)
                        2'b00: dataout[7:0] = data[7:0];
                        2'b01: dataout[7:0] = data[15:8];
                        2'b10: dataout[7:0] = data[23:16];
                        2'b11: dataout[7:0] = data[31:24];
                    endcase
                end
            3'b001:
                begin
                    if(data[offset * 8 + 15] == 1'b1)
                        dataout[31:16] = {16{1'b1}};
                    else
                        dataout[31:16] = {16{1'b0}};
                    case(offset)
                        2'b00: dataout[15:0] = data[15:0];
                        2'b10: dataout[15:0] = data[31:16];
                    endcase
                end
            3'b010:
                begin
                    dataout[31:0] = data;
                end
            3'b100:
                begin
                    dataout[31:8] = {24{1'b0}};
                    case(offset)
                        2'b00: dataout[7:0] = data[7:0];
                        2'b01: dataout[7:0] = data[15:8];
                        2'b10: dataout[7:0] = data[23:16];
                        2'b11: dataout[7:0] = data[31:24];
                    endcase
                end
            3'b101:
                begin
                    dataout[31:16] = {16{1'b0}};
                    case(offset)
                        2'b00: dataout[15:0] = data[15:0];
                        2'b10: dataout[15:0] = data[31:16];
                    endcase
                end
            endcase
        end
    end
    always @(posedge wrclk)
    begin
        if(we == 1'b1)
        begin
            case(memop)
            3'b000:
                begin
                     case(offset)
                        2'b00: mem[unit][7:0] = datain[7:0];
                        2'b01: mem[unit][15:8] = datain[7:0];
                        2'b10: mem[unit][23:16] = datain[7:0];
                        2'b11: mem[unit][31:24] = datain[7:0];
                    endcase
                end
            3'b001:
                begin
                    case(offset)
                        2'b00: mem[unit][15:0] = datain[15:0];
                        2'b10: mem[unit][31:16] = datain[15:0];
                    endcase
                end
            3'b010:
                begin
                    mem[unit][31:0] = datain[31:0];
                end
            endcase
        end
    end
endmodule

`endif
