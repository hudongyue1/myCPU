`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 20:00:31
// Design Name: 
// Module Name: alu_decoder
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
`include "defines.vh"
`include "aludefines.vh"

module alu_decoder(
    input [5:0] op, funct,
    input [4:0] rs,
    input stallD, rst,
    output reg [7:0] ALUControl
);

    always@(*) begin
        if(stallD | rst) begin
            ALUControl <= `ALU_DEFAULT;
        end
        else begin
            case (op)
                // R型，op = 0
                `EXE_ZERO_OP: 
                    case (funct)
                        // 逻辑
                        `EXE_AND:   ALUControl <= `ALU_AND;
                        `EXE_OR:    ALUControl <= `ALU_OR;   
                        `EXE_XOR:   ALUControl <= `ALU_XOR;
                        `EXE_NOR:   ALUControl <= `ALU_NOR;
                        // 移位              
                        `EXE_SLL:   ALUControl <= `ALU_SLL;
                        `EXE_SRL:   ALUControl <= `ALU_SRL;
                        `EXE_SRA:   ALUControl <= `ALU_SRA;
                        `EXE_SLLV:  ALUControl <= `ALU_SLLV;
                        `EXE_SRLV:  ALUControl <= `ALU_SRLV;
                        `EXE_SRAV:  ALUControl <= `ALU_SRAV;
                        // 数据迁移                
                        `EXE_MFHI:  ALUControl <= `ALU_MFHI;
                        `EXE_MFLO:  ALUControl <= `ALU_MFLO;
                        `EXE_MTHI:  ALUControl <= `ALU_MTHI;
                        `EXE_MTLO:  ALUControl <= `ALU_MTLO;
                        // 算术
                        `EXE_ADD:   ALUControl <= `ALU_ADD;
                        `EXE_ADDU:  ALUControl <= `ALU_ADDU;
                        `EXE_SUB:   ALUControl <= `ALU_SUB;
                        `EXE_SUBU:  ALUControl <= `ALU_SUBU;
                        `EXE_SLT:   ALUControl <= `ALU_SLT;
                        `EXE_SLTU:  ALUControl <= `ALU_SLTU;
                        `EXE_MULT:  ALUControl <= `ALU_MULT;
                        `EXE_MULTU: ALUControl <= `ALU_MULTU;
                        `EXE_DIV:   ALUControl <= `ALU_DIV;
                        `EXE_DIVU:  ALUControl <= `ALU_DIVU;
                        default:    ALUControl <= `ALU_DEFAULT;
                    endcase
    
                // I型
                `EXE_ANDI_OP:   ALUControl = `ALU_AND;
                `EXE_XORI_OP:   ALUControl = `ALU_XOR;
                `EXE_LUI_OP:    ALUControl = `ALU_LUI;
                `EXE_ORI_OP:    ALUControl = `ALU_OR;
                // 算术
                `EXE_ADDI_OP: 	ALUControl <= `ALU_ADD;
                `EXE_ADDIU_OP:  ALUControl <= `ALU_ADDU;
                `EXE_SLTI_OP: 	ALUControl <= `ALU_SLT;
                `EXE_SLTIU_OP:  ALUControl <= `ALU_SLTU;
                // load、store
                `EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP, `EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP: begin
                                ALUControl <= `ALU_ADDU;
                end
                // 特殊指令
                `EXE_PRI_OP: begin
                    case (rs)
                        `EXE_MTC0:  ALUControl = `ALU_MTC0;
                        `EXE_MFC0:  ALUControl = `ALU_MFC0; 
                        default:    ALUControl = `ALU_DEFAULT;
                    endcase
                end     
                default: ALUControl = `ALU_DEFAULT;
            endcase
        end
    end
                                                                          
endmodule
