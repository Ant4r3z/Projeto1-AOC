.data

b1: .byte
io_control: .word 0xffff

.text

main:
lui $t0, 0xFFFF
j mmio_loop

mmio_loop:
    lw $t1, 0($t0)
    andi $t2, $t1, 1
    beq $t2, $zero, mmio_loop
    mmio_show:
        lw $t3, 4($t0)
        wait_transmitter:
            lw $t4, 8($t0)
            andi $t5, $t4, 1
            beqz $t5, wait_transmitter
            sw $t3, 12($t0)
            j mmio_loop

