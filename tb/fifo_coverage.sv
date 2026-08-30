// -----------------------------------------------------------------------------
// fifo_coverage.sv
// Tracks which scenarios the constrained-random stimulus has actually
// exercised. The cross-coverage points are the important part -- they
// confirm we hit the hard cases (e.g. simultaneous read+write while full),
// not just full and simultaneous read+write independently.
// -----------------------------------------------------------------------------

class fifo_coverage;
    virtual fifo_if vif;

    covergroup cg @(posedge vif.clk);
        cp_full:  coverpoint vif.full;
        cp_empty: coverpoint vif.empty;
        cp_simul: coverpoint (vif.wr_en && vif.rd_en);

        cross cp_full,  cp_simul;   // simultaneous r/w while full?
        cross cp_empty, cp_simul;   // simultaneous r/w while empty?
    endgroup

    function new(virtual fifo_if vif);
        this.vif = vif;
        cg = new();
    endfunction

    function void report();
        $display("=== Coverage Report ===");
        $display("Functional coverage: %0.2f%%", cg.get_coverage());
    endfunction
endclass
