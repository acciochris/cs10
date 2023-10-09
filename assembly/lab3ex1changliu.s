# Lab 3 Exercise 1 (Chang Liu)
# Student ID even => masking and `10X = (8 + 2)X = 8X + 2X`

# ASCII for reference
# | char | dec | hex | bin    |
# | 0    | 48  | 30  | 110000 |
# | 1    | 49  | 31  | 110001 |
# ...
# | 9    | 57  | 39  | 111001 |
#
# Masking
# '0' & 0xF (lower four bits)

# syscall reference
# | service       | $v0 | parameters and/or outputs    |
# | print integer | 1   | $a0: integer                 |
# | print string  | 4   | $a0: string                  |
# | read string   | 8   | $a0: buffer, $a1: max_length |
# | read integer  | 5   | $v0: integer                 |

.data
.align 2
M: .space 64
input_vector: .space 13 # 2*4 (ints) + 1*3 (spaces) + 1 (\0) + 1 (extra buffer)
prompt_row: .asciiz "Row "
prompt_row2: .asciiz ": "
result_sum: .asciiz "Sum: "
result_parity_0: .asciiz "Parity: 0\n"
result_parity_1: .asciiz "Parity: 1\n"
newline: .asciiz "\n"

.text
.globl main
main:
    li $s0, 4
    la $s2, M
    main_read_matrix:
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
        li $a1, 13
        li $v0, 8
        syscall

        # calculate array offset
        addiu $t0, $s1, -1 # row 1 => offset 0
        sll $t0, $t0, 4    # 4 words = 16 bytes = 2^4
        addu $a1, $s2, $t0

        jal parse_vector

        addiu $s0, $s0, -1
        bne $s0, $zero, main_read_matrix

    # sum
    li $s0, 16
    li $s1, 0
    main_sum:
        addiu $s0, $s0, -1
        sll $t0, $s0, 2
        addu $t0, $s2, $t0
        lw $t0, 0($t0)
        addu $s1, $s1, $t0
        bne $s0, $zero, main_sum

    la $a0, result_sum
    jal _print_str

    move $a0, $s1
    jal _print_int

    la $a0, newline
    jal _print_str

    # parity with if-then else
    andi $t0, $s1, 0x1
    bne $t0, $zero, main_parity_1
    la $a0, result_parity_0
    jal _print_str
    j main_end_parity
    main_parity_1:
        la $a0, result_parity_1
        jal _print_str
    main_end_parity:

    # exit
    li $v0, 10
    syscall

# parameters:
# $a0: integer to print
_print_int:
    li $v0, 1
    syscall
    jr $ra

# parameters:
# $a0: null-terminated string to print
_print_str:
    li $v0, 4
    syscall
    jr $ra

# parameters:
# $a0: (char *) pointer to a string of four space-separated 2-digit integers
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
        addiu $s0, $s0, 3
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
# $a0: (char *) pointer to a slice of two characters representing a 2-digit integer
# returns:
# $v0: (int) parsed integer
atoi:
    # upper digit
    lbu $t0, 0($a0)
    andi $t0, $t0, 0xF

    # 10X
    sll $t0, $t0, 1 # 2X
    move $v0, $t0
    sll $t0, $t0, 2 # 2X * 4 = 8X
    addu $v0, $v0, $t0

    # lower digit
    lbu $t0, 1($a0)
    andi $t0, $t0, 0xF
    addu $v0, $v0, $t0

    jr $ra
