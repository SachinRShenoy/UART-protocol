`timescale 1ns/1ps

module Baud_rate (input clk,
                  input reset,
                  input en,
                  output reg baud_tick);
         
         parameter CLOCK_FREQ = 50_000_000;
         parameter BAUD_RATE = 9600;
         parameter OVERSAMPLE = 16;
         
         // 50_000_000 / 9600 is almost 5208 
         // 50_000_000 / 9600*16 is almost 325
         localparam BAUD_COUNT = CLOCK_FREQ / (BAUD_RATE * OVERSAMPLE);
         localparam COUNTER_WIDTH = $clog2(BAUD_COUNT);

         reg [COUNTER_WIDTH-1:0] count;
         
         always @(posedge clk)
         begin
            if(reset)
            begin
                count <= 1'b0;
                baud_tick <= 1'b0;
            end
            else if(en)
            begin
                if(count == BAUD_COUNT - 1)
                begin
                    baud_tick <= 1'b1;
                    count <= 1'b0;
                end
                else
                begin
                    count <= count + 1'b1;
                    baud_tick <= 1'b0;
                end
            end
            else begin
                count <= 1'b0;
                baud_tick <= 1'b0;
            end
         end
                  
endmodule