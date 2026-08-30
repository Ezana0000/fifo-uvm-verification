# Synchronous FIFO with SystemVerilog Verification Environment

A parameterized synchronous FIFO designed in SystemVerilog, verified using a
class-based testbench built around a driver / monitor / scoreboard
architecture, with constrained-random stimulus, functional coverage, and
SystemVerilog Assertions (SVA).

## Design

- Parameterized data width (default 8 bits) and depth (default 16 entries)
- Standard FIFO interface: `wr_en`, `rd_en`, `data_in`, `data_out`, `full`, `empty`
- First-word fall-through (combinational read)
- Uses the classic "extra pointer bit" technique to distinguish full from
  empty without a separate counter
- Handles simultaneous read/write on the same cycle correctly

## Verification Architecture

- **`fifo_if`** — SystemVerilog interface bundling the DUT's signals for the
  class-based testbench
- **`fifo_txn`** — randomizable transaction (a potential write and/or read),
  with constraints biasing stimulus toward filling the FIFO and forcing
  frequent simultaneous read+write, since that's the trickiest logic path
- **`fifo_driver`** — drives randomized transactions onto the DUT interface
- **`fifo_monitor`** — passively samples DUT pins each cycle and reconstructs
  transactions for the scoreboard
- **`fifo_scoreboard`** — runs an independent software reference model (a
  SystemVerilog queue) and flags any mismatch against actual DUT output
- **`fifo_coverage`** — functional coverage tracking full/empty conditions
  and simultaneous read+write scenarios, including cross-coverage against
  full/empty
- **`fifo_assertions`** — SVA checking for full+empty simultaneously, and
  unknown (X) values on valid reads/writes

500 constrained-random transactions are run through the environment per
simulation.

## What I Found

Debugging this environment surfaced three real issues, each a genuinely
common category of verification mistake:

1. **Simulator portability** — an implicitly-typed local variable lifetime
   that Riviera-PRO only warned about but Questa treated as a hard error.
2. **Monitor conflating simultaneous events** — the monitor originally used
   a single shared data field with a ternary (`wr_en ? data_in : data_out`)
   to capture transactions, which silently dropped the read data whenever a
   write and read happened on the same cycle. Fixed by tracking write and
   read data in separate fields.
3. **Scoreboard evaluating full/empty against the wrong state** — the
   reference model originally pushed new write data *before* checking
   whether a same-cycle read should pop it, letting a same-cycle
   write+read-while-empty scenario succeed in the model when real hardware
   (which evaluates `full`/`empty` from state *before* that cycle's write
   commits) correctly blocks it. This caused a cascading off-by-one through
   the rest of the test. Fixed by evaluating write- and read-validity
   against the same pre-cycle snapshot, mirroring the DUT's actual timing.

Final result: **258 checks, 0 errors, 100% functional coverage**, including
the simultaneous-read+write-while-full and simultaneous-read+write-while-empty
cross-coverage bins.

## Coverage Results

**Functional coverage: 100.00%** — all coverpoints and cross-coverage bins
hit, including simultaneous read+write under both full and empty conditions.

![Coverage Report](docs/coverage_report.png)

## Waveform Example

![Waveform](docs/waveform.png)

## How to Run

See [`sim/run_instructions.md`](sim/run_instructions.md). Built and tested
using Siemens Questa on EDA Playground for full SystemVerilog class and
mailbox support.

## Why I Built This

Built to go deeper on verification methodology than my earlier RTL projects
(an FSM-based FPGA UART packet processor, a Verilog BCD arithmetic logic
unit) — specifically to get hands-on with the class-based driver/monitor/
scoreboard architecture, constrained-random verification, functional
coverage, and assertions that production verification teams actually use.
