// -----------------------------------------------------------------------------
// fifo_if.sv
// Bundles the DUT's signals so the driver/monitor classes can access them
// through a single virtual interface handle, instead of a long port list.
// -----------------------------------------------------------------------------

interface fifo_if #(parameter DATA_WIDTH = 8) (input logic clk);
    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic                  full;
    logic                  empty;
endinterface
