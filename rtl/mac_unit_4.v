// =============================================================
// Module      : mac_unit_4
// Description : Top-level 4-bit pipelined Multiply-Accumulate
//               (MAC) unit.
//                 Stage 1 - register src_A/src_B
//                 Stage 2 - Wallace-tree multiply, register product
//                 Stage 3 - 12-bit CLA accumulate into accum_out
//               Overall latency: 2 clock cycles from valid inputs
//               to the corresponding accumulation.
//               Depends on: wallace_tree_4, CLA_12bit
// =============================================================
module mac_unit_4(
    input clk,
    input rst_n,
    input clr_accum,
    input en,
    input [3:0] src_A,
    input [3:0] src_B,
    output reg [11:0] accum_out
    );
    // Stage 1 Registers (Input Boundaries from Phase 1)
    reg [3:0] reg_A;
    reg [3:0] reg_B;
    // Stage 2 Registers (Output Product Boundaries from Phase 1)
    wire [7:0] raw_product;
    reg  [7:0] piped_product;
    // Stage 3 Accumulation Wires
    wire [11:0] extended_product;
    wire [11:0] next_accum_val;
    wire cla_cout;

    // -----------------------------------------------------------------
    // STAGE 1: Input Registration
    // -----------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_A <= 4'b0000;
            reg_B <= 4'b0000;
        end else if (en) begin
            reg_A <= src_A;
            reg_B <= src_B;
        end
    end

    // -----------------------------------------------------------------
    // STAGE 2: Core Multiplication Logic & Product Pipeline Register
    // -----------------------------------------------------------------
    // Your exact custom Phase 1 Wallace Tree Core
    wallace_tree_4 multiplication(
        .A(reg_A),
        .B(reg_B),
        .Result(raw_product)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            piped_product <= 8'h00;
        end else if (en) begin
            piped_product <= raw_product; // Mirrors your 8 output DFFs
        end
    end

    // -----------------------------------------------------------------
    // STAGE 3: 12-Bit Structural Accumulation Loop
    // -----------------------------------------------------------------
    // Zero-extend the registered 8-bit pipeline product to 12 bits
    assign extended_product = {4'b0000, piped_product};

    // Your custom 12-bit Structural Carry-Lookahead Adder
    CLA_12bit accumulator_reg(
        .A(accum_out),
        .B(extended_product),
        .Cin(1'b0),
        .Sum(next_accum_val),
        .Cout(cla_cout)
    );

    // Accumulator Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accum_out <= 12'h000;
        end else if (clr_accum) begin
            accum_out <= 12'h000;
        end else if (en) begin
            accum_out <= next_accum_val;
        end
    end
endmodule
