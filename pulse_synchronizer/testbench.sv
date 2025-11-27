// Code your testbench here
// or browse Examples
module tb;

  // clock & input/output
  reg  clk1;
  reg  clk2;
  reg  in;
  wire out;

  // DUT
  pulse_synchronizer dut (
    .clk1 (clk1),
    .clk2 (clk2),
    .in   (in),
    .out  (out)
  );

  // clk1: 10ns period (100MHz)
  initial begin
    clk1 = 0;
    forever #5 clk1 = ~clk1;
  end

  // clk2: 14ns period (約 71MHz，不同步)
  initial begin
    clk2 = 0;
    forever #7 clk2 = ~clk2;
  end

  // 產生 stimulus：在 clk1 domain 裡送短 pulse
  initial begin
    in = 0;

    // 等一段時間再開始
    #20;

    // 連續送幾個 pulse，每個 pulse 寬度 1 個 clk1 週期 
    repeat (8) begin
      @(posedge clk1);
      in <= 1'b1;          // 在 clk1 上升沿拉高
      @(posedge clk1);
      in <= 1'b0;          // 一個 clk1 週期後拉低（形成 pulse）
      // 再空 3 個 clk1 週期
      repeat (3) @(posedge clk1);
    end

    // 等一段時間收尾
    #100;
    $finish;
  end

  // waveform dump
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule