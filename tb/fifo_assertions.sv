// -----------------------------------------------------------------------------
// fifo_assertions.sv
// SystemVerilog Assertions (SVA) that run continuously during simulation.
// These catch a different class of bug than the scoreboard: protocol/
// timing violations, checked every single cycle, independent of whether
// a transaction happened to be scored at that moment.
// -----------------------------------------------------------------------------

module fifo_assertions (fifo_if vif);

    // The FIFO should never report full and empty at the same time.
    property p_no_full_and_empty;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        !(vif.full && vif.empty);
    endproperty
    assert property (p_no_full_and_empty)
        else $error("ASSERTION FAILED: FIFO reported full and empty simultaneously!");

    // data_out should never be unknown (X) during a valid read.
    property p_no_x_on_read;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.rd_en && !vif.empty) |-> !$isunknown(vif.data_out);
    endproperty
    assert property (p_no_x_on_read)
        else $error("ASSERTION FAILED: data_out is unknown during a valid read!");

    // data_in should never be unknown (X) during a valid write.
    property p_no_x_on_write;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.wr_en && !vif.full) |-> !$isunknown(vif.data_in);
    endproperty
    assert property (p_no_x_on_write)
        else $error("ASSERTION FAILED: data_in is unknown during a valid write!");

endmodule
