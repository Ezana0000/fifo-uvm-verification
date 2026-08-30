// -----------------------------------------------------------------------------
// fifo_scoreboard.sv
// Runs an independent software reference model (a simple queue) alongside
// the DUT and flags any mismatch between what the reference model predicts
// and what the monitor actually observed coming out of the DUT.
//
// Note: this reference model is intentionally simple. It mirrors the DUT's
// full condition (depth 16) so it doesn't drift out of sync during
// back-pressure scenarios, but it does not model cycle-accurate timing --
// it's a functional check, not a timing check (that's what the SVA in
// fifo_assertions.sv is for).
// -----------------------------------------------------------------------------

class fifo_scoreboard;
    mailbox #(fifo_txn) mon2scb;
    bit [7:0]            ref_model[$];
    int                   errors = 0;
    int                   checks = 0;

    function new(mailbox #(fifo_txn) mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task automatic run();
        fifo_txn txn;
        forever begin
            automatic bit       wr_valid;
            automatic bit       rd_valid;
            automatic bit [7:0] expected;

            mon2scb.get(txn);

            // Evaluate both against the SAME pre-cycle size, mirroring how the
            // real hardware's full/empty flags reflect state from before this
            // cycle's write commits -- not a snapshot updated mid-check.
            wr_valid = txn.wr_en && (ref_model.size() < 16);
            rd_valid = txn.rd_en && (ref_model.size() > 0);

            if (rd_valid) begin
                expected = ref_model.pop_front();
                checks++;
                if (expected !== txn.rd_data) begin
                    errors++;
                    $error("MISMATCH at time %0t: expected=%0h actual=%0h",
                            $time, expected, txn.rd_data);
                end
            end

            if (wr_valid)
                ref_model.push_back(txn.wr_data);
        end
    endtask

    function void report();
        $display("=== Scoreboard Report ===");
        $display("Checks: %0d   Errors: %0d", checks, errors);
        if (errors == 0) $display("RESULT: PASS");
        else              $display("RESULT: FAIL");
    endfunction
endclass
