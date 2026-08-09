// =============================================================
// Module      : CLA_12bit
// Description : 12-bit structural carry-lookahead adder built by
//               cascading three CLA_4bit blocks with high-level
//               lookahead between blocks. Used as the accumulator
//               adder in mac_unit_4.
//               Depends on: CLA_4bit
// =============================================================
module CLA_12bit(
    input  [11:0] A,
    input  [11:0] B,
    input         Cin,
    output [11:0] Sum,
    output        Cout
    );
    wire [2:0] P_blk; // Block propagates
    wire [2:0] G_blk; // Block generates
    wire [3:0] C_blk; // Carries between blocks

    assign C_blk[0] = Cin;

    // Block 0: Lower Nibble (Bits 0 to 3)
    CLA_4bit blk0 (
        .A(A[3:0]),
        .B(B[3:0]),
        .Cin(C_blk[0]),
        .Sum(Sum[3:0]),
        .Cout(), // Left floating, using high-level lookahead instead
        .Pg(P_blk[0]),
        .Gg(G_blk[0])
    );

    // High-level Lookahead for Block 1 Carry-In
    assign C_blk[1] = G_blk[0] | (P_blk[0] & C_blk[0]);

    // Block 1: Middle Nibble (Bits 4 to 7)
    CLA_4bit blk1 (
        .A(A[7:4]),
        .B(B[7:4]),
        .Cin(C_blk[1]),
        .Sum(Sum[7:4]),
        .Cout(),
        .Pg(P_blk[1]),
        .Gg(G_blk[1])
    );

    // High-level Lookahead for Block 2 Carry-In
    assign C_blk[2] = G_blk[1] | (P_blk[1] & C_blk[1]);

    // Block 2: Upper Nibble (Bits 8 to 11)
    CLA_4bit blk2 (
        .A(A[11:8]),
        .B(B[11:8]),
        .Cin(C_blk[2]),
        .Sum(Sum[11:8]),
        .Cout(),
        .Pg(P_blk[2]),
        .Gg(G_blk[2])
    );

    // Final Carry-Out Lookahead Equation
    assign C_blk[3] = G_blk[2] | (P_blk[2] & C_blk[2]);
    assign Cout = C_blk[3];

endmodule
