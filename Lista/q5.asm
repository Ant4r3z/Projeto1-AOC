# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 01
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues

# Implemente um código fica constantemente tentando ler um caractere do KEYBOARD MMIO e, 
# sempre que receber um, imprime o mesmo caracter imediatamente no DISPLAY MMIO. 
# A leitura do Apêndice A8 é fundamental para a implementação da questão. Utilize a abordagem sem 
# interrupção (“polling”) por simplicidade. 

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

