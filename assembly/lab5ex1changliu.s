# Lab 5 Exercise 1 (Chang Liu)
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

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
# Answers to evaluation questions are HERE #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

# Program length: If the loop is only unrolled once, the program length is only
#                 slightly larger than the original version.
# Register usage: As the loop is not fully unrolled, the loop counter must still
#                 exist. Combined with the new registers for the unrolled code,
#                 Register pressure is quite high.
# Conceptual complexity: Conceptual complexity is reasonable. In most cases, only
#                        register names need to be changed.

.data
.align 2
M1: .space 64
M2: .space 64
M3: .space 64
input_vector: .space 9 # 1*4 (ints) + 1*3 (spaces) + 1 (\0) + 1 (extra buffer)
prompt_row: .asciiz "Row "
prompt_row2: .asciiz ": "
newline: .asciiz "\n"
space: .asciiz " "

.text
.globl main
main:
    # read in two matrices
    la $a0, M1
    jal read_matrix

    la $a0, newline
    jal _print_str

    la $a0, M2
    jal read_matrix

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
# $a0: (int *) pointer to where the integers should be stored
read_matrix:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    li $s0, 4
    move $s2, $a0

    read_matrix_loop:
        la $a0, prompt_row
        jal _print_str

        # print row index
        li $s1, 5
        sub $s1, $s1, $s0
        move $a0, $s1
        jal _print_int

        la $a0, prompt_row2
        jal _print_str

        # input
        la $a0, input_vector
        li $a1, 9
        li $v0, 8
        syscall

        # calculate array offset
        addiu $t0, $s1, -1 # row 1 => offset 0
        sll $t0, $t0, 4    # 4 words = 16 bytes = 2^4
        addu $a1, $s2, $t0

        jal parse_vector

        addiu $s0, $s0, -1
        bne $s0, $zero, read_matrix_loop

    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 16

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

    li $s0, 4
    move $s2, $a0

    print_matrix_loop:
        la $a0, prompt_row
        jal _print_str

        # print row index
        li $s1, 5
        sub $s1, $s1, $s0
        move $a0, $s1
        jal _print_int

        la $a0, prompt_row2
        jal _print_str

        # calculate array offset
        addiu $t0, $s1, -1 # row 1 => offset 0
        sll $t0, $t0, 4    # 4 words = 16 bytes = 2^4
        addu $s3, $s2, $t0

        # print first integer
        lw $a0, 0($s3)
        jal _print_int

        # print rest with spaces
        li $s4, 3
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
    # for (int i = 0; i < 4; ++i) {
    #   for (int j = 0; j < 4; ++j) {
    #     for (int k = 0; k < 4; ++k) {
    #       $a0[i][j] += $a1[i][k] * $a2[k][j];
    #     }
    #   }
    # }
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    li $t3, 4

    multiply_matrix_loop1:
        addiu $t3, $t3, -1
        li $t4, 4

        multiply_matrix_loop2:
            addiu $t4, $t4, -1
            li $t5, 4

            # compute result address
            sll $t6, $t3, 4
            sll $t7, $t4, 2
            addu $t0, $t6, $t7
            addu $t0, $t0, $s0
            move $a0, $zero

            multiply_matrix_loop3_unroll2:
                # NOTE: The comments on program length, etc. are at the beginning
                #       of the file.
                # one row: 4 * 4 = 16 bytes
                # one element: 4 bytes

                # load 1
                addiu $t5, $t5, -1
                sll $t6, $t3, 4
                sll $t7, $t5, 2
                addu $t6, $t6, $t7
                addu $t6, $t6, $s1
                lw $t1, 0($t6)

                sll $t6, $t5, 4
                sll $t7, $t4, 2
                addu $t7, $t6, $t7
                addu $t7, $t7, $s2
                lw $t2, 0($t7)

                # load 2
                addiu $t5, $t5, -1
                sll $a3, $t3, 4
                sll $v0, $t5, 2
                addu $a3, $a3, $v0
                addu $a3, $a3, $s1
                lw $a1, 0($a3)

                sll $a3, $t5, 4
                sll $v0, $t4, 2
                addu $v0, $a3, $v0
                addu $v0, $v0, $s2
                lw $a2, 0($v0)

                # multiply
                mul $t1, $t1, $t2
                mul $a1, $a1, $a2

                # add
                addu $t1, $t1, $a1
                addu $a0, $a0, $t1

                bne $t5, $zero, multiply_matrix_loop3_unroll2

            sw $a0, 0($t0)

            bne $t4, $zero, multiply_matrix_loop2

        bne $t3, $zero, multiply_matrix_loop1

    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 12

    jr $ra

# parameters:
# $a0: (char *) pointer to a string of four space-separated digits
# $a1: (int *) pointer to where the integers should be stored
parse_vector:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s0, $a0
    move $s1, $a1
    li $s2, 4

    parse_vector_loop:
        move $a0, $s0
        jal atoi
        sw $v0, 0($s1)
        addiu $s0, $s0, 2
        addiu $s1, $s1, 4
        addiu $s2, $s2, -1
        bne $s2, $zero, parse_vector_loop

    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 16

    jr $ra

# parameters:
# $a0: (char *) pointer to a character representing a digit
# returns:
# $v0: (int) parsed integer
atoi:
    # upper digit
    lbu $v0, 0($a0)
    addiu $v0, $v0, -48

    jr $ra
