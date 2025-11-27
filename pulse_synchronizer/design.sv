// Code your design here
module pulse_synchronizer(
  input clk1,
  input clk2,
  input in,
  output out
);
  reg q0 = 1'b0;
  reg q1 = 1'b0;
  reg q2 = 1'b0;
  reg q3 = 1'b0;
  
  /*initial begin
    reg q0 = 1'b0;
  	reg q1 = 1'b0;
  	reg q2 = 1'b0;
  	reg q3 = 1'b0;
  end*/
  
  wire a_p_in;
 
  assign a_p_in = in^q0;
    
  always@(posedge clk1)begin
    q0 <= a_p_in;
  end
  
  always@(posedge clk2)begin
    q1 <= q0;
    q2 <= q1;
    q3 <= q2;
  end
  
  assign out = q3^q2;
  
  
endmodule