module core_ctrl (
    input wire active,
    input wire [31:0] pc,
    input wire [31:0] ir,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] d_mem_data,
    input wire [31:0] result,
    output reg wreg,
    output reg [4:0] rs1_addr,
    output reg [4:0] rs2_addr,
    output reg [4:0] rd_addr,
    output reg [31:0] rd_data,
    output reg [3:0] alusel,
    output reg [31:0] op1,
    output reg [31:0] op2,
    output reg [31:0] nextpc,
    output reg [31:0] d_mem_addr,
    output reg [3:0] d_mem_wen,
    output reg [31:0] d_mem_wdata
);

// Instruction type masks
localparam R_TYPE = 7'b0110011;
localparam I_TYPE = 7'b0010011;
localparam L_TYPE = 7'b0000011;
localparam S_TYPE = 7'b0100011;
localparam B_TYPE = 7'b1100011;
localparam JAL    = 7'b1101111;
localparam JALR   = 7'b1100111;
localparam LUI    = 7'b0110111;
localparam AUIPC  = 7'b0010111;

// ALU operations
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

// Instruction fields extraction
wire [6:0] opcode = ir[6:0];
wire [2:0] funct3 = ir[14:12];
wire [6:0] funct7 = ir[31:25];
wire [4:0] rs1 = ir[19:15];
wire [4:0] rs2 = ir[24:20];
wire [4:0] rd = ir[11:7];

// Immediate values generation
wire [31:0] imm_i = {{20{ir[31]}}, ir[31:20]};
wire [31:0] imm_s = {{20{ir[31]}}, ir[31:25], ir[11:7]};
wire [31:0] imm_b = {{19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0};
wire [31:0] imm_u = {ir[31:12], 12'b0};
wire [31:0] imm_j = {{11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0};


// Branch decision
reg branch_taken;

always @(*) begin
    // Default values
    rs1_addr = rs1;
    rs2_addr = rs2;
    rd_addr = rd;
    wreg = 1'b0;
    op1 = 32'b0;
    op2 = 32'b0;
    alusel = ALU_ADD;
    nextpc = pc + 4;
    rd_data = 32'b0;
    d_mem_addr = 32'b0;
    d_mem_wen = 4'b0;
    d_mem_wdata = 32'b0;
    branch_taken = 1'b0;
    
    if (active) begin
        case (opcode)
            R_TYPE: begin
                // R-type instructions: Register-Register operations
                op1 = rs1_data;
                op2 = rs2_data;
                wreg = 1'b1;
                
                case (funct3)
                    3'b000: alusel = (funct7[5]) ? ALU_SUB : ALU_ADD; // ADD/SUB
                    3'b001: alusel = ALU_SLL;  // SLL
                    3'b010: alusel = ALU_SLT;  // SLT
                    3'b011: alusel = ALU_SLTU; // SLTU
                    3'b100: alusel = ALU_XOR;  // XOR
                    3'b101: alusel = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRL/SRA
                    3'b110: alusel = ALU_OR;   // OR
                    3'b111: alusel = ALU_AND;  // AND
                endcase
                
                rd_data = result;
            end
            
            I_TYPE: begin
                // I-type instructions: Register-Immediate operations
                op1 = rs1_data;
                op2 = imm_i;
                wreg = 1'b1;
                
                case (funct3)
                    3'b000: alusel = ALU_ADD;  // ADDI
                    3'b001: alusel = ALU_SLL;  // SLLI
                    3'b010: alusel = ALU_SLT;  // SLTI
                    3'b011: alusel = ALU_SLTU; // SLTUI
                    3'b100: alusel = ALU_XOR;  // XORI
                    3'b101: alusel = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRLI/SRAI
                    3'b110: alusel = ALU_OR;   // ORI
                    3'b111: alusel = ALU_AND;  // ANDI
                endcase
                
                rd_data = result;
            end
            
            L_TYPE: begin
                // Load instructions
                op1 = rs1_data;
                op2 = imm_i;
                alusel = ALU_ADD;
                d_mem_addr = {result[31:2], 2'b00}; // Word aligned address
                wreg = 1'b1;
                
                case (funct3)
                    3'b000: begin // LB
                        case (result[1:0])
                            2'b00: rd_data = {{24{d_mem_data[7]}}, d_mem_data[7:0]};
                            2'b01: rd_data = {{24{d_mem_data[15]}}, d_mem_data[15:8]};
                            2'b10: rd_data = {{24{d_mem_data[23]}}, d_mem_data[23:16]};
                            2'b11: rd_data = {{24{d_mem_data[31]}}, d_mem_data[31:24]};
                        endcase
                    end
                    
                    3'b001: begin // LH
                        case (result[1])
                            1'b0: rd_data = {{16{d_mem_data[15]}}, d_mem_data[15:0]};
                            1'b1: rd_data = {{16{d_mem_data[31]}}, d_mem_data[31:16]};
                        endcase
                    end
                    
                    3'b010: begin // LW
                        rd_data = d_mem_data;
                    end
                    
                    3'b100: begin // LBU
                        case (result[1:0])
                            2'b00: rd_data = {24'b0, d_mem_data[7:0]};
                            2'b01: rd_data = {24'b0, d_mem_data[15:8]};
                            2'b10: rd_data = {24'b0, d_mem_data[23:16]};
                            2'b11: rd_data = {24'b0, d_mem_data[31:24]};
                        endcase
                    end
                    
                    3'b101: begin // LHU
                        case (result[1])
                            1'b0: rd_data = {16'b0, d_mem_data[15:0]};
                            1'b1: rd_data = {16'b0, d_mem_data[31:16]};
                        endcase
                    end
                    
                    default: rd_data = d_mem_data;
                endcase
            end
            
            S_TYPE: begin
                // Store instructions
                op1 = rs1_data;
                op2 = imm_s;
                alusel = ALU_ADD;
                d_mem_addr = {result[31:2], 2'b00}; // Word aligned address
                
                case (funct3)
                    3'b000: begin // SB
                        case (result[1:0])
                            2'b00: begin
                                d_mem_wdata = {24'b0, rs2_data[7:0]};
                                d_mem_wen = 4'b0001;
                            end
                            2'b01: begin
                                d_mem_wdata = {16'b0, rs2_data[7:0], 8'b0};
                                d_mem_wen = 4'b0010;
                            end
                            2'b10: begin
                                d_mem_wdata = {8'b0, rs2_data[7:0], 16'b0};
                                d_mem_wen = 4'b0100;
                            end
                            2'b11: begin
                                d_mem_wdata = {rs2_data[7:0], 24'b0};
                                d_mem_wen = 4'b1000;
                            end
                        endcase
                    end
                    
                    3'b001: begin // SH
                        case (result[1])
                            1'b0: begin
                                d_mem_wdata = {16'b0, rs2_data[15:0]};
                                d_mem_wen = 4'b0011;
                            end
                            1'b1: begin
                                d_mem_wdata = {rs2_data[15:0], 16'b0};
                                d_mem_wen = 4'b1100;
                            end
                        endcase
                    end
                    
                    3'b010: begin // SW
                        d_mem_wdata = rs2_data;
                        d_mem_wen = 4'b1111;
                    end
                    
                    default: begin
                        d_mem_wdata = 32'b0;
                        d_mem_wen = 4'b0000;
                    end
                endcase
            end
            
            B_TYPE: begin
                // Branch instructions
                op1 = rs1_data;
                op2 = rs2_data;
                
                case (funct3)
                    3'b000: alusel = ALU_EQ;  // BEQ
                    3'b001: alusel = ALU_NE;  // BNE
                    3'b100: alusel = ALU_LT;  // BLT
                    3'b101: alusel = ALU_GE;  // BGE
                    3'b110: alusel = ALU_LTU; // BLTU
                    3'b111: alusel = ALU_GEU; // BGEU
                    default: alusel = ALU_ADD;
                endcase
                
                branch_taken = (result == 32'b1);
                
                if (branch_taken) begin
                    nextpc = pc + imm_b;
                end
            end
            
            JAL: begin
                // JAL instruction
                wreg = 1'b1;
                rd_data = pc + 4;
                nextpc = pc + imm_j;
            end
            
            JALR: begin
                // JALR instruction
                op1 = rs1_data;
                op2 = imm_i;
                alusel = ALU_ADD;
                wreg = 1'b1;
                rd_data = pc + 4;
                nextpc = {result[31:1], 1'b0}; // Clear LSB as per spec
            end
            
            LUI: begin
                // LUI instruction
                wreg = 1'b1;
                rd_data = imm_u;
            end
            
            AUIPC: begin
                // AUIPC instruction
                wreg = 1'b1;
                rd_data = pc + imm_u;
            end
            
            default: begin
                // Unknown instruction - treat as NOP
            end
        endcase
    end
end

endmodule
