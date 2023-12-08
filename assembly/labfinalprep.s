# Lab Final Prep

.data
.align 2
changliu1: .space 64
.space 64
changliu2: .space 64

.text
.globl main
main:
    li $t3, 2
    main_loop:
        la $t1, changliu1
        li $t0, 4
        main_load_1:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_1

        la $t1, changliu2
        li $t0, 4
        main_load_2:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_2
        
        addiu $t3, $t3, -1
        bne $t3, $zero, main_loop
    
    li $v0, 10
    syscall
