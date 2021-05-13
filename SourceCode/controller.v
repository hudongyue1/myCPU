`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 20:00:58
// Design Name: 
// Module Name: controller
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


module controller(
    input [31:0] instrD,
    input stallD, rst,
    output [7:0] ALUControl,
    output branch,jump,jal,jr,bal,aluSrc,memRead,memWrite,memToReg,regWrite,regDst,
    output sign_ext,
    output hilo_we,   
    output isDiv,
    output invalid,
    output cp0_we
);

    wire [5:0] op;
	wire [4:0] rs,rt;
	wire [5:0] funct;
    
    assign op    = instrD[31:26];
	assign rs    = instrD[25:21];
	assign rt    = instrD[20:16];
	assign funct = instrD[5:0];

    // andi, xori, lui, ori是无符号扩展，其他的是符号扩展
    assign sign_ext = ~(op[5:2] == 4'b0011);
    		
    // div，divu，mult，multu，mthi mtlo会写hi、lo寄存器
    assign hilo_we = ((op == `EXE_ZERO_OP && funct == `EXE_MTHI) ||
                      (op == `EXE_ZERO_OP && funct == `EXE_MTLO) ||
                      (op == `EXE_ZERO_OP && funct == `EXE_MULT) ||
                     (op == `EXE_ZERO_OP && funct == `EXE_MULTU) ||
                       (op == `EXE_ZERO_OP && funct == `EXE_DIV) ||
                      (op == `EXE_ZERO_OP && funct == `EXE_DIVU));      
    
    // 除法
    assign isDiv = ((op == `EXE_ZERO_OP && funct == `EXE_DIV) ||
                      (op == `EXE_ZERO_OP && funct == `EXE_DIVU));
    
    // MTC0，写cp0寄存器
    assign cp0_we = (instrD[31:21] == 11'b01000000100 && instrD[10:0] == 11'b00000000000); 

    main_decoder main_dec(
        .instrD(instrD),
        .stallD(stallD), .rst(rst),
        .branch(branch), 
        .jump(jump), 
        .jal(jal),
        .jr(jr),
        .bal(bal),
        .aluSrc(aluSrc),
        .memRead(memRead),
        .memWrite(memWrite),
        .memToReg(memToReg),
        .regWrite(regWrite),
        .regDst(regDst),
        .invalid(invalid)
    );

    alu_decoder alu_dec(
        .op(op),
        .funct(funct),
        .stallD(stallD), .rst(rst),
        .rs(rs),
        .ALUControl(ALUControl)
    );


endmodule