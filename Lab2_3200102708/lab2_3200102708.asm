.orig x3000
;
; say "Enter a name: " at the beginning
;
SAYHELLO    LEA R0, HELLO
            TRAP x22
;
; store the input name
;
INPUT       LEA R1, SAVENAME
            LD R2, N_ENTER; R2 stores the negative of ASCII ENTER
NEXTINPUT   TRAP X20
            TRAP x21
            ADD R3, R0, R2
            BRz ENDINPUT
            STR R0, R1, #0
            ADD R1, R1, #1
            BRnzp NEXTINPUT
ENDINPUT    AND R0, R0, #0
            STR R0, R1, #0; x0000 represents the end of a string

;
; find address book, respectively check first and last name
; MAIN PART OF LAB2
;
FIND        AND R1, R1, #0
            ST R1, FLAG; initialize FLAG 0. everytime you find a match, FLAG+1
            LD R2, HEAD
            LDR R2, R2, #0
            BRnzp CHECK_FN
            
NEXTNODE    LDR R2, R2, #0
            BRz ENDNODE
; 
; check if first name is the same
;
CHECK_FN    LEA R1, SAVENAME; R1 holds the ptr to SAVENAME
            LDR R3, R2, #2; R3 holds the ptr to first name R2 refer to
LOOP_FN     LDR R4, R1, #0
            ADD R1, R1, #1; prepare for next letter
            LDR R5, R3, #0
            BRz SAME_FN; reach the end of name, tell whether they`re same or not
            ADD R3, R3, #1; preprare for next letter
            NOT R5, R5
            ADD R5, R5, #1
            ADD R5, R4, R5
            BRnp CHECK_LN; not same
            BRz LOOP_FN
SAME_FN     ADD R4, R4, #0; tell whether str end at the same time
            BRz OUTPUT; same
            BRnp CHECK_LN; not same
;
; check if last name is the same   
;
CHECK_LN    LEA R1, SAVENAME; R1 holds the ptr to SAVENAME
            LDR R3, R2, #3; R3 holds the ptr to last name R2 refer to
LOOP_LN     LDR R4, R1, #0
            ADD R1, R1, #1; prepare for next letter
            LDR R5, R3, #0
            BRz SAME_LN; end of name, tell whether they`re same or not
            ADD R3, R3, #1; preprare for next letter
            NOT R5, R5
            ADD R5, R5, #1
            ADD R5, R4, R5
            BRnp NEXTNODE; not same
            BRz LOOP_LN
SAME_LN     ADD R4, R4, #0; tell whether str end at the same time
            BRz OUTPUT; same
            BRnp NEXTNODE; not same
;
; output info R2 refer to
;
OUTPUT      LD R1, FLAG
            ADD R1, R1, #1
            ST R1, FLAG; everytime you find a match, flag+1
            
            LDR R0, R2, #2
            TRAP x22; output first name
            LD R0, SPACE
            TRAP x21; separate by space
            
            LDR R0, R2, #3
            TRAP x22; output last name
            LD R0, SPACE
            TRAP x21; separate by space
            
            LDR R0, R2, #1
            TRAP x22; output room number
            LD R0, ENTER
            TRAP x21; end of output, separate by enter
            BRnzp NEXTNODE
;
; end of this program, if not found any match, output hint
;
ENDNODE     LD R1, FLAG; FLAG equals to 0 means there`s no such name you find
            BRnp ENDFIND
            LEA R0, NOTFOUND
            TRAP x22
            
ENDFIND     TRAP x25

SAVENAME    .blkw #16; input is less than 16
N_ENTER     .fill xFFF6; negative of ASCII ENTER or we say LF 0x0A
HELLO       .stringz "Enter a name: "
HEAD        .fill x4000
NOTFOUND    .stringz "Not found"
ENTER       .fill x000A; ASCII ENTER or we say LF 0x0A
SPACE       .fill x0020; ASCII SPACE x0020
FLAG        .blkw #1

.end