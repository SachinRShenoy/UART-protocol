`timescale 1ns/1ps
module uart_tx (clk, reset, baud_tick, tx_data, tx_start, tx_busy, tx);

    input             clk;
    input             reset;
    input             baud_tick;
    input      [7:0]  tx_data;
    input             tx_start;
    output reg        tx_busy;
    output reg        tx;

    parameter [1:0] IDLE  = 2'b00,
                    START = 2'b01,
                    DATA  = 2'b10,
                    STOP  = 2'b11;

    reg [1:0] NS, PS;
    reg [2:0] bit_count;
    reg [3:0] tick_count;
    reg [7:0] shift_reg;
    wire      bit_done;

    // State register
    always @(posedge clk) begin
        if (reset)
            PS <= IDLE;
        else
            PS <= NS;
    end

    // Tick counter: counts 0-15 baud_ticks per bit while busy
    always @(posedge clk) begin
        if (reset)
            tick_count <= 4'd0;
        else if (baud_tick && tx_busy) begin
            if (tick_count == 4'd15)
                tick_count <= 4'd0;
            else
                tick_count <= tick_count + 4'd1;
        end
    end

    assign bit_done = (tick_count == 4'd15) && baud_tick;

    // Next-state logic
    always @(*) begin
        NS = PS;
        case (PS)
            IDLE:  if (tx_start)                       NS = START;
            START: if (bit_done)                       NS = DATA;
            DATA:  if (bit_done && bit_count == 3'd7)  NS = STOP;
                   else                                NS = DATA;
            STOP:  if (bit_done)                       NS = IDLE;
            default:                                   NS = IDLE;
        endcase
    end

    // Output and datapath logic
    always @(posedge clk) begin
        if (reset) begin
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            shift_reg <= 8'h00;
            bit_count <= 3'b0;
        end else begin
            case (PS)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        bit_count <= 3'b0;
                        tx_busy   <= 1'b1;
                    end else begin
                        tx_busy   <= 1'b0;
                    end
                end

                START: begin
                    tx <= 1'b0;
                end

                DATA: begin
                    tx <= shift_reg[0];
                    if (bit_done) begin
                        shift_reg <= shift_reg >> 1;
                        bit_count <= bit_count + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (bit_done) begin
                        tx_busy   <= 1'b0;
                        bit_count <= 3'b0;
                    end
                end

                default: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                end
            endcase
        end
    end

endmodule
