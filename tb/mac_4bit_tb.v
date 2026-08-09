// =============================================================
// Module      : mac_4bit_tb
// Description : Self-checking testbench for mac_unit_4. Runs a
//               golden reference model (with a 2-cycle history
//               pipeline for debug visibility) alongside the DUT
//               and flags any mismatch. Covers zero/max cases,
//               walking-ones, alternating bits, an exhaustive
//               16x16 sweep, accumulator clear, clock gating,
//               random stress, and accumulator overflow wrap.
// =============================================================
module mac_4bit_tb;

reg clk;
reg rst_n;
reg clr_accum;
reg en;

reg [3:0] src_A;
reg [3:0] src_B;

wire [11:0] accum_out;

/////////////////////////////////////////////////////////
// DUT Instance
/////////////////////////////////////////////////////////
mac_unit_4 DUT(
    .clk(clk),
    .rst_n(rst_n),
    .clr_accum(clr_accum),
    .en(en),
    .src_A(src_A),
    .src_B(src_B),
    .accum_out(accum_out)
);

/////////////////////////////////////////////////////////
// Clock Generator (100 MHz)
/////////////////////////////////////////////////////////
initial clk = 0;
always #5 clk = ~clk;

/////////////////////////////////////////////////////////
// Golden Model with Pipeline History Tracking (2-Cycle Latency)
/////////////////////////////////////////////////////////
reg [7:0] product_pipe1;
reg [11:0] expected;

// 2-Stage history tracking registers
reg [3:0] hist_A_p1,   hist_A_p2;
reg [3:0] hist_B_p1,   hist_B_p2;
reg       hist_en_p1,  hist_en_p2;
reg       hist_clr_p1, hist_clr_p2;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        product_pipe1 <= 0;
        expected      <= 0;

        // Reset debugging history
        hist_A_p1   <= 0; hist_A_p2   <= 0;
        hist_B_p1   <= 0; hist_B_p2   <= 0;
        hist_en_p1  <= 0; hist_en_p2  <= 0;
        hist_clr_p1 <= 0; hist_clr_p2 <= 0;
    end
    else
    begin
        // Standard data path pipeline execution (1st Stage)
        if(en)
        begin
            product_pipe1 <= src_A * src_B;
        end

        // Step inputs down the debug pipeline every clock cycle
        hist_A_p1   <= src_A;      hist_A_p2   <= hist_A_p1;
        hist_B_p1   <= src_B;      hist_B_p2   <= hist_B_p1;
        hist_en_p1  <= en;         hist_en_p2  <= hist_en_p1;
        hist_clr_p1 <= clr_accum;  hist_clr_p2 <= hist_clr_p1;

        // Accumulator accumulation control (2nd Stage)
        if(clr_accum)
        begin
            expected <= 0;
        end
        else if(en)
        begin
            expected <= expected + product_pipe1; // Accumulating directly from pipe1
        end
    end
end

/////////////////////////////////////////////////////////
// Self-Checking Monitor Block
/////////////////////////////////////////////////////////
integer error_count = 0;

always @(posedge clk)
begin
    if (rst_n)
    begin
        #1; // Wait for non-blocking assignments to settle

        if (accum_out !== expected)
        begin
            error_count = error_count + 1;

            $display("=================================================");
            $display("MAC VERIFICATION ERROR CAUGHT AT %0t", $time);
            $display("-------------------------------------------------");
            $display("CULPRIT INPUTS (From True 2 Cycles Ago):");
            $display("A (Historical)     = %0d", hist_A_p2);
            $display("B (Historical)     = %0d", hist_B_p2);
            $display("en (Historical)    = %0b", hist_en_p2);
            $display("clr (Historical)   = %0b", hist_clr_p2);
            $display("-------------------------------------------------");
            $display("OUTPUT MISMATCH:");
            $display("Expected Output    = %0d", expected);
            $display("Actual DUT Output  = %0d", accum_out);
            $display("=================================================");

            $fatal(1, "Stopping simulation due to hardware mismatch.");
        end
    end
end

/////////////////////////////////////////////////////////
// Stimulus Vectors
/////////////////////////////////////////////////////////
integer i, j;

initial
begin
    // Initial State Setup
    rst_n = 0;
    clr_accum = 0;
    en = 0;
    src_A = 0;
    src_B = 0;

    #30;
    rst_n = 1;

    // Test 1: Zero Multiplication
    en = 1;
    src_A = 0;
    src_B = 0;
    repeat(5) @(posedge clk);

    // Test 2: Max Multiplication
    src_A = 15;
    src_B = 15;
    repeat(5) @(posedge clk);

    // Test 3: Walking Ones
    src_A = 1; src_B = 1; @(posedge clk);
    src_A = 2; src_B = 2; @(posedge clk);
    src_A = 4; src_B = 4; @(posedge clk);
    src_A = 8; src_B = 8; @(posedge clk);

    // Test 4: Alternating Bits
    src_A = 4'b1010; src_B = 4'b0101; @(posedge clk);
    src_A = 4'b1111; src_B = 4'b0001; @(posedge clk);

    // Test 5: Exhaustive 256 Combinations
    for(i=0; i<16; i=i+1)
    begin
        for(j=0; j<16; j=j+1)
        begin
            src_A = i;
            src_B = j;
            @(posedge clk);
        end
    end

    // Test 6: Accumulator Clear
    clr_accum = 1;
    @(posedge clk);
    clr_accum = 0;
    repeat(3) @(posedge clk);

    // Test 7: Clock Gating (Enable/Disable)
    src_A = 10;
    src_B = 10;
    en = 0;
    repeat(5) @(posedge clk);

    en = 1;
    repeat(5) @(posedge clk);

    // Test 8: Random Stress Profiling
    repeat(500)
    begin
        src_A = $random;
        src_B = $random;
        @(posedge clk);
    end

    // Test 9: Overflow Wrap Boundary
    clr_accum = 1;
    @(posedge clk);
    clr_accum = 0;

    src_A = 15;
    src_B = 15;
    repeat(50) @(posedge clk);

    // Final Reporting
    $display("");
    $display("=======================================");
    $display("SUCCESS: Simulation Finished Cleanly!");
    $display("=======================================");
    $finish;
end

endmodule
