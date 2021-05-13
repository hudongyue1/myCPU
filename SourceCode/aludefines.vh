//ALU OP
`define ALU_AND   	8'b00100100
`define ALU_OR    	8'b00100101
`define ALU_XOR  	8'b00100110
`define ALU_NOR  	8'b00100111
`define ALU_ANDI  	8'b01011001
`define ALU_ORI  	8'b01011010
`define ALU_XORI  	8'b01011011
`define ALU_LUI  	8'b01011100   
       
`define ALU_SLL  	8'b01111100
`define ALU_SLLV  	8'b00000100
`define ALU_SRL  	8'b00000010
`define ALU_SRLV  	8'b00000110
`define ALU_SRA  	8'b00000011
`define ALU_SRAV  	8'b00000111
      
`define ALU_MFHI  8'b00010000
`define ALU_MTHI  8'b00010001
`define ALU_MFLO  8'b00010010
`define ALU_MTLO  8'b00010011
       
`define ALU_SLT  8'b00101010
`define ALU_SLTU  8'b00101011
`define ALU_SLTI  8'b01010111
`define ALU_SLTIU  8'b01011000   
`define ALU_ADD  8'b00100000
`define ALU_ADDU  8'b00100001
`define ALU_SUB  8'b00100010
`define ALU_SUBU  8'b00100011
`define ALU_ADDI  8'b01010101
`define ALU_ADDIU  8'b01010110

`define ALU_MULT  8'b00011000
`define ALU_MULTU  8'b00011001
    
`define ALU_DIV  8'b00011010
`define ALU_DIVU  8'b00011011
      
`define ALU_J  8'b01001111
`define ALU_JAL  8'b01010000
`define ALU_JALR  8'b00001001
`define ALU_JR  8'b00001000
`define ALU_BEQ  8'b01010001
`define ALU_BGEZ  8'b01000001
`define ALU_BGEZAL  8'b01001011
`define ALU_BGTZ  8'b01010100
`define ALU_BLEZ  8'b01010011
`define ALU_BLTZ  8'b01000000
`define ALU_BLTZAL  8'b01001010
`define ALU_BNE  8'b01010010
      
`define ALU_LB  8'b11100000
`define ALU_LBU  8'b11100100
`define ALU_LH  8'b11100001
`define ALU_LHU  8'b11100101
`define ALU_LL  8'b11110000
`define ALU_LW  8'b11100011
`define ALU_LWL  8'b11100010
`define ALU_LWR  8'b11100110
`define ALU_PREF  8'b11110011
`define ALU_SB  8'b11101000
`define ALU_SC  8'b11111000
`define ALU_SH  8'b11101001
`define ALU_SW  8'b11101011
`define ALU_SWL  8'b11101010
`define ALU_SWR  8'b11101110
`define ALU_SYNC  8'b00001111
       
`define ALU_MFC0 8'b01011101
`define ALU_MTC0 8'b01100000
      
`define ALU_SYSCALL 8'b00001100
`define ALU_BREAK 8'b00001011
       
`define ALU_TEQ 8'b00110100
`define ALU_TEQI 8'b01001000
`define ALU_TGE 8'b00110000
`define ALU_TGEI 8'b01000100
`define ALU_TGEIU 8'b01000101
`define ALU_TGEU 8'b00110001
`define ALU_TLT 8'b00110010
`define ALU_TLTI 8'b01000110
`define ALU_TLTIU 8'b01000111
`define ALU_TLTU 8'b00110011
`define ALU_TNE 8'b00110110
`define ALU_TNEI 8'b01001001
     
`define ALU_ERET 8'b01101011
      
`define ALU_NOP    8'b00000000
`define ALU_DEFAULT 8'b00000000
