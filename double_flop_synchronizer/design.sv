// Code your design here
module double_flop_synchronizer(
  input  clk2,
  input in,
  output reg out
);
  reg q1;
  
  always@(posedge clk2)begin
    q1 <= in;
    out <= q1;
  end
endmodule