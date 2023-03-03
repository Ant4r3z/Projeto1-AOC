.data
help_out: .asciiz "Esta eh a lista dos comandos disponiveis\n    cmd_1. ad_morador-<ap>-<morador>: adiciona um morador ao apartamento\n"

arquivo: .asciiz "C:\\arquivos\\output.txt"

invalid_auto_out: .asciiz "As opcoes de tipo sao apenas 'c' (carro) e 'm' (moto)\n"
no_space_auto_out: .asciiz "Nao ha mais vagas na sua garagem\n"
cmd_4: .asciiz "rm_auto-<apt>-<tipo>-<modelo>-<cor>\n"
cmd_4_auto_n: .asciiz "Falha: automóvel nao encontrado"
cmd_4_ap_n: .asciiz "Falha: AP invalido"
cmd_4_tipo_n: .asciiz "Falha: tipo invalido"
nao_tem_carro_pra_remover_out: .asciiz "Falha: Nao ha carros para remover"

.text
.globl help_fn, ad_auto_fn, salvar_fn,  rm_auto_fn

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


    end_ad_auto_fn:

    invalid_auto:
        la $a0, invalid_auto_out
        jal print_str
        j start

    no_space_auto:
        la $a0, no_space_auto_out
        jal print_str
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

        add $t0, $t0, $t1
        addi $t2, $t2, -1
        blez $t2, end_write_ap
        j write_ap
    
    end_write_ap:
        
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
        j start
    
    remover_segunda_moto:
        addi $t4,$t4, 4    
        addi $t9, $t9, 1 
        j continue_ad_auto

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