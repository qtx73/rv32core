module core (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire [31:0] i_mem_data,
    input wire [31:0] d_mem_data,
    output wire [31:0] i_mem_addr,
    output wire [31:0] d_mem_addr,
    output wire [3:0]  d_mem_wen,
    output wire [31:0] d_mem_wdata
);

wire active;
core_fsm core_fsm (
    .clk(clk),
    .rstn(rstn),
    .start(start),
    .active (active)
);

wire [31:0] pc;
wire [31:0] nextpc;
assign i_mem_addr = active ? nextpc : pc;
always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        pc <= 32'b0;
    end else begin
        if (active) begin
            pc <= nextpc;
        end else begin
            pc <= pc;
        end
    end
end

reg [31:0] ir;
always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        ir <= 32'b0;
    end else begin
        if (active) begin
            ir <= i_mem_data;
        end else begin
            ir <= ir;
        end
    end
end

wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire wreg;
wire [4:0] rd_addr;
wire [31:0] rd_data;
wire [31:0] rs1_data;
wire [31:0] rs2_data;
core_regfile core_regfile (
    .clk(clk),
    .rstn(rstn),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .wreg(wreg),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

wire [31:0] result;
core_alu core_alu (
    .alusel(alusel),
    .op1(op1),
    .op2(op2),
    .result(result)
);

core_ctrl core_ctrl (
    .active(active),
    .pc(pc),
    .ir(ir),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .d_mem_data(d_mem_data),
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
    .d_mem_addr(d_mem_addr),
    .d_mem_wen(d_mem_wen),
    .d_mem_wdata(d_mem_wdata)
);

endmodule
