.data
  select_method: .asciiz "Select method (0 for iterative, 1 for recursive): "
  input: .asciiz "x: "
  output: .asciiz "fib(x) = "
  error_lt_zero: .asciiz "x must be greater than zero\n"
  error_invalid_method: .asciiz "invalid method\n"
  newline: .asciiz "\n"
  part1: .asciiz "fib("
  part2: .asciiz ") = "

.text
  # $a0: message to print
  print_msg:
    li $v0, 4
    syscall
    jr $ra

  print_int:
    li $v0, 1
    syscall
    jr $ra

  # $a0: message to print before reading
  read_int:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal print_msg

    li $v0, 5
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

  debug:
    jr $ra # disable debug
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)

    add $s0, $zero, $a0
    add $s1, $zero, $a1

    la $a0, part1
    jal print_msg
    add $a0, $zero, $s1
    jal print_int
	  la $a0, part2
    jal print_msg
    add $a0, $zero, $s0
    jal print_int
    la $a0, newline
    jal print_msg

    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

  # $a0: x
  # $v0: fib(x)
  fib_recursive:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s0, 8($sp)

    move $s1, $a0
    slti $t0, $s1, 2
    beq $t0, $zero, fib_recursive_else

    # fib(x) = x where x < 2
    move $s0, $s1
    j fib_recursive_ret

    fib_recursive_else:
    # fib(x - 1)
    addi $a0, $s1, -1
    jal fib_recursive
    move $s0, $v0

    # fib(x - 2)
    addi $a0, $s1, -2
    jal fib_recursive
    add $s0, $s0, $v0

    fib_recursive_ret:
    # debug
    move $a0, $s0
    move $a1, $s1
    jal debug

    # return value
    add $v0, $zero, $s0

    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

  # $a0: x
  # $v0: fib(x)
  fib_iterative:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s2, $a0
    slti $t0, $a0, 2
    beq $t0, $zero, fib_iterative_else

    # fib(x) = x where x < 2
    move $s0, $s2
    j fib_iterative_ret

    fib_iterative_else:
    li $s1, 0
    li $s0, 1
    addi $s2, $s2, -1

    # do {
    #   $t0 = $s0;
    #   $s0 += $s1;
    #   $s1 = $t0;
    # } while (--x);
    fib_iterative_loop:
    move $t0, $s0
    add $s0, $s0, $s1
    move $s1, $t0

    add $s2, $s2, -1
    bne $s2, $zero, fib_iterative_loop

    fib_iterative_ret:
    move $v0, $s0

    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra

  main:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp) # method
    sw $s1, 8($sp) # x

    # select_method
    la $a0, select_method
    jal read_int
    move $s0, $v0

    # validate method input
    srl $t0, $s0, 1
    beq $t0, $zero, main_load_x

    # error: invalid method
    la $a0, error_invalid_method
    jal print_msg
    j main_error

    # load x
    main_load_x:
    la $a0, input
    jal read_int
    move $s1, $v0

    # validate x
    slti $t0, $s1, 0
    beq $t0, $zero, main_fib

    # error: negative x
    la $a0, error_lt_zero
    jal print_msg
    j main_error

    # fib(x)
    main_fib:
    move $a0, $s1
    beq $s0, $zero, main_iterative

    jal fib_recursive
    j main_output

    main_iterative:
    jal fib_iterative

    # print x
    main_output:
    move $a0, $v0
    jal print_int

    # print newline
    la $a0, newline
    jal print_msg
    j main_success

    main_error:
    li $v0, 1
    j main_ret

    main_success:
    li $v0, 0

    main_ret:
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra
