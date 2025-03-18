module core_regfile (
    input wire clk,
    input wire rstn,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire wreg,
    input wire [4:0] rd_addr,
    input wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

reg [31:0] regfile [1:31];

assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : regfile[rs1_addr];
assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : regfile[rs2_addr];

integer i;
always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile[i] <= 32'b0;
        end
    end else begin
        if (wreg & (rd_addr != 5'b0)) begin
            regfile[rd_addr] <= rd_data;
        end
    end
end
endmodule
