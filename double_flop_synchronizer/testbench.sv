// Code your testbench here
// or browse Examples
module testbench();

    // DUT I/O
    reg  clk2;
    reg  in;
    wire out;

    // Instantiate the DUT
    double_flop_synchronizer uut (
        .clk2 (clk2),
        .in   (in),
        .out  (out)
    );

    // Generate destination domain clock (clk2)
    initial begin
        clk2 = 0;
        forever #3 clk2 = ~clk2;   // clk2 period = 6ns
    end

    // Async input generator (跨時鐘域、不對齊 clk2)
    initial begin
        in = 0;

        #5  in = 1;   // not aligned to clk2
        #7  in = 0;
        #11 in = 1;
        #4  in = 0;
        #9  in = 1;
        #10 in = 0;

        #20 $finish;
    end

    // Monitor signals
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("  time   clk2   in   out");
        $monitor("%5t    %b     %b     %b", $time, clk2, in, out);
    end

endmodule
  