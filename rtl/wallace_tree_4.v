// =============================================================
// Module      : wallace_tree_4
// Description : Custom 4x4 Wallace-tree multiplier core.
//               Partial products are reduced with half/full
//               adders, and the top bits are resolved with a
//               6-bit carry-lookahead structure.
//               Depends on: half_adder, full_adder
// =============================================================
module wallace_tree_4(
    input  [3:0] A,
    input  [3:0] B,
    output [7:0] Result
    );

    wire HA1_sum,HA2_sum,FA1_sum,FA2_sum ;
    wire HA1_carry,HA2_carry,FA1_carry,FA2_carry;

    //Step-1
    half_adder HA1 (A[2]&B[0], A[1]&B[1], HA1_sum, HA1_carry);
    full_adder FA1 (A[3]&B[0],A[2]&B[1],A[1]&B[2], FA1_sum, FA1_carry);
    full_adder FA2 (A[3]&B[1],A[2]&B[2],A[1]&B[3], FA2_sum, FA2_carry);


    //Step-2
    wire HA_2_1_sum,FA_2_1_sum,HA_2_2_sum;
    wire HA_2_1_carry,FA_2_1_carry,HA_2_2_carry;

    half_adder HA_2_1 (FA1_sum,HA1_carry,HA_2_1_sum,HA_2_1_carry);//Checked
    half_adder HA_2_2 (FA2_sum,FA1_carry,HA_2_2_sum,HA_2_2_carry);//Checked
    full_adder FA_2_1 (A[3]&B[2],A[2]&B[3],FA2_carry,FA_2_1_sum,FA_2_1_carry);//Checked

    wire [5:0]Sum ;
    wire [5:0] G;   // Generate
    wire [5:0] P;   // Propagate
    wire [6:0] C;   // Carry
    wire Cout ;

    assign C[0] = 1'b0;
    assign G[0] = (A[1]&B[0]) & (A[0]&B[1]) ;
    assign P[0] = (A[1]&B[0]) ^ (A[0]&B[1]) ;
    assign G[1] = HA1_sum & (A[0]&B[2]) ;
    assign P[1] = HA1_sum ^ (A[0]&B[2]) ;
    assign G[2] = HA_2_1_sum & (A[0]&B[3])  ;
    assign P[2] = HA_2_1_sum ^ (A[0]&B[3])  ;
    assign G[3]= (HA_2_2_sum) & (HA_2_1_carry) ;
    assign P[3]= (HA_2_2_sum) ^ (HA_2_1_carry) ;
    assign G[4]= (FA_2_1_sum) & (HA_2_2_carry) ;
    assign P[4]= (FA_2_1_sum) ^ (HA_2_2_carry) ;
    assign G[5]=  (A[3]&B[3]) & FA_2_1_carry ;
    assign P[5]=  (A[3]&B[3]) ^ FA_2_1_carry ;


    // Carry Lookahead Logic
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1]
                | (P[1] & G[0])
                | (P[1] & P[0] & C[0]);
    assign C[3] = G[2]
                | (P[2] & G[1])
                | (P[2] & P[1] & G[0])
                | (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3]
                | (P[3] & G[2])
                | (P[3] & P[2] & G[1])
                | (P[3] & P[2] & P[1] & G[0])
                | (P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[5] = G[4]
                | (P[4] & G[3])
                | (P[4] & P[3] & G[2])
                | (P[4] & P[3] & P[2] & G[1])
                | (P[4] & P[3] & P[2] & P[1] & G[0])
                | (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[6] = G[5]
                | (P[5] & G[4])
                | (P[5] & P[4] & G[3])
                | (P[5] & P[4] & P[3] & G[2])
                | (P[5] & P[4] & P[3] & P[2] & G[1])
                | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                | (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    // Sum
    assign Sum[0] = P[0] ^ C[0];
    assign Sum[1] = P[1] ^ C[1];
    assign Sum[2] = P[2] ^ C[2];
    assign Sum[3] = P[3] ^ C[3];
    assign Sum[4] = P[4] ^ C[4];
    assign Sum[5] = P[5] ^ C[5];
    assign Cout = C[6];


    assign Result = {Cout, Sum[5], Sum[4], Sum[3], Sum[2], Sum[1], Sum[0], A[0]&B[0]} ;


endmodule
