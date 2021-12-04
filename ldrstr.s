.text

L1:
.word 24

L2:
.word 123

ldr R0, L1

ldr R1, =L2

ldr R2, [R0, #4]

ldr R3, [R1, #-4]

str R3, [R1]
str R3, L3



.data

L3:
.word 0