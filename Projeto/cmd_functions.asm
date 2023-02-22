.data
help_out: .asciiz "Esta eh a lista dos comandos disponiveis\n    cmd_1. ad_morador-<ap>-<morador>: adiciona um morador ao apartamento\n"

.text
.globl help_fn

help_fn:                                                                # comando help
    addi $a0, $zero, 1  # pega a opcao da posicao 1 
    jal get_fn_option   # executa a funcao
    add $t0, $zero, $v0 # escreve o endereco da opcao em $t8
    addi $a0, $zero, 2
    jal get_fn_option
    add $t1, $zero, $v0

    la $a0, help_out
    jal print_str

    add $a0, $zero, $t0
    jal free
    add $a0, $zero, $t1
    jal free
    j start
