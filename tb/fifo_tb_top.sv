// -----------------------------------------------------------------------------
// fifo_tb_top.sv
// Top-level testbench. Instantiates the DUT, the interface, the assertion
// checker, and the driver/monitor/scoreboard/coverage classes, then runs
// 500 constrained-random transactions through the environment.
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module fifo_tb_top;

    // 100 MHz clock
    logic clk = 0;
    always #5 clk = ~clk;

    fifo_if #(.DATA_WIDTH(8)) vif (.clk(clk));

    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) dut (
        .clk      (vif.clk),
        .rst_n    (vif.rst_n),
        .wr_en    (vif.wr_en),
        .rd_en    (vif.rd_en),
        .data_in  (vif.data_in),
        .data_out (vif.data_out),
        .full     (vif.full),
        .empty    (vif.empty)
    );

    fifo_assertions assertions_inst (.vif(vif));

    mailbox #(fifo_txn) mon2scb = new();

    fifo_driver     driver;
    fifo_monitor    monitor;
    fifo_scoreboard scoreboard;
    fifo_coverage   coverage;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, fifo_tb_top);

        driver     = new(vif);
        monitor    = new(vif, mon2scb);
        scoreboard = new(mon2scb);
        coverage   = new(vif);

        driver.reset();

        fork
            monitor.run();
            scoreboard.run();
        join_none

        // constrained-random test: 500 randomized transactions
        repeat (500) begin
            fifo_txn txn = new();
            if (!txn.randomize())
                $error("Randomization failed!");
            driver.drive(txn);
        end

        // let the last few transactions finish being scored
        repeat (5) @(posedge vif.clk);

        scoreboard.report();
        coverage.report();

        $finish;
    end

endmodule
