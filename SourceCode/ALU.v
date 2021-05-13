`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/03 14:47:43
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "aludefines.vh"

module ALU(
    input [31:0] a,
    input [31:0] b,
    input [4:0] sa,     //
    input [7:0] op,
    input [63:0] hilo,
    input [31:0] cp0data,
    output [63:0] res,
    output overFlow
);

    wire [31:0] mult_a, mult_b;
    wire [63:0] mulres;
    wire [31:0] subresult;
    wire [63:0] hilo_temp;
    
    reg [31:0] y;
    
    assign res = (op == `ALU_MTHI) ? {a, hilo[31:0]} : 
                 (op == `ALU_MTLO) ? {hilo[63:32],a} : 
                 (op == `ALU_MULT || op == `ALU_MULTU) ? mulres : {32'b0, y};
    
    
    assign mult_a = ((op == `ALU_MULT) && (a[31] == 1'b1))? (~a + 1):a;
    assign mult_b = ((op == `ALU_MULT) && (b[31] == 1'b1))? (~b + 1):b;
    assign hilo_temp = mult_a * mult_b;
    assign mulres = ((op == `ALU_MULT) && (a[31]^b[31] == 1'b1))?~hilo_temp +1 : hilo_temp;
    assign subresult = a + (~b + 1);
    
    
    assign overFlow = ((op == `ALU_ADD) || (op == `ALU_ADDI))? (y[31] && !a[31] && !b[31]) || (!y[31] && a[31] && b[31]):
                      (op == `ALU_SUB)? ((a[31]&!b[31])&!y[31]) || ((!a[31]&b[31])&y[31]):
                      1'b0;             
    
    always@(*) begin
        case(op)
            `ALU_AND, `ALU_ANDI: y<= a & b;
            `ALU_OR, `ALU_ORI: y <= a | b;
            `ALU_XOR, `ALU_XORI: y <= a ^ b;
            `ALU_NOR: y <= ~(a | b);
            `ALU_LUI: y <= {b[15:0],b[31:16]};
            `ALU_SLL: y <= b<<sa;
            `ALU_SRL: y <= b>>sa;
            `ALU_SRA: y <= ({32{b[31]}} << (6'd32 - {1'b0,sa})) | b>>sa;
            `ALU_SLLV: y <= b<<a[4:0];
            `ALU_SRLV: y <= b>>a[4:0];
            `ALU_SRAV: y <= ({32{b[31]}} << (6'd32 - {1'b0,a[4:0]})) | b>>a[4:0];
            `ALU_MFHI: y <= hilo[63:32];
            `ALU_MFLO: y <= hilo[31:0];
            `ALU_ADD, `ALU_ADDI, `ALU_ADDU, `ALU_ADDIU: y<= a+b;
            `ALU_SUB, `ALU_SUBU: y <= subresult;
            `ALU_SLT, `ALU_SLTI: y <= ((a[31] && !b[31]) || (!a[31] && !b[31] && subresult[31]) ||  (a[31] && b[31] && subresult[31]));
            `ALU_SLTU, `ALU_SLTIU: y <= a<b;
            `ALU_LB, `ALU_LBU, `ALU_LH, `ALU_LHU, `ALU_LW, `ALU_SB, `ALU_SH, `ALU_SW: y<=a+b;
            `ALU_MTC0: y <= b;
            `ALU_MFC0: y <= cp0data;
            `ALU_DEFAULT: y <= 32'b0;
        endcase
    end
   
   
endmodule
