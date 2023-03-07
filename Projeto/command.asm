# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 01
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues

.data
.macro stack_reg                                                                # salva registradores na stack
    addi $sp, $sp, -48
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    sw $t7, 28($sp)
    sw $a0, 32($sp)
    sw $a1, 36($sp)
    sw $a2, 40($sp)
    sw $a3, 44($sp)
.end_macro

.macro unstack_reg                                                      # recupera registradores da stackk
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $a0, 32($sp)
    lw $a1, 36($sp)
    lw $a2, 40($sp)
    lw $a3, 44($sp)
    addi $sp, $sp, 48
.end_macro



# definicao dos comandos
help: .asciiz "help"
ad_morador: .asciiz "ad_morador"
rm_morador: .asciiz "rm_morador"
salvar: .asciiz "salvar"
recarregar: .asciiz "recarregar"
info_geral: .asciiz "info_geral"
formatar: .asciiz "formatar"
limpar_ap: .asciiz "limpar_ap"

rm_auto: .asciiz "rm_auto"
ad_auto: .asciiz "ad_auto"
info_ap: .asciiz "info_ap"




.text
.globl get_fn_option, free, process_command

process_command:                                                        # funcao que processa o comando do usuario
# stack_reg                                                               # salva registradores na stack
    la $t0, input                                                       # carrega a string input
    lb $t1, 0($t0)
    beqz $t1, end_process
    addi $t1, $zero, -1                                               # tamanho do nome do comando
    la $t3, separador                                                   # carrega o char separador
    lb $t3, 0($t3)
    prcmd_loop:                                                         # loop que encontra o nome do comando
        lb $t2, 0($t0)                                                  # carrega o byte atual de input em t2
        beqz $t2, cmd_cmp                                               # se chegar no fim da string, desvia para o comparador de comando
        beq $t2, $t3, cmd_cmp                                           # se encontrar o separador, //
        addi $t0, $t0, 1                                                # incrementa o cursor da string input  
        addi $t1, $t1, 1                                                # incrementa o tamanho do nome do comando
        j prcmd_loop                                                    # iteracao do loop
    cmd_cmp:                                                            # encontra e direciona o comando a sua determinada funcao (switch-case)


        la $a0, help                                                    # carrega o nome de comando help em a0
        la $a1, input                                                   # carrega a string input em a1
        add $a3, $zero, $t1                                             # carrega o tamanho do nome do comando
        jal strncmp                                                     # chama a funcao strncmp (compara o numero n de bytes de duas strings)
        beqz $v0, help_fn                                               # se for igual (v0 = 0), encontrou a funcao e a executa
        # -------------------------------------------------------------------------------------------------------------------------------------
        la $a0, ad_morador                                              # a partir deste ponto, o programa carrega cada nome de comando 
        li $a3, 10                                                      # tamanho do comando
        jal strncmp                                                     # e compara com o informado pelo usuario
        beqz $v0, ad_morador_fn                                         # ao encontrar, direciona para o comando escolhido

        la $a0, rm_morador                                              # //
        li $a3, 10
        jal strncmp                                                     # //
        beqz $v0, rm_morador_fn                                         # //

        la $a0, ad_auto                                                 # //
        li $a3, 7
        jal strncmp                                                     # //
        beqz $v0, ad_auto_fn                                            # //

        la $a0, rm_auto                                                 # //
        li $a3, 7
        jal strncmp                                                     # //
        beqz $v0, rm_auto_fn                                            # //
        
        la $a0, salvar                                                  # //
        li $a3, 6
        jal strncmp                                                     # //
        beqz $v0, salvar_fn                                             # //

        la $a0, limpar_ap                                               # //
        li $a3, 9
        jal strncmp                                                     # //
        beqz $v0, limpar_ap_fn                                          # //

        la $a0, recarregar                                              # //
        li $a3, 10
        jal strncmp                                                     # //
        beqz $v0, recarregar_fn                                         # //

        la $a0, info_geral                                              # //
        li $a3, 10
        jal strncmp                                                     # //
        beqz $v0, info_geral_fn                                         # //

        la $a0, formatar                                                # //
        li $a3, 8
        jal strncmp                                                     # //
        beqz $v0, formatar_fn                                           # //
        
        la $a0, info_ap                                                # //
        li $a3, 7
        jal strncmp                                                     # //
        beqz $v0, info_ap_fn                                           # //

        j cmd_invalido_fn                                               # default: caso o comando nao corresponda a nenhum caso, comando invalido
    end_process:                                                        # fim da funcao
        # unstack_reg                                                     # recupera registradores da stack
        j start                                                         # inicio do programa, pronto para aguardar um novo comando



get_fn_option:
    stack_reg                                                               # salva registradores na stack                                                           # 
    add $t0, $zero, $a1                                                 # endereco da string para extrair a opcao
    la $t1, separador                                                   # carreaga o endereco do separador de opcoes
    lb $t1, 0($t1)                                                      # carrega o caracter separador em t1
    add $t2, $a0, $zero                                                 # posicao da opcao

    find_separador:                                                     # 
        lb $t3, 0($t0)                                                  # carrega o byte da iteracao atual em t3
        addi $t0, $t0, 1                                                # proximo byte
        beqz $t3, abort_get_fn_op                                       # caso o byte seja nulo, a opcao desejada esta faltando no input. Aborta
        bne $t3, $t1, find_separador                                    # caso nao seja o separados, reinicia
        addi $t2, $t2, -1                                               # incrementa a posicao desejada pelo usuario
        beqz $t2, store_option                                          # caso o contador de posicao seja 0, encontrou a opcao desejada, parte para o salvamento
        j find_separador                                                # se ainda nao for 0, reinicia o loop ate encontrar o desejado
    
    store_option:                                                       # 
        add $t2, $t0, $zero                                             # endereco do inicio da opcao
        find_option_end:                                                # encontra o final da string da opcao desejada
            lb $t3, 0($t2)                                              # carrega o byte
            addi $t2, $t2, 1                                            # proximo byte
            beqz $t3, store_option_end                                  # caso o byte seja nulo, encontrou o fim da opcao, continua 
            bne $t3, $t1, find_option_end                               # caso o byte seja o separador, encontrou o fim da opcao, continua
            addi $t2, $t2, -1                                           # decrementa
        
        store_option_end:                                               # 
            sub $t2, $t2, $t0                                           # fim - comeco = tamanho da string da opcao
            addi $t2, $t2, 1                                            # tamanho + 1 (para alocar a heap com espaco para o null final do memcpy)
            add $a0, $zero, $t2                                         # numero de bytes para alocar na heap
            addi $v0, $zero, 9                                          # aloca memoria
            syscall                                                     #
            add $v1, $zero, $t2                                         # tamanho da string da opcao no retorno v1
            addi $t2, $t2, -1                                           # decrementa para o tamanho real da string (sem null)
            add $a2, $zero, $t2                                         # tamanho da string para copia
            add $a1, $zero, $t0                                         # endereco do inicio da opcao em input (source)
            add $a0, $zero, $v0                                         # endereco alocado na heap (destination)
            addi $sp, $sp, -4                                           # salva  return address na stack
            sw $ra, 0($sp)                                              #
            jal memcpy                                                  # copia a string para o espaco alocado na memoria
            lw $ra, 0($sp)                                              # recupera return address
            addi $sp, $sp, 4                                            #
            unstack_reg                                                     # recupera registradores da stack                                                 #
            jr $ra                                                      # return

    abort_get_fn_op:                                                    # opcao informada nao encontrada
        unstack_reg                                                     # recupera registradores da stack                                                     #
        j miss_options_fn                                               #
        jr $ra                                                          # return 


free: # a0: endereco 
    stack_reg                                                               # salva registradores na stack                                                           #
    lb $t0, 0($a0)                                                      # carrega o byte em t0
    sb $zero, 0($a0)                                                    # zera o endereco
    addi $a0, $a0, 1                                                    # proximo byte
    beqz $t0, end_free                                                  # caso encontre um byte nulo, encerra
    j free                                                              # loop

    end_free:                                                           #
    unstack_reg                                                     # recupera registradores da stack                                                         #
        jr $ra                                                          # retorno
        
