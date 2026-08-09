// =============================================================
// Module      : full_adder
// Description : 1-bit full adder, built from two half adders.
//               Used in the Wallace tree partial-product
//               reduction stages.
// =============================================================
module full_adder (
    input  a,
    input  b,
    input  c,
    output sum,
    output cout
);

    wire w1, w2, w3;

    half_adder HA1 (a, b, w2, w1);
    half_adder HA2 (w2, c, sum, w3);

    assign cout = w1 | w3;

endmodule // full_adder
