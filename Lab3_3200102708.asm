; SYSTEM BOOTING CODE WITH INTERRUPTION ENABLE
.orig x0200
        LD  R6, OS_SP
        
        LD  R0, USER_PSR; push PSR
        ADD R6, R6, #-1
        STR R0, R6, #0
        
        LD  R0, USER_PC; push PC
        ADD R6, R6, #-1
        STR R0, R6, #0
        
        LD  R0, IE; KBSR interruption enable
        STI  R0, KBSR
        
        LD  R0, INT_ADD
        STI  R0, KBINT
        RTI
        
OS_SP    .FILL x3000
USER_PSR .FILL x8002
USER_PC  .FILL x3000
KBSR     .FILL xFE00
IE       .FILL x4000; [14]=1, interruption enable
KBINT    .FILL x0180
INT_ADD  .FILL x0800; address of my keyboard interrupt service

 .END
 
; KEYBOARD INTERRUPT SEVICE
.orig x0800
        LDI R0, KBDR
        
        LD  R2, NASCII_NL
        ADD R2, R0, R2
        BRz INPUT_NL
        
        LD  R2, NASCII_0
        ADD R2, R0, R2
        BRn INPUT_ELSE
        LD  R2, NASCII_9
        ADD R2, R0, R2
        BRp INPUT_ELSE
        
INPUT_NUM   ADD R5, R0, #0
            BRnzp END
            
INPUT_NL    LD  R2, NASCII_0
            ADD R2, R5, R2
            BRz END
            ADD R5, R5, #-1
            BRnzp END

INPUT_ELSE  LD  R4, _NL_CNT; reset R4  
            ST  R7, _DELAY_R7; another JSR will be used in INPUT_ELSE
            ADD R3, R0, #0; temporary holds R0
            LD  R0, ASCII_NL; output enter
            OUT
            ADD R0, R3, #0
            
ELSE_LOOP   OUT
            JSR _DELAY
            ADD R4, R4, #-1
            BRnz ELSE_END
            BRp ELSE_LOOP

_DELAY       ST  R1, _DELAY_R1
             LD  R1, _DELAY_COUNT
_DELAY_LOOP  ADD R1, R1, #-1
             BRnp _DELAY_LOOP
             LD  R1, _DELAY_R1
             RET

ELSE_END     LD  R7, _DELAY_R7
END          AND R4, R4, #0 
             RTI
            
_DELAY_COUNT .FILL #256
_DELAY_R1 .BLKW #1
_DELAY_R7 .BLKW #1
_NL_CNT  .FILL #40
KBDR     .FILL xFE02
NASCII_0 .FILL xFFD0; negative x0030, ASCII of 0
NASCII_9 .FILL xFFC7; negative x0039, ASCII of 9
NASCII_NL .FILL xFFF6; negative x000A, ASCII of newline or called enter
ASCII_NL .FILL x000A
.END

; USER PROGRAM
.orig x3000
            LD  R5, TASK_CNT; task counter, initialize as x37, ASCII OF 7
            LD  R4, NL_CNT; new line counter, initialize as 40
        
OUTPUT_LOOP ADD R0, R5, #0
            OUT
            ADD R4, R4, #-1
            JSR DELAY
            ADD R4, R4, #0
            BRz OUTPUT_NL
            BRnp OUTPUT_LOOP
            
OUTPUT_NL   LD  R0, NEWLINE
            OUT
            LD  R4, NL_CNT; reset new line counter
            BRnzp OUTPUT_LOOP

DELAY       ST  R1, DELAY_R1
            LD  R1, DELAY_COUNT
DELAY_LOOP  ADD R1, R1, #-1
            BRnp DELAY_LOOP
            LD  R1, DELAY_R1
            RET
            
DELAY_COUNT .FILL #256
DELAY_R1 .BLKW #1
NEWLINE .FILL x000A; ASCII of new line
TASK_CNT .FILL x0037; ASCII of 7
NL_CNT .FILL #40

.end