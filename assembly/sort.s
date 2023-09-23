# Sorting algorithms
# note: pass integer values as command line arguments

.data
newline: .asciiz "\n"

.text
exit:
    li $v0, 10
    syscall

print_int:
    li $v0, 1
    syscall
    jr $ra

print_msg:
    li $v0, 4
    syscall
    jr $ra

# $a0: null-terminated string to parse
parse_int:
    # detect negative
    lb $t0, 0($a0)
    li $t3, 45
    beq $t0, $t3, parse_int_negative # ascii for -
    li $t1, 0
    j parse_int_begin
    parse_int_negative:
    li $t1, 1
    addi $a0, $a0, 1 # compensate for negative sign

    parse_int_begin:
    li $v0, 0
    li $t2, 10

    # main loop
    parse_int_loop:
    lb $t0, 0($a0)
    beq $t0, $zero, parse_int_end
    mult $v0, $t2
    mflo $v0
    addi $t0, $t0, -48 # ascii for 0
    add $v0, $v0, $t0
    addi $a0, $a0, 1
    j parse_int_loop

    parse_int_end:
    beq $t1, $zero, parse_int_ret

    # negate value
    sub $v0, $zero, $v0
    
    parse_int_ret:
    jr $ra

# $a0: array of integers
# $a0: length of array
debug_integers:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a0
    move $s1, $a1

    debug_integers_loop:
    beq $s1, $zero, debug_integers_ret
    lw $a0, 0($s0)
    jal print_int
    la $a0, newline
    jal print_msg
    addi $s0, $s0, 4
    addi $s1, $s1, -1
    j debug_integers_loop

    debug_integers_ret:
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

main:
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp)   # argc - 1
    sw $s1, 8($sp)   # argv[1]
    sw $s2, 12($sp)  # int integers[]
    sw $s3, 16($sp)  # int i
    sw $s4, 20($sp)  # char **argv_iterator
    sw $s5, 24($sp)  # int *integers_iterator

    addi $s0, $a0, -1 # remove the program itself from argc
    addi $s1, $a1, 4 # start from argv[1]

    # allocate memory for integers
    li $v0, 9
    move $a0, $s0
    sll $a0, $a0, 2
    syscall
    move $s2, $v0

    # parse integers
    li $s3, 0
    move $s4, $s1
    move $s5, $s2

    main_parse_int_loop:
    beq $s3, $s0, main_begin_sort
    lw $a0, 0($s4)
    jal parse_int
    sw $v0, 0($s5)
    addi $s4, $s4, 4
    addi $s5, $s5, 4
    addi $s3, $s3, 1
    j main_parse_int_loop

    main_begin_sort:
    move $a0, $s2
    move $a1, $s0
    jal debug_integers

    lw $s5, 24($sp)
    lw $s4, 20($sp)
    lw $s3, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 28
    
    move $a0, $zero
    j exit
