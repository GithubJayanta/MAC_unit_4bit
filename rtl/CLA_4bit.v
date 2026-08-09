// =============================================================
// Module      : CLA_4bit
// Description : 4-bit carry-lookahead adder block with block-level
//               propagate/generate outputs (Pg, Gg) for cascading
//               into a wider structural CLA (see CLA_12bit).
// =============================================================
module CLA_4bit(
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout,
    output       Pg, // Block Propagate
    output       Gg  // Block Generate
    );
    wire [3:0] p;
    wire [3:0] g;
    wire [4:0] c;

    // Bit-level Generate and Propagate
    assign g = A & B;
    assign p = A ^ B;

    // Lookahead Carry Logic
    assign c[0] = Cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);

    // Sum Generation
    assign Sum = p ^ c[3:0];
    assign Cout = c[4];

    // Block-level outputs for cascading
    assign Pg = p[3] & p[2] & p[1] & p[0];
    assign Gg = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

endmodule
