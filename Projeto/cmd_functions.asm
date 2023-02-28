.data
help_out: .asciiz "Esta eh a lista dos comandos disponiveis\n    cmd_1. ad_morador-<ap>-<morador>: adiciona um morador ao apartamento\n"

arquivo: .asciiz "C:\\arquivos\\output.txt"

invalid_auto_out: .asciiz "As opcoes de tipo sao apenas 'c' (carro) e 'm' (moto)\n"
no_space_auto_out: .asciiz "Nao ha mais vagas na sua garagem\n"

.text
.globl help_fn, ad_auto_fn

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


# ad_auto_fn:
#     addi $a0, $zero, 1
#     la $a1, input
#     jal get_fn_option

    
#     add $a0, $zero, $v0
#     jal str_to_int
#     add $a0, $zero, $v0
#     jal get_ap_index

#     add $t0, $zero, $v0
#     addi $t1, $zero, -1
#     beq $t1, $v0, abort_invalid_ap
    
#     add $a0, $zero, $t0
#     jal free

#     add $t0, $zero, $v0

    
#     # 28

    
#     la $t4, building

#     addi $t1, $zero, 36
#     addi $t0, $t0, -1
#     mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers
#     mflo	$t2					# copy Lo to $t2
    
#     add $t4, $t4, $t2

#     addi $t4, $t4, 28
    
#     li $v0, 9
#     li $a0, 32
#     syscall

#     sw $v0, 0($t4)
    
#     add $t5, $zero, $v0  # endereco do automovel



#     addi $a0, $zero, 2
#     la $a1, input
#     jal get_fn_option

#     add $t0, $zero, $v0 # endereco do tipo de auto

#     lb $t1, 0($t0)
#     sb $t1, 0($t5)

#     add $a0, $zero, $t0
#     jal free


#     addi $a0, $zero, 3
#     la $a1, input
#     jal get_fn_option

#     add $t0, $zero, $v0 # endereco do modelo de auto
#     add $t1, $zero, $v1 # tamanho do modelo de auto

#     addi $t5, $t5, 1
    
#     add $a1, $t0, $zero
#     add $a0, $t5, $zero
#     add $a2, $zero, $t1

#     jal memcpy

#     add $a0, $zero, $t0
#     jal free


#     addi $t5, $t5, 20
#     addi $a0, $zero, 4
#     la $a1, input
#     jal get_fn_option

#     add $t0, $zero, $v0
#     add $t1, $zero, $v1

        
#     add $a1, $t0, $zero
#     add $a0, $t5, $zero
#     add $a2, $zero, $t1

#     jal memcpy


#     add $a0, $zero, $t0
#     jal free



#     # teste de escrita em arquivo



#     la $a0, arquivo
#     li $a1, 1
#     li $a2, 0
#     li $v0, 13
#     syscall

#     add $s7, $zero, $v0

#     add $a0, $zero, $s7
#     addi $a1, $t5, -21
#     addi $a2, $zero, 32

#     addi $v0, $zero, 15
#     syscall

#     add $a0, $zero, $s7
#     li $v0, 16
#     syscall

#     j start


ad_auto_fn:
    # verificacoes
    # valida numero do apartamento

    addi $a0, $zero, 1
    la $a1, input
    jal get_fn_option
    
    add $a0, $zero, $v0
    jal str_to_int
    add $a0, $zero, $v0
    jal get_ap_index

    add $t0, $zero, $v0 # t0: numero do apartamento
    bltz $v0, abort_invalid_ap

    # add $a0, $zero, $t0
    # jal free

    add $t0, $zero, $v0

    
    # 28

    
    la $t4, building

    addi $t1, $zero, 36
    addi $t0, $t0, -1
    mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers
    mflo	$t2					# copy Lo to $t2
    
    add $t4, $t4, $t2

    addi $t4, $t4, 28           # word do primeiro auto na estrutura ap


    # li $v0, 9
    # li $a0, 32
    # syscall

    # sw $v0, 0($t4)



    addi $a0, $zero, 2
    la $a1, input
    jal get_fn_option
    add $t0, $zero, $v0
    lw $t0, 0($t0)

    addi $t1, $zero, 99
    bne $t0, $t1, invalid_auto_input
    beq $t0, $t1, is_carro
    
    invalid_auto_input:
        addi $t1, $zero, 109
        bne $t0, $t1, invalid_auto
        beq $t0, $t1, is_moto



    is_carro:
        lw $t7, 8($t4)
        bgtz $t7, no_space_auto
        addi $t7, $zero, 1
        sw $t7, 8($t4)
        j continue_ad_auto

    is_moto:
        lw $t7, 8($t4)
        beqz $t7, there_is_no_moto
        addi $t8, $zero, 3
        beq $t7, $t8, no_space_auto
        addi $t8, $zero, 2
        beq $t7, $t8, there_is_one_moto


        there_is_one_moto:
        addi $t7, $zero, 3
        sw $t7, 8($t4)
        addi $t4, $t4, 4
        j continue_ad_auto

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