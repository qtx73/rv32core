module core_alu (
    input wire [3:0] alusel,
    input wire [31:0] op1,
    input wire [31:0] op2,
    output reg [31:0] result
);

// ALU operation select values
localparam ALU_ADD  = 4'b0000;
localparam ALU_SUB  = 4'b0001;
localparam ALU_SLL  = 4'b0010;
localparam ALU_SLT  = 4'b0011;
localparam ALU_SLTU = 4'b0100;
localparam ALU_XOR  = 4'b0101;
localparam ALU_SRL  = 4'b0110;
localparam ALU_SRA  = 4'b0111;
localparam ALU_OR   = 4'b1000;
localparam ALU_AND  = 4'b1001;
localparam ALU_EQ   = 4'b1010;
localparam ALU_NE   = 4'b1011;
localparam ALU_LT   = 4'b1100;
localparam ALU_GE   = 4'b1101;
localparam ALU_LTU  = 4'b1110;
localparam ALU_GEU  = 4'b1111;

// ALU implementation
always @(*) begin
    case (alusel)
        ALU_ADD:  result = op1 + op2;
        ALU_SUB:  result = op1 - op2;
        ALU_SLL:  result = op1 << op2[4:0];
        ALU_SLT:  result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
        ALU_SLTU: result = (op1 < op2) ? 32'b1 : 32'b0;
        ALU_XOR:  result = op1 ^ op2;
        ALU_SRL:  result = op1 >> op2[4:0];
        ALU_SRA:  result = $signed(op1) >>> op2[4:0];
        ALU_OR:   result = op1 | op2;
        ALU_AND:  result = op1 & op2;
        ALU_EQ:   result = (op1 == op2) ? 32'b1 : 32'b0;
        ALU_NE:   result = (op1 != op2) ? 32'b1 : 32'b0;
        ALU_LT:   result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
        ALU_GE:   result = ($signed(op1) >= $signed(op2)) ? 32'b1 : 32'b0;
        ALU_LTU:  result = (op1 < op2) ? 32'b1 : 32'b0;
        ALU_GEU:  result = (op1 >= op2) ? 32'b1 : 32'b0;
        default:  result = 32'b0;
    endcase
end

endmodule
