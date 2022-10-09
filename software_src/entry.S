	.section .entry
	.align 2

	.globl entry
	.type  entry, @function
entry:
    mv s0, zero
    la sp, _stack_pointer
    j main
