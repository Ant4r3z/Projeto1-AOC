.data
help_out: .asciiz "Esta eh a lista dos comandos disponiveis\n    cmd_1. ad_morador-<ap>-<morador>: adiciona um morador ao apartamento\n"

arquivo: .asciiz "C:\\arquivos\\output.txt"
info_geral_out: .asciiz "Nao vazios:    xxxx (xxx%)\nVazios:        xxxx (xxx%)\n"

cmd_4: .asciiz "rm_auto-<apt>-<tipo>-<modelo>-<cor>\n"
cmd_4_auto_n: .asciiz "Falha: automóvel nao encontrado"
cmd_4_ap_n: .asciiz "Falha: AP invalido"
cmd_4_tipo_n: .asciiz "Falha: tipo invalido"
nao_tem_carro_pra_remover_out: .asciiz "Falha: Nao ha carros para remover"
cmd_5_limpar_ap_fn: .asciiz "limpar_ap-<apt>\n"
limpar_ap_n: .asciiz "Falha: AP invalido"
cmd_10_formatar: .asciiz "formatar"
input_file: .space 1000000

.text
.globl help_fn, ad_morador_fn, rm_morador_fn, ad_auto_fn, salvar_fn, rm_auto_fn, recarregar_fn, limpar_ap_fn, info_geral_fn, formatar_fn


help_fn:                                                                # comando help
    addi $a0, $zero, 1  # pega a opcao da posicao 1 
    la $a1, input
    jal get_fn_option   # executa a funcao
    add $t0, $zero, $v0 # escreve o endereco da opcao em $t8


    la $a0, help_out
    jal print_str

    add $a0, $zero, $t0
    jal str_to_int



    add $a0, $zero, $v0
    jal get_ap_index

    add $t1, $zero, $v0

    addi		$v0, $0, 1		# system call #1 - print int
    add		$a0, $0, $t1
    syscall						# execute

    add $a0, $zero, $t0
    jal free
    
    j start


ad_morador_fn: # adiciona um morador a um apartamento: ad_morador-<apartamento>-<nome do morador>

    # valida numero do apartamento

    addi $a0, $zero, 1  # extrai o numero do apartamento do input
    la $a1, input
    jal get_fn_option
    
    add $a0, $zero, $v0 # converte o numero do apartamento de string para inteito
    jal str_to_int
    
    add $a0, $zero, $a0 # apaga o numero do apartamento da heap
    jal free
    
    add $a0, $zero, $v0 # converte o numero do apartamento para indice
    jal get_ap_index

    add $t0, $zero, $v0 # t0: indice do apartamento 
    bltz $v0, abort_invalid_ap # caso o retorno de get_ap_index seja negativo, o apartamento não existe. abortar

    # fim
    # procedimento real

    la $t4, building            # carrega o endereço da estrutura building

    addi $t1, $zero, 40         # quantidade de bytes por apartamento
    addi $t0, $t0, -1           # subtrai 1 do apartamento
    mult	$t0, $t1			# multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					# Lo: offset do apartamento escolhido
    
    add $t4, $t4, $t2           # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    # verificacao de numero de moradores
    addi $t5, $t4, 4            # onde esta o numero de moradores
    lw $t6, 0($t5)
    bge $t6, 5, abort_exceeding_tenant

    # else
    lw $t3, 0($t5)              # load num de moradores no apt
    addi $t3, $t3, 1            # add 1
    sw $t3, 0($t5)              # retorna ao lugar

    addi $t5, $t5, 4            # onde esta o primeiro morador
    add $t7, $t5, 28            # limite do iterador (ultimo slot de morador disponivel)
    
    find_empty_space:                       # procura um slot vazio
        blt $t5, $t7, search_slot_loop      # se não chegou ao ultimo slot, pula para search_slot_loop
        j unexpected_error1_ap              # else tela de erro
    
    search_slot_loop:                       # itera os slots
        beq $t6, $zero, is_empty            # se o slot está vazio, continua
        addi $t5, $t5, 4                    # else, endereco do prox morador
        lw $t6, 0($t5)
        j find_empty_space                  # retorna ao loop

    is_empty:
        addi $a0, $zero, 2      # extrai o nome do morador de do input
        la $a1, input
        jal get_fn_option
        sw $v0, 0($t5)		    # guarda o endereco do nome do morador no slot 
        j add_morador_conclusion
        

rm_morador_fn: # remove um morador de um apartamento: rm_morador-<apartamento>-<nome do morador>

    # valida numero do apartamento

    addi $a0, $zero, 1  # extrai o numero do apartamento do input
    la $a1, input
    jal get_fn_option
    
    add $a0, $zero, $v0 # converte o numero do apartamento de string para inteito
    jal str_to_int
    
    add $a0, $zero, $a0 # apaga o numero do apartamento da heap
    jal free
    
    add $a0, $zero, $v0 # converte o numero do apartamento para indice
    jal get_ap_index

    add $t0, $zero, $v0 # t0: indice do apartamento 
    bltz $v0, abort_invalid_ap # caso o retorno de get_ap_index seja negativo, o apartamento não existe. abortar

    # fim
    # procedimento real

    la $t4, building            # carrega o endereço da estrutura building

    addi $t1, $zero, 40         # quantidade de bytes por apartamento
    addi $t0, $t0, -1           # subtrai 1 do apartamento
    mult	$t0, $t1			# multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					# Lo: offset do apartamento escolhido
    
    add $t4, $t4, $t2           # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    # verificacao de numero de moradores
    addi $t5, $t4, 4            # onde esta o numero de moradores
    lw $t6, 0($t5)
    ble $t6, 0, abort_no_tenant

    # receber o input do usuario
    addi $a0, $zero, 2          # extrai o nome do morador do input
    la $a1, input
    jal get_fn_option
    add $a0, $zero, $v0		    # $a0 recebe o endereço guardado em $v0

    # fim
    addi $t5, $t5, 4            # onde esta o primeiro morador
    add $t7, $t5, 28            # limite do iterador (ultimo slot de morador disponivel)
    
    find_tentant:                       # procura um novo slot
        blt $t5, $t7, tenant_loop       # se não chegou ao ultimo slot, pula para search_slot_loop
        j abort_tenant_not_found        # else tela de erro
    
    tenant_loop:
        lw $t6, 0($t5)                  # $t6 recebe a word armazenada em t5
        bnez $t6, compare_tenant        # se o slot nao for vazio, compare
        addi $t5, $t5, 4                # else, endereco do prox morador
        j find_tentant                  # retorna ao loop

    compare_tenant:
        add $a1, $zero, $t6             # $a1 recebe o endereço guardado em $t6
        jal strcmp                      # $a1 e $a0 são comparados
        beqz $v0, remove_tenant         # se sao iguais, remove
        addi $t5, $t5, 4                # else, endereco do prox morador
        j find_tentant                  # retorna ao loop
    
    remove_tenant:
        sw $zero, 0($t5)                # volta o valor a 0
        
        # atualiza numero de moradores
        lw $t3, 4($t4)                  # load num de moradores no apt
        addi $t3, $t3, -1               # subtrai 1
        sw $t3, 4($t4)                  # retorna ao lugar
        blez $t3, remove_all_vehicles

        j rm_morador_conclusion         # finaliza o procedimento

    remove_all_vehicles:
        sw $zero, 28($t4)
        sw $zero, 32($t4)
        sw $zero, 36($t4)

        j rm_morador_conclusion         # finaliza o procedimento

ad_auto_fn: # adiciona um automovel no apartamento: ad_auto-<apartamento>-<tipo>-<modelo>-<cor>
    # verificacoes
    # valida numero do apartamento

    addi $a0, $zero, 1  # extrai o numero do apartamento do input
    la $a1, input
    jal get_fn_option
    
    add $a0, $zero, $v0 # converte o numero do apartamento de string para inteito
    jal str_to_int
    
    add $a0, $zero, $a0 # apaga o numero do apartamento da heap
    jal free
    
    add $a0, $zero, $v0 # converte o numero do apartamento para indice
    jal get_ap_index

    add $t0, $zero, $v0 # t0: indice do apartamento 
    bltz $v0, abort_invalid_ap # caso o retorno de get_ap_index seja negativo, o apartamento não existe. abortar

    
    # 28

    
    la $t4, building    # carrega o endereçco da estrutura building

    addi $t1, $zero, 40 # quantidade de bytes por apartamento
    addi $t0, $t0, -1   # subtrai 1 do apartamento
    mult	$t0, $t1			# multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					# Lo: offset do apartamento escolhido
    
    add $t4, $t4, $t2           # soma o offset ao endereço base

    addi $t4, $t4, 28           # word do primeiro auto na estrutura ap

    addi $a0, $zero, 2          # extrai o tipo de automovel do input
    la $a1, input
    jal get_fn_option
    add $t0, $zero, $v0         # endereco da opcao 2
    add $t2, $zero, $t0         # copia para t2 para apagar depois
    lw $t0, 0($t0)              # carrega o numero ascii do character informado

    
    add $a0, $zero, $t2         # apaga a opcao 2 da heap
    jal free

    addi $t1, $zero, 99         # c ascii
    bne $t0, $t1, invalid_auto_input    # caso o tipo informado nao seja um c, pula para a proxima verificacao
    beq $t0, $t1, is_carro  # se for c, pula para o procedimento de adicionar carro
    
    invalid_auto_input:
        addi $t1, $zero, 109    # m ascii
        bne $t0, $t1, invalid_auto  # caso nao seja m nem c, o automovel e invalido. Aborta
        beq $t0, $t1, is_moto   # caso seja m, pula para o procedimento de adicionar moto



    is_carro:   
        lw $t7, 8($t4)      # carrega a flag de quantidade de automovel no apartamento
        bgtz $t7, no_space_auto         # se for maior que 0, nao ha espaco para outro carro. Aborta
        addi $t7, $zero, 1  # adiciona 1 a flag de quantidade de automovel no apartamento
        sw $t7, 8($t4)  # grava na memoria
        j continue_ad_auto  # continua o procedimento de adicionar automovel

    is_moto:
        lw $t7, 8($t4)  # carrega a flag de quantidade de automovel no apartamento
        beqz $t7, there_is_no_moto  # se for 0, nao tem nenhum veiculo, pula para o procedimento de adicionar a primeira moto
        addi $t8, $zero, 3  # flag 3 para verificacao
        beq $t7, $t8, no_space_auto # caso seja 3, ja tem duas motos, nao pode mais adicionar. Aborta
        addi $t8, $zero, 2  # flag 2 para verificacao
        beq $t7, $t8, there_is_one_moto # caso seja 2, ha uma moto e pode adicionar mais uma, segue para o procedimento


        there_is_one_moto:
        addi $t7, $zero, 3  # flag 3 para gravacao
        sw $t7, 8($t4)  # grava 3 na word de quantidade de automovel no apartamento
        addi $t4, $t4, 4    # soma o endereco para a proxima vaga de moto
        j continue_ad_auto  # pula para o procedimento de continuar

        there_is_no_moto:
        addi $t7, $zero, 2
        sw $t7, 8($t4)

    continue_ad_auto:
        la $a0, input        # Load the address of the string into $a0
        jal get_str_size       # Call the getStringSize function
        move $a0, $v0           # Copy the return value to $t0
        addi $a0, $a0, -11

        li $v0, 9
        syscall

        sw $v0, 0($t4)
        add $a2, $a0, $zero
        add $a0, $v0, $zero
        la $a1, input
        addi $a1, $a1, 11
        jal memcpy
        j start


salvar_fn:
    
    la $a0, arquivo
    li $a1, 1
    li $a2, 0
    li $v0, 13
    syscall

    add $s7, $zero, $v0 # file descriptor

    la $t0, building
    li $t1, 40  # bytes per apartment
    li $t2, 40

    write_ap:
        add $t4, $zero, $t0  # endereco base temporario

        lw $t3, 0($t0)
        add $a0, $zero, $t3
        li $a1, 4
        la $a2, buffer_int_to_str
        jal int_to_string
        move $a0, $s7
        la $a1, buffer_int_to_str
        addi $a2, $zero, 4
        li $v0, 15
        syscall
        
        move $a0, $s7
        la $a1, next_line
        addi $a2, $zero, 1
        li $v0, 15
        syscall

                # salva moradores
        li $t6, 7
        salva_dados:
            lw $t5, 8($t4)
            beqz $t6, end_salva_dados
            beqz $t5, skip_null_salva_dados

            add $a0, $zero, $t5
            jal get_str_size

            move $a0, $s7
            add $a1, $zero, $t5
            add $a2, $zero, $v0
            li $v0, 15
            syscall

            skip_null_salva_dados:
            move $a0, $s7
            la $a1, next_line
            addi $a2, $zero, 1
            li $v0, 15
            syscall

            addi $t4, $t4, 4
            addi $t6, $t6, -1
            j salva_dados

            end_salva_dados:
                addi $t4, $t4, 8
                lw $a0, 0($t4)
                li $a1, 4
                la $a2, buffer_int_to_str
                jal int_to_string

                la $t4, buffer_int_to_str
                addi $t4, $t4, 3
                move $a0, $s7
                add $a1, $zero, $t4
                addi $a2, $zero, 1
                li $v0, 15
                syscall

                

            move $a0, $s7
            la $a1, next_line
            addi $a2, $zero, 1
            li $v0, 15
            syscall
        
            

        
        add $t0, $t0, $t1
        addi $t2, $t2, -1
        blez $t2, end_write_ap
        j write_ap
    
    end_write_ap:
        
        add $a0, $zero, $s7
        li $v0, 16
        syscall

        j start

recarregar_fn:
    la $a0, arquivo
    li $a1, 0
    li $a2, 0
    li $v0, 13
    syscall

    add $s7, $zero, $v0 # file descriptor

    li $v0, 14
    add $a0, $zero, $s7
    la $a1, input_file
    li $a2, 1000000
    syscall

    la $a0, input_file
    jal print_str

    add $a0, $zero, $s7
    li $v0, 16
    syscall

    j start




rm_auto_fn:                                                                         #codigo de remover auto

    addi $a0, $zero, 1  # pega a opcao da posicao 1 
    la $a1, input
    jal get_fn_option   # executa a funcao
    add $t0, $zero, $v0 # escreve o endereco da opcao em $t8
    addi $t9, $0, 0

    add $a0, $zero, $t0
    jal str_to_int
    
    
    addi $a0, $zero, 1
    la $a1, input
    jal get_fn_option
    
    add $a0, $zero, $v0
    jal str_to_int
    
    add $a0, $zero, $a0
    jal free
    
    add $a0, $zero, $v0
    jal get_ap_index

    add $t0, $zero, $v0 # t0: numero do apartamento
    bltz $v0, abort_invalid_ap
    #----

    la $t4, building    # carrega o endereçco da estrutura building

    addi $t1, $zero, 40 # quantidade de bytes por apartamento
    addi $t0, $t0, -1   # subtrai 1 do apartamento
    mult	$t0, $t1			# multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					# Lo: offset do apartamento escolhido
    
    add $t4, $t4, $t2           # soma o offset ao endereço base

    addi $t4, $t4, 28           # word do primeiro auto na estrutura ap

    addi $a0, $zero, 2          # extrai o tipo de automovel do input
    la $a1, input
    jal get_fn_option
    add $t0, $zero, $v0         # endereco da opcao 2
    add $t2, $zero, $t0         # copia para t2 para apagar depois
    lw $t0, 0($t0)              # carrega o numero ascii do character informado

    
    add $a0, $zero, $t2         # apaga a opcao 2 da heap
    jal free
    
    addi $t1, $zero, 99         # c ascii
    bne $t0, $t1, n_e_carro    # caso o tipo informado nao seja um c, pula para a proxima verificacao
    beq $t0, $t1, is_carro_rm  # se for c, pula para o procedimento de remover carro
    
    n_e_carro:
    addi $t1, $zero, 109    # m ascii
        bne $t0, $t1, invalid_auto  # caso nao seja m nem c, o automovel e invalido. Aborta
        beq $t0, $t1, is_moto_rm
    


    is_carro_rm:
        lw $t2, 8($t4)
        beqz $t2, nao_tem_carro_pra_remover 
        j continue_rm_auto #rm carro

    is_moto_rm:
        lw $t2, 8($t4)
        li $t3, 2 
        blt $t2, $t3, nao_tem_carro_pra_remover 
        j continue_rm_auto 
 
    continue_rm_auto:
     	li $a0, 3
        la $a1, input
        jal get_fn_option
        add $t6, $zero, $v0
        li $a0, 2
        lw $a1, 0($t4)
        jal get_fn_option
        add $t7, $zero, $v0
        add $a0, $zero, $t6
        add $a1, $zero, $t7
        jal strcmp
        bnez $v0, auto_n_encontrado

        li $a0, 4
        la $a1, input
        jal get_fn_option
        add $t6, $zero, $v0
        li $a0, 3
        lw $a1, 0($t4)
        jal get_fn_option
        add $t7, $zero, $v0
        add $a0, $zero, $t6
        add $a1, $zero, $t7
        jal strcmp
        bnez $v0, auto_n_encontrado 

        lw $a0, 0($t4)
        jal free #excluiu da heap o carro
        sw $0, 0($t4)

        blt $t2, 3, removeu_unico
        beq $t2, 3, removeu_moto

        removeu_unico:
            sw $0, 8($t4)
            j start

        removeu_moto:
            li $t8, 2
            beq $t9, 0, removeu_primeira_moto
            sw $t8, 4($t4)
            j start

        removeu_primeira_moto:
            sw $t8, 8($t4)
            lw $t8, 4($t4)
            sw $zero, 4($t4)
            sw $t8, 0($t4)
            j start

        j start
    
    remover_segunda_moto:
        addi $t4,$t4, 4    
        addi $t9, $t9, 1 
        j continue_rm_auto

    nao_tem_carro_pra_remover:

        la $a0, nao_tem_carro_pra_remover_out
        jal print_str

        j start

        auto_n_encontrado:
        bnez $t9, end
        lw $t8, 8($t4) #Compara o valor da flag para verificar se possui uma segunda moto
        beq $t8, 3, remover_segunda_moto # Caso haja (3), envia para remover_segunda_moto
        end:
        la $a0, cmd_4_auto_n
        jal print_str
 
        j start

limpar_ap_method:                       # codigo de limpar apartamento

    add $t0, $a0, $zero                 # copia o valor contido em $a0 para o registrador $t0
                                        # verifica se o numero do apartamento eh valido
    ble $t0, $zero, erro_ap_invalido    # se for menor ou igual a 0 o ap eh invalido
    bgt $t0, 40, erro_ap_invalido       # se for maior que 40 o ap eh invalido
    j contador                          # se o apartamento for valido vai para o contador

    erro_ap_invalido:                   # codigo para tratar o erro de AP invalido
                                        
    li $v0, 4                           # carrega o valor 4 no registrador $v0
    la $a0, limpar_ap_n                 # carrega mensagem de ap invalido em a0
    addi $sp, $sp, -4                   # decrementa o valor do registrador $sp em 4 bytes para alocar espaço na pilha para armazenar o registrador de retorno $ra.
    sw $ra, 0($sp)                      # armazena o valor do registrador de retorno $ra na pilha      
    jal print_str                       # chama a funcao print string
    lw $ra, 0($sp)                      # carrega o valor do registrador de retorno $ra da pilha
    addi $sp, $sp, 4                    # incrementa o valor do registrador $sp em 4 bytes para liberar o espaço alocado anteriormente na pilha.
    syscall                             # imprime 

    contador:                           # funcao contador
    la $t4, building                    # carrega o endereço da estrutura building

    addi $t1, $zero, 40                 # quantidade de bytes por apartamento
    addi $t0, $t0, -1                   # subtrai 1 do apartamento
    mult $t0, $t1			            # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo $t2					        # Lo: offset do apartamento escolhido
    addi $t0, $zero, 9                  # calcula o endereço adicionando 9
    add $t4, $t4, $t2                   # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    loop_limpar:                        # loop que limpa os apartamentos
    addi $t4, $t4, 4                    # libera uma posicao na stack
    addi $t0, $t0, -1                   # apaga 
    sw $0, 0($t4)                       # salva o apartamento limpo em $t4
    bnez $t0, loop_limpar               # se o character nao for zero, reinicia a funcao loop_limpar

	fim:                                # funcao para terminar 

    jr $ra                              # return

    limpar_ap_fn:                       # funcao de limpar apartamento

    addi $a0, $zero, 1                  # adiciona o valor 1 ao registrador $zero e armazena o resultado no registrador $a0.
    la $a1, input                       # extrai o numero do apartamento do input
    jal get_fn_option                   # executa a funcao
    add $a0, $v0, $zero                 # adiciona o valor da funcao em a0
    jal str_to_int                      # chama a funcao str_to_int
    add $a0, $v0, $zero                 # copia o valor contido em $v0 para o registrador $a0
    jal get_ap_index                    # transforma o numero do apartamento em um unico numero
    add $a0, $v0, $zero                 # copia o valor contido em $v0 para o registrador $a0

    jal limpar_ap_method                # chama a funcao limpar_ap_method

    j start                             # desvia para o inicio 

info_geral_fn:

    la $t0, building                # carrega o endereco de building
    li $t1, 40                      # bytes por apartamento
    li $t2, 39                      # numero de apartamentos

    add $t3, $zero, $zero       # apartamentos vazios
    

    loop_info_geral:
        addi $t2, $t2, -1
        beqz $t2, end_info_geral    	
        lw $t4, 4($t0)              # carrega o numero de moradores do apartamento
        add $t0, $t0, $t1
        beqz $t4, loop_info_geral

        addi $t3, $t3, 1
        bnez $t2, loop_info_geral

    end_info_geral:
        li $t7, 10
        mult	$t7, $t3			# $t7 * $t3 = Hi and Lo registers
        mflo	$t8					# copy Lo to $t2
        
        li $t2, 4
        div		$t8, $t2			# $t3 / $t1
        mflo	$t2					# $t2 = floor($t3 / $t1) 

        # addi $t5, $zero, 100
        # mult	$t4, $t5			# $t4 * $t3 = Hi and Lo registers
        # mflo	$t2					# copy Lo to $t2

        add $a0, $t3, $zero
        li $a1, 4
        la $a2, buffer_int_to_str
        jal int_to_string

        la $a1, buffer_int_to_str
        la $t5, info_geral_out
        addi $a0, $t5, 15
        li $a2, 4
        jal memcpy

        la $t5, info_geral_out
        li $t6, 40
        sb $t6, 20($t5)

        # ----------------------------------

        add $a0, $t2, $zero
        li $a1, 4
        la $a2, buffer_int_to_str
        jal int_to_string

        la $a1, buffer_int_to_str
        la $t5, info_geral_out
        addi $a1, $a1, 1
        addi $a0, $t5, 21
        li $a2, 3
        jal memcpy

        la $t5, info_geral_out
        li $t6, 41
        sb $t6, 25($t5)

        # ---------------------------------

        addi $t5, $zero 40
        sub $a0, $t5, $t3
        li $a1, 4
        la $a2, buffer_int_to_str
        jal int_to_string

        la $a1, buffer_int_to_str
        la $t5, info_geral_out
        addi $a0, $t5, 42
        li $a2, 4
        jal memcpy

        la $t5, info_geral_out
        li $t6, 40
        sb $t6, 47($t5)

        # ----------------------------------

        addi $t5, $zero, 100
        sub $a0, $t5, $t2
        li $a1, 4
        la $a2, buffer_int_to_str
        jal int_to_string

        la $a1, buffer_int_to_str
        la $t5, info_geral_out
        addi $a1, $a1, 1
        addi $a0, $t5, 48
        li $a2, 3
        jal memcpy

        la $t5, info_geral_out
        li $t6, 41
        sb $t6, 52($t5)

        # ---------------------------------



        la $a0, info_geral_out
        jal print_str

        j start

formatar_fn:

    addi $t9, $zero, 0 #soma 1 ao registrador "t0" até 40 vezes
    loop_limpar_tudo: 
    addi $t9, $t9, 1 #soma 1 ao registrador "" até 40 vezes
    add $a0, $t9, $zero
    jal limpar_ap_method
    bne $t9, 40, loop_limpar_tudo
    beq $t9, 40, fim_tudo 

    fim_tudo:
    j start 