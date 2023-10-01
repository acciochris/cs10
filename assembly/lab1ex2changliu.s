# Lab 1 Exercise 2 (Chang Liu)

.data
name_prompt: .asciiz "What is your name? "
age_prompt: .asciiz "What is your age? "
hello: .asciiz "Hello, "
name:
.align 2  # align name on word boundary
.space 51
max_length: .word 50
age_result_1: .asciiz "You will be "
age_result_2: .asciiz " years old in four years"

.text
# prompt for name
li $v0, 4
la $a0, name_prompt
syscall

li $v0, 8
la $a0, name       # address of string buffer
la $t0, max_length # maximum length of string
lw $a1, 0($t0)
syscall # store in buffer

# prompt for age
li $v0, 4
la $a0, age_prompt
syscall

li $v0, 5
syscall
move $t0, $v0 # store in $t0

# output greeting message
li $v0, 4
la $a0, hello
syscall

li $v0, 4
la $a0, name
syscall

# output age result
li $v0, 4
la $a0, age_result_1
syscall

li $v0, 1 # service id for print integer
addi $a0, $t0, 4
syscall

li $v0, 4
la $a0, age_result_2
syscall
