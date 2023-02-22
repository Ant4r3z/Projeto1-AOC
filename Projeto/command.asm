.data


# definicao dos comandos
help: .asciiz "help"
ad_morador: .asciiz "ad_morador"


# textos de saida de comandos
cmd_invalido: .asciiz "Comando invalido\n"
miss_options: .asciiz "Comando incorreto, opcoes faltando\n"

.text
.globl get_fn_option, free, process_command

process_command:                                                        # funcao que processa o comando do usuario
    la $t0, input                                                       # carrega a string input
    lb $t1, 0($t0)
    beqz $t1, end_process
    add $t1, $zero, $zero                                               # tamanho do nome do comando
    la $t3, separador                                                   # carrega o char separador
    prcmd_loop:                                                         # loop que encontra o nome do comando
        beqz $t2, cmd_cmp                                               # se chegar no fim da string, desvia para o comparador de comando
        beq $t2, $t3, cmd_cmp                                           # se encontrar o separador, //
        addi $t0, $t0, 1                                                # incrementa o cursor da string input  
        addi $t1, $t1, 1                                                # incrementa o tamanho do nome do comando
        lb $t2, 0($t0)                                                  # carrega o byte atual de input em t2
        j prcmd_loop                                                    # iteracao do loop
    cmd_cmp:                                                            # encontra e direciona o comando a sua determinada funcao (switch-case)


        la $a0, help                                                    # carrega o nome de comando help em a0
        la $a1, input                                                   # carrega a string input em a1
        add $a2, $zero, $t1                                               # carrega o tamanho do nome do comando
        jal strncmp                                                     # chama a funcao strncmp (compara o numero n de bytes de duas strings)
        beqz $v0, help_fn                                               # se for igual (v0 = 0), encontrou a funcao e a executa

        la $a0, ad_morador

        j cmd_invalido_fn                                               # default: caso o comando nao corresponda a nenhum caso, comando invalido
    end_process:                                                        # fim da funcao
        j start                                                         # inicio do programa, pronto para aguardar um novo comando



get_fn_option:
    la $t0, input
    la $t1, separador
    lb $t1, 0($t1)
    add $t2, $a0, $zero

    find_separador:
        lb $t3, 0($t0)
        addi $t0, $t0, 1
        beqz $t3, abort_get_fn_op
        bne $t3, $t1, find_separador
        addi $t2, $t2, -1
        beqz $t2, store_option
        j find_separador
    
    store_option:
        add $t2, $t0, $zero
        find_option_end:
            lb $t3, 0($t2)
            addi $t2, $t2, 1
            beqz $t3, store_option_end
            bne $t3, $t1, find_option_end
            addi $t2, $t2, -1
        
        store_option_end:
            sub $t2, $t2, $t0
            addi $t2, $t2, 1
            add $a0, $zero, $t2
            addi $v0, $zero, 9
            syscall
            addi $t2, $t2, -1
            add $a2, $zero, $t2
            add $a1, $zero, $t0
            add $a0, $zero, $v0
            addi $sp, $sp, -4
            sw $ra, 0($sp)
            jal memcpy
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra
        
    abort_get_fn_op:
        j miss_options_fn
        jr $ra



cmd_invalido_fn:                                                        # comando invalido
    la $a0, cmd_invalido
    jal print_str

    j start

miss_options_fn:
    la $a0, miss_options
    jal print_str

    j start


free: # a0: endereco 
    lb $t0, 0($a0)
    sb $zero, 0($a0)
    addi $a0, $a0, 1
    beqz $t0, end_free
    j free

    end_free:
        jr $ra
        
