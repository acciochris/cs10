# Lab Final Prep

.data
.align 2
changliu1: .space 64
changliu2: .space 64
changliu3: .space 64
changliu4: .space 64
changliu5: .space 64
changliu6: .space 64
changliu7: .space 64
changliu8: .space 64

.text
.globl main
main:
    li $t3, 2
    main_loop:
        la $t1, changliu1
        li $t0, 2
        main_load_1:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_1

        la $t1, changliu2
        li $t0, 2
        main_load_2:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_2

        la $t1, changliu3
        li $t0, 2
        main_load_3:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_3

        la $t1, changliu4
        li $t0, 2
        main_load_4:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_4

        la $t1, changliu5
        li $t0, 2
        main_load_5:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_5

        la $t1, changliu6
        li $t0, 2
        main_load_6:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_6

        la $t1, changliu7
        li $t0, 2
        main_load_7:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_7

        la $t1, changliu8
        li $t0, 2
        main_load_8:
            lw $t2, 0($t1)
            addiu $t1, $t1, 4
            addiu $t0, $t0, -1
            bne $t0, $zero, main_load_8

        addiu $t3, $t3, -1
        bne $t3, $zero, main_loop

    li $v0, 10
    syscall
