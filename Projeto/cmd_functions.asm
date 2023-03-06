.data
help_out: .asciiz "Esta eh a lista dos comandos disponiveis\n    cmd_1. ad_morador-<ap>-<morador>: adiciona um morador ao apartamento\n    cmd_2. rm_morador-<ap>-<morador>: remove um morador do apartamento\n    cmd_3. ad_auto-<ap>-<tipo>-<modelo>-<cor>: adiciona um carro ou uma moto ao apartamento\n    cm4_4. rm_auto-<ap>-<tipo>-<modelo>-<cor>: remove um carro ou uma moto ao apartamento\n    cmd_5. limpar_ap-<ap>: limpa todos os dados de um apartamento\n    cmd_6. info_ap-<ap>: detalha os dados do apartamento\n    cmd_7. info_geral: panorama geral de apartamentos varios e nao vazios\n    cmd_8. salvar: salva os dados do programa em um arquivo externo\n    cmd_9. recarregar: recarrega os dados do arquivo externo\n    cmd_10. formatar: apaga todas as informacoes atuais do programa sem excluir do arquivo\n"                                                                                                                        

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


help_fn:                                            # comando help
    la $a0, help_out
    jal print_str

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

               
    lw $t7, 8($t4)                                          # carrega a flag de quantidade de automovel no apartamento
    beq $t7, 1, no_space_auto                               # se for maior que 0, nao ha espaco para outro carro. Aborta

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
        j auto_adicionado                                   # reinicia a execucao


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

        j salvo                                             # volta ao inicio do programa

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
            add $a0, $zero, $t0                             # converte a string com a flag de automoveis no buffer do arquivo para inteiro
            jal str_to_int                                  # 
            sw $v0, 0($t4)                                  # 


            jal find_next_line                              # pula uma linha do arquivo




        addi $t1, $t1, 40                                   # proximo apartamento
        addi $t2, $t2, -1                                   # decrementa o contador de apartamentos
        beqz $t2, end_recaregar                             # quando o contador chega a 0, encerra
        j load_ap                                           # reinicia o loop


    
    end_recaregar:
    add $a0, $zero, $s7                                     # fecha o arquivo
    li $v0, 16                                              #
    syscall                                                 #

    j recarregado                                                 # volta ao inicio do programa


find_next_line:                                             # pula para a proxima linha no buffer do arquivo
    add $t9, $t9, $zero                                     # inicia o contador
    
    loop_find_nl:
        lb $t7, 0($t0)                                      # carrega o byte atual de input_file
        beq $t7, 10, fim_find_nl                            # caso chegou em um \n, finaliza
        addi $t9, $t9, 1                                    # incrementa o contador
        addi $t0, $t0, 1                                    # proximo byte em t0
        j loop_find_nl                                      # reinicia o loop

    fim_find_nl:
        addi $t0, $t0, 1                                    # endereco do inicio da proxima linha
        add $v0, $t9, $zero                                 # retorna o tamanho da linha
        jr $ra                                              # 



rm_auto_fn:                                                 #codigo de remover auto

    addi $a0, $zero, 1                                      # pega a opcao da posicao 1 
    la $a1, input                                   
    jal get_fn_option                                       # executa a funcao
    add $t0, $zero, $v0                                     # escreve o endereco da opcao em $t8
    addi $t9, $0, 0                                 

    add $a0, $zero, $t0                                     # Utilizado para converter a string armazenada em t0 em um inteiro
    jal str_to_int                                          # chama a funcao str_to_int


    addi $a0, $zero, 1                                      # Extrai o numero do apartamento do imput
    la $a1, input                                           # input do terminal 
    jal get_fn_option                                       # chama a funcao get_fn_option

    add $a0, $zero, $v0                                     #adiciona o string contido em v0 para o a0 para converter em inteiro
    jal str_to_int                                          # chama a funcao str_to_int

    add $a0, $zero, $a0                                     # apaga o numero do apartamento da heap
    jal free                                                # chama a funcao free

    add $a0, $zero, $v0                                     # converte o numero do apartamento para indice
    jal get_ap_index                                        # chama a funcao get_ap_index

    add $t0, $zero, $v0                                     # t0: numero do apartamento
    bltz $v0, abort_invalid_ap                               # chama a funcao abort_invalid_ap
    #----

    la $t4, building                                        # carrega o endereçco da estrutura building
                                    
    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult	$t0, $t1			                            # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo	$t2					                            # Lo: offset do apartamento escolhido

    add $t4, $t4, $t2                                       # soma o offset ao endereço base

    addi $t4, $t4, 28                                       # word do primeiro auto na estrutura ap

    addi $a0, $zero, 2                                      # extrai o tipo de automovel do input
    la $a1, input                                           # input no terminal
    jal get_fn_option                                       # chama a funcao get_fn_option
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
        bne $t0, $t1, invalid_auto                          # caso nao seja m nem c, o automovel eh invalido. Aborta
        beq $t0, $t1, is_moto_rm                            # caso seja m em ambos os registradores, se valida como moto
    


    is_carro_rm:
        lw $t2, 8($t4)                                      # carrega a flag
        beqz $t2, nao_tem_carro_pra_remover                 # caso a flag seja 0, nao ha automoveis na garagem
        j continue_rm_auto                                  # executa a remocao do automovel

    is_moto_rm:
        lw $t2, 8($t4)                                      # carrega a flag de quantidade de automovel no apartamento
        li $t3, 2                                           # carrega imediatamente o valor 2 no registrador t3 para adereçar se existe mais de uma moto
        blt $t2, $t3, nao_tem_carro_pra_remover             # caso comparando que que o registrador t2 tenha menos moto que o t3, o qual foi feito para ter uma moto, se leva ao label de sem automovel
        j continue_rm_auto                                  #continua a remocao
 
    continue_rm_auto:
     	li $a0, 3                                           # Carrega a flag (3) do veiculo
        la $a1, input                                       # input para digitar o veiculo que será removido
        jal get_fn_option                                   # usa a funcao get_fn_option
        add $t6, $zero, $v0                                 # zera o registrador t6
        li $a0, 2                                           # carrega a flag (2) do veiculo
        lw $a1, 0($t4)                                      # carrega o valor de t4 em a1
        jal get_fn_option                                   # chama a funcao get_fn_option
        add $t7, $zero, $v0                                 # compara o c/m salvo com o digitado
        add $a0, $zero, $t6                                 # compara a cor salva com a digitada
        add $a1, $zero, $t7                                 # compara o modelo salvo com o digitado
        jal strcmp                                          # chama a funcao strcmp
        bnez $v0, auto_n_encontrado                         # se nao se igualar a zero, ir para a funcao auto_n_encontrado

        li $a0, 4                                           # carrega a flag (4) do veiculo
        la $a1, input                                       # input para digitar o veiculo que será removido
        jal get_fn_option                                   # usa a funcao get_fn_option
        add $t6, $zero, $v0                                 # zera o registrador t6
        li $a0, 3                                           # carrega a flag (3) do veiculo
        lw $a1, 0($t4)                                      # carrega o valor de t4 em a1
        jal get_fn_option                                   # chama a funcao get_fn_option
        add $t7, $zero, $v0                                 # compara o c/m salvo com o digitado
        add $a0, $zero, $t6                                 # compara a cor salva com a digitada
        add $a1, $zero, $t7                                 # compara o modelo salvo com o digitado
        jal strcmp                                          # chama a funcao strcmp
        bnez $v0, auto_n_encontrado                         # se nao se igualar a zero, ir para a funcao auto_n_encontrado

        lw $a0, 0($t4)                                      # Carrega o valor de t4 em a0
        jal free                                            # excluiu da heap o carro
        sw $0, 0($t4)                                       # transfere o valor de t4 para a memória o zerando

        blt $t2, 3, removeu_unico                           # caso o valor seja menor que a flag 3, removeu unico veiculo
        beq $t2, 3, removeu_moto                            # caso o valor seja igual, vamos ver se há uma ou mais motos estacionadas

        removeu_unico:
            sw $0, 8($t4)                                   # transfere o valor de t4 para a memoria o zerando
            j start                                         # fim

        removeu_moto:                           
            li $t8, 2                                       # carrega a flag de moto em t8
            beq $t9, 0, removeu_primeira_moto               # envia para o chamado de remover primeira moto
            sw $t8, 4($t4)                                  # transfere o valor de t4 para t8 para relacionar com a possibilidade de remover mais de uma moto
            j start                                         # fim

        removeu_primeira_moto:                          
            sw $t8, 8($t4)                                  # carrega o registrador da moto da segunda opção
            lw $t8, 4($t4)                                  # carrega o valor no registrador t8
            sw $zero, 4($t4)                                # carrega a flag 4
            sw $t8, 0($t4)                                  # zera o valor da primeira moto
            j start                                         # fim

        j start                                             # fim 

    remover_segunda_moto:                           
        addi $t4,$t4, 4                                     # adiciona o valor de mais um veículo   
        addi $t9, $t9, 1                                    # adiciona mais uma moto no stack
        j continue_rm_auto                                  # chama funcao para continuar a remocao

    nao_tem_carro_pra_remover:

        la $a0, nao_tem_carro_pra_remover_out               # carrega a string de nao haver carro para remover
        jal print_str                                       # imprime tal string

        j start                                             # conclui o comando

        auto_n_encontrado:                          
        bnez $t9, end                                       # caso não haja mais veículo na memória, ir para o fim
        lw $t8, 8($t4)                                      # Compara o valor da flag para verificar se possui uma segunda moto
        beq $t8, 3, remover_segunda_moto                    # Caso haja (3), envia para remover_segunda_moto
        end:                                                # funcao para acabar
        la $a0, cmd_4_auto_n                                # carrega a string de automovel nao encontrado
        jal print_str                                       # imprime tal string

        j start                                             # conclui o comando

limpar_ap_method:                                           # codigo de limpar apartamento

    add $t0, $a0, $zero                                     # copia o valor contido em $a0 para o registrador $t0
                                                            # verifica se o numero do apartamento eh valido
    ble $t0, $zero, erro_ap_invalido                        # se for menor ou igual a 0 o ap eh invalido
    bgt $t0, 40, erro_ap_invalido                           # se for maior que 40 o ap eh invalido
    j contador                                              # se o apartamento for valido vai para o contador

    erro_ap_invalido:                                       # codigo para tratar o erro de AP invalido

    li $v0, 4                                               # carrega o valor 4 no registrador $v0
    la $a0, limpar_ap_n                                     # carrega mensagem de ap invalido em a0
    addi $sp, $sp, -4                                       # decrementa o valor do registrador $sp em 4 bytes para alocar espaço na pilha para armazenar o registrador de retorno $ra.
    sw $ra, 0($sp)                                          # armazena o valor do registrador de retorno $ra na pilha      
    jal print_str                                           # chama a funcao print string
    lw $ra, 0($sp)                                          # carrega o valor do registrador de retorno $ra da pilha
    addi $sp, $sp, 4                                        # incrementa o valor do registrador $sp em 4 bytes para liberar o espaço alocado anteriormente na pilha.
    syscall                                                 # imprime 

    contador:                                               # funcao contador
    la $t4, building                                        # carrega o endereço da estrutura building

    addi $t1, $zero, 40                                     # quantidade de bytes por apartamento
    addi $t0, $t0, -1                                       # subtrai 1 do apartamento
    mult $t0, $t1			                                # multiplica o numero de bytes do apartamento pelo indice do apartamento
    mflo $t2					                            # Lo: offset do apartamento escolhido
    addi $t0, $zero, 9                                      # calcula o endereço adicionando 9
    add $t4, $t4, $t2                                       # soma o offset ao endereço base (gera o primeiro byte do apartamento)

    loop_limpar:                                            # loop que limpa os apartamentos
    addi $t4, $t4, 4                                        # libera uma posicao na stack
    addi $t0, $t0, -1                                       # apaga 
    sw $0, 0($t4)                                           # salva o apartamento limpo em $t4
    bnez $t0, loop_limpar                                   # se o character nao for zero, reinicia a funcao loop_limpar

	fim:                                                    # funcao para terminar 

    jr $ra                                                  # return

    limpar_ap_fn:                                           # funcao de limpar apartamento

    addi $a0, $zero, 1                                      # adiciona o valor 1 ao registrador $zero e armazena o resultado no registrador $a0.
    la $a1, input                                           # extrai o numero do apartamento do input
    jal get_fn_option                                       # executa a funcao
    add $a0, $v0, $zero                                     # adiciona o valor da funcao em a0
    jal str_to_int                                          # chama a funcao str_to_int
    add $a0, $v0, $zero                                     # copia o valor contido em $v0 para o registrador $a0
    jal get_ap_index                                        # transforma o numero do apartamento em um unico numero
    add $a0, $v0, $zero                                     # copia o valor contido em $v0 para o registrador $a0

    jal limpar_ap_method                                    # chama a funcao limpar_ap_method

    j start                                                 # desvia para o inicio 

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
        mflo	$t8					                        # numero de apartamentos vazios * 10
                                
        li $t2, 4                       
        div		$t8, $t2			                        # $t3 / $t1
        mflo	$t2					                        # aps vazios * 10 / 4 = porcentagem de apartamentos vazios
      
        add $a0, $t3, $zero                                 # numero de apartamentos vazios
        li $a1, 4                                           # converte o numero de apartamentos vazios para string
        la $a2, buffer_int_to_str                           # 
        jal int_to_string                                   # 

        la $a1, buffer_int_to_str                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_out                              # carrega o endereco do texto de info geral
        addi $a0, $t5, 15                                   # offset 15: campo com o numero de apartamentos nao vazios
        li $a2, 4                                           # 4 bytes para copia
        jal memcpy                                          # copia o numero para o texto de info geral
 
        la $t5, info_geral_out                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 40                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 20($t5)                                     # 

        # ----------------------------------

        add $a0, $t2, $zero                                 # porcentagem de apartamentos nao vazios
        li $a1, 4                                           # converte a pocentagem de apartamentos vazios para string
        la $a2, buffer_int_to_str                           # 
        jal int_to_string                                   #

        la $a1, buffer_int_to_str                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_out                              # carrega o endereco do texto de info geral
        addi $a1, $a1, 1                                    # offset para apenas 3 bytes serem copiados
        addi $a0, $t5, 21                                   # offset 21: campo com a porcentagem de apartamentos nao vazios
        li $a2, 3                                           # tamanho da string para copia
        jal memcpy                                          # 

        la $t5, info_geral_out                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 41                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 25($t5)                                     #

        # ---------------------------------

        addi $t5, $zero 40                                  # obtem o complemento de apartamentos vazios
        sub $a0, $t5, $t3                                   #
        li $a1, 4                                           # converte a pocentagem de apartamentos vazios para string
        la $a2, buffer_int_to_str                           #
        jal int_to_string                                   #

        la $a1, buffer_int_to_str                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_out                              # carrega o endereco do texto de info geral
        addi $a0, $t5, 42                                   # offset 42: campo com o numero de apartamentos vazios
        li $a2, 4                                           # 4 bytes para copia
        jal memcpy                                          # copia o numero para o texto de info geral

        la $t5, info_geral_out                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 40                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 47($t5)                                     #

        # ----------------------------------

        addi $t5, $zero, 100                                # obtem o complemento da porcentagem
        sub $a0, $t5, $t2                                   #
        li $a1, 4                                           # converte a pocentagem de apartamentos vazios para string
        la $a2, buffer_int_to_str                           # carrega o endereco do numero convertido para string
        jal int_to_string                                   #

        la $a1, buffer_int_to_str                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_out                              # carrega o endereco do texto de info geral
        addi $a1, $a1, 1                                    # offset para apenas 3 bytes serem copiados
        addi $a0, $t5, 48                                   # offset 48: campo com a porcentagem de apartamentos nao vazios
        li $a2, 3                                           # tamanho da string para copia
        jal memcpy                                          #

        la $t5, info_geral_out                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 41                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 52($t5)                                     #

        # ---------------------------------



        la $a0, info_geral_out                              # imprime info geral 
        jal print_str                                       #

        j start                                             # volta para o inicio do programa

formatar_fn:

    addi $t9, $zero, 0                                      #soma 1 ao registrador "t0" até 40 vezes
    loop_limpar_tudo: 
    addi $t9, $t9, 1                                        #soma 1 ao registrador "t9" até 40 vezes
    add $a0, $t9, $zero                                     #soma t9 em a0 para realizar o método
    jal limpar_ap_method                                    #retorna para o método limpar apartamento para realizar o loop
    bne $t9, 40, loop_limpar_tudo                           #reinicia o loop caso o registrador não tenha alcançado o ultimo apartamento
    beq $t9, 40, fim_tudo                                   # encerra a função caso o registradr tenha alcançado o último apartamento

    fim_tudo:
    j start 