.global _start
_start:

mov r0, 45    @r0 = 45
mov r1, 27    @r1 = 27

gcd:
CMP r0,r1         @if r0 > r1
SUBGT  r0,r0,r1   @r0 = r0 - r1
SUBLT  r1,r1,r0   @else, r1 = r1 - r0
BNE    gcd        @loop back through if the #s aren't equal
                  @end program if #s are equal
mov r7, #1        @procedure for ending the program...
swi 0