module request_manager (
    input        clk,
    input        reset,

    input        tick_1sec,

    input  [3:0] floor_request,
    input  [3:0] up_call,
    input  [3:0] down_call,

    input  [1:0] current_floor,

    input        clear_request,

    output reg [3:0] pending
);

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            pending <= 4'b0000;

        end

        else begin

            /*
             * Add new requests.
             *
             * A request remains stored until the elevator
             * reaches that floor.
             */

            pending <= pending |
                       floor_request |
                       up_call |
                       down_call;


            /*
             * Clear the request after reaching the floor.
             */

            if (clear_request)
                pending[current_floor] <= 1'b0;

        end

    end

endmodule