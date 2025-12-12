// Code your testbench here
// or browse Examples

module tb ();
  reg clk;
  reg rst;
  reg [7:0]wdata;
  reg r_en;
  reg w_en;
  
  wire [7:0]rdata;
  wire wfull;
  wire rempty;
  
  //產生 clk----------------------------------------------------------------------------------------------
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  //產生初始 rst-------------------------------------------------------------------------------------------
  
  initial begin
    rst = 1'b1;
    repeat(4) @(posedge clk);
    rst = 1'b0;
  end
  
  //產生測資-----------------------------------------------------------------------------------------------
  
  integer i;
  
  initial begin
    w_en  = 1'b0;
    r_en  = 1'b0;
    
    for (i = 0; i < 17; i = i + 1) begin
      @(negedge clk);
      wdata = i; 
      w_en  = 1'b1;
      
      @(negedge clk);
      w_en = 1'b0;
    end
    
    rst = 1'b1;
    repeat(3) @(negedge clk);
    rst = 1'b0;
    
    for (i = 0; i < 17; i = i + 1) begin
      @(negedge clk);
      wdata = i; 
      w_en  = 1'b1;
      
      @(negedge clk);
      w_en = 1'b0;
    end
    
    repeat(17)begin
      @(negedge clk);
      r_en = 1'b1;
      @(negedge clk);
      r_en = 1'b0;
    end
    
    
    w_en  = 1'b0;
  	r_en  = 1'b0;
    repeat (2) begin
      @(negedge clk);
  	  w_en  = 1'b1;
  	  r_en  = 1'b1;
  	  wdata = $urandom;
      @(posedge clk);
	end
    
    repeat (50) begin
      @(negedge clk);
  	  w_en  = $urandom_range(0,1);
  	  r_en  = $urandom_range(0,1);
  	  wdata = $urandom;
	end
    
    #100;
    $finish;
    
  end
  
  //存波型------------------------------------------------------------------------------------------------
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  //實例化DUT---------------------------------------------------------------------------------------------
  
  synchronous_FIFO uut (.clk(clk), .rst(rst), .wdata(wdata), .r_en(r_en), .w_en(w_en), .rdata(rdata), .wfull(wfull), .rempty(rempty));
  
endmodule



/*-------------------------------------------------------------------------------------------------------
以下是gpt所寫使用systemverilog queue充當fifo，並且同步讀寫資料並驗證兩邊讀出來的資料是不是一樣。
並且gpt說tb資料的更新，其時間沿要跟dut錯開，所以下面的tb更新是沿負沿。
--------------------------------------------------------------------------------------------------------*/



/*module tb;

  // 和 FIFO 內的 parameter 對齊
  localparam DATASIZE = 8;
  localparam ADDRSIZE = 4;

  // DUT 介面
  logic                 clk;
  logic                 rst;
  logic                 w_en;
  logic                 r_en;
  logic [DATASIZE-1:0]  wdata;
  logic [DATASIZE-1:0]  rdata;
  logic                 wfull;
  logic                 rempty;

  // ----------------------------------------------------------------
  // DUT 實例化
  // ----------------------------------------------------------------
  fifo #(
    .datasize(DATASIZE),
    .addrsize(ADDRSIZE)
  ) uut (
    .clk   (clk),
    .rst   (rst),
    .wdata (wdata),
    .r_en  (r_en),
    .w_en  (w_en),
    .rdata (rdata),
    .wfull (wfull),
    .rempty(rempty)
  );

  // ----------------------------------------------------------------
  // clock 產生：10ns 週期
  // ----------------------------------------------------------------
  initial clk = 0;
  always #5 clk = ~clk;

  // ----------------------------------------------------------------
  // reset：active-high，同你的設計
  // ----------------------------------------------------------------
  initial begin
    rst   = 1'b1;
    w_en  = 1'b0;
    r_en  = 1'b0;
    wdata = '0;

    repeat (5) @(posedge clk);
    rst = 1'b0;          // 解除 reset，開始測試
  end

  // ----------------------------------------------------------------
  // Scoreboard / 軟體 model (queue)
  // ----------------------------------------------------------------
  byte    model_q[$];     // 軟體版 FIFO
  byte    exp_data;       // 預期讀出的資料
  bit     exp_valid;      // 下一個 negedge 要不要檢查 rdata
  integer i;

  // ----------------------------------------------------------------
  // 測試流程：
  // 在每個負緣：
  //   1) 先檢查上一拍 rdata 是否正確
  //   2) 決定下一拍的 w_en / r_en / wdata
  //   3) 更新軟體 model（決定下一拍要期待什麼資料）
  // ----------------------------------------------------------------
  initial begin
    exp_valid = 0;
    model_q.delete();

    // 等 reset 結束
    @(negedge rst);
    $display("[%0t] Start random FIFO test...", $time);

    // 總共跑 200 個 clock 週期
    for (i = 0; i < 200; i = i + 1) begin
      @(negedge clk);

      // 1) 檢查「上一拍」的讀出結果
      if (exp_valid) begin
        if (rdata !== exp_data) begin
          $display("[%0t] ERROR: expected 0x%0h, got 0x%0h",
                   $time, exp_data, rdata);
          $stop;
        end
      end

      // 2) 產生這一拍的控制訊號與寫入資料
      //    在 negedge 設定，讓它在下一個 posedge 被 DUT 使用
      w_en  = $urandom_range(0, 1);
      r_en  = $urandom_range(0, 1);
      wdata = $urandom;  // 只會取低 8 bits

      // 3) 軟體 model 更新：
      //    如果這拍 DUT 會真正寫入，就 push 進 queue
      if (w_en && !wfull) begin
        model_q.push_back(wdata);
      end

      //    如果這拍 DUT 會真正讀出，就從 queue pop 一筆
      if (r_en && !rempty) begin
        if (model_q.size() == 0) begin
          $display("[%0t] MODEL ERROR: pop from empty model_q", $time);
          $stop;
        end
        exp_data  = model_q.pop_front();  // 下一拍應該看到的資料
        exp_valid = 1;
      end else begin
        exp_valid = 0;
      end
    end

    // 最後再檢查一次最後一筆資料
    @(negedge clk);
    if (exp_valid && (rdata !== exp_data)) begin
      $display("[%0t] ERROR (final check): expected 0x%0h, got 0x%0h",
               $time, exp_data, rdata);
      $stop;
    end

    $display("====================================================");
    $display("   FIFO RANDOM TEST PASSED (no mismatches found)   ");
    $display("====================================================");
    $finish;
  end

  // ----------------------------------------------------------------
  // 波形 dump（給 EDA Playground / GTKWave 用）
  // ----------------------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end

endmodule*/