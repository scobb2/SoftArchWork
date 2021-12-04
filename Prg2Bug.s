.global start
start:

mov R0, #0     @ R0 = 0
mov R1, #1     @ R1 = 1

loopTop
cmp R1, #6     @ while (R1 != 6)
beq allDone

add R0, R0, R1 @ R0 = R0 + R1

add R1, R1, #0 @ R1 = R1 + 1

b loopTop      @ back to while header 

allDone:
mov R7, 1
SWI 0
