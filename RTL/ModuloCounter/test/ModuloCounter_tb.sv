`timescale 1ns/1ps
// `PERIOD 20ns/1ps

import vunit_pkg::*;
`include "vunit_defines.svh"

module ModuloCounter_tb();
    parameter MODULUS = 10;
    localparam LG_MODULUS = $clog2(MODULUS);

    const int MONITOR_COUNT = 32;

    bit clk = 0;
    bit resetn = 0;
    initial forever #20 clk = ~clk;

    logic [LG_MODULUS-1:0] counted;
    
    ModuloCounter #(
        .MODULUS(MODULUS)
    ) dut(
        .clk(clk),
        .resetn(resetn),
        .counted(counted)
    );

    task initial_reset();
        resetn <= 0;
        repeat(6) @(posedge clk);
        resetn <= 1;
        repeat(6) @(posedge clk);
    endtask

    task monitor();
        repeat (MONITOR_COUNT) begin
            @(posedge clk);
            $display("counted: %0d", counted);
        end
    endtask

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            initial_reset();
        end        
        `TEST_CASE("test") begin
            monitor();
            $finish;
        end
    end
endmodule
