module alu(
	input   wire    [31:0]  dataa,
	input   wire    [31:0]  datab,
	input   wire    [3:0]   ALUctr,
	output  reg             less,
	output  reg             zero,
	output  reg     [31:0]  aluresult
);
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