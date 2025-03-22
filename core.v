module core (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire stall,
    input wire [31:0] instruction,
    input wire [31:0] data_rdata,
    output wire [31:0] instr_addr,
    output wire [31:0] data_addr,
    output wire        data_wen,
    output wire [3:0]  data_be,
    output wire [31:0] data_wdata
);

wire active;
core_fsm core_fsm (
    .clk(clk),
    .rstn(rstn),
    .start(start),
    .stall(stall),
    .active (active)
);

reg  [31:0] pc;
wire [31:0] nextpc;
assign instr_addr = active ? nextpc : pc;
always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        pc <= 32'b0;
    end else begin
        if (active && !stall) begin
            pc <= instr_addr;
        end else begin
            pc <= pc;
        end
    end
end

reg [31:0] ir;
always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        ir <= 32'b0;
    end else if (!stall) begin
        ir <= instruction;
    end
end

wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire wreg;
wire [4:0] rd_addr;
wire [31:0] rd_data;
wire [31:0] rs1_data;
wire [31:0] rs2_data;
core_regfiles core_regfiles (
    .clk(clk),
    .rstn(rstn),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .wreg(wreg && !stall),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

wire [3:0] alusel;
wire [31:0] op1;
wire [31:0] op2;
wire [31:0] result;
core_alu core_alu (
    .alusel(alusel),
    .op1(op1),
    .op2(op2),
    .result(result)
);

core_ctrl core_ctrl (
    .active(active && !stall),
    .pc(pc),
    .ir(ir),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .data_rdata(data_rdata),
    .result(result),
    .wreg(wreg),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .alusel(alusel),
    .op1(op1),
    .op2(op2),
    .nextpc(nextpc),
    .data_addr(data_addr),
    .data_wen(data_wen),
    .data_be(data_be),
    .data_wdata(data_wdata)
);

endmodule
