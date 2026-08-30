// -----------------------------------------------------------------------------
// fifo_driver.sv
// Takes a transaction object and drives it onto the DUT's pins, one clock
// edge at a time.
// -----------------------------------------------------------------------------

class fifo_driver;
    virtual fifo_if vif;

    function new(virtual fifo_if vif);
        this.vif = vif;
    endfunction

    task automatic drive(fifo_txn txn);
        @(posedge vif.clk);
        vif.wr_en   <= txn.wr_en;
        vif.rd_en   <= txn.rd_en;
        vif.data_in <= txn.data;
    endtask

    task automatic reset();
        vif.rst_n   = 0;
        vif.wr_en   = 0;
        vif.rd_en   = 0;
        vif.data_in = '0;
        repeat (2) @(posedge vif.clk);
        vif.rst_n = 1;
        @(posedge vif.clk);
    endtask
endclass
