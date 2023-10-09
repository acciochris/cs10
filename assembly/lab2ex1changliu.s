# Lab 2 Exercise 1 (Chang Liu)
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
.align 2 # to word boundary
V: .space 32 # 8 * sizeof(int)
VPrime: .space 32
VCheck: .space 32
V_str: .space 28 # 2*8 + 1*7 + 1 + extra buffer
prompt_V: .asciiz "Input V: "
prompt_VPrime: .asciiz "Input VPrime:\n"
prompt_result: .asciiz "Check Result: "
newline: .asciiz "\n"

.text
.globl main
main:
    # read a string of integers
    la $a0, prompt_V
    li $v0, 4
    syscall

    la $a0, V_str
    li $a1, 28 # len(V_str)
    li $v0, 8
    syscall

    # parse integers into V (impl. w/ pointers)
    # for (int i = 0; i < 8; ++i) {
    #     int result = (V_str[3*i] & 0xF) * 10; // see note above
    #     result += (V_str[3*i + 1] & 0xF);
    #     V[i] = result;
    # }
    li $t0, 0 # int i = 0
    li $t7, 8 # len(V)
    la $t1, V_str
    la $t2, V
    parse:
        beq $t0, $t7, end_parse

        # upper digit
        lbu $t4, 0($t1)
        andi $t4, $t4, 0xF

        # 10X
        sll $t4, $t4, 1 # 2X
        move $t3, $t4
        sll $t4, $t4, 2 # 2X * 4 = 8X
        add $t3, $t3, $t4

        # lower digit
        lbu $t4, 1($t1)
        andi $t4, $t4, 0xF
        add $t3, $t3, $t4

        # store
        sw $t3, 0($t2)

        # increment pointers
        addi $t1, $t1, 3 # two characters and a whitespace
        addi $t2, $t2, 4 # a word

        addi $t0, $t0, 1
        j parse
    end_parse:

    # read integers into VPrime
    la $a0, prompt_VPrime
    li $v0, 4
    syscall

    li $t0, 0
    la $t1, VPrime
    readint:
        beq $t0, $t7, end_readint

        li $v0, 5
        syscall
        sw $v0, 0($t1)

        # increment pointer
        addi $t1, $t1, 4

        addi $t0, $t0, 1
        j readint
    end_readint:

    # check
    li $t0, 0
    la $t1, V
    la $t2, VPrime
    la $t3, VCheck
    check:
        beq $t0, $t7, end_check

        lw $t4, 0($t1)
        lw $t5, 0($t2)
        sub $t4, $t5, $t4 # VPrime - V
        sw $t4, 0($t3)

        # increment pointers
        addi $t1, $t1, 4
        addi $t2, $t2, 4
        addi $t3, $t3, 4

        addi $t0, $t0, 1
        j check
    end_check:

    # sum VCheck
    li $t0, 0
    la $t1, VCheck
    li $t2, 0
    sum:
        beq $t0, $t7, end_sum

        lw $t3, 0($t1)
        add $t2, $t2, $t3

        # increment pointers
        addi $t1, $t1, 4

        addi $t0, $t0, 1
        j sum
    end_sum:

    la $a0, prompt_result
    li $v0, 4
    syscall

    move $a0, $t2
    li $v0, 1
    syscall

    # exit
    li $v0, 10
    syscall
