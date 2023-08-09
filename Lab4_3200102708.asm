.ORIG x3000
            LD  R6, USP_BOTTOM
            ADD R6, R6, #-13
            ADD R6, R6, #-13; user stack
            AND R1, R1, #0
            AND R0, R0, #0
            ADD R0, R0, #13
            ADD R0, R0, #12; initialize R0 as 25, clean1 counter
CLEAN1_LOOP ADD R5, R0, R6; clear stack
            STR R1, R5, #0
            ADD R0, R0, #-1
            BRzp CLEAN1_LOOP

INPUT_LOOP  GETC
            OUT
            BRnzp INPUT_LOOP
; what kind of input
    
            HALT
USP_BOTTOM .FILL xFE00
.END