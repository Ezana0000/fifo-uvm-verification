// -----------------------------------------------------------------------------
// fifo_txn.sv
// One randomizable FIFO operation (a potential write and/or read on a given
// cycle). Constraints bias the randomization toward the scenarios most
// likely to expose bugs: keeping the FIFO mostly full, and frequently
// forcing simultaneous read+write, which is the trickiest path in the DUT.
// -----------------------------------------------------------------------------

class fifo_txn;
    rand bit       wr_en;
    rand bit       rd_en;
    rand bit [7:0] data;

    constraint c_dist {
        wr_en dist { 1 :/ 60, 0 :/ 40 };   // bias toward writes so the FIFO fills up
        rd_en dist { 1 :/ 45, 0 :/ 55 };   // still read often enough to drain it
    }

    function void display(string tag = "");
        $display("[%0t] %s wr_en=%0b rd_en=%0b data=%0h", $time, tag, wr_en, rd_en, data);
    endfunction
endclass
