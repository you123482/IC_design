// Code your design here
module fifo(
  input clk,
  input rst,
  input [7:0]wdata,
  input r_en,
  input w_en,
  output reg [7:0]rdata,
  output wfull,
  output rempty
);
  parameter datasize = 8;
  parameter addrsize = 4;
  
  reg [addrsize-1:0]wptr;
  reg [addrsize-1:0]rptr;
  reg [datasize-1:0] mem [1<<addrsize];
  
  w_ctrl wuut (.clk(clk), .rst(rst), .wpush(w_en), .rptr(rptr), .wptr(wptr), .wfull( wfull ));
  r_ctrl ruut (.clk(clk), .rst(rst), .rpop( r_en), .wptr(wptr), .rptr(rptr), .rempty(rempty));
  
  always@(posedge clk)begin
    if(!wfull && w_en)begin
      mem[wptr] <= wdata;
    end
  end
  
  always@(posedge clk)begin
    if(!rempty && r_en)begin
       rdata <= mem[rptr];
    end
  end
  
endmodule

//----------------------------------------------------------------------------------------
module w_ctrl(
  input clk,
  input rst,
  input wpush,
  input [3:0]rptr,
  output reg [3:0]wptr,
  output wfull
);
  assign wfull = ((wptr+4'b1) == rptr)?1'b1:1'b0;
 
  always@(posedge clk) begin
    if(rst)begin
      wptr <= 1'b0;
    end
    
    else begin
      if(wpush && !wfull)begin
        wptr <= wptr+1'b1;
      end
    end
    
  end
endmodule

//----------------------------------------------------------------------------------------
module r_ctrl(
  input clk,
  input rst,
  input rpop,
  input [3:0]wptr,
  output reg [3:0]rptr,
  output rempty
);
  assign rempty = (rptr == wptr)?1:0;
  
  always@(posedge clk)begin
    if(rst)begin
      rptr <= 'b0;
    end
    
    else begin
      if(rpop && !rempty)begin
        rptr <= rptr + 'b1;
      end
    end
    
  end
endmodule
