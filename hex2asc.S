  # hexmain.S
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

	.text
	.globl hex2asc


hex2asc:
	li	a0, 17		# test number (from 0 to 15)
	
	addi    sp,sp,-4
	sw      ra,0(sp)
	
	jal	hexasc		# call hexasc
	
	li	a7, 11	# write a0 to stdout
	ecall

	lw      ra,0(sp)
	addi    sp,sp,4
	jr      ra	
	

  # You can write your own code for hexasc here
  #

# 1,2,3,4,5,6,7,8,9 A,B,C,D,E,F
hexasc: 
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

