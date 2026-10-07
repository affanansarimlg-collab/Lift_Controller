module elevator_controller #(
    parameter FLOOR_TIME = 2,
    parameter DOOR_TIME  = 3
)(
    input        clk,
    input        reset,

    input        tick_1sec,

    input  [3:0] pending,

    output reg [1:0] current_floor,

    output reg motor_up,
    output reg motor_down,

    output reg door_open,

    output reg clear_request
);

    //================================================
    // FSM STATES
    //================================================

    parameter IDLE       = 3'b000;
    parameter MOVE_UP    = 3'b001;
    parameter MOVE_DOWN  = 3'b010;
    parameter DOOR_OPEN  = 3'b011;
    parameter DOOR_WAIT  = 3'b100;
    parameter DOOR_CLOSE = 3'b101;

    reg [2:0] state;


    //================================================
    // TIMERS
    //================================================

    reg [31:0] floor_timer;
    reg [31:0] door_timer;


    //================================================
    // REQUEST STATUS
    //================================================

    reg request_above;
    reg request_below;


    //================================================
    // CHECK REQUESTS ABOVE / BELOW
    //================================================

    always @(*) begin

        request_above = 1'b0;
        request_below = 1'b0;

        case (current_floor)

            // Floor 1
            2'd0: begin

                request_above = |pending[3:1];
                request_below = 1'b0;

            end


            // Floor 2
            2'd1: begin

                request_above = |pending[3:2];
                request_below = pending[0];

            end


            // Floor 3
            2'd2: begin

                request_above = pending[3];
                request_below = |pending[1:0];

            end


            // Floor 4
            2'd3: begin

                request_above = 1'b0;
                request_below = |pending[2:0];

            end

        endcase

    end


    //================================================
    // MAIN FSM
    //================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            state         <= IDLE;

            current_floor <= 2'd0;

            motor_up      <= 1'b0;
            motor_down    <= 1'b0;

            door_open     <= 1'b0;

            clear_request <= 1'b0;

            floor_timer   <= 32'd0;
            door_timer    <= 32'd0;

        end

        else begin

            // Default

            clear_request <= 1'b0;


            case (state)

                //================================================
                // IDLE
                //================================================

                IDLE: begin

                    motor_up   <= 1'b0;
                    motor_down <= 1'b0;
                    door_open  <= 1'b0;

                    floor_timer <= 32'd0;
                    door_timer  <= 32'd0;


                    /*
                     * If there is a request on current floor,
                     * open the door.
                     */

                    if (pending[current_floor]) begin

                        state <= DOOR_OPEN;

                    end


                    /*
                     * Otherwise search upward.
                     */

                    else if (request_above) begin

                        state <= MOVE_UP;

                    end


                    /*
                     * Otherwise search downward.
                     */

                    else if (request_below) begin

                        state <= MOVE_DOWN;

                    end

                end


                //================================================
                // MOVE UP
                //================================================

                MOVE_UP: begin

                    motor_up   <= 1'b1;
                    motor_down <= 1'b0;
                    door_open  <= 1'b0;


                    /*
                     * One floor is reached after FLOOR_TIME
                     * seconds.
                     */

                    if (tick_1sec) begin

                        if (floor_timer == FLOOR_TIME - 1) begin

                            floor_timer <= 32'd0;


                            if (current_floor < 2'd3)
                                current_floor <= current_floor + 1'b1;


                            /*
                             * Stop if this floor was requested.
                             */

                            if (pending[current_floor + 1'b1]) begin

                                state <= DOOR_OPEN;

                            end

                        end

                        else begin

                            floor_timer <= floor_timer + 1'b1;

                        end

                    end

                end


                //================================================
                // MOVE DOWN
                //================================================

                MOVE_DOWN: begin

                    motor_up   <= 1'b0;
                    motor_down <= 1'b1;
                    door_open  <= 1'b0;


                    if (tick_1sec) begin

                        if (floor_timer == FLOOR_TIME - 1) begin

                            floor_timer <= 32'd0;


                            if (current_floor > 2'd0)
                                current_floor <= current_floor - 1'b1;


                            /*
                             * Stop if destination is reached.
                             */

                            if (pending[current_floor - 1'b1]) begin

                                state <= DOOR_OPEN;

                            end

                        end

                        else begin

                            floor_timer <= floor_timer + 1'b1;

                        end

                    end

                end


                //================================================
                // DOOR OPEN
                //================================================

                DOOR_OPEN: begin

                    motor_up   <= 1'b0;
                    motor_down <= 1'b0;

                    door_open <= 1'b1;

                    /*
                     * Clear request for current floor.
                     */

                    clear_request <= 1'b1;

                    door_timer <= 32'd0;

                    state <= DOOR_WAIT;

                end


                //================================================
                // DOOR WAIT
                //================================================

                DOOR_WAIT: begin

                    motor_up   <= 1'b0;
                    motor_down <= 1'b0;

                    door_open <= 1'b1;


                    if (tick_1sec) begin

                        if (door_timer == DOOR_TIME - 1) begin

                            door_timer <= 32'd0;

                            state <= DOOR_CLOSE;

                        end

                        else begin

                            door_timer <= door_timer + 1'b1;

                        end

                    end

                end


                //================================================
                // DOOR CLOSE
                //================================================

                DOOR_CLOSE: begin

                    motor_up   <= 1'b0;
                    motor_down <= 1'b0;

                    door_open <= 1'b0;

                    state <= IDLE;

                end


                //================================================
                // DEFAULT
                //================================================

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule