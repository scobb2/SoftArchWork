.global _start
_start:

mov R0, #0     @ R0 = 0
mov R1, #5     @ R1 = 5

loopTop:
cmp R1, #0     @ while (R1 > 0)
ble allDone

add R0, R0, R1 @ R0 = R0 + R1 

sub R1, R1, #1 @ R1 = R1 + 1

b loopTop      @ back to while header 

allDone:
mov R7, #1
swi 0
