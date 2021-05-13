`timescale 1ns / 1ps
`include "defines.vh"

module dataPath(
    input clk,rst,
    input [5:0] int,
    
    // IF
    input [31:0] instrF,
    output [31:0] pcF,
    
    // ID
    input regWriteD,memToRegD,memReadD,memWriteD,aluSrcD,regDstD,
    input branchD,jumpD,jalD,jrD,balD,
    input [7:0] ALUControlD,
    input sign_extD,
    input hilo_weD,
    input isDivD,
    input invalidD,
    input cp0_weD,
    output [31:0] instrD,
    output stallD,
    
    // Mem
    output [31:0] pcM,
    input [31:0] readDataM, bad_addrM,
    input adelM, adesM,
    output [31:0] ALUOutM,writeDataM,
    output [5:0] opM,
    output mem_enM,memWriteM,
    output [31:0] excepttypeM,
    output flush_exceptM,
    
    // WB
    output [31:0] pcW, resultW,
    output [4:0] writeRegW,
    output regWriteW,
    
    input stallreq_from_if, stallreq_from_mem
    );

    // IF
    wire stallF, flushF;
    wire [7:0] exceptF;
    wire is_in_delayslotF;
    
    // FD
    wire [31:0] pc_next_FD, pc_nextbrFD, pc_nextjpFD, pc_plus4F, pc_plus8F,pc_branchD,pc_jumpD;
    
    // ID
    wire [31:0] pcD, pc_plus4D, pc_plus8D;
    wire forwardAD, forwardBD,euqalD,pcSrcD;
    wire [5:0] opD, functD;
    wire [4:0] rsD,rtD,rdD,saD;
    wire flushD;
    wire [31:0] signImmD,signImmD_sl2D;
    wire [31:0] srcaD,srca2D,srcbD,srcb2D;
    wire [7:0] exceptD;
    wire breakD, syscallD, eretD;
    wire is_in_delayslotD;
    
    // Exe
    wire [31:0] pcE, pc_plus8E;
    wire [1:0] forwardAE,forwardBE, forwardHiloE;
    wire [4:0] rsE,rtE,rdE,saE;
    wire [5:0] opE;
    wire stallE, flushE;
    wire [4:0] writeRegE,writeReg2E;
    wire [31:0] signImmE;
    wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E, instrE;
    wire memToRegE,memReadE,memWriteE,aluSrcE,regWriteE,regDstE;
    wire jalE, jrE, balE;
    wire [7:0] ALUControlE;
    wire [63:0] ALUOutE;
    wire [31:0] ALUOut2E;
    wire [63:0] hilo_for_aluE;
    wire hilo_weE;
    wire [63:0] alu_resultE, div_resultE;
    wire stall_divE, isDivE;
    wire [7:0] exceptE;
    wire [31:0] cp0dataE, cp0data2E;
    wire is_in_delayslotE;
    wire cp0_weE;
    wire [1:0] forwardcp0E;
    
    // Mem
    wire [4:0] writeRegM, rdM;
    wire memToRegM,memReadM,regWriteM;
    wire hilo_weM;
    wire [63:0] hilo_iM;
    wire [7:0] exceptM;
    wire is_in_delayslotM;
    wire [31:0] newpcM;
    wire cp0_weM;
    wire pc_trapM;
    wire stallM, flushM;
    wire [31:0] instrM;
    
    // WB
    wire [4:0] rdW;
    wire [31:0] ALUOutW,readDataW, instrW;
    wire memToRegW;
    wire hilo_weW, cp0_weW;
    wire [63:0] hilo_iW, hilo_oW;
    wire stallW, flushW;

    wire zero,overFlow;              
    wire [31:0] count_o,compare_o,status_o,cause_o,epc_o,config_o,prid_o,badvaddr;
    wire timer_int_o;
        
    
    // 显示ascii
    wire [39:0] asciiF, asciiD, asciiE, asciiM, asciiW;
    
    instdec instdec1(instrD, asciiD);
    instdec instdec2(instrF, asciiF);
    instdec instdec3(instrE, asciiE);
    instdec instdec4(instrM, asciiM);
    instdec instdec5(instrW, asciiW);
    
    //冒险
    hazard h(
     // IF
    .stallF(stallF),
    .flushF(flushF),
    // ID
    .rsD(rsD), 
    .rtD(rtD),
    .branchD(branchD),
    .jumpD(jumpD),
    .jrD(jrD),
    .balD(balD),
    .forwardAD(forwardAD), 
    .forwardBD(forwardBD),
    .stallD(stallD),
    .flushD(flushD),
    // Exe
    .rsE(rsE), 
    .rtE(rtE),
    .rdE(rdE),
    .writeRegE(writeRegE),
    .regWriteE(regWriteE),
    .memToRegE(memToRegE),
    .forwardAE(forwardAE), 
    .forwardBE(forwardBE),
    .forwardHiloE(forwardHiloE),
    .forwardcp0E(forwardcp0E),
    .stall_divE(stall_divE),
    .stallE(stallE),
    .flushE(flushE),
    // Mem
    .writeRegM(writeRegM),
    .rdM(rdM),
    .regWriteM(regWriteM),
    .memToRegM(memToRegM),
    .hilo_weM(hilo_weM),
    .cp0_weM(cp0_weM),
    .flush_exceptM(flush_exceptM),
    .stallM(stallM),
    .flushM(flushM),
    
    // WB
    .writeRegW(writeRegW),
    .regWriteW(regWriteW),
    .rdW(rdW),
    .hilo_weW(hilo_weW),
    .cp0_weW(cp0_weW),
    .stallW(stallW),
    .flushW(flushW),
    .stallreq_from_if(stallreq_from_if), 
    .stallreq_from_mem(stallreq_from_mem)
    );
    
    // -------------------------IF-------------------------
    // pcSrc=1, branch跳转
    mux2to1 #(32) mux_pc_beq(
        .a(pc_plus4F),
        .b(pc_branchD),
        .s(pcSrcD),
        .y(pc_nextbrFD)
    );
    
    // J型pc跳转
    mux2to1 #(32) mux_pc_jump(
        .a(pc_nextbrFD),
        .b(pc_jumpD),
        .s(jumpD | jalD | jrD),
        .y(pc_nextjpFD)
    );

    // exception
    mux2to1 #(32) mux_pc_exc(
        .a(pc_nextjpFD),
        .b(newpcM),
        .s(pc_trapM),
        .y(pc_next_FD)
    );

    // pc寄存器
    pc_reg #(32) pcReg(
        .clk(clk),
        .rst(rst),
        .en(~stallF),
        .d(pc_next_FD),
        .q(pcF)
    );
    
    assign pc_plus4F = pcF + 32'h4;
    assign pc_plus8F = pcF + 32'h8;
    
    // 所有的branch和jump指令都需要延时槽
    assign is_in_delayslotF = (jumpD | jalD | jrD | branchD);
    
    // 异常，adel, sys, bp, eret, ri, ov, ades
    assign exceptF = (pcF[1:0] == 2'b00) ? 8'b0000_0000 : 8'b1000_0000;  

    // -------------------------ID-------------------------
    //IF-ID
    flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcF,pcD);  
    flopenrc #(32) r2D(clk,rst,~stallD,flushD,pc_plus4F,pc_plus4D); 
    flopenrc #(32) r3D(clk,rst,~stallD,flushD,pc_plus8F,pc_plus8D);      
    flopenrc #(32) r4D(clk,rst,~stallD,flushD,instrF,instrD);          
    flopenrc #(1)  r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
    flopenrc #(8)  r6D(clk,rst,~stallD,flushD,exceptF,exceptD);
    
    assign opD    = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD    = instrD[25:21];
    assign rtD    = instrD[20:16];
    assign rdD    = instrD[15:11];
    assign saD    = instrD[10:6];
    
    // RF
    regfile rf(
        .clk(~clk),         // 时钟取反
        .we(regWriteW),
        .ra1(rsD),
        .ra2(rtD),
        .wa(writeRegW),     
        .din(resultW),
        .dout1(srcaD),
        .dout2(srcbD)
    );

    // 位扩展，只有ori、andi、lui、xori是无符号扩展，其余为符号扩展
    signext signExtend(instrD[15:0] ,sign_extD, signImmD);
    
    // 计算branch跳转pc
    sl2 sl2_immed(signImmD, signImmD_sl2D);
    assign pc_branchD = pc_plus4D + signImmD_sl2D;

    // srca和srcb的数据前推
    mux2to1 #(32) mux_cmp_src1(srcaD, ALUOutM, forwardAD, srca2D);
    mux2to1 #(32) mux_cmp_src2(srcbD, ALUOutM, forwardBD, srcb2D);
    
     // 比较是否满足branch跳转条件
    eqcmp comp(
        .a(srca2D),
        .b(srcb2D),
        .op(opD),
        .rt(rtD),
        .y(euqalD)
    );
    
    assign pcSrcD = branchD & euqalD;
    
    // j, jal跳转pc
    mux2to1 #(32) mux_jump_addr({pc_plus4D[31:28],instrD[25:0],2'b00}, srca2D, jrD, pc_jumpD);
    
    // invalid从controller传出
    assign syscallD = (opD == `EXE_ZERO_OP && functD == `EXE_SYSCALL);
    assign breakD   = (opD == `EXE_ZERO_OP && functD == `EXE_BREAK);
    assign eretD    = (instrD == `EXE_ERET);


    // -------------------------Exe-------------------------
    //ID-Exe
    flopenrc #(32) r1E(clk,rst,~stallE,flushE,pcD,pcE);
    flopenrc #(32) r2E(clk,rst,~stallE,flushE,pc_plus8D,pc_plus8E);
    flopenrc #(6)  r3E(clk,rst,~stallE,flushE,opD, opE);
    flopenrc #(5)  r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5)  r7E(clk,rst,~stallE,flushE,saD,saE);
    flopenrc #(32) r8E(clk,rst,~stallE,flushE,instrD,instrE);
    flopenrc #(32) r9E(clk,rst,~stallE,flushE,srcaD,srcaE);  
    flopenrc #(32) r10E(clk,rst,~stallE,flushE,srcbD,srcbE); 
    flopenrc #(32) r11E(clk,rst,~stallE,flushE,signImmD,signImmE);

    flopenrc #(24) r12E(clk,rst,~stallE,flushE,{memToRegD,memReadD,memWriteD,aluSrcD,regDstD,regWriteD,ALUControlD,hilo_weD,isDivD,cp0_weD},
                                               {memToRegE,memReadE,memWriteE,aluSrcE,regDstE,regWriteE,ALUControlE,hilo_weE,isDivE,cp0_weE});
    flopenrc #(3)  r13E(clk,rst,~stallE,flushE,{jalD,jrD,balD},{jalE,jrE,balE});
    flopenrc #(1)  r14E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);

    // 异常，adel, sys, bp, eret, ri, ov, ades
    flopenrc #(8)  r15E(clk,rst,~stallE,flushE,{exceptD[7],syscallD,breakD,eretD,invalidD,exceptD[2:0]},exceptE);
    
    // srcaE和srcbE数据前推
    mux3to1 #(32) mux_alu_src1(srcaE,resultW,ALUOutM,forwardAE,srca2E);  
    mux3to1 #(32) mux_alu_src2(srcbE,resultW,ALUOutM,forwardBE,srcb2E);  
    
    // srcb是否取自立即数
    mux2to1 #(32) mux_alu_src3(srcb2E, signImmE, aluSrcE,srcb3E);
    
    // hi、lo数据前推
    mux3to1 #(64) mux_alu_hilo(hilo_oW, hilo_iW, hilo_iM, forwardHiloE, hilo_for_aluE);  
    
    // cp0数据前推-----------------------------------------------------
    mux3to1 #(32) mux_alu_cp0(cp0dataE, ALUOutW, ALUOutM, forwardcp0E, cp0data2E);  // choose the right cp0 data for ALU

    ALU alu(
        .a(srca2E),
        .b(srcb3E),
        .sa(saE),
        .op(ALUControlE),        
        .hilo(hilo_for_aluE),  
        .cp0data(cp0data2E), 
        .res(alu_resultE),
        .overFlow(overFlow)
    );
    
    divider_primary divider(
        .clk(~clk), 
        .rst(rst | flushE),
        .ALUControl_i(ALUControlE),
	    .opdata1_i(srca2E),
	    .opdata2_i(srcb3E),
	    .annul_i(1'b0),    
	    .result_o(div_resultE),
        .stall_div(stall_divE)
    );

    // 写回寄存器地址，rd、rt
    mux2to1 #(5) wrmux1(rtE,rdE,regDstE,writeRegE);      
        
    // 选择出ALUresult
    mux2to1 #(64) wrmux2(alu_resultE, div_resultE, isDivE, ALUOutE);              
    
    // jal、bal写回pcplus8
    mux2to1 #(32) wrmux3(ALUOutE[31:0], pc_plus8E, jalE | jrE | balE, ALUOut2E);    
    
    // jal、bal类指令需要写$31  
    mux2to1 #(5) wrmux4(writeRegE, 5'b11111, jalE | balE | (jrE & (writeRegE==5'b0)), writeReg2E);                
    

    // -------------------------Mem-------------------------
    // Exe-Mem
    flopenrc #(32) r1M(clk,rst,~stallM,flushM,pcE,pcM);
    flopenrc #(32) r2M(clk,rst,~stallM,flushM,instrE,instrM);
    flopenrc #(5)  r3M(clk,rst,~stallM,flushM,rdE,rdM);
    flopenrc #(6)  r4M(clk,rst,~stallM,flushM,opE,opM);
    flopenrc #(32) r5M(clk,rst,~stallM,flushM,srcb2E,writeDataM);      
    flopenrc #(32) r6M(clk,rst,~stallM,flushM,ALUOut2E,ALUOutM);
    flopenrc #(64) r7M(clk,rst,~stallM,flushM,ALUOutE,hilo_iM);  
    flopenrc #(5)  r8M(clk,rst,~stallM,flushM,writeReg2E,writeRegM); 
    
    flopenrc #(8) r9M(clk,rst,~stallM,flushM,{memToRegE,memReadE,memWriteE,regWriteE,hilo_weE,cp0_weE},
                                             {memToRegM,memReadM,memWriteM,regWriteM,hilo_weM,cp0_weM});

    flopenrc #(1) r10M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
   
    // 异常，adel, sys, bp, eret, ri, ov, ades   
    flopenrc #(8)  r11M(clk,rst,~stallM,flushM,{exceptE[7:3],overFlow,exceptE[1:0]},exceptM);
    
    
    // exception
    exception exp(rst, exceptM, adelM, adesM, status_o, cause_o, epc_o, excepttypeM, newpcM);
    
    
    assign pc_trapM = (excepttypeM != 32'b0);
    assign flush_exceptM = (excepttypeM != 32'b0);
    assign mem_enM = (memReadM | memWriteM) & ~flush_exceptM;     

    cp0_reg cp0(
        .clk(clk),
	    .rst(rst),

	    .we_i(cp0_weW),
	    .waddr_i(rdW),
	    .raddr_i(rdE),
	    .data_i(ALUOutW),

	    .int_i(int),

	    .excepttype_i(excepttypeM),
	    .current_inst_addr_i(pcM),
	    .is_in_delayslot_i(is_in_delayslotM),
	    .bad_addr_i(bad_addrM),

	    .data_o(cp0dataE),
	    .count_o(count_o),
	    .compare_o(compare_o),
	    .status_o(status_o),
	    .cause_o(cause_o),
	    .epc_o(epc_o),
	    .config_o(config_o),
	    .prid_o(prid_o),
	    .badvaddr(badvaddr),
	    .timer_int_o(timer_int_o)
    );

    wire [4:0] writeRegExcept;
    
    // -------------------------WB-------------------------
    flopenrc #(32) r1W(clk,rst,~stallW,flushW,pcM,pcW);
    flopenrc #(5)  r2W(clk,rst,~stallW,flushW,rdM,rdW);
    flopenrc #(32) r3W(clk,rst,~stallW,flushW,instrM,instrW);
    flopenrc #(32) r4W(clk,rst,~stallW,flushW,readDataM,readDataW);
    flopenrc #(32) r5W(clk,rst,~stallW,flushW,ALUOutM,ALUOutW);
    flopenrc #(5)  r6W(clk,rst,~stallW,flushW,writeRegM,writeRegExcept);
    flopenrc #(64) r7W(clk,rst,~stallW,flushW,hilo_iM,hilo_iW);
    flopenrc #(4) r8W(clk,rst,~stallW,flushW,{memToRegM,regWriteM,hilo_weM,cp0_weM},
                                             {memToRegW,regWriteW,hilo_weW,cp0_weW});

    assign writeRegW = (pcW == 32'hbfc00380) ? 5'h1a : writeRegExcept;
    
    hilo_reg hilo_reg(
        .clk(clk),
        .rst(rst),
        .we(hilo_weW),
        .hi(hilo_iW[63:32]),
        .lo(hilo_iW[31:0]),
        .hi_o(hilo_oW[63:32]),
        .lo_o(hilo_oW[31:0])
    );
    
    //选择写回寄存器的数据来源, aluOut、Mem读出
    mux2to1 #(32) mux_res(ALUOutW, readDataW, memToRegW, resultW); 

endmodule