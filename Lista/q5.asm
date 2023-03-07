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
lui $t0, 0xFFFF                             # endereco dos registradores MMIO
j mmio_loop                                 # desvia para o loop

mmio_loop:
    lw $t1, 0($t0)                          # t1 <- receiver ready
    beqz $t1, mmio_loop                     # caso receiver ready seja 0 (nao ha dado em receiver data), reinicia o loop 
    mmio_show:                              # caso seja 1, continua para a impressao do caracter
        lw $t3, 4($t0)                      # t3 <- receiver data
        wait_transmitter:
            lw $t4, 8($t0)                  # t4 <- transmitter ready
            beqz $t4, wait_transmitter      # caso o transmitter ready seja 0 (transmissor nao aceita caracter para transmitir), reinicia o loop
            sw $t3, 12($t0)                 # caso seja 1, grava o caracter a ser transmitido em transmitter data
            j mmio_loop                     # reinicia o programa

