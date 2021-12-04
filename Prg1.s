.global _start
_start:
mov R0, #42 
mov R7, #1
SWI 0       @ Return 42 as exit code
