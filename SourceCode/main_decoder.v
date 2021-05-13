`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 20:00:00
// Design Name: 
// Module Name: main_decoder
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

module main_decoder(
    input [31:0] instrD,
    input stallD, rst,
    output branch,jump,jal,jr,bal,aluSrc,memRead,memWrite,memToReg,regWrite,regDst,  // 0-> rt, 1-> rd
    output reg invalid
    );

    reg [5:0] sigs;
    assign {aluSrc, memRead, memWrite, memToReg, regWrite, regDst} = sigs;

    wire [5:0] op;
	wire [4:0] rs,rt;
	wire [5:0] funct;
    assign op    = instrD[31:26];
	assign rs    = instrD[25:21];
	assign rt    = instrD[20:16];
	assign funct = instrD[5:0];
	
	// 所有的branch指令
	assign branch = ((op == `EXE_BEQ_OP) || (op == `EXE_BNE_OP) || (op == `EXE_BLEZ_OP) || (op == `EXE_BGTZ_OP) ||
                      (op == `EXE_REGIMM_OP && rt == `EXE_BLTZ) || (op == `EXE_REGIMM_OP && rt == `EXE_BLTZAL) ||
                      (op == `EXE_REGIMM_OP && rt == `EXE_BGEZ) || (op == `EXE_REGIMM_OP && rt == `EXE_BGEZAL));

    // j、jr
	assign jump = ((op == `EXE_J_OP) || (op == `EXE_ZERO_OP && funct == `EXE_JR));
	
	// jal
	assign jal = (op == `EXE_JAL_OP);
	
	// jr、jalr
	assign jr =  ((op == `EXE_ZERO_OP && funct == `EXE_JR) || (op == `EXE_ZERO_OP && funct == `EXE_JALR));
	
	// bltzal、bgezal
	assign bal = (op == `EXE_REGIMM_OP && rt == `EXE_BLTZAL) || (op == `EXE_REGIMM_OP && rt == `EXE_BGEZAL);
	

    always@(*) begin
        if(rst | stallD) begin
            invalid = 1'b0;
            sigs =  6'b000_000;
        end
        else begin
            invalid = 1'b0;
            case (op)
                // I型指令，op = 0
                `EXE_ZERO_OP:
                    case (funct)
                        // 逻辑、移位、数据迁移、算术
                        `EXE_AND,`EXE_OR,`EXE_XOR,`EXE_NOR, `EXE_SLL, `EXE_SRL, `EXE_SRA, `EXE_SLLV, `EXE_SRLV, `EXE_SRAV,
                        `EXE_MFHI, `EXE_MFLO,
                        `EXE_ADD,`EXE_ADDU,`EXE_SUB,`EXE_SUBU,`EXE_SLT,`EXE_SLTU: begin
                            sigs <= 6'b000_011;
                        end
                        // 无需和Mem、RF打交道
                        `EXE_MTHI, `EXE_MTLO, `EXE_MULT, `EXE_MULTU, `EXE_DIV, `EXE_DIVU,
                        `EXE_BREAK, `EXE_SYSCALL: begin
                            sigs <= 6'b000_000;
                        end
                        `EXE_JR: begin
                            sigs <= 6'b000_000;
                        end
                        `EXE_JALR: begin
                            sigs <= 6'b000_011;
                        end
                        default: begin
                            sigs <= 6'b0000_0000_000;
                            invalid <= 1'b1;
                        end
                    endcase
                
                // I型指令
                // 逻辑、算术
                `EXE_ANDI_OP, `EXE_LUI_OP, `EXE_XORI_OP, `EXE_ORI_OP,
                `EXE_ADDI_OP, `EXE_ADDIU_OP, `EXE_SLTI_OP, `EXE_SLTIU_OP: begin
                    sigs <= 6'b0000_0100_010;
                end
                `EXE_J_OP: begin
                    sigs <= 6'b000_000;
                end
                `EXE_JAL_OP: begin
                    sigs <= 6'b000_010;
                end
                `EXE_BEQ_OP, `EXE_BNE_OP, `EXE_BGTZ_OP, `EXE_BLEZ_OP: begin
                    sigs <= 6'b000_000;
                end
                `EXE_REGIMM_OP: begin
                    case (rt)
                        `EXE_BLTZ, `EXE_BGEZ:     sigs <= 6'b000_000; 
                        `EXE_BLTZAL, `EXE_BGEZAL: sigs <= 6'b000_010;
                        default: begin
                            sigs <= 6'b000_000;
                            invalid <= 1'b1;
                        end                 
                    endcase
                end
                // load、store
                `EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP: begin
                    sigs <= 6'b110_110;
                end
                `EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP: begin
                    sigs <= 6'b101_000;
                end
                // 特殊指令
                `EXE_PRI_OP: begin
                    case (rs)
                        `EXE_MTC0: sigs <= 6'b000_000;
                        `EXE_MFC0: sigs <= 6'b000_010; 
                        default: begin
                            sigs <= 6'b000_000;
                            invalid <= |(instrD ^ `EXE_ERET);
                        end
                    endcase
                end
                default: begin
                    sigs <= 6'b000_0000;
                    invalid <= 1'b1;
                end
            endcase
        end
    end

endmodule
