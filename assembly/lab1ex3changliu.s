# Lab 1 Exercise 3 (Chang Liu)

.data
.align 2
# format: pitch (byte), volume (byte), duration (half)
song:
.byte 60, 80
.half 500
.byte 60, 80
.half 500
.byte 67, 85
.half 500
.byte 67, 85
.half 500
.byte 69, 90
.half 500
.byte 69, 90
.half 500
.byte 67, 85
.half 1000
.byte 65, 80
.half 500
.byte 65, 80
.half 500
.byte 64, 80
.half 500
.byte 64, 80
.half 500
.byte 62, 80
.half 500
.byte 62, 80
.half 500
.byte 60, 80
.half 1000
length: .word 14

.text
# load length of melody at $t0
la $t0, length
lw $t0, 0($t0)

# load base address of song
la $t1, song

# load instrument: piano
li $a2, 0

loop:
beq $t0, $zero, loop_end
lw $t2, 0($t1) # load note info

# load duration
srl $a1, $t2, 16

# load pitch
andi $a0, $t2, 0x000000FF

# load volume
srl $a3, $t2, 8
andi $a3, $a3, 0x000000FF

# load service id
li $v0, 33

syscall
addi $t1, $t1, 4
addi $t0, $t0, -1
j loop

loop_end:
