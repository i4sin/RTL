`timescale 1ns / 1ps
`define PERIOD 20

import vunit_pkg::*;
import uvm_pkg::*;
import TestbenchClasses::*;
`include "vunit_defines.svh"

// module Divisible_adder_width;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(4),
//         .M_TDATA_WIDTH(32),
//         .SINGLE_WORD_OUTPUT(0),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module Divisible_adder_width_single_output;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(2),
//         .M_TDATA_WIDTH(16),
//         .SINGLE_WORD_OUTPUT(1),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module NDivisible_adder_width;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(7),
//         .M_TDATA_WIDTH(16),
//         .SINGLE_WORD_OUTPUT(0),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module NDivisible_adder_width_single_output;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(3),
//         .M_TDATA_WIDTH(16),
//         .SINGLE_WORD_OUTPUT(1),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module Same_width;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(16),
//         .ADDER_WIDTH(16),
//         .M_TDATA_WIDTH(16),
//         .SINGLE_WORD_OUTPUT(0),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module Same_width_single_output;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(8),
//         .M_TDATA_WIDTH(8),
//         .SINGLE_WORD_OUTPUT(1),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module Bigger_adder_width;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(16),
//         .M_TDATA_WIDTH(32),
//         .SINGLE_WORD_OUTPUT(0),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

// module Bigger_adder_width_single_output;
//     parameter string runner_cfg = "";
//     AxisAccumulator_tb #(
//         .S_TDATA_WIDTH(8),
//         .ADDER_WIDTH(16),
//         .M_TDATA_WIDTH(32),
//         .SINGLE_WORD_OUTPUT(1),
//         .MAX_PACKETS_COUNT(512),
//         .runner_config(runner_cfg)
//     ) test ();
// endmodule

module AxisAccumulator_tb ();

    parameter S_TDATA_WIDTH = 8;
    parameter ADDER_WIDTH = 4;
    parameter M_TDATA_WIDTH = 32;
    parameter SINGLE_WORD_OUTPUT = 0;
    parameter MAX_PACKETS_COUNT = 512;

    bit clk;
    logic reset;

    initial clk = 0;
    always #(`PERIOD / 2) clk = ~clk;

    AxisIf #(
        .TDATA_WIDTH(S_TDATA_WIDTH)
    ) s_axis_add (
        clk,
        !reset
    );
    AxisIf #(
        .TDATA_WIDTH(S_TDATA_WIDTH)
    ) s_axis_sub (
        clk,
        !reset
    );
    AxisIf #(
        .TDATA_WIDTH(M_TDATA_WIDTH)
    ) m_axis (
        clk,
        !reset
    );

    AxisAccumulator #(
        .ADDER_WIDTH(ADDER_WIDTH),
        .SINGLE_WORD_OUTPUT(SINGLE_WORD_OUTPUT)
    ) axis_accumulator (
        .s_axis_add(s_axis_add),
        .s_axis_sub(s_axis_sub),
        .m_axis(m_axis)
    );

    task automatic set_uvm_config_db(int DELAY_INSERT);

        uvm_coreservice_t cs_ = uvm_coreservice_t::get();
        uvm_config_db#(virtual AxisIf#(.TDATA_WIDTH(S_TDATA_WIDTH)))::set(cs_.get_root(), "*", "add_vif", s_axis_add);
        uvm_config_db#(virtual AxisIf#(.TDATA_WIDTH(S_TDATA_WIDTH)))::set(cs_.get_root(), "*", "sub_vif", s_axis_sub);
        uvm_config_db#(virtual AxisIf#(.TDATA_WIDTH(M_TDATA_WIDTH)))::set(cs_.get_root(), "*", "m_vif", m_axis);

        uvm_config_db#(int)::set(cs_.get_root(), "*", "DELAY_INSERT", DELAY_INSERT);
        uvm_config_db#(int)::set(cs_.get_root(), "*", "S_TDATA_WIDTH", S_TDATA_WIDTH);
        uvm_config_db#(int)::set(cs_.get_root(), "*", "ADDER_WIDTH", ADDER_WIDTH);
        uvm_config_db#(int)::set(cs_.get_root(), "*", "M_TDATA_WIDTH", M_TDATA_WIDTH);
        uvm_config_db#(int)::set(cs_.get_root(), "*", "SINGLE_WORD_OUTPUT", SINGLE_WORD_OUTPUT);
        uvm_config_db#(int)::set(cs_.get_root(), "*", "MAX_PACKETS_COUNT", MAX_PACKETS_COUNT);

    endtask

    `TEST_SUITE begin //todo parameterizing
        `TEST_SUITE_SETUP begin
            $display("Running test suite setup code");
        end

        `TEST_CASE_SETUP begin
            $display("Running random test case setup code");
            // reset = 1;
            // s_axis_add.tdata <= 0;
            // s_axis_add.tlast <= 0;
            // s_axis_add.tvalid <= 0;
            // s_axis_sub.tdata <= 0;
            // s_axis_sub.tlast <= 0;
            // s_axis_sub.tvalid <= 0;
            // repeat (3) @(posedge clk);
            // reset = 0;
            // repeat (3) @(posedge clk);
        end

        `TEST_CASE("random_test") begin
            set_uvm_config_db(.DELAY_INSERT(1));
            run_test("random_test");
        end

        `TEST_CASE("master_ready_random_test") begin
            set_uvm_config_db(.DELAY_INSERT(0));
            run_test("random_test");
        end

        `TEST_CASE_CLEANUP begin
            repeat (10) @(posedge clk);
            $display("Cleaning up after a test case");
        end

        `TEST_SUITE_CLEANUP begin
            $display("Cleaning up after running the complete test suite");
        end
    end

    `WATCHDOG(100000000ns)
endmodule
