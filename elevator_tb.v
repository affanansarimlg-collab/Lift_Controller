`timescale 1ns/1ps

module elevator_tb;

    //================================================
    // SIGNAL DECLARATIONS
    //================================================

    reg clk;
    reg reset;

    reg [3:0] floor_request;
    reg [3:0] up_call;
    reg [3:0] down_call;

    wire motor_up;
    wire motor_down;

    wire door_open;

    wire [1:0] current_floor;
    wire [6:0] seg;

    // Used only for displaying Floor 1-4
    wire [2:0] display_floor;

    assign display_floor = {1'b0, current_floor} + 3'd1;


    //================================================
    // DEVICE UNDER TEST
    //================================================

    elevator_top #(
        .CLOCK_FREQ(10),
        .FLOOR_TIME(2),
        .DOOR_TIME(3)
    ) DUT (
        .clk(clk),
        .reset(reset),

        .floor_request(floor_request),

        .up_call(up_call),
        .down_call(down_call),

        .motor_up(motor_up),
        .motor_down(motor_down),

        .door_open(door_open),

        .current_floor(current_floor),

        .seg(seg)
    );


    //================================================
    // CLOCK GENERATION
    // 10 ns clock period
    //================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    //================================================
    // VCD WAVEFORM
    //================================================

    initial begin

        $dumpfile("elevator_tb.vcd");
        $dumpvars(0, elevator_tb);

    end


    //================================================
    // TASK: WAIT FOR ELEVATOR ARRIVAL
    //
    // Wait until:
    //   1. Elevator reaches requested floor
    //   2. Door opens
    //
    // If it takes too long, simulation stops
    // with an error.
    //================================================

    task wait_for_arrival;

        input [1:0] target_floor;
        input integer max_cycles;

        integer cycles;

        begin

            cycles = 0;

            while (!((current_floor == target_floor) &&
                     (door_open == 1'b1))) begin

                @(posedge clk);

                cycles = cycles + 1;

                if (cycles >= max_cycles) begin

                    $display("");
                    $display("****************************************");
                    $display("ERROR: Elevator did not reach Floor %0d",
                             target_floor + 1);
                    $display("****************************************");
                    $display("");

                    $finish;

                end

            end

            $display("");
            $display("----------------------------------------");
            $display("ARRIVED AT FLOOR %0d", target_floor + 1);
            $display("Door is OPEN");
            $display("----------------------------------------");
            $display("");

        end

    endtask


    //================================================
    // TASK: WAIT FOR DOOR TO CLOSE
    //================================================

    task wait_for_door_close;

        integer cycles;

        begin

            cycles = 0;

            while (door_open == 1'b1) begin

                @(posedge clk);

                cycles = cycles + 1;

                if (cycles >= 100) begin

                    $display("");
                    $display("ERROR: Door did not close");
                    $display("");

                    $finish;

                end

            end

        end

    endtask


    //================================================
    // MAIN TEST SEQUENCE
    //================================================

    initial begin

        //================================================
        // INITIAL CONDITIONS
        //================================================

        reset = 1'b1;

        floor_request = 4'b0000;

        up_call = 4'b0000;

        down_call = 4'b0000;


        //================================================
        // RESET
        //================================================

        $display("");
        $display("========================================");
        $display("       ELEVATOR CONTROLLER TEST");
        $display("========================================");
        $display("");

        #20;

        reset = 1'b0;

        $display("RESET RELEASED");
        $display("Starting Floor = 1");


        //================================================
        // TEST 1
        //
        // Floor 1 -> Floor 4
        //================================================

        $display("");
        $display("========================================");
        $display("TEST 1: FLOOR 1 -> FLOOR 4");
        $display("========================================");

        #20;

        // Request Floor 4
        floor_request = 4'b1000;

        #10;

        // Remove request
        floor_request = 4'b0000;

        // Wait until Floor 4 and door opens
        wait_for_arrival(2'd3, 200);

        // Wait for door to close
        wait_for_door_close;

        $display("TEST 1 PASSED");


        //================================================
        // TEST 2
        //
        // Floor 4 -> Floor 2
        //================================================

        $display("");
        $display("========================================");
        $display("TEST 2: FLOOR 4 -> FLOOR 2");
        $display("========================================");

        #20;

        // Request Floor 2
        floor_request = 4'b0010;

        #10;

        // Remove request
        floor_request = 4'b0000;

        // Wait until Floor 2 and door opens
        wait_for_arrival(2'd1, 200);

        // Wait for door to close
        wait_for_door_close;

        $display("TEST 2 PASSED");


        //================================================
        // TEST 3
        //
        // Floor 2 -> Floor 1
        //================================================

        $display("");
        $display("========================================");
        $display("TEST 3: FLOOR 2 -> FLOOR 1");
        $display("========================================");

        #20;

        // Request Floor 1
        floor_request = 4'b0001;

        #10;

        // Remove request
        floor_request = 4'b0000;

        // IMPORTANT:
        // Wait for actual arrival at Floor 1
        wait_for_arrival(2'd0, 200);

        // Wait for door to close
        wait_for_door_close;

        $display("TEST 3 PASSED");


        //================================================
        // TEST 4
        //
        // Multiple requests
        //
        // From Floor 1:
        // Request Floor 2 AND Floor 4
        //
        // 1010 = Floor 2 + Floor 4
        //================================================

        $display("");
        $display("========================================");
        $display("TEST 4: MULTIPLE REQUESTS");
        $display("========================================");

        #20;

        $display("Requesting Floor 2 and Floor 4");

        // Floor 2 + Floor 4
        floor_request = 4'b1010;

        #10;

        // Remove external request
        floor_request = 4'b0000;


        //================================================
        // FIRST DESTINATION: FLOOR 2
        //================================================

        $display("");
        $display("Waiting for Floor 2...");

        wait_for_arrival(2'd1, 300);

        wait_for_door_close;

        $display("Floor 2 request serviced");


        //================================================
        // SECOND DESTINATION: FLOOR 4
        //================================================

        $display("");
        $display("Waiting for Floor 4...");

        wait_for_arrival(2'd3, 300);

        wait_for_door_close;

        $display("Floor 4 request serviced");


        //================================================
        // TEST 4 PASSED
        //================================================

        $display("");
        $display("========================================");
        $display("TEST 4 PASSED");
        $display("Multiple requests completed");
        $display("========================================");


        //================================================
        // ALL TESTS PASSED
        //================================================

        $display("");
        $display("");
        $display("****************************************");
        $display("*                                      *");
        $display("*    ***ALL TESTS PASSED***            *");
        $display("*                                      *");
        $display("*  TEST 1 : Floor 1 -> Floor 4   PASS *");
        $display("*  TEST 2 : Floor 4 -> Floor 2   PASS *");
        $display("*  TEST 3 : Floor 2 -> Floor 1   PASS *");
        $display("*  TEST 4 : Multiple Requests    PASS *");
        $display("*                                      *");
        $display("****************************************");
        $display("");

        #50;

        $finish;

    end


    //================================================
    // CONTINUOUS MONITOR
    //================================================

    initial begin

        $monitor(
            "Time=%0t | Floor=%0d | UP=%b | DOWN=%b | DOOR=%b | Request=%b | Pending=%b",
            $time,
            display_floor,
            motor_up,
            motor_down,
            door_open,
            floor_request,
            DUT.pending
        );

    end


endmodule