// Code your design here

module asynchronous_FIFO(
  input clk1,
  input clk2,
  input rst1,
  input rst2,
  input w_en,
  input r_en,
  input [7:0]wdata,
  output reg [7:0]rdata,
  output reg full,
  output reg empty
);
  
  parameter datasize = 8;
  parameter addrsize = 4;
  
  reg [datasize-1:0] mem[1<<addrsize];
  
  wire [addrsize:0]wptr_g, rptr_g;
  reg [addrsize:0]wptr, rptr;
  reg [addrsize:0]wptr_gr, wptr_grr, rptr_gr, rptr_grr;
  
  assign wptr_g = wptr^(wptr>>1);
  assign rptr_g = rptr^(rptr>>1);
  
  /*assign full = (wptr_g[addrsize:addrsize-1] == ~rptr_grr[addrsize:addrsize-1] && wptr_g[addrsize-2:0] == rptr_grr[addrsize-2:0])?1'b1:1'b0;
  assign empty = (wptr_grr == rptr_g)?1'b1:1'b0;*/
  
  //full計算
  
  always@(posedge clk1)begin
    if((wptr_g[addrsize:addrsize-1] == ~rptr_grr[addrsize:addrsize-1] && wptr_g[addrsize-2:0] == rptr_grr[addrsize-2:0]))
      full <= 1;
    else
      full <= 0;
  end
  
  //empty計算
  
  always@(posedge clk2)begin
    if(wptr_grr == rptr_g)
      empty <= 1;
    else
      empty <= 0;
    
  end
  
  //2 flop rptr
  
  always@(posedge clk1)begin
    if(rst1)begin
      rptr_gr <= 0;
      rptr_grr <= 0;
    end
    else begin
      {rptr_grr, rptr_gr} <= {rptr_gr, rptr_g};
    end
  end
  
  //2 flop wptr
  
  always@(posedge clk2)begin
    if(rst2)begin
      wptr_gr <= 0;
      wptr_grr <= 0;
    end
    else begin
      {wptr_grr, wptr_gr} <= {wptr_gr, wptr_g};
    end
  end
  
  //fifo in
  
  always@(posedge clk1)begin
    if(rst1)begin
      wptr <= 0;
    end
    else begin
      if(w_en && ~full)begin
        wptr <= wptr+1;
        mem[wptr[3:0]] <= wdata;
      end
    end
  end
  
  //fifo out
  
  always@(posedge clk2)begin
    if(rst2)begin
      rptr <= 0;
    end
    else begin
      if(r_en && ~empty)begin
        rptr <= rptr+1;
        rdata <= mem[rptr[3:0]];
      end
    end
  end
  
endmodule

