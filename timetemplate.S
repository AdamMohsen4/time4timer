# timetemplate.S
# Written 2015 by F Lundevall
# Ported 2024/06 by W Szczerek (from MIPS to RISC-V)
# Copyright abandonded - this file is in the public domain.

#############################################################
# Choose the macro syntax for RARS or DTEK-V board.         #
# The syntax for RARS is probably due to its MIPS heritage. #
#############################################################
###################
# Macros for RARS #
###################
#.macro	PUSH (%reg)
#	addi	sp,sp,-4
#	sw	%reg,0(sp) 
#.end_macro

#.macro	POP (%reg)
#	lw	%reg,0(sp)
#	addi	sp,sp,4
#.end_macro
###################
# Macros for DTEK #
###################
#.macro	PUSH reg
#	addi sp,sp,-4
#	sw \reg,0(sp) 
#.endm

#.macro	POP reg
#	lw	\reg,0(sp)
#	addi	sp,sp,4
#.endm
#############################################################

	.data
	.align 2
mytime:	.word 	0x5957
timstr:	.asciz 	"text more text lots of text\0"
	.text
	.globl timetemplate, tick, time2string, delay, display_string
# Function for displaying a string with a newline at the end	
display_string:	
	li a7,4
	ecall
	li a0, 10
	li a7,11
	ecall
	jr ra
	
timetemplate:
	la	a0, timstr
	jal     display_string
	
	# wait a little
	li	a0, 1000 # ms
	jal	delay
	
	# call tick
	la 	a0, mytime
	jal	tick
	
	# call your function time2string
	la	a0, timstr
	la	t0, mytime
	lw	a1, 0(t0)
	jal	time2string
	
	# go back and do it all again
	j	timetemplate

	
# tick: update time pointed to by $a0
tick:	lw	t0, 0(a0)	# get time
	addi	t0, t0, 1	# increase
	andi	t1, t0, 0xf	# check lowest digit
	sltiu	t2, t1, 0xa	# if digit < a, okay
	bnez	t2, tiend
	addi	t0, t0, 0x6	# adjust lowest digit
	
	andi	t1, t0, 0xf0	# check next digit
	sltiu	t2, t1, 0x60	# if digit < 6, okay
	bnez	t2, tiend
	addi	t0, t0, 0xa0	# adjust digit
	
	li	t3, 0xF
	slli	t3, t3, 0x8
	and	t1, t0, t3	# check minute digit
	addi	t3, x0, 0xA
	slli	t3, t3, 0x8
	slt	t2, t1, t3	# if digit < a, okay
	bnez	t2, tiend
	addi	t0, t0, 0x600	# adjust digit - this one's okay, it's lower than 0x7FF 
	
	li	t3, 0xF
	slli	t3, t3, 0xC
	and	t1, t0, t3	# check last digit
	addi	t3, x0, 0x6
	slli	t3, t3, 0xC
	slt	t2, t1, t3	# if digit < 6, okay
	bnez	t2, tiend
	
	li	t3, 0xA
	slli	t3, t3, 0xC
	add	t0, t0, t3	# adjust last digit
tiend:	sw	t0,0(a0)	# save updated result
	jr	ra		# return

#########################################################
# Place for your functions: time2string, hex2asc, delay.#
#########################################################


hex2asc: 
# Mask off 4 
	andi a0, a0, 0xF
	
	li   t0, 10
	blt  a0, t0, less10
	
	
	addi  a0, a0, -10
	li    t1, 'A'
	add   a0, a0, t1
	
	j done
	
	
less10: 
	
	li t1, '0'
	add a0, a0, t1
	
	
	done: 
	
	andi  a0, a0, 0x7F
	ret




#a0 = addr
#a1 = time data

time2string:
    addi    sp, sp, -16
    sw      a0,  4(sp)      # dest
    sw      a1,  8(sp)      # time
    sw      ra, 12(sp)

    # M10
    lw      a0,  8(sp)
    srli    a0, a0, 12
    andi    a0, a0, 0xF
    jal     hex2asc
    lw      t0,  4(sp)
    sb      a0,  0(t0)
    addi    t0, t0, 1
    sw      t0,  4(sp)

    # M1
    lw      a0,  8(sp)
    srli    a0, a0, 8
    andi    a0, a0, 0xF
    jal     hex2asc
    lw      t0,  4(sp)
    sb      a0,  0(t0)
    addi    t0, t0, 1
    sw      t0,  4(sp)

    # ':'
    lw      t0,  4(sp)
    li      t1,  0x3A
    sb      t1,  0(t0)
    addi    t0,  t0, 1
    sw      t0,  4(sp)

    # S10
    lw      a0,  8(sp)
    srli    a0, a0, 4
    andi    a0, a0, 0xF
    jal     hex2asc
    lw      t0,  4(sp)
    sb      a0,  0(t0)
    addi    t0, t0, 1
    sw      t0,  4(sp)

    # S1
    lw      a0,  8(sp)
    andi    a0, a0, 0xF
    jal     hex2asc
    lw      t0,  4(sp)
    sb      a0,  0(t0)
    addi    t0, t0, 1
    sw      t0,  4(sp)

    # '\0' - null terminator
    lw      t0,  4(sp)
    sb      zero, 0(t0)

    lw      ra, 12(sp)
    addi    sp, sp, 16
    ret


delay:

## a0 = ms delay 
## t0 = counter
## a1 holds the value 4711

        bge  x0, a0, .done
        li   a1, 4711

       
.msloop:
	li t0, 0

.inner:
	addi t0, t0, 1
	blt  t0, a1, .inner
	
	addi a0, a0, -1
	blt  x0, a0, .msloop
	
.done: 
      ret

