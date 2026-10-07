module clock_tick #(
    parameter CLOCK_FREQ = 50000000
)(
    input  clk,
    input  reset,

    output reg tick_1sec
);

    reg [31:0] count;

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            count     <= 32'd0;
            tick_1sec <= 1'b0;
        end

        else begin

            if (count == CLOCK_FREQ - 1) begin

                count     <= 32'd0;
                tick_1sec <= 1'b1;

            end

            else begin

                count     <= count + 1'b1;
                tick_1sec <= 1'b0;

            end

        end

    end

endmodule