module clock_divider #(parameter DIVISOR = 25_000_000)(
    input clk_in,
    input reset,
    output reg clk_out
);
    reg [31:0] count;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            count <= 0;
            clk_out <= 0;
        end else begin
            if (count == DIVISOR-1) begin
                count <= 0;
                clk_out <= ~clk_out;
            end else
                count <= count + 1;
        end
    end
endmodule
