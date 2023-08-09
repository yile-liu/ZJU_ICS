.ORIG x3000
            LDI R0, ROW
            LDI R1, COLUMN
            JSR MUL; multiply non-negative R0 R1 and store the result in R2
            LD  R0, MAP_HEAD
            ADD R0, R0, #-1
            ST  R0, START; initialize start point as MAP_HEAD-1
            ADD R0, R0, R2
            ST  R0, MAP_TAIL; addr of the end of map
            AND R2, R2, #0
            ADD R2, R2, #1
            ST  R2, RESULT; initialize RESULT as 1

NEWSTART    LD  R6, USP_BOTTOM; reset R6 as USP
            LD  R0, START
            ADD R0, R0, #1
            LD  R1, MAP_TAIL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1
            BRp ENDSKI; have tried all place to start
            ST  R0, START; update current start point
            
            ADD R6, R6, #-4
            AND R7, R7, #0
            STR R7, R6, #3; PUSH PC, but not avaliable for the first step
            STR R0, R6, #2; PUSH start point addr
            AND R1, R1, #0
            STR R1, R6, #1; PUSH breadcrumb, unavaliable for the first step
            ADD R2, R1, #1
            STR R2, R6, #0; PUSH path length, initialize as 1
            BRnzp SKI_N
            
SKI_LOOP    ADD R6, R6, #-4
            STR R7, R6, #3; PUSH PC for previous step
            STR R0, R6, #2; PUSH addr now
            STR R1, R6, #1; PUSH breadcrumb
            STR R2, R6, #0; PUSH path length now
            
            LD  R3, RESULT
            NOT R3, R3
            ADD R3, R3, #1
            ADD R3, R3, R2
            BRnz SKI_N; path length now is no bigger than the biggest result before
            ST  R2, RESULT; wo get a new longest path, update RESULT
            
; try to ski toward north
SKI_N       LD  R0, MASK_S
            LDR R1, R6, #1
            AND R0, R0, R1
            BRp SKI_E; came here form north in the last step, don`t go back
            LDR R0, R6, #2; addr now
            LDI R1, COLUMN
            NOT R1, R1
            ADD R1, R1, #1
            ADD R0, R0, R1
            LD  R1, MAP_HEAD
            NOT R1, R1
            ADD R1, R1, #1
            ADD R0, R0, R1
            BRn SKI_E; cannot go north, out of map
            LDR R0, R6, #2; addr now
            LDI R1, COLUMN
            NOT R1, R1
            ADD R1, R1, #1
            ADD R2, R0, R1; addr of north
            LDR R0, R0, #0; altitude here
            LDR R2, R2, #0; altitude of north
            NOT R2, R2
            ADD R2, R2, #1
            ADD R2, R2, R0
            BRnz SKI_E; cannot go north for it`s higher
            LDR R0, R6, #2; addr now
            LDI R1, COLUMN
            NOT R1, R1
            ADD R1, R1, #1
            ADD R0, R0, R1; new addr
            LD  R1, MASK_N; breadcrumb
            LDR R2, R6, #0
            ADD R2, R2, #1; new path length
            JSR SKI_LOOP; north is avaliable
           
; try to ski toward east 
SKI_E       LD  R0, MASK_W
            LDR R1, R6, #1
            AND R0, R0, R1
            BRp SKI_S; came here form east in the last step, don`t go back
            LDR R0, R6, #2; addr now
            ADD R0, R0, #1
            LD  R1, MAP_HEAD
            NOT R1, R1
            ADD R1, R1, #1
            ADD R0, R0, R1
            LDI R2, COLUMN
            NOT R2, R2
            ADD R2, R2, #1
E_LOOP      ADD R0, R0, R2
            BRp E_LOOP
            BRz SKI_S; cannot go east, out of map
            LDR R0, R6, #2; addr now
            ADD R2, R0, #1; addr of east
            LDR R0, R0, #0; altitude here
            LDR R2, R2, #0; altitude of east
            NOT R2, R2
            ADD R2, R2, #1
            ADD R2, R2, R0
            BRnz SKI_S; cannot go east for it`s higher
            LDR R0, R6, #2; addr now
            ADD R0, R0, #1; new addr
            LD  R1, MASK_E; breadcrumb
            LDR R2, R6, #0
            ADD R2, R2, #1; new path length
            JSR SKI_LOOP; east is avaliable

; try to ski toward south
SKI_S       LD  R0, MASK_N
            LDR R1, R6, #1
            AND R0, R0, R1
            BRp SKI_W; came here form south in the last step, don`t go back
            LDR R0, R6, #2; addr now
            LDI R1, COLUMN
            ADD R0, R0, R1
            LD  R1, MAP_TAIL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R0, R0, R1
            BRp SKI_W; cannot go south, out of map
            LDR R0, R6, #2; addr now
            LDI R1, COLUMN
            ADD R2, R0, R1; addr of south
            LDR R0, R0, #0; altitude here
            LDR R2, R2, #0; altitude of south
            NOT R2, R2
            ADD R2, R2, #1
            ADD R2, R2, R0
            BRnz SKI_W; cannot go south for it`s higher
            LDR R0, R6, #2; addr now
            LDI R1, COLUMN
            ADD R0, R0, R1; new addr
            LD  R1, MASK_S; breadcrumb
            LDR R2, R6, #0
            ADD R2, R2, #1; new path length
            JSR SKI_LOOP; south is avaliable

; try to ski toward west
SKI_W       LD  R0, MASK_E
            LDR R1, R6, #1
            AND R0, R0, R1
            BRp RESTORE; came here form west in the last step, don`t go back
            LDR R0, R6, #2; addr now
            LD  R1, MAP_HEAD
            NOT R1, R1
            ADD R1, R1, #1
            ADD R0, R0, R1
            BRz RESTORE; cannot go west, out of map
            LDI R2, COLUMN
            NOT R2, R2
            ADD R2, R2, #1
W_LOOP      ADD R0, R0, R2
            BRp W_LOOP
            BRz RESTORE; cannot go west, out of map
            LDR R0, R6, #2; addr now
            ADD R2, R0, #-1; addr of west
            LDR R0, R0, #0; altitude here
            LDR R2, R2, #0; altitude of west
            NOT R2, R2
            ADD R2, R2, #1
            ADD R2, R2, R0
            BRnz RESTORE; cannot go west for it`s higher
            LDR R0, R6, #2; addr now
            ADD R0, R0, #-1; new addr
            LD  R1, MASK_W; breadcrumb
            LDR R2, R6, #0
            ADD R2, R2, #1; new path length
            JSR SKI_LOOP; north is avaliable

RESTORE     LDR R7, R6, #3
            BRz NEWSTART
            ADD R6, R6, #4
            RET
            
MUL         AND R2, R2, #0
            ADD R1, R1, #0
            BRz MUL_END
MUL_LOOP    ADD R2, R2, R0
            ADD R1, R1, #-1
            BRz MUL_END
            BRnzp MUL_LOOP
MUL_END     RET

ENDSKI      LD  R2, RESULT
            HALT

RESULT .BLKW #1; store the result to save register
START .BLKW #1
USP_BOTTOM .FILL xFE00
MASK_N .FILL x0008
MASK_E .FILL x0004
MASK_S .FILL x0002
MASK_w .FILL x0001; for breadcrumb
ROW .FILL x4000
COLUMN .FILL x4001
MAP_HEAD .FILL x4002
MAP_TAIL .BLKW #1; addr of the end of map
.END

.ORIG x4000
 .FILL #5 ; N
 .FILL #5 ; M

 .FILL #23
 .FILL #29
 .FILL #31
 .FILL #37
 .FILL #41
 .FILL #19
 .FILL #73
 .FILL #79
 .FILL #83
 .FILL #43
 .FILL #17
 .FILL #71
 .FILL #97
 .FILL #89
 .FILL #47
 .FILL #13
 .FILL #67
 .FILL #61
 .FILL #59
 .FILL #53
 .FILL #11
 .FILL #7
 .FILL #5
 .FILL #3
 .FILL #2
 .END