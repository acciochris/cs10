# Lab 4 Exercise 1 (Chang Liu)
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
M1: .space 64
M2: .space 64
M3: .space 64
input_vector: .space 9 # 1*4 (ints) + 1*3 (spaces) + 1 (\0) + 1 (extra buffer)
prompt_row: .asciiz "Row "
prompt_row2: .asciiz ": "
newline: .asciiz "\n"

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
    addi $sp, $sp, -16
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
    addi $sp, $sp, 16

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
