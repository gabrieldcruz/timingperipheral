; File: Lab8Game.asm
; Author: Conner Thompson
; Course: ECE 2031, L12
; Purpose: Runs a game with the player goal to knock out
;          the largest hex digit until the number is 0000

ORG 0
    LOADI  0
    STORE  Score
    OUT    Hex1          ; Sets score = 0
    OUT    Hex0          ; 0000 until a round starts
    STORE  RandomNum
    OUT    Timer         ; Begins 10 second clock

; Waits for all switches to be down before initiating
WaitDown:
    CALL   CheckTime
    IN     Switches
    OUT    LEDs
    JNZ    WaitDown

; Counts and waits for exactly SW9 to be initiated, otherwise reverts to WaitDown
Generate:
    CALL   CheckTime
    IN     Switches
    OUT    LEDs
    JZERO  IncRandom
    SUB    Bit9
    JZERO  StartRound
    JUMP   WaitDown
    
IncRandom:
    LOAD   RandomNum
    ADDI   1
    STORE  RandomNum
    JUMP   Generate

StartRound:
    LOAD   RandomNum
    STORE  Num
    OUT    Hex0

Play:
    CALL   CheckTime
    IN     Switches
    OUT    LEDs
    STORE  SwValue
    LOAD   Num
    JZERO  WaitDown
    CALL   FindMax
    LOAD   Num
    STORE  DigWork
    LOADI  1
    STORE  SwBit
    LOADI  &H000F
    STORE  PosMask
    LOADI  4
    STORE  PosCount

Scan:
    LOAD   SwValue
    AND    SwBit
    JZERO  NextPos
    LOAD   DigWork
    AND    FMask
    JZERO  NextPos
    SUB    Max
    JZERO  Correct
    JUMP   GameOver

NextPos:
    LOAD   DigWork
    SHIFT  -4
    STORE  DigWork
    LOAD   SwBit
    SHIFT  1
    STORE  SwBit
    LOAD   PosMask
    SHIFT  4
    STORE  PosMask
    LOAD   PosCount
    ADDI   -1
    STORE  PosCount
    JNZ    Scan
    JUMP   Play

; Checks if player correctly knocked out highest digit and adds to score
Correct:
    LOAD   Num
    AND    PosMask       
    STORE  Temp
    LOAD   Num
    SUB    Temp
    STORE  Num
    OUT    Hex0
    LOAD   Score
    ADDI   1
    STORE  Score
    OUT    Hex1
    JUMP   Play

; Jumps to gameover if less than Max
GameOver:
    IN     Switches
    OUT    LEDs
    JUMP   GameOver

; Jumps to GameOver once the timer clocks in at 10 seconds
CheckTime:
    IN     Timer
    ADDI   -100
    JNEG   CT_OK
    JUMP   GameOver
CT_OK:
    RETURN

; Max = largest hex digit of Num
FindMax:
    LOAD   Num
    STORE  FM_Work
    STORE  HN_A
    SHIFT  -4
    STORE  FM_Work
    STORE  HN_B
    CALL   HigherNibble
    STORE  Max
    LOAD   FM_Work
    SHIFT  -4
    STORE  FM_Work
    STORE  HN_B
    LOAD   Max
    STORE  HN_A
    CALL   HigherNibble
    STORE  Max
    LOAD   FM_Work
    SHIFT  -4
    STORE  HN_B
    LOAD   Max
    STORE  HN_A
    CALL   HigherNibble
    STORE  Max
    RETURN
FM_Work:   DW 0

; HigherNibble Implementation from the prelab
HigherNibble:
    LOAD   HN_A
    AND    HN_Mask
    STORE  HN_A
    LOAD   HN_B
    AND    HN_Mask
    STORE  HN_B
    SUB    HN_A
    JPOS   HN_BigB
    LOAD   HN_A
    RETURN
HN_BigB:
    LOAD   HN_B
    RETURN
HN_A:      DW 0
HN_B:      DW 0
HN_Mask:   DW &H000F

; Program Variables
Score:     DW 0
RandomNum: DW 0
Num:       DW 0
Max:       DW 0
SwValue:   DW 0
DigWork:   DW 0
SwBit:     DW 0
PosMask:   DW 0
PosCount:  DW 0
Temp:      DW 0

; Program Constants
Bit9:      DW &H0200
FMask:     DW &H000F

; Used Addresses
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005