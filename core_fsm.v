module core_fsm (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire stall,
    output reg active
);

reg nextstate;

always @ * begin
    if (start) begin
        nextstate = 1'b1;
    end else begin
        nextstate = active;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        active <= 1'b0;
    end else if (!stall) begin
        active <= nextstate;
    end
end

endmodule
