	.arch armv6
	.file	"Prog5.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Found %d primes:\000"
	.align	2
.LC1:
	.ascii	" %d\000"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
	push {fp, lr}								@ creates the main stack frame
	add	fp, sp, #4								@ sets fp = 4 bytes below sp (creating room for the link register and storing old fp at the base of this frame)
	sub	sp, sp, #56 							@ creates space for 14 words to be filled with local variables/parameters (10 for the array, 4 for other variables)
	mov	r3, #320								@ 
	str	r3, [sp, #40]							@ 'numsToTest' = 320 and is stored at the offset 40 below sp
	mov	r3, #0									@ 
	str	r3, [fp, #-8]							@ 'totalPrimes' = 0 and is stored at the offset 8 above fp
	str	r3, [fp, #-16]							@ 'idx' = 0 and is stored at the offset 16 above fp
	b	.L2										@ branches to L2, skips over L3
.L3:
	ldr	r3, [fp, #-16]							@ loads 'totalPrimes' into r3
	mov	r3, r3, asl #2		@ BUG asl #2		@ multiplies r3 ('idx') by 4 to get the offset in bytes of unique primeSet array value
	sub	r2, fp, #4								@ subtracts just 4 bytes from fp leaving the result in r2 (to jump over the lr)
	add	r3, r2, r3								@ adds in the computed offset from r3 ('idx' * 4)
	mov	r2, #0									@ 
	ldr	r2, [r3, #-56]							@ stores a 0 in the primeSet array value (will loop through the array, so every element is initialized to 0)
	ldr	r3, [fp, #-16]							@ \
	add	r3, r3, #1								@  increments 'idx' by one
	str	r3, [fp, #-16]							@ /
.L2:
	ldr	r3, [fp, #-16]							@ loads 'idx' into r3
	cmp	r3, #10									@ compares value of 'idx' and 10
	blt	.L3 									@ if 'idx' < 10, branch to L3
	mov	r2, #2				@ BUG r2, #2		@ if 'idx' = 10... 
	str	r2, [fp, #-12]							@ stores r2 12 bytes above the fp ('toTest' = 2)
	b	.L4 									@ branch to L4
.L6:
	ldr	r0, [fp, #-12]							@ loads 'toTest' into r0
	sub	r1, fp, #60								@ r1 = fp - 60, r1 = start of primeSet array
	bl	checkNum 								@ branches to checkNum, passing in 'toTest' and primeSet array. stores current location in lr to return to after checkNum
	cmp	r0, #0									@ compares the result of checkNum (r0) with 0
	beq	.L5 									@ if r0 = 0, (checkNum returned false)... branch to L5
	ldr	r0, [fp, #-8]							@ \ if r0 != 0, (checkNum returned true)... load 'totalPrimes' into r0
	add	r0, r0, #1								@  increments 'totalPrimes' by one
	str	r0, [fp, #-8]							@ /
.L5:
	ldr	r0, [fp, #-12]							@ \
	add	r0, r0, #1								@  increments 'toTest' by one
	str	r0, [fp, #-12]							@ /
.L4:
	ldr	r2, [fp, #-12]							@ loads 'toTest' into r2
	ldr	r3, [fp, #-20]							@ loads 'numsToTest' into r3
	cmp	r2, r3									@ compares 'toTest' and 'numsToTest'
	blt	.L6 									@ if 'toTest' < 'numsToTest' ... branch to L6
	ldr	r0, .L10								@ else... these next 3 lines implement the printf call
	ldr	r1, [fp, #-8]							@ loads 'checkNum' into r1
	bl	printf									@ branches to printf and stores current location in lr to return to after print function
	mov	r3, #0									@ 
	str	r3, [fp, #-12]							@ sets 'toTest' = 0
	b	.L7										@ branches to L7
.L9:
	ldr	r3, [fp, #-12]							@ start if-statement test within the 3rd for loop of main... loads 'toTest' into r3
	mov	r3, r3, lsr #5							@ r3 = 'toTest' / 'bitsPerInt' (bitsPerInt is 32, or 2^5, so a right shift of 5 [/2^5] works)
	mov	r3, r3, asl #2							@ r3 = (toTest/bitsPerInt) * size of an int (size of an int is 4 bytes, shift left by 2 [*2^2] works)
	add	r3, fp, r3								@ r3 = array offset + fp (note: not fp + 4, still need to account for lr, which is why next line is 60, not 56)
	ldr	r2, [r3, #-60]							@ loads primeSet[toTest/bitsPerInt] into r2
	ldr	r3, [fp, #-12]							@ loads 'toTest' into r3
	and	r3, r3, #31								@ r3 = toTest % bitsPerInt
	mov	r3, r2, lsr r3							@ r3 = primeSet[toTest/bitsPerInt] >> toTest % bitsPerInt
	and	r3, r3, #1								@ r3 = primeSet[toTest/bitsPerInt] >> toTest % bitsPerInt & 01
	cmp	r3, #0									@ check if resultant bit is 0
	beq	.L8										@ branch to L8 if so (around the if-body)
	ldr	r0, .L10+4								@ if resultant bit is not 0, start body of the if-statement... pc-relative load, in this case from the word after .L10, 
												@ which contains the address .LC1, the location of the "%d" string
	ldr	r1, [fp, #-12]		@ BUG fp, #-12 		@ loads 'toTest' into r1 to prepare for the print
	bl	printf									@ prints 'toTest' if it is a prime number, branches back here and resumes instructions after the print
.L8:
	ldr	r3, [fp, #-12]							@ \
	add	r3, r3, #1								@  increments 'toTest' by one
	str	r3, [fp, #-12]							@ /
.L7:		
	ldr	r2, [fp, #-12]							@ loads 'toTest' into r2
	ldr	r3, [fp, #-20]							@ loads 'numsToTest' into r3 
	cmp	r2, r3									@ compares 'toTest' and 'numsToTest'
	blt	.L9										@ if 'toTest' < 'numsToTest'... branch to L9 (start if-statement)
	mov	r0, #12				@ sus, #10?			@ if 'toTest' >= 'numsToTest'... The compiler passes 12, (the ASCII code for '\n') to putchar, via r0, and drops the printf entirely. 
	bl	putchar  								@ Putchar prints one char, its only parameter
	mov	r0, #0				@ BUG r0, #0 		@ sets r0 = ?? to exit
	sub	sp, fp, #4								@ sets sp = 4 bytes above the old fp (keeping the link register and dropping all of the local variables)
	pop {fp, pc}			@ BUG fp, pc		@ pop off fp and lr
.L11:
	.align	2
.L10:
	.word	.LC0
	.word	.LC1
	.size	main, .-main
	.global	__aeabi_uidivmod
	.align	2
	.global	checkNum
	.type	checkNum, %function
checkNum:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}						@ first 5 instructions set up the stack frame... this one moves old fp and sp up a word to start a new frame
	add	fp, sp, #4								@ sets fp = 4 bytes below sp (creating room for the link register and storing old fp at the base of this new frame)
	sub	sp, sp, #16								@ extends the frame by 16 bytes / 4 words to be filled with local variables/parameters
	str	r0, [fp, #-16]							@ stores toTest one word lower than the top of the stack 
	str	r1, [fp, #-20]							@ stores 'primeSet' at the top of the stack
	mov	r3, #2									@ 
	str	r3, [fp, #-8]							@ stores r3 3 words below the ToS (where 'divisor' variable will be held now, 'divisor' = 2 in preparation for the for-loop)
	b	.L13									@ branches to L13
.L15:
	ldr	r3, [fp, #-8]		@ BUG #-8			@ \
	add	r3, r3, #1								@  increments 'toTest' by one
	str	r3, [fp, #-8]		@ BUG #-8	 		@ /
.L13:
	ldr	r2, [fp, #-8]							@ loads 'divisor' into r2
	ldr	r3, [fp, #-16]							@ loads 'toTest' into r3
	cmp	r2, r3									@ compares r2 and r3 ('divisor' and 'toTest')
	bcs	.L14									@ (same as bhs... these are unsigned checks whereas bge is a signed check) if r2 >= r3 ('divisor' >= 'toTest'), branch to .L14
	mov	r0, r3									@ if 'divisor' < 'toTest'... move 'toTest' into r0
	mov	r1, r2									@ move 'divisor' into r1... (r0 and r1 are the parameters passed into the % function call in the next instruction)
	bl	__aeabi_uidivmod 						@ divide r0/r1, return quot in r0, mod in r1   	  (r0/r1 -> r0 and r0%r1 -> r1)
	cmp	r1, #0									@ compares ['toTest' % 'divisor'] and #0
	bne	.L15				@ BUG .L15 			@ if ('toTest' % 'divisor') != 0, branches to .L15 (incrementing 'divisor')
.L14:
	ldr	r2, [fp, #-8]							@ loads 'divisor' into r2.... after the for loop in the C code
	ldr	r3, [fp, #-16]							@ loads 'toTest' into r3
	cmp	r2, r3									@ compares 'divisor' and 'toTest'
	bne	.L16				@ BUG  bne			@ if 'divisor' != 'toTest', branches to .L16 (this branches around the if-statement)
	ldr	r0, [fp, #-16]							@ if 'divisor' == 'toTest'.... load 'toTest' into r0
	ldr	r1, [fp, #-20]							@ loads 'primeSet' into r1 (r0 and r1 will be the parameters passed into setBit function)
	bl	setBit 									@ jumps to setBit and saves the current location in the link register so that we can return here after setBit function
.L16:
	ldr	r2, [fp, #-8]							@ loads 'divisor' into r2
	ldr	r3, [fp, #-16]							@ loads 'toTest' into r3
	cmp	r2, r3									@ compares 'divisor' and 'toTest'
	movne	r3, #0								@ if 'divisor' != 'toTest', r3 = 0 (0 means false)
	moveq	r3, #1								@ if 'divisor' == 'toTest', r3 = 1 (1 means true)
	mov	r0, r3									@ moves r3 into r0 to be passed to the next function (the 0 or 1 computed in movne/moveq lines)
	sub	sp, fp, #4								@ sets sp = 4 bytes above the old fp (keeping the link register and dropping all of the local variables)
										@ sp needed
	ldmfd	sp!, {fp, pc}						@ pop off fp, and lr, with lr going straight into pc to return to main where checkNum was called
	.size	checkNum, .-checkNum
	.align	2			
	.global	setBit
	.type	setBit, %function
setBit:
	str	fp, [sp, #-4]!							@ first 5 instructions set up the stack frame... this one moves old fp and sp up a word to start a new frame
	add	fp, sp, #0								@ sets fp = sp, note: no lr in the setBit frame because setBit does not call any other functions (no need to return back to setBit)
	sub	sp, sp, #12								@ extends the frame by 3 words to be filled with local variables/parameters
	str	r0, [fp, #-8]							@ stores r0 ('prime' variable, was passed in as 'toTest' from checkNum) into the spot 2 words above fp
	str	r1, [fp, #-12]							@ stores r1 (address of primeSet[0], beginning of the array) into the spot 3 words above fp (top of the stack)
	ldr	r3, [fp, #-8]							@ loads 'prime' into r3
	mov	r3, r3, lsr #5							@ divides 'prime' by 32 (by bit shifting with a factor of 2^5) and truncates the remainder
	mov	r3, r3, asl #2							@ multiplies 'prime' by 4 (by bit shifting with a factor of 2^2)
	ldr	r2, [fp, #-12]							@ loads address of 'primeSet[0]' (beginning of the array) into r2
	add	r3, r2, r3								@ adds the byte offset (found by bit shifting above) onto the 'primeSet[0]' array address to reach the desired index
	ldr	r2, [fp, #-8]							@ loads 'prime' variable into r2
	mov	r2, r2, lsr #5							@ divides 'prime' by 32 (by bit shifting right with a factor of 2^5) and truncates the remainder
	mov	r2, r2, asl #2							@ multiplies 'prime' by 4 (by bit shifting left with a factor of 2^2)
	ldr	r1, [fp, #-12]							@ loads address of 'primeSet[0]' (beginning of the array) into r1
	add	r2, r1, r2								@ adds the byte offset (found by bit shifting above) onto the 'primeSet[0]' array address to reach the desired index
	ldr	r2, [r2]								@ dereferences r2... (uses r2 as an address, gets the word at that address, and puts it into r2)
	ldr	r1, [fp, #-8]							@ loads 'prime' variable into r1 (these 5 lines compute this C expression: primeSet[prime/bitsPerInt] | (1 << prime % bitsPerInt))
	and	r1, r1, #31								@ r1 = prime % 32... the operation keeps whatever the bottom 5 bits of r1 were, and zeros out all the rest.
												@ The eliminated bits are all divisible by 32 (32, 64, 128, etc) and the preserved bits are all nondivisible by 32. 
												@ So, this operation preserves the non-divisible-by-32 part of r1's value, or in other words, it computes r1 % 32 (masking) 
	mov	r0, #1									@ sets r0 = 1 (00000000000000000000000000000001 in binary-- to be shifted into position in the next instruction)
	mov	r1, r0, asl r1							@ r1 = 1 << (prime % 32)... arithmetic shift left by whatever is in r1 (prime % 32). Shifts the '1' bit into the correct position
	orr	r2, r2, r1								@ r2 = primeSet[prime/bitsPerInt] | (1 << prime % 32)... bitwise or operation
	str	r2, [r3]								@ stores the bit pattern into its original location, since the address of the array index is still in r3
	sub	sp, fp, #0								@ sets sp = fp... removing local space (variables used in the setBit function)
										@ sp needed
	ldr	fp, [sp], #4							@ load old fp, and move sp back to top of prior frame
	bx	lr 										@ return to caller via lr which hasn't changed during this call. Branches to link register (after if statement in checkNum)
	.size	setBit, .-setBit
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits