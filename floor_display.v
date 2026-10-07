module floor_display (
    input  [1:0] floor,
    output reg [6:0] seg
);

    always @(*) begin

        case (floor)

            // Floor 1
            2'd0:
                seg = 7'b0110000;

            // Floor 2
            2'd1:
                seg = 7'b1101101;

            // Floor 3
            2'd2:
                seg = 7'b1111001;

            // Floor 4
            2'd3:
                seg = 7'b0110011;

            default:
                seg = 7'b0000000;

        endcase

    end

endmodule