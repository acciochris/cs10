# Lab 6 Exercise 1 (Chang Liu)
# Student ID even => arithmetic

# ASCII for reference
# | char | dec | hex | bin    |
# | 0    | 48  | 30  | 110000 |
# | 1    | 49  | 31  | 110001 |
# ...
# | 9    | 57  | 39  | 111001 |
#
# Arithmetic
# '0' - 48

# syscall reference
# | service       | $v0 | parameters and/or outputs    |
# | print integer | 1   | $a0: integer                 |
# | print string  | 4   | $a0: string                  |
# | read string   | 8   | $a0: buffer, $a1: max_length |
# | read integer  | 5   | $v0: integer                 |

.data
.align 2
M1:  # identity matrix
.word 1, 0, 0, 0, 0, 0, 0, 0
.word 0, 1, 0, 0, 0, 0, 0, 0
.word 0, 0, 1, 0, 0, 0, 0, 0
.word 0, 0, 0, 1, 0, 0, 0, 0
.word 0, 0, 0, 0, 1, 0, 0, 0
.word 0, 0, 0, 0, 0, 1, 0, 0
.word 0, 0, 0, 0, 0, 0, 1, 0
.word 0, 0, 0, 0, 0, 0, 0, 1
M2:  # some random matrix
.word 1, 5, 4, 7, 2, 4, 8, 6
.word 9, 3, 8, 4, 6, 2, 6, 5
.word 0, 1, 2, 6, 5, 8, 5, 4
.word 8, 3, 6, 8, 3, 8, 6, 6
.word 8, 7, 7, 9, 3, 4, 6, 1
.word 8, 5, 6, 3, 5, 6, 0, 1
.word 1, 9, 8, 2, 5, 6, 8, 0
.word 0, 1, 2, 6, 5, 7, 2, 9
M3:
.space 256
prompt_row: .asciiz "Row "
prompt_row2: .asciiz ": "
newline: .asciiz "\n"
space: .asciiz " "

.text
.globl main
main:
    # multiply
    la $a0, M3
    la $a1, M1
    la $a2, M2
    jal multiply_matrix

    # print
    la $a0, newline
    jal _print_str

    la $a0, M3
    jal print_matrix

    # exit
    li $v0, 10
    syscall

# parameters:
# $a0: (int) integer to print
_print_int:
    li $v0, 1
    syscall
    jr $ra

# parameters:
# $a0: (char *) null-terminated string to print
_print_str:
    li $v0, 4
    syscall
    jr $ra

# parameters:
# $a0: (int *) pointer to matrix
print_matrix:
    addiu $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)

    li $s0, 8
    move $s2, $a0

    print_matrix_loop:
        la $a0, prompt_row
        jal _print_str

        # print row index
        li $s1, 9
        sub $s1, $s1, $s0
        move $a0, $s1
        jal _print_int

        la $a0, prompt_row2
        jal _print_str

        # calculate array offset
        addiu $t0, $s1, -1 # row 1 => offset 0
        sll $t0, $t0, 5    # 8 words = 32 bytes = 2^5
        addu $s3, $s2, $t0

        # print first integer
        lw $a0, 0($s3)
        jal _print_int

        # print rest with spaces
        li $s4, 7
        print_matrix_inner_loop:
            la $a0, space
            jal _print_str

            addiu $s3, $s3, 4
            lw $a0, 0($s3)
            jal _print_int

            addiu $s4, $s4, -1
            bne $s4, $zero, print_matrix_inner_loop

        # print newline
        la $a0, newline
        jal _print_str

        addiu $s0, $s0, -1
        bne $s0, $zero, print_matrix_loop

    lw $s4, 20($sp)
    lw $s3, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 24

    jr $ra

# parameters:
# $a0: (int *) pointer to result matrix
# $a1: (int *) pointer to first matrix
# $a2: (int *) pointer to second matrix
multiply_matrix:
    addiu $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)

    # pseudo-code
    # for (int i = 0; i < 8; ++i) {
    #   for (int j = 0; j < 8; ++j) {
    #     for (int k = 0; k < 8; ++k) {
    #       $a0[i][j] += $a1[i][k] * $a2[k][j];
    #     }
    #   }
    # }
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    li $t3, 8

    multiply_matrix_loop1:
        addiu $t3, $t3, -1
        li $t4, 8

        multiply_matrix_loop2:
            addiu $t4, $t4, -1
            li $t5, 8

            multiply_matrix_loop3:
                addiu $t5, $t5, -1

                # one row: 4 * 8 = 32 bytes
                # one element: 4 bytes

                # load
                sll $t6, $t3, 5
                sll $t7, $t5, 2
                addu $t1, $t6, $t7
                addu $t1, $t1, $s1
                lw $t1, 0($t1)

                sll $t6, $t5, 5
                sll $t7, $t4, 2
                addu $t2, $t6, $t7
                addu $t2, $t2, $s2
                lw $t2, 0($t2)

                # multiply
                mul $t1, $t1, $t2

                # add in place
                sll $t6, $t3, 5
                sll $t7, $t4, 2
                addu $t0, $t6, $t7
                addu $t0, $t0, $s0
                lw $t2, 0($t0)

                addu $t2, $t2, $t1
                sw $t2, 0($t0)

                bne $t5, $zero, multiply_matrix_loop3

            bne $t4, $zero, multiply_matrix_loop2

        bne $t3, $zero, multiply_matrix_loop1

    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 12

    jr $ra
