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
input_file: .space 1000000

.text
.globl help_fn, ad_morador_fn, rm_morador_fn, ad_auto_fn, salvar_fn, rm_auto_fn, recarregar_fn, limpar_ap_fn, info_geral_fn


help_fn:                                            # comando help
    addi $a0, $zero, 1                              # pega a opcao da posicao 1 
    la $a1, input
    jal get_fn_option                               # executa a funcao
    add $t0, $zero, $v0                             # escreve o endereco da opcao em $t8


    la $a0, help_out
    jal print_str

    add $a0, $zero, $t0
    jal str_to_int



    add $a0, $zero, $v0
    jal get_ap_index

    add $t1, $zero, $v0

    addi		$v0, $0, 1		                    # system call #1 - print int
    add		$a0, $0, $t1
    syscall						                    # execute

    add $a0, $zero, $t0
    jal free        

    j start     


ad_morador_fn:                                              # adiciona um morador a um apartamento: ad_morador-<apartamento>-<nome do morador>

                                                            # valida numero do apartamento

    addi $a0, $zero, 1                                      # extrai o numero do apartamento do input
    la $a1, input       
    jal get_fn_option       

    add $a0, $zero, $v0                                     # converte o numero do apartamento de string para inteito
    jal str_to_int      

    add $a0, $zero, $a0                                     # apaga o numero do apartamento da heap
    jal free        

    add $a0, $zero, $v0                                     # converte o numero do apartamento para indice
    jal get_ap_index        

    add $t0, $zero, $v0                                     # t0: indice do apartamento 
    bltz $v0, abort_invalid_ap                              # caso o retorno de get_ap_index seja negativo, o apartamento não existe. abortar

    # fim       
    # procedimento real     

    la $t4, building                                        # carrega o endereço da estrutura building

    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult	$t0, $t1			                            # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					                            # Lo: offset do apartamento escolhido

    add $t4, $t4, $t2                                       # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    # verificacao de numero de moradores        
    addi $t5, $t4, 4                                        # onde esta o numero de moradores
    lw $t6, 0($t5)      
    bge $t6, 5, abort_exceeding_tenant      

    # else      
    lw $t3, 0($t5)                                          # load num de moradores no apt
    addi $t3, $t3, 1                                        # add 1
    sw $t3, 0($t5)                                          # retorna ao lugar

    addi $t5, $t5, 4                                        # onde esta o primeiro morador
    add $t7, $t5, 28                                        # limite do iterador (ultimo slot de morador disponivel)

    find_empty_space:                                       # procura um slot vazio
        blt $t5, $t7, search_slot_loop                      # se não chegou ao ultimo slot, pula para search_slot_loop
        j unexpected_error1_ap                              # else tela de erro

    search_slot_loop:                                       # itera os slots
        beq $t6, $zero, is_empty                            # se o slot está vazio, continua
        addi $t5, $t5, 4                                    # else, endereco do prox morador
        lw $t6, 0($t5)              
        j find_empty_space                                  # retorna ao loop

    is_empty:       
        addi $a0, $zero, 2                                  # extrai o nome do morador de do input
        la $a1, input       
        jal get_fn_option       
        sw $v0, 0($t5)		                                # guarda o endereco do nome do morador no slot 
        j add_morador_conclusion        


rm_morador_fn:                                              # remove um morador de um apartamento: rm_morador-<apartamento>-<nome do morador>

    # valida numero do apartamento      

    addi $a0, $zero, 1                                      # extrai o numero do apartamento do input
    la $a1, input       
    jal get_fn_option       

    add $a0, $zero, $v0                                     # converte o numero do apartamento de string para inteito
    jal str_to_int                                  

    add $a0, $zero, $a0                                     # apaga o numero do apartamento da heap
    jal free                                    

    add $a0, $zero, $v0                                     # converte o numero do apartamento para indice
    jal get_ap_index                                    

    add $t0, $zero, $v0                                     # t0: indice do apartamento 
    bltz $v0, abort_invalid_ap                              # caso o retorno de get_ap_index seja negativo, o apartamento não existe. abortar

    # fim       
    # procedimento real     

    la $t4, building                                        # carrega o endereço da estrutura building

    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult	$t0, $t1			                            # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					                            # Lo: offset do apartamento escolhido

    add $t4, $t4, $t2                                       # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    # verificacao de numero de moradores        
    addi $t5, $t4, 4                                        # onde esta o numero de moradores
    lw $t6, 0($t5)      
    ble $t6, 0, abort_no_tenant     

    # receber o input do usuario        
    addi $a0, $zero, 2                                      # extrai o nome do morador do input
    la $a1, input                           
    jal get_fn_option                           
    add $a0, $zero, $v0		                                # $a0 recebe o endereço guardado em $v0

    # fim                           
    addi $t5, $t5, 4                                        # onde esta o primeiro morador
    add $t7, $t5, 28                                        # limite do iterador (ultimo slot de morador disponivel)

    find_tentant:                                           # procura um novo slot
        blt $t5, $t7, tenant_loop                           # se não chegou ao ultimo slot, pula para search_slot_loop
        j abort_tenant_not_found                            # else tela de erro

    tenant_loop:                    
        lw $t6, 0($t5)                                      # $t6 recebe a word armazenada em t5
        bnez $t6, compare_tenant                            # se o slot nao for vazio, compare
        addi $t5, $t5, 4                                    # else, endereco do prox morador
        j find_tentant                                      # retorna ao loop

    compare_tenant:                 
        add $a1, $zero, $t6                                 # $a1 recebe o endereço guardado em $t6
        jal strcmp                                          # $a1 e $a0 são comparados
        beqz $v0, remove_tenant                             # se sao iguais, remove
        addi $t5, $t5, 4                                    # else, endereco do prox morador
        j find_tentant                                      # retorna ao loop

    remove_tenant:                  
        sw $zero, 0($t5)                                    # volta o valor a 0

        # atualiza numero de moradores                  
        lw $t3, 4($t4)                                      # load num de moradores no apt
        addi $t3, $t3, -1                                   # subtrai 1
        sw $t3, 4($t4)                                      # retorna ao lugar
        blez $t3, remove_all_vehicles                   

        j rm_morador_conclusion                             # finaliza o procedimento

    remove_all_vehicles:                    
        sw $zero, 28($t4)                   
        sw $zero, 32($t4)                   
        sw $zero, 36($t4)                   

        j rm_morador_conclusion                             # finaliza o procedimento

ad_auto_fn:                                                 # adiciona um automovel no apartamento: ad_auto-<apartamento>-<tipo>-<modelo>-<cor>
    # verificacoes      
    # valida numero do apartamento      

    addi $a0, $zero, 1                                      # extrai o numero do apartamento do input
    la $a1, input                                   
    jal get_fn_option                                   

    add $a0, $zero, $v0                                     # converte o numero do apartamento de string para inteito
    jal str_to_int                                  

    add $a0, $zero, $a0                                     # apaga o numero do apartamento da heap
    jal free                                    

    add $a0, $zero, $v0                                     # converte o numero do apartamento para indice
    jal get_ap_index                                    

    add $t0, $zero, $v0                                     # t0: indice do apartamento 
    bltz $v0, abort_invalid_ap                              # caso o retorno de get_ap_index seja negativo, o apartamento não existe. abortar


    # 28        


    la $t4, building                                        # carrega o endereçco da estrutura building

    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult	$t0, $t1			                            # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					                            # Lo: offset do apartamento escolhido

    add $t4, $t4, $t2                                       # soma o offset ao endereço base

    addi $t4, $t4, 28                                       # word do primeiro auto na estrutura ap

    addi $a0, $zero, 2                                      # extrai o tipo de automovel do input
    la $a1, input                           
    jal get_fn_option                           
    add $t0, $zero, $v0                                     # endereco da opcao 2
    add $t2, $zero, $t0                                     # copia para t2 para apagar depois
    lw $t0, 0($t0)                                          # carrega o numero ascii do character informado


    add $a0, $zero, $t2                                     # apaga a opcao 2 da heap
    jal free        

    addi $t1, $zero, 99                                     # c ascii
    bne $t0, $t1, invalid_auto_input                        # caso o tipo informado nao seja um c, pula para a proxima verificacao
    beq $t0, $t1, is_carro                                  # se for c, pula para o procedimento de adicionar carro

    invalid_auto_input:     
        addi $t1, $zero, 109                                # m ascii
        bne $t0, $t1, invalid_auto                          # caso nao seja m nem c, o automovel e invalido. Aborta
        beq $t0, $t1, is_moto                               # caso seja m, pula para o procedimento de adicionar moto



    is_carro:           
        lw $t7, 8($t4)                                      # carrega a flag de quantidade de automovel no apartamento
        bgtz $t7, no_space_auto                             # se for maior que 0, nao ha espaco para outro carro. Aborta
        addi $t7, $zero, 1                                  # adiciona 1 a flag de quantidade de automovel no apartamento
        sw $t7, 8($t4)                                      # grava na memoria
        j continue_ad_auto                                  # continua o procedimento de adicionar automovel

    is_moto:        
        lw $t7, 8($t4)                                      # carrega a flag de quantidade de automovel no apartamento
        beqz $t7, there_is_no_moto                          # se for 0, nao tem nenhum veiculo, pula para o procedimento de adicionar a primeira moto
        addi $t8, $zero, 3                                  # flag 3 para verificacao
        beq $t7, $t8, no_space_auto                         # caso seja 3, ja tem duas motos, nao pode mais adicionar. Aborta
        addi $t8, $zero, 2                                  # flag 2 para verificacao
        beq $t7, $t8, there_is_one_moto                     # caso seja 2, ha uma moto e pode adicionar mais uma, segue para o procedimento


        there_is_one_moto:      
        addi $t7, $zero, 3                                  # flag 3 para gravacao
        sw $t7, 8($t4)                                      # grava 3 na word de quantidade de automovel no apartamento
        addi $t4, $t4, 4                                    # soma o endereco para a proxima vaga de moto
        j continue_ad_auto                                  # pula para o procedimento de continuar

        there_is_no_moto:       
        addi $t7, $zero, 2      
        sw $t7, 8($t4)      

    continue_ad_auto:       
        la $a0, input                                       # Load the address of the string into $a0
        jal get_str_size                                    # Call the getStringSize function
        move $a0, $v0                                       # Copy the return value to $t0
        addi $a0, $a0, -11                                  # Ignora o inicio do input

        li $v0, 9                                           # aloca memoria
        syscall     

        sw $v0, 0($t4)                                      # registra o endereco do automovel no apartamento
        add $a2, $a0, $zero                                 # a2 <- a0: tamanho da string
        add $a0, $v0, $zero                                 # a0 <- v0: endereco alocado na heap (destino)
        la $a1, input                                       # fonte
        addi $a1, $a1, 11                                   # offset (ignora inicio do input)
        jal memcpy                                          # copia
        j start                                             # reinicia a execucao


salvar_fn:      

    la $a0, arquivo                                         # abre o arquivo em modo de escrita
    li $a1, 1       
    li $a2, 0       
    li $v0, 13      
    syscall     

    add $s7, $zero, $v0                                     # file descriptor

    la $t0, building        
    li $t1, 40                                              # bytes per apartment
    li $t2, 40                                              # numero de apartamentos

    write_ap:       
        add $t4, $zero, $t0                                 # endereco base temporario

        lw $t3, 0($t0)                                      # carrega o numero do apartamento no endereco em t0
        add $a0, $zero, $t3                                 # move o numero carregado para a0
        li $a1, 4                                           # numero de bytes 
        la $a2, buffer_int_to_str                           # endereco do buffer de destino da funcao inteiro para string
        jal int_to_string                                   # executa a funcao int to string
        move $a0, $s7                                       # file descriptor
        la $a1, buffer_int_to_str                           # endereco da string para ser escrita no arquivo
        addi $a2, $zero, 4                                  # 4 bytes para escrita
        li $v0, 15                                          # escreve no arquivo
        syscall     

        jal break_line_arquivo                              # pula uma linha no arquivo

        lw $a0, 4($t4)                                      # escreve o numero de moradores do apartamento no arquivo
        li $a1, 4                                           #
        la $a2, buffer_int_to_str                           #
        jal int_to_string                                   # converte o numero de moradores de int para string

        la $t9, buffer_int_to_str                           # escreve o numero de moradores no arquivo
        addi $a1, $t9, 3                                    #
        move $a0, $s7                                       #
        addi $a2, $zero, 1                                  # apenas o ultimo byte é escrito (o numero maximo de moradores e 5)
        li $v0, 15                                          # 
        syscall                                             #


        jal break_line_arquivo                              # pula uma linha o arquivo


                # salva moradores       
        li $t6, 7                                           # contador
        salva_dados:                                        # armazena as strings apontadas na estrutura building no arquivo (moradores e automoveis)
            lw $t5, 8($t4)                                  # carrega o endereco da string salva no apartamento
            beqz $t6, end_salva_dados                       # caso o contador seja 0, encerra
            beqz $t5, skip_null_salva_dados                 # caso o endereco esteja vazio, desvia das instrucoes de salvamento 

            add $a0, $zero, $t5                             # calcula o tamanho da string carregada
            jal get_str_size                                #

            move $a0, $s7                                   # escreve a string no arquivo
            add $a1, $zero, $t5                             #
            add $a2, $zero, $v0                             #
            li $v0, 15                                      #
            syscall                                         #

            skip_null_salva_dados:                          # 
            jal break_line_arquivo                          # pula uma linha no arquivo

            addi $t4, $t4, 4                                # proxima word de building
            addi $t6, $t6, -1                               # decrementa o contador
            j salva_dados                                   # reinicia o loop

            end_salva_dados:                                # 
                addi $t4, $t4, 8                            # chega a word com a flag de automovel
                lw $a0, 0($t4)                              # carrega a flag
                li $a1, 4                                   #
                la $a2, buffer_int_to_str                   # 
                jal int_to_string                           # converte a flag para string

                la $t4, buffer_int_to_str                   # salva a flag no arquivo
                addi $t4, $t4, 3                            # apenas o ultimo byte (a flag vai ate 3)
                move $a0, $s7                               #
                add $a1, $zero, $t4                         #
                addi $a2, $zero, 1                          #
                li $v0, 15                                  #
                syscall                                     #



            jal break_line_arquivo                          # pula uma linha no arquivo




        add $t0, $t0, $t1                                   # soma 40 ao endereco salvo de building para chegar ao proximo apartamento
        addi $t2, $t2, -1                                   # decrementa o contador
        blez $t2, end_write_ap                              # caso o contador chegue a 0, encerra
        j write_ap                                          # reinicia o loop

    break_line_arquivo:                                     # escrene \n (ascii 10) no arquivo
        move $a0, $s7                                       # file descriptor
        la $a1, next_line                                   # \n
        addi $a2, $zero, 1                                  # um byte para escrita
        li $v0, 15                                          # escreve
        syscall                                             #
        jr $ra                                              # retorno

    end_write_ap:                                           #

        add $a0, $zero, $s7                                 # file descriptor
        li $v0, 16                                          # fecha o arquivo
        syscall                                             #

        j start                                             # volta ao inicio do programa

recarregar_fn:
    la $a0, arquivo                                         # abre o arquivo em modo de leitura
    li $a1, 0
    li $a2, 0
    li $v0, 13
    syscall

    add $s7, $zero, $v0                                     # file descriptor

    li $v0, 14                                              # lê o arquivo para input_file
    add $a0, $zero, $s7                                     
    la $a1, input_file
    li $a2, 1000000
    syscall

    la $t0, input_file                                      # endereco de input_file em t0
    la $t1, building                                        # endereco de building em t1

    li $t2, 40                                              # numero de apartamentos

    load_ap:
        beqz $t2, end_recaregar
        # addi $t0, $t0, 5                                  # endereco base temporario + numero do apartamento
        jal find_next_line                                  # busca por um \n
        add $a0, $zero, $t0
        jal str_to_int                                      # converte o numero de moradores de string para int
        addi $t4, $t1, 4
        sw $v0, 0($t4)                                      # salva o numero de moradores carregado no apartamento

        li $t3,  8                                          # contador de moradores
        load_moradores:
            jal find_next_line                              # busca por um \n
            addi $t3, $t3, -1

            addi $t4, $t4, 4

            beqz $t3, fim_load_moradores                    # caso t3 seja 0, fim dos moradores
            add $a0, $t0, $zero                             # conta o tamanho da string do morador
            jal get_str_size  
            beqz $v0, load_moradores                        # caso o tamanho do nome do morador seja 0, nao ha morador, pula para o proximo
            
            add $a0, $t0, $zero                             # conta o tamanho da string do morador
            jal get_str_size                                # 
            addi $a0, $v0, 1                                # tamanho do nome do morador em a0
            addi $t5, $v0, 1                                # tamanho do nome do morador em a0
            li $v0, 9                                       # aloca a memoria na heap
            syscall

            sw $v0, 0($t4)                                  # salva o endereco no apartamento
            
            add $a0, $zero, $v0                             # destination: v0
            add $a1, $zero, $t0                             # source: t0
            add $a2, $zero, $t5                             # tamanho da string
            jal memcpy                                      # copia
            j load_moradores
        
        fim_load_moradores:
            # jal find_next_line
            add $a0, $zero, $t0
            jal str_to_int
            sw $v0, 0($t4)


            jal find_next_line




        addi $t1, $t1, 40
        addi $t2, $t2, -1
        beqz $t2, end_recaregar
        j load_ap


    
    end_recaregar:
    add $a0, $zero, $s7                                     # fecha o arquivo
    li $v0, 16
    syscall

    j start


find_next_line:
    add $t9, $t9, $zero                                     # inicia o contador
    
    loop_find_nl:
        lb $t7, 0($t0)                                      # carrega o byte atual de input_file
        beq $t7, 10, fim_find_nl                            # caso chegou em um \n, finaliza
        addi $t9, $t9, 1                                    # incrementa o contador
        addi $t0, $t0, 1                                    # proximo byte em t0
        j loop_find_nl

    fim_find_nl:
        addi $t0, $t0, 1
        add $v0, $t9, $zero
        jr $ra



rm_auto_fn:                                                 #codigo de remover auto

    addi $a0, $zero, 1                                      # pega a opcao da posicao 1 
    la $a1, input                                   
    jal get_fn_option                                       # executa a funcao
    add $t0, $zero, $v0                                     # escreve o endereco da opcao em $t8
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

    add $t0, $zero, $v0                                     # t0: numero do apartamento
    bltz $v0, abort_invalid_ap
    #----

    la $t4, building                                        # carrega o endereçco da estrutura building
                                    
    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult	$t0, $t1			                            # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					                            # Lo: offset do apartamento escolhido

    add $t4, $t4, $t2                                       # soma o offset ao endereço base

    addi $t4, $t4, 28                                       # word do primeiro auto na estrutura ap

    addi $a0, $zero, 2                                      # extrai o tipo de automovel do input
    la $a1, input
    jal get_fn_option
    add $t0, $zero, $v0                                     # endereco da opcao 2
    add $t2, $zero, $t0                                     # copia para t2 para apagar depois
    lw $t0, 0($t0)                                          # carrega o numero ascii do character informado


    add $a0, $zero, $t2                                     # apaga a opcao 2 da heap
    jal free                            

    addi $t1, $zero, 99                                     # c ascii
    bne $t0, $t1, n_e_carro                                 # caso o tipo informado nao seja um c, pula para a proxima verificacao
    beq $t0, $t1, is_carro_rm                               # se for c, pula para o procedimento de remover carro
    
    n_e_carro:
    addi $t1, $zero, 109                                    # m ascii
        bne $t0, $t1, invalid_auto                          # caso nao seja m nem c, o automovel e invalido. Aborta
        beq $t0, $t1, is_moto_rm                            # caso seja m, executa
    


    is_carro_rm:
        lw $t2, 8($t4)                                      # carrega a flag
        beqz $t2, nao_tem_carro_pra_remover                 # caso a flag seja 0, nao ha automoveis na garagem
        j continue_rm_auto                                  # executa a remocao do automovel

    is_moto_rm:
        lw $t2, 8($t4)                                      # carrega a flag
        li $t3, 2                                           
        blt $t2, $t3, nao_tem_carro_pra_remover             # caso a flag seja menor que 2, nao ha moto para ser removida
        j continue_rm_auto                                  # executa a remocao do automovel
 
    continue_rm_auto:
     	li $a0, 3                                           # pega o modelo do automovel do input
        la $a1, input                                       # 
        jal get_fn_option                                   # 
        add $t6, $zero, $v0                                 # salva o endereco da string em t6
        li $a0, 2                                           # pega o modelo do automovel salvo
        lw $a1, 0($t4)
        jal get_fn_option
        add $t7, $zero, $v0                                 # salva o endereco da string em t7
        add $a0, $zero, $t6                                 # compara o modelo informado com o que esta salvo
        add $a1, $zero, $t7                                 #
        jal strcmp                                          
        bnez $v0, auto_n_encontrado                         # caso o retorno nao seja 0, o automovel nao foi encontrado

        li $a0, 4                                           # pega a cor do automovel do input
        la $a1, input                                       
        jal get_fn_option
        add $t6, $zero, $v0                                 # salva o endereco em t6
        li $a0, 3                                           # pega a cor do automovel salvo
        lw $a1, 0($t4)                                      # 
        jal get_fn_option
        add $t7, $zero, $v0                                 # compara as cores
        add $a0, $zero, $t6
        add $a1, $zero, $t7
        jal strcmp
        bnez $v0, auto_n_encontrado                         # caso nao seja igual, aborta

        lw $a0, 0($t4)                                      # apaga os dados do carro
        jal free #excluiu da heap o carro
        sw $0, 0($t4)

        blt $t2, 3, removeu_unico                           # caso a flag seja menor que 3, ha apenas um carro ou uma moto
        beq $t2, 3, removeu_moto                            # caso seja 3, ha duas motos e uma delas saira

        removeu_unico:
            sw $0, 8($t4)                                   # zera o endereco do primeiro automovel do apartamento
            j start

        removeu_moto:
            li $t8, 2                                       # flag 2 para registrar
            beq $t9, 0, removeu_primeira_moto               # caso t9 seja 0, significa que a primeira moto foi removida
            sw $t8, 4($t4)                                  # altera a flag para 2 (uma moto)
            j start

        removeu_primeira_moto:
            sw $t8, 8($t4)                                  # altera a flag para 2 (uma moto)
            lw $t8, 4($t4)                                  # carrega o endereco da segunda moto
            sw $zero, 4($t4)                                # zera o endereco da primeira moto
            sw $t8, 0($t4)                                  # guarda o endereco da segunda moto na primeira posicao
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
        lw $t8, 8($t4)                                      #Compara o valor da flag para verificar se possui uma segunda moto
        beq $t8, 3, remover_segunda_moto                    # Caso haja (3), envia para remover_segunda_moto
        end:
        la $a0, cmd_4_auto_n
        jal print_str
 
        j start

limpar_ap_fn: 

    addi $a0, $zero, 1
    la $a1, input
    jal get_fn_option                                       # executa a funcao
    add $a0, $v0, $zero                                     # adiciona o valor da funcao em a0
    jal str_to_int
    add $a0, $v0, $zero

    jal get_ap_index                                        # Transforma o numero do apartamento em um unico numero
    add $t0, $v0, $zero 
    

    ble $t0, $zero, erro_ap_invalido                        # verifica se o nÃºmero do apartamento Ã© vÃ¡lido
    bgt $t0, 40, erro_ap_invalido
    j contador

    erro_ap_invalido:
    # cÃ³digo para tratar o erro de AP invÃ¡lido
    li $v0, 4
    la $a0, limpar_ap_n
    jal print_str
    syscall

    contador:
    la $t4, building                                        # carrega o endereço da estrutura building

    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult $t0, $t1			                                # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo $t2					                            # Lo: offset do apartamento escolhido
    addi $t0, $zero, 9                          
    add $t4, $t4, $t2                                       # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    loop_limpar:
    addi $t4, $t4, 4
    addi $t0, $t0, -1
    sw $0, 0($t4)
    bnez $t0, loop_limpar

	fim:

    j start        

info_geral_fn:

    la $t0, building                                        # carrega o endereco de building
    li $t1, 40                                              # bytes por apartamento
    li $t2, 39                                              # numero de apartamentos
                        
    add $t3, $zero, $zero                                   # apartamentos vazios
                            
                        
    loop_info_geral:                        
        addi $t2, $t2, -1                       
        beqz $t2, end_info_geral                            	
        lw $t4, 4($t0)                                      # carrega o numero de moradores do apartamento
        add $t0, $t0, $t1                       
        beqz $t4, loop_info_geral                       
                        
        addi $t3, $t3, 1                        
        bnez $t2, loop_info_geral                       
                        
    end_info_geral:                     
        li $t7, 10                      
        mult	$t7, $t3			                        # $t7 * $t3 = Hi and Lo registers
        mflo	$t8					                        # copy Lo to $t2
                                
        li $t2, 4                       
        div		$t8, $t2			                        # $t3 / $t1
        mflo	$t2					                        # $t2 = floor($t3 / $t1) 
                        
        # addi $t5, $zero, 100                      
        # mult	$t4, $t5			                        # $t4 * $t3 = Hi and Lo registers
        # mflo	$t2					                        # copy Lo to $t2

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


        
        