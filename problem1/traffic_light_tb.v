`timescale 1ns/1ps
module traffic_light_tb;
    reg  clk = 0;
    reg  reset = 1;
    wire red, green, yellow;
    integer errors = 0;
    integer i;

    traffic_light dut (.clk(clk), .reset(reset),
                       .red(red), .green(green), .yellow(yellow));

    always #5 clk = ~clk;

    // expected one-hot {red, green, yellow} for tick index 0,1,2,...
    function [2:0] expected(input integer n);
        integer m;
        begin
            m = n % 3;
            if (m == 0)      expected = 3'b100; // RED
            else if (m == 1) expected = 3'b010; // GREEN
            else             expected = 3'b001; // YELLOW
        end
    endfunction

    task check(input integer n);
        begin
            if ({red, green, yellow} !== expected(n)) begin
                errors = errors + 1;
                $display("FAIL tick %0d: got R=%b G=%b Y=%b, expected %b",
                         n, red, green, yellow, expected(n));
            end else
                $display("ok   tick %0d: R=%b G=%b Y=%b", n, red, green, yellow);
            // exactly one output high
            if ((red + green + yellow) !== 1) begin
                errors = errors + 1;
                $display("FAIL tick %0d: outputs not one-hot", n);
            end
        end
    endtask

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, traffic_light_tb);

        // hold reset across a clock edge, then release
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;
        #1;
        check(0);                       // RED right after reset
        // run 4 full cycles (12 ticks)
        for (i = 1; i <= 12; i = i + 1) begin
            @(posedge clk); #1;
            check(i);
        end

        // synchronous reset mid-sequence: go to GREEN, then reset -> RED
        @(posedge clk); #1;             // tick 13 -> GREEN
        reset = 1;
        @(posedge clk); #1;
        if ({red, green, yellow} !== 3'b100) begin
            errors = errors + 1;
            $display("FAIL: reset did not return to RED");
        end else
            $display("ok   mid-sequence reset returns to RED");
        reset = 0;

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
