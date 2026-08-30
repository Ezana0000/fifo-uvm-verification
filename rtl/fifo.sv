// -----------------------------------------------------------------------------
// fifo.sv
// Parameterized synchronous FIFO, first-word fall-through (combinational read).
// Uses the classic "extra MSB on the pointers" technique to distinguish
// full from empty without a separate counter.
// -----------------------------------------------------------------------------

module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  full,
    output logic                  empty
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // one extra bit beyond the address width lets us tell full from empty:
    // full  -> pointers equal in address bits, but differ in the extra bit
    // empty -> pointers fully equal
    logic [ADDR_WIDTH:0] wr_ptr, rd_ptr;

    wire [ADDR_WIDTH-1:0] wr_addr = wr_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] rd_addr = rd_ptr[ADDR_WIDTH-1:0];

    assign full     = (wr_ptr[ADDR_WIDTH]     != rd_ptr[ADDR_WIDTH]) &&
                       (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
    assign empty    = (wr_ptr == rd_ptr);
    assign data_out = mem[rd_addr];   // combinational read (first-word fall-through)

    // write side
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (wr_en && !full) begin
            mem[wr_addr] <= data_in;
            wr_ptr       <= wr_ptr + 1'b1;
        end
    end

    // read side
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= '0;
        end else if (rd_en && !empty) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

endmodule
