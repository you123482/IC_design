// Code your testbench here
// or browse Examples

module tb();
  reg clk1;
  reg clk2;
  reg rst1;
  reg rst2;
  reg w_en;
  reg r_en;
  reg [7:0]wdata;
  
  wire [7:0]rdata;
  wire full;
  wire empty;
  
  initial begin
    clk1 = 0;
    forever #3 clk1 = ~clk1;
  end
  
  initial begin
    clk2 = 0;
    forever #5 clk2 = ~clk2;
  end
  
  initial begin
    w_en = 0;
    rst1 = 1;
    repeat(2)@(negedge clk1);
    rst1 = 0;
  end
  
  initial begin
    r_en = 0;
    rst2 = 1;
    repeat(2)@(negedge clk2);
    rst2 = 0;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    #2000;
    $finish;
  end
  
  /*initial begin
    #30;
    @(negedge clk1)
    wdata = {$random}%30;
    w_en = 1;

    repeat(7) begin
      @(negedge clk1)
      wdata = {$random}%30;
    end

    @(negedge clk1)
    w_en = 0;

    @(negedge clk2)
    r_en = 1;

    repeat(7) begin
      @(negedge clk2);
    end

    @(negedge clk2)
    r_en = 0;

    #150;

    @(negedge clk1)
    w_en = 1;
    wdata = {$random}%30;

    repeat(15) begin
      @(negedge clk1)
      wdata = {$random}%30;
    end

    @(negedge clk1)
    w_en = 0;

    #50;
    $finish;
  end*/
  
  always@(negedge clk1)begin
    w_en  = $urandom_range(0,1);
    wdata = $urandom;
  end
  
  always@(negedge clk2)begin
    r_en  = $urandom_range(0,1);
  end
  
  asynchronous_FIFO #(.datasize(8), .addrsize(4)) uut(.clk1(clk1), .clk2(clk2), .rst1(rst1), .rst2(rst2), .w_en(w_en), .r_en(r_en), .wdata(wdata), .rdata(rdata), .full(full), .empty(empty));
  
endmodule

