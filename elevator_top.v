module elevator_top #(
    parameter CLOCK_FREQ = 50000000,
    parameter FLOOR_TIME = 2,
    parameter DOOR_TIME  = 3
)(
    input        clk,
    input        reset,

    //========================================
    // INSIDE ELEVATOR
    //========================================

    input [3:0] floor_request,


    //========================================
    // EXTERNAL CALL BUTTONS
    //========================================

    input [3:0] up_call,
    input [3:0] down_call,


    //========================================
    // OUTPUTS
    //========================================

    output motor_up,
    output motor_down,

    output door_open,

    output [1:0] current_floor,

    output [6:0] seg

);

    wire tick_1sec;

    wire [3:0] pending;

    wire clear_request;


    //================================================
    // CLOCK TICK GENERATOR
    //================================================

    clock_tick #(
        .CLOCK_FREQ(CLOCK_FREQ)
    ) tick_generator (

        .clk(clk),
        .reset(reset),

        .tick_1sec(tick_1sec)

    );


    //================================================
    // REQUEST MANAGER
    //================================================

    request_manager request_unit (

        .clk(clk),
        .reset(reset),

        .tick_1sec(tick_1sec),

        .floor_request(floor_request),

        .up_call(up_call),

        .down_call(down_call),

        .current_floor(current_floor),

        .clear_request(clear_request),

        .pending(pending)

    );


    //================================================
    // ELEVATOR CONTROLLER
    //================================================

    elevator_controller #(
        .FLOOR_TIME(FLOOR_TIME),
        .DOOR_TIME(DOOR_TIME)
    ) controller (

        .clk(clk),
        .reset(reset),

        .tick_1sec(tick_1sec),

        .pending(pending),

        .current_floor(current_floor),

        .motor_up(motor_up),

        .motor_down(motor_down),

        .door_open(door_open),

        .clear_request(clear_request)

    );


    //================================================
    // DISPLAY
    //================================================

    floor_display display_unit (

        .floor(current_floor),

        .seg(seg)

    );

endmodule