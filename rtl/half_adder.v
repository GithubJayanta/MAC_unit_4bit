// =============================================================
// Module      : half_adder
// Description : 1-bit half adder. Base building block used by
//               full_adder and the Wallace tree partial-product
//               reduction stages.
// =============================================================
module half_adder (
    input  A,
    input  B,
    output sum,
    output carry
);

    assign sum   = A ^ B;  // bitwise xor
    assign carry = A & B;  // bitwise and

endmodule // half_adder
