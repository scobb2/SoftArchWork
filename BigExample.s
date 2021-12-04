001     .arch armv6
002     .section    .rodata
003     .align    2
004 .LC0:
005     .ascii    "Found %d primes:\000"
006     .align    2
007 .LC1:
008     .ascii    " %d\000"
009     .text
010     .align    2
011     .global    main
012     .type    main, %function
013 main:
014     stmfd    sp!, {fp, lr}			@ first 7 lines set up the stack frame.... this one moves old fp and sp up a word to start a new frame
015     add    fp, sp, #4    			@ sets fp = 4 bytes below sp (creating room for the link register and storing old fp at the base of this new frame)
016     sub    sp, sp, #56				@ extends the frame by 56 bytes / 14 words to be filled with local variables/parameters (10 for the array, 4 for other variables)
017     mov    r3, #320					@ puts the constant 320 in r3 
018     str    r3, [fp, #-20]			@ stores r3 20 bytes off of the fp (const int 'numsToTest')
019     mov    r3, #0					@ puts the constant 0 in r3
020     str    r3, [fp, #-8]			@ stores r3 8 bytes off of the fp (int 'totalPrimes')
021     mov    r3, #0					@ puts a 0 in r3
022     str    r3, [fp, #-16]			@ stores r3 16 bytes off of the fp (for 'idx')
023     b    .L2						@ branches to .L2
024 .L3:
025     ldr    r3, [fp, #-16]			@ loads 'idx' into r3
026     mov    r3, r3, asl #2			@ multiplies r3 ('idx') by 4 to get the offset in bytes of primeSet
027     sub    r2, fp, #4				@ subtracts just 4 bytes from fp leaving the result in r2 (to jump over the lr)
028     add    r3, r2, r3				@ adds in the computed offset from r3 ('idx' * 4)
029     mov    r2, #0					@ puts a 0 in r2
030     str    r2, [r3, #-56]			@ stores a 0 in the array value (loops through the array, so every element is initialized to 0)
										@ fp - 60 + idx*4 is the math going on in the end to reach the correct location in the primeSet array
031     ldr    r3, [fp, #-16]			@ loads idx into r3
032     add    r3, r3, #1				@ increments 'idx'
033     str    r3, [fp, #-16]			@ stores incremented 'idx' back into the stack frame
034 .L2:
035     ldr    r3, [fp, #-16]			@ loads 'idx' into r3
036     cmp    r3, #9					@ compares 'idx' and 9
037     ble    .L3 						@ if 'idx' <= 9, branches to .L3
038     mov    r3, #2					@ puts a 2 into r3
039     str    r3, [fp, #-12]			@ stores r3 12 bytes off of the fp (for 'toTest')
040     b    .L4 						@ braches to .L4
041 .L6:
042     ldr    r2, [fp, #-12]			@ loads 'toTest' into r2
043     sub    r3, fp, #60				@ puts the loaction of the start of array 'primeSet' into r3
044     mov    r0, r2 					@ puts 'toTest' into r0
045     mov    r1, r3					@ puts the loaction of the start of array 'primeSet' into r1
046     bl    checkNum 					@ branches to checkNum and saves *this* location so that it can return after
047     mov    r3, r0 					@ moves the result from checkNum (r0) into r3
048     cmp    r3, #0					@ compares the result with 0
049     beq    .L5 						@ 
050     ldr    r3, [fp, #-8]			@ 
051     add    r3, r3, #1				@ 
052     str    r3, [fp, #-8]			@ 
053 .L5:
054     ldr    r3, [fp, #-12]			@ loads 'toTest' into r3
055     add    r3, r3, #1				@ increments r3 ('toTest')
056     str    r3, [fp, #-12]			@ stores the incremented value back into 'toTest' spot in the stack frame
057 .L4:
058     ldr    r2, [fp, #-12]			@ loads 'toTest' into r2
059     ldr    r3, [fp, #-20]			@ loads 'numsToTest' 
060     cmp    r2, r3					@ compares 'toTest' and 'numsToTest'
061     blt    .L6  					@ 
062     ldr    r0, .L10       			@ these next 3 lines implement the printf call
063     ldr    r1, [fp, #-8]  			@ 
064     bl    printf					@ 
065     mov    r3, #0					@ 
066     str    r3, [fp, #-12]			@ 
067     b    .L7						@ 
068 .L9:
069     ldr    r3, [fp, #-12]			@ start if-statement test... loads 'toTest' into r3
070     mov    r3, r3, lsr #5			@ r3 = 'toTest' / 'bitsPerInt' (bitsPerInt is 32, or 2^5, so a right shift of 5 [/2^5] works)
071     mov    r3, r3, asl #2			@ r3 = (toTest/bitsPerInt) * size of an int (size of an int is 4 bytes, shift left by 2 [*2^2] works)
072     sub    r2, fp, #4				@ r2 points to the bottom of the local variables
073     add    r3, r2, r3				@ r3 = array offset + start of the local variables
074     ldr    r2, [r3, #-56]			@ loads primeSet[toTest/bitsPerInt] into r2
075     ldr    r3, [fp, #-12]			@ loads 'toTest' into r3
076     and    r3, r3, #31				@ r3 = toTest % bitsPerInt 
077     mov    r3, r2, lsr r3			@ r3 = primeSet[toTest/bitsPerInt] >> toTest % bitsPerInt
078     and    r3, r3, #1				@ r3 = primeSet[toTest/bitsPerInt] >> toTest % bitsPerInt & 01
079     cmp    r3, #0					@ check if resultant bit is 0
080     beq    .L8						@ branch around the if-body if so
081     ldr    r0, .L10+4				@ if resultant bit is not, 0 start body of the if-statement... pc-relative load, in this case from the word after .L10, 
										@ which contains the address .LC1, the location of the "%d" string
082     ldr    r1, [fp, #-12]			@ loads 'toTest' into r1 to prepare for the print
083     bl    printf					@ prints 'toTest' if it is a prime number, branches back here and resumes instructions after the print
084 .L8:
085     ldr    r3, [fp, #-12]			@ increments
086     add    r3, r3, #1				@ 
087     str    r3, [fp, #-12]			@ 
088 .L7:
089     ldr    r2, [fp, #-12]			@ 
090     ldr    r3, [fp, #-20]			@ 
091     cmp    r2, r3					@ 
092     blt    .L9						@ 
093     mov    r0, #10					@ sets r0 = 10
094     bl     putchar					@ The putchar function takes a single ASCII character as its only parameter and prints it. The compiler passes 10 
										@ (the ASCII code for '\n') to putchar, via r0, and drops the printf entirely. 
										@ This is an example of the kind of cleverness compilers can exhibit.
095     mov    r0, #0					@ sets r0 = 0
096     sub    sp, fp, #4				@ 
097     ldmfd    sp!, {fp, pc}			@ 
098 .L11:
099     .align    2
100     
101     
102 .L10:
103     .word    .LC0
104     .word    .LC1
105     .size    main, .-main
106     .global    __aeabi_uidivmod
107     .align    2
108     .global    checkNum
109     .type    checkNum, %function
110     
111 checkNum:
112     stmfd  sp!, {fp, lr}			@ first 5 instructions set up the stack frame... this one moves old fp and sp up a word to start a new frame
113     add    fp, sp, #4				@ sets fp = 4 bytes below sp (creating room for the link register and storing old fp at the base of this new frame)
114     sub    sp, sp, #16				@ extends the frame by 16 bytes / 4 words to be filled with local variables/parameters
115     str    r0, [fp, #-16]			@ stores toTest one word lower than the top of the stack 
116     str    r1, [fp, #-20]			@ stores 'primeSet' at the top of the stack
117     mov    r3, #2					@ setting r3 = 2
118     str    r3, [fp, #-8]			@ stores r3 3 words below the ToS (where 'divisor' variable will be held now, 'divisor' = 2 in preparation for the for-loop)
119     b    .L13						@ branches to .L13
120 .L15:
121     ldr    r3, [fp, #-8]			@ loads 'divisor' into r3
122     add    r3, r3, #1				@ increments r3 by 1
123     str    r3, [fp, #-8]			@ stores r3 back into 'divisor' (divisor++)
124 .L13:
125     ldr    r2, [fp, #-8]			@ loads 'divisor' into r2
126     ldr    r3, [fp, #-16]			@ loads 'toTest' into r3
127     cmp    r2, r3					@ compares r2 and r3 ('divisor' and 'toTest')
128     bcs    .L14          			@ (same as bhs... these are unsigned checks whereas bge is a signed check) if r2 >= r3 ('divisor' >= 'toTest'), branch to .L14
129     ldr    r3, [fp, #-8]			@ if r2 < r3 ('divisor' < 'toTest'), load 'divisor' into r3
130     ldr    r2, [fp, #-16]			@ load 'toTest' into r2
131     mov    r0, r2 					@ r0 = 'toTest'
132     mov    r1, r3					@ r1 = 'divisor'.... (r0 and r1 are the parameters passed into the % function call in the next instruction)
133     bl    __aeabi_uidivmod			@ library funct. supplied by C compiler to compute both the quotient and modulo of a pair of integers (r0/r1 -> r0 and r0%r1 -> r1)
134     mov    r3, r1					@ r3 = 'toTest' % 'divisor'
135     cmp    r3, #0					@ compares ['toTest' % 'divisor'] and #0
136     bne    .L15						@ if ['toTest' % 'divisor'] != 0, branches to .L15 (incrementing 'divisor')
137 .L14:
138     ldr    r2, [fp, #-8]			@ loads 'divisor' into r2.... after the for loop in the C code
139     ldr    r3, [fp, #-16]			@ loads 'toTest' into r3
140     cmp    r2, r3					@ compares 'divisor' and 'toTest'
141     bne    .L16						@ if 'divisor' != 'toTest', branches to .L16 (which does???).... (this branches around the if-statement)
142     ldr    r0, [fp, #-16]			@ if 'divisor' == 'toTest'.... load 'toTest' into r0
143     ldr    r1, [fp, #-20]			@ loads 'primeSet' into r1 (r0 and r1 will be the parameters passed into setBit function)
144     bl    setBit					@ jumps to setBit and saves the current location in the link register so that we can return here after setBit function is complete
145 .L16:
146     ldr    r2, [fp, #-8]			@ loads 'divisor' into r2
147     ldr    r3, [fp, #-16]			@ loads 'toTest' into r3
148     cmp    r2, r3					@ compares 'divisor' and 'toTest'
149     moveq    r3, #1					@ if 'divisor' == 'toTest', r3 = 1 (1 means true)
150     movne    r3, #0					@ if 'divisor' != 'toTest', r3 = 0 (0 means false)
151     uxtb    r3, r3 					@ compiler dumbness... does a needless sign extension
152     mov    r0, r3					@ moves r3 into r0 to be brought to the next function (r0 is returned... the 0 or 1 computed in 149 & 150)
153     sub    sp, fp, #4				@ sets sp = 4 bytes above the old fp (keeping the link register and dropping all of the local variables)
154     ldmfd    sp!, {fp, pc}			@ pop off fp, and lr, with lr going straight into pc???????
155     .size    checkNum, .-checkNum
156     .align    2
157     .global    setBit
158     .type    setBit, %function
159     
160 setBit:
161     str    fp, [sp, #-4]!			@ first 5 instructions set up the stack frame... this one moves old fp and sp up a word to start a new frame
162     add    fp, sp, #0				@ sets fp = sp, note: no lr in the setBit frame because setBit does not call any other functions (no need to return back to setBit)
163     sub    sp, sp, #12				@ extends the frame by 3 words to be filled with local variables/parameters
164     str    r0, [fp, #-8]			@ stores r0 (prime variable) into the spot 2 words above fp
165     str    r1, [fp, #-12]			@ stores r1 (address of primeSet[0], beginning of the array) into the spot 3 words above fp (top of the stack)
166     ldr    r3, [fp, #-8]			@ loads 'prime' variable into r3
167     mov    r3, r3, lsr #5			@ divides 'prime' by 32 (by bit shifting with a factor of 2^5) and truncates the remainder
168     mov    r3, r3, asl #2			@ multiplies 'prime' by 4 (by bit shifting with a factor of 2^2)
169     ldr    r2, [fp, #-12]			@ loads address of 'primeSet[0]' (beginning of the array) into r2
170     add    r3, r2, r3				@ adds the byte offset (found by bit shifting above) onto the 'primeSet[0]' array address to reach the desired index
171     ldr    r2, [fp, #-8]			@ loads 'prime' variable into r2
172     mov    r2, r2, lsr #5			@ divides 'prime' by 32 (by bit shifting with a factor of 2^5) and truncates the remainder
173     mov    r2, r2, asl #2			@ multiplies 'prime' by 4 (by bit shifting with a factor of 2^2)
174     ldr    r1, [fp, #-12]			@ loads address of 'primeSet[0]' (beginning of the array) into r1
175     add    r2, r1, r2				@ adds the byte offset (found by bit shifting above) onto the 'primeSet[0]' array address to reach the desired index
176     ldr    r2, [r2]					@ dereferences r2... uses r2 as an address, gets the word at that address, and puts it into r2
177     ldr    r1, [fp, #-8]			@ loads 'prime' variable into r1 (these 5 lines compute this C expression: primeSet[prime/bitsPerInt] | (1 << prime % bitsPerInt))
178     and    r1, r1, #31				@ r1 = prime % 32... the operation keeps whatever the bottom 5 bits of r1 were, and zeros out all the rest.
										@ The eliminated bits are all divisible by 32 (32, 64, 128, etc) and the preserved bits are all nondivisible by 32. 
										@ So, this operation preserves the non-divisible-by-32 part of r1's value, or in other words, it computes r1 % 32 (masking)
179     mov    r0, #1					@ sets r0 = 1 (00000000000000000000000000000001 in binary-- to be shifted into position in the next instruction)
180     mov    r1, r0, asl r1			@ r1 = 1 << (prime % 32)... arithmetic shift left by whatever is in r1 (prime % 32). Shifts the '1' bit into the correct position
181     orr    r2, r2, r1				@ r2 = primeSet[prime/bitsPerInt] | (1 << prime % 32)... bitwise or operation
182     str    r2, [r3]					@ stores the bit pattern into its original location, since the address of the array index is still in r3
183     sub    sp, fp, #0				@ sets sp = fp... removing local space (variables used in the setBit function), and returning sp to fp location
184     ldr    fp, [sp], #4				@ load old fp, and move sp back to top of prior frame
185     bx    lr 						@ return to caller via lr which hasn't changed during this call. Branches to link register




