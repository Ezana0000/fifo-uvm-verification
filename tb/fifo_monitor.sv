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
            @(posedge vif.clk);
            begin
                fifo_txn txn = new();
                txn.wr_en = vif.wr_en;
                txn.rd_en = vif.rd_en;
                // on a write, record what went in; on a read, record what came out
                txn.data  = vif.wr_en ? vif.data_in : vif.data_out;
                mon2scb.put(txn);
            end
        end
    endtask
endclass
