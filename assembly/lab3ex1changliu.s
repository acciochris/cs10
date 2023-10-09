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

.text
.globl main
main:
    # exit
    li $v0, 10
    syscall

# parameters:
# $a0: (char *) pointer to a string of four space-separated 2-digit integers
# $a1: (int *) pointer to where the integers should be stored
parse_vector:
    addi $sp, $sp, -16
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
        addi $s0, $s0, 3
        addi $s1, $s1, 4
        addi $s2, $s2, -1
        bne $s2, $zero, parse_vector_loop

    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
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
    add $v0, $v0, $t0

    # lower digit
    lbu $t0, 1($a0)
    andi $t0, $t0, 0xF
    add $v0, $v0, $t0

    jr $ra
