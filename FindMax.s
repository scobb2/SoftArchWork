.text
	.align	2						@ setting alignment to 4 bits (or bytes???)
	.global	findMax 				@ findMax is global
	.syntax unified					
	.arm							
	.fpu vfp						
	.type	findMax, %function		
findMax:
	str	fp, [sp, #-4]!				@ stores fp to 4 bytes/1 word above sp and decrements sp by the same (starting a new frame for findMax)
	add	fp, sp, #0					@ sets fp equal to sp (fp = sp + 0)
	sub	sp, sp, #20					@ decrements sp by 20 (sp = sp - 20), extends stack by 20 bytes/5 words
	str	r0, [fp, #-16]				@ stores what's in r0 (address to beginning of the vals array) to 16 bytes/4 words above fp
	ldr	r3, [fp, #-16]				@ r3 = r0, r3 points to the beginning of the array
	ldr	r3, [r3]					@ puts the value of what is in the adress r3 points to into r3 (dereferences)
	str	r3, [fp, #-8]				@ stores r3 into address 8 bytes/2 words up from fp
	mov	r3, #1						@ r3 = 1 [i = 1]
	str	r3, [fp, #-12]				@ stores r3 (#1) into 12 bytes/3 words above the old fp (where variable i will be held)
	b	.L2							@ branches to .L2
.L4:
	ldr	r3, [fp, #-12]				@ loads i into r3
	lsl	r3, r3, #2					@ byte shift left, does (r3) i * 4 to put values onto the stack correctly
	ldr	r2, [fp, #-16]				@ sets r2 = the array val[0] address
	add	r3, r2, r3					@ sets r3 = val[i] by offsetting by the byte-shifted i
	ldr	r2, [r3]					@ loads the value of val[i] into r2
	ldr	r3, [fp, #-8]				@ loads the value of max into r3
	cmp	r2, r3						@ [compare val[i] and max]
	ble	.L3							@ if r2 <= r3, branches to .L3 [if val[i] <= max]
	ldr	r3, [fp, #-12]				@ loads i into r3
	lsl	r3, r3, #2					@ byte shift left, does (r3) i * 4
	ldr	r2, [fp, #-16]				@ loads array val[0] address into r2
	add	r3, r2, r3					@ sets r3 = val[i] by offsetting by the byte-shifted i
	ldr	r3, [r3]					@ dereferences the array address and loads that value into r3
	str	r3, [fp, #-8]				@ stores the current array value into 'max'
.L3:
	ldr	r3, [fp, #-12]				@ loads i into r3
	add	r3, r3, #1					@ increments r3 [i++]
	str	r3, [fp, #-12]				@ stores incremented i back in place
.L2:
	ldr	r3, [fp, #-12]				@ loads (i) into r3
	cmp	r3, #9						@ compares the value in r3 (i) to 9 [i < 10 check]
	ble	.L4							@ if r3 <= 9, branch to .L4 [if i < 10]
	ldr	r3, [fp, #-8]				@ if r3 > 9, [if i = 10], load 'max' into r3
	mov	r0, r3						@ r0 = r3, r0 = max
	add	sp, fp, #0					@ sp = fp (+ 0)
	@ sp needed 					
	ldr	fp, [sp], #4				@ set fp to 4 below sp, (at the top of main's frame)
	bx	lr 							@ branches back to the line after findMax was called from main, and brings r0 back with it [return max]
	.size	findMax, .-findMax		
	.section	.rodata
	.align	2
.LC0:
	.ascii	"%d\000"				@ format string for scanf & printf
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}				@ sets up the stack frame with sp pointing to the top (first bit of lr)
	add	fp, sp, #4					@ sets the fp to the top of the old fp
	sub	sp, sp, #48					@ moves the top of the frame up 48 bytes (12 words)
	mov	r3, #0						@ puts a 0 value in r3 
	str	r3, [fp, #-8]				@ stores 0 into the word found 8 bytes/2 words above fp [i = 0]
	b	.L7							@ branches to .L7
.L8:
	sub	r2, fp, #48					@ r2 points to the address 48 bytes/12 words above fp 
	ldr	r3, [fp, #-8]				@ loads i back into r3
	lsl	r3, r3, #2					@ byte shift left, does i * 4 to put values onto the stack correctly
	add	r3, r2, r3					@ r3 holds the address of the next word in memory for new val[i]
	mov	r1, r3						@ r1 = r3
	ldr	r0, .L10					@ loads "%d\000" into r0, end of string thing (from .LC0)....r0 to be passed into scanf
	bl	__isoc99_scanf				@ calls scanf, sets input integer into the address passed in (from r1)
	ldr	r3, [fp, #-8]				@ loads i back into r3
	add	r3, r3, #1					@ increments r3 [i++]
	str	r3, [fp, #-8]				@ stores r3 back into the word above lr (where i is being stored)
.L7:
	ldr	r3, [fp, #-8]				@ loads i back into r3
	cmp	r3, #9						@ does a comparison of r3 (i) and 9
	ble	.L8							@ if r3 (i) < 9, branches to .L8 to continue filling in values [i < 10 check]
	sub	r3, fp, #48					@ if r3 (i) > 9, (i = 10)... r3 = fp - 48 (r3 = address of the start of the array)
	mov	r0, r3						@ r0 = r3, r0 points to the start of the array
	bl	findMax 					@ jump to findMax function and store where you were so you can get back (after findMax function returns, continue from here)
	mov	r3, r0						@ r3 = r0, r3 = max
	mov	r1, r3						@ r1 = r3, r1 = max
	ldr	r0, .L10					@ prepares for the print statement
	bl	printf						@ prints out the max value
	mov	r3, #0						@ r3 = 0
	mov	r0, r3						@ r0 = r3, r0 = 0
	sub	sp, fp, #4					@ dropping all of local variables by setting sp = lr, important setup for pop
	@ sp needed 					
	pop	{fp, pc}					@ pops the frame off, puts old fp back into fp and sets the pc to lr to return
.L11:
	.align	2
.L10:
	.word	.LC0					@ address of format string
	.size	main, .-main
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits