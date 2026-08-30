// -----------------------------------------------------------------------------
// fifo_monitor.sv
// Passively watches the DUT's pins every cycle and packages what it sees
// into transaction objects, sent to the scoreboard over a mailbox. Kept
// deliberately separate from the driver -- in a real verification
// environment the monitor has to work whether the stimulus came from this
// driver, a different driver, or even real hardware.
// -----------------------------------------------------------------------------

class fifo_monitor;
    virtual fifo_if     vif;
    mailbox #(fifo_txn) mon2scb;

    function new(virtual fifo_if vif, mailbox #(fifo_txn) mon2scb);
        this.vif     = vif;
        this.mon2scb = mon2scb;
    endfunction

    task automatic run();
        forever begin
            @(negedge vif.clk);   // sample mid-cycle, after same-edge NBA updates settle
            begin
                automatic fifo_txn txn = new();
                txn.wr_en   = vif.wr_en;
                txn.rd_en   = vif.rd_en;
                txn.wr_data = vif.data_in;
                txn.rd_data = vif.data_out;
                mon2scb.put(txn);
            end
        end
    endtask
endclass
