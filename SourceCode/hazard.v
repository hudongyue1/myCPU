`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/07 15:22:20
// Design Name: 
// Module Name: hazard
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


module hazard(
    // IF
    output stallF, flushF,
    // ID
    input [4:0] rsD, rtD,
    input branchD, jumpD, jrD, balD,
    output forwardAD, forwardBD,
    output stallD,flushD,
    // Exe
    input [4:0] rsE, rtE, rdE,
    input [4:0] writeRegE,
    input regWriteE,
    input memToRegE,
    input stall_divE,
    output [1:0] forwardAE, forwardBE, forwardHiloE,
    output [1:0] forwardcp0E,
    output stallE, flushE,
    // Mem
    input [4:0] writeRegM, rdM,
    input regWriteM,
    input memToRegM,
    input hilo_weM, cp0_weM,
    input flush_exceptM,
    output stallM, flushM,
    // WB
    input [4:0] writeRegW, rdW,
    input regWriteW,
    input hilo_weW, cp0_weW,
    output stallW, flushW,
    input stallreq_from_if, stallreq_from_mem
    );
    
    //数据冒险 R型指令，前推
    assign forwardAE = ((rsE!=0) && (rsE==writeRegM) && regWriteM) ? 2'b10: 
                       ((rsE!=0) && (rsE==writeRegW) && regWriteW) ? 2'b01:
                        2'b00;
                    
    assign forwardBE = ((rtE!=0) && (rtE==writeRegM) && regWriteM) ? 2'b10: 
                       ((rtE!=0) && (rtE==writeRegW) && regWriteW) ? 2'b01:
                        2'b00;
    
    // hilo寄存器导致的数据冒险，总是同时写hi、lo
    assign forwardHiloE = hilo_weM ? 2'b10 : (hilo_weW ? 2'b01 : 2'b00);

    // cp0
    assign forwardcp0E = (cp0_weM && rdM == rdE)? 2'b10 :
                         (cp0_weW && rdW == rdE)? 2'b01 : 2'b00;

    //数据冒险 load指令的，前推并且阻塞一周期
    wire lwStall;
    assign lwStall = ((rsD==rtE) || (rtD==rtE)) && memToRegE;
    
    //结构冒险 beq指令
    assign forwardAD = (rsD!=0) && (rsD==writeRegM) && regWriteM;
    assign forwardBD = (rtD!=0) && (rtD==writeRegM) && regWriteM;

    // branch and jump stall 
    wire branchStall, jumpStall;
    assign branchStall = (branchD && regWriteE && (writeRegE==rsD || writeRegE==rtD))
                       | (branchD && memToRegM && (writeRegM==rsD || writeRegM==rtD));
                       
    assign jumpStall = (jrD && regWriteE && (writeRegE==rsD))
                     | (jrD && memToRegM && (writeRegM==rsD));                
    
    assign dataHz_stall = (lwStall | branchStall | jumpStall);
    
    assign stallF = (dataHz_stall | stall_divE | stallreq_from_if | stallreq_from_mem) & ~flush_exceptM;
    assign stallD = stallF;
    assign stallE = (stall_divE) | stallreq_from_mem;
    assign stallM = stallreq_from_mem;
    assign stallW = 0;

    assign flushF = flush_exceptM;
    assign flushD = flush_exceptM;
    assign flushE = flush_exceptM | dataHz_stall;
    assign flushM = flush_exceptM;
    assign flushW = flush_exceptM | stallreq_from_mem;

endmodule

