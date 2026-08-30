# How to Run This Project

## Option A: EDA Playground (recommended — this is how it was built and tested)

1. Go to https://www.edaplayground.com and sign in
2. Create a new project
3. In the left sidebar, set:
   - **Language**: SystemVerilog
   - **Simulator**: Aldec Riviera-PRO (latest available version)
4. Check **"Open EPWave after run"** to view waveforms in-browser
5. In the **Design** panel, paste the contents of:
   - `rtl/fifo.sv`
   - `tb/fifo_if.sv`
6. In the **Testbench** panel, paste the contents of, in this order:
   - `tb/fifo_txn.sv`
   - `tb/fifo_driver.sv`
   - `tb/fifo_monitor.sv`
   - `tb/fifo_scoreboard.sv`
   - `tb/fifo_coverage.sv`
   - `tb/fifo_assertions.sv`
   - `tb/fifo_tb_top.sv`
7. Click **Run**
8. Check the console output for the scoreboard report (checks/errors/PASS
   or FAIL) and the coverage report (final percentage)
9. Open EPWave to inspect the waveform, especially around any moments where
   `full`, `empty`, `wr_en`, and `rd_en` are all changing on the same cycle

## Option B: Local (Icarus Verilog) — RTL only, no UVM/class support

Icarus Verilog does not fully support SystemVerilog classes or mailboxes,
so it can only be used to simulate the RTL design itself, not the full
class-based verification environment:

```bash
iverilog -g2012 -o sim.out rtl/fifo.sv
vvp sim.out
```

For the full driver/monitor/scoreboard/coverage/assertions environment,
use Option A.

## After running

1. Note your final **coverage percentage** from the console output
2. Note whether the scoreboard reported **PASS** or **FAIL**, and if FAIL,
   what the mismatch was — that's your bug story for interviews and your
   resume
3. Screenshot the coverage report and a waveform view, save them to
   `docs/coverage_report.png` and `docs/waveform.png`
4. Fill in the bracketed sections of `README.md` with your real results
