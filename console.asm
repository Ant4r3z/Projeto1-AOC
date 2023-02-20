.eqv R 10                                                               # DEFINE: Enter (Return) char = 10
.eqv BS 8                                                               # DEFINE: Backpace char = 8

.data

next_line: .asciiz "\n"                                                  # nova linha
separador: .asciiz "-"                                                   # separador de comando

banner: .asciiz "GGJR-shell>> "                                         # Banner da equipe (shell)

# definicao dos comandos
help: .asciiz "help"
ad_morador: .asciiz "ad_morador"


# textos de saida de comandos
cmd_invalido: .asciiz "Comando invalido\n"
help_out: .asciiz "Esta eh a lista dos comandos disponiveis\n    cmd_1. ad_morador-<ap>-<morador>: adiciona um morador ao apartamento\n"


input: .space 1024                                                      # espaco para o input do usuario
output: .space 1024


.text

main:
    lui $s0, 0xFFFF                                                     # carrega o endereco base dos registradores do controle mmio em s0
    la $s1, input                                                       # carrega o endereco base do input em s1
    j start
    
start:
    la $a0, banner                                                      # carrega o endereco do banner
    jal print_str                                                       # chama a funcao print string
    jal clear_input
    j mmio_loop                                                         # inicia o loop do mmio

clear_input:
    addi $s1, $s1, -1                                                   
    lb $t0, 0($s1)
    beqz $t0, end_clear
    sb $zero, 0($s1)
    j clear_input
    end_clear:
    	addi $s1, $s1, 1
        jr $ra

mmio_loop:                                                              # loop do mmio
    lw $t0, 0($s0)                                                      # s1 = receiver ready
    beqz $t0, mmio_loop                                                 # se receiver nao estiver pronto, reinicia o loop
    lw $s2, 4($s0)                                                      # s2 = receiver data
    beq $s2, BS, backspace                                              # se o character digitado for um backspace, inicia a logica de apagar um character do input
    sb $s2, 0($s1)                                                      # escreve o ultimo char digitado em transmitter data
    jal mmio_show_char                                                  # chama a funcao que mostra o char na tela mmio
    addi $s1, $s1, 1                                                    # move o cursor do input para o proximo byte
    beq $s2, R, enter                                                   # se for um enter, inicia a logica
    j mmio_loop                                                         # reinicia o loop do mmio

mmio_show_char:                                                         # funcao que imprime um character na tela mmio
    lw $t0, 8($s0)                                                      # t0 = transmitter ready
    beqz $t0, mmio_show_char                                            # caso transmitter nao esteja pronto, volta ao inicio da funcao
    sw $s2, 12($s0)                                                     # escreve o dado recebido do teclado em transmitter data
    jr $ra                                                              # return


print_str:                                                              # imprime uma string na tela mmio [$a0: endereco da string]
    addi	$sp, $sp, -4			                                    # reserva uma posicao na stack
    sw $ra, 0($sp)                                                      # grava return adress na stack
    lb		$s2, 0($a0)                                                 # carrega o byte da string em s2
    jal		mmio_show_char				                                # chama a funcao mmio_show_char
    lw $ra, 0($sp)                                                      # recupera o return adress da stack
    addi $sp, $sp, 4                                                    # libera uma posicao na stack
    addi $a0, $a0, 1                                                    # move o cursor da string 
    bnez $s2, print_str	                                                # se o character nao for zero, reinicia a funcao e continua a imprimir
    jr $ra                                                              # return
    
enter:                                                                  # executado quando a tecla enter eh digitada
    jal process_command                                                 # chama a funcao que processa o comando
    la $a0, banner                                                      # carrega o endereco do banner
    jal print_str                                                       # chama a funcao print string
    j start                                                             # desvia para o inicio do loop mmio

backspace:                                                              # executado quando um backspace eh digitado
    lb $t0, -1($s1)                                                     # carrega o ultimo byte do input
    beqz $t0, end_backspace                                             # se for o fim da string, encerra a funcao
    la $a0, next_line                                                   # pula uma linha
    jal print_str
    la $a0, banner                                                      # imprime o banner
    jal print_str
    addi $s1, $s1, -1                                                   # move o cursor do input a uma posicao anterior
    sb $zero, 0($s1)                                                    # escreve \0 nessa posicao
    la $a0, input                                                       # inprime o input atualizado na nova linha                                                 
    jal print_str                                                       
    end_backspace:                                                      # encerra a funcao
        j mmio_loop                                                     # desvia para o inicio de mmio_loop
    
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
            add $a0, $zero, $t2
            addi $v0, $zero, 9
            syscall
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
        jr $ra



help_fn:                                                                # comando help
    addi $a0, $zero, 1  # pega a opcao da posicao 1 
    jal get_fn_option   # executa a funcao
    add $t8, $zero, $v0 # escreve o endereco da opcao em $t8
    addi $a0, $zero, 2
    jal get_fn_option
    add $t9, $zero, $v0
    la $a0, help_out
    jal print_str

    j start

cmd_invalido_fn:                                                        # comando invalido
    la $a0, cmd_invalido
    jal print_str

    j start




strcmp:                                 # compara duas strings
    add $t0, $zero, $a0                 # escreve o endere?o da str1 para t0
    add $t1, $zero, $a1                 # escreve o endere?o da str2 para t1
    
    strcmp_loop:                        # loop principal
        lb $t2, 0($t0)                  # carrega o caracter de str1 em t2
        lb $t3, 0($t1)                  # carrega o caracter de str2 em t3
        addi $v0, $zero, 1              # v0 = 1
        bgt $t2, $t3, end_strcmp        # caso t2 seja maior que t3, encerra o programa e o retorno ser? 1
        addi $v0, $zero, -1             # v0 = -1
	    blt $t2, $t3, end_strcmp        # caso t2 seja menor que t3, encerra o programa e o retorno ser? -1
	    add $v0, $zero, $zero           # v0 = 0
	    beqz $t2, end_strcmp            # se chegar no fim da string, encerra o programa e o retorno ser? 0
	    addi $t0, $t0, 1                # incrementa str1
	    addi $t1, $t1, 1                # incrementa str2
	    j strcmp_loop                   # iteracao
	
    end_strcmp:                         # fim da fun??o
        jr $ra                          # retorno


strcpy:                                 # copia uma string
    add $t0, $a1, $zero                 # escreve o endere?o source para t0
    add $t1, $a0, $zero                 # escreve o endere?o destination para t1

    strcpy_loop:                        # loop principal
        lb $t2, 0($t0)                  # carrega o caracter i de source em t2
        beqz $t2, end_strcpy            # se for \0, encerra a fun??o
        sb $t2, 0($t1)                  # grava o character i de source no endere?o i de destination
        addi $t0, $t0, 1                # incrementa source
        addi $t1, $t1, 1                # incrementa destination
        j strcpy_loop                   # reinicia o loop

    end_strcpy:                         # fim da fun??o
        jr $ra                          # retorno


strncmp:                                # compara duas strings at? o caracter num
    add $t0, $zero, $a0                 
    add $t1, $zero, $a1                 
    add $t4, $zero, $zero               
    
    strncmp_loop:                       
        lb $t2, 0($t0)                  
        lb $t3, 0($t1)
        addi $v0, $zero, 1              
        bgt $t2, $t3, end_strncmp       
        addi $v0, $zero, -1             
	blt $t2, $t3, end_strncmp           
	add $v0, $zero, $zero               
	beqz $t2, end_strncmp               
	addi $t4, $t4, 1                    
	bge $t4, $a3, end_strncmp           
	addi $t0, $t0, 1                    
	addi $t1, $t1, 1                    
	j strncmp_loop                      
    
    end_strncmp:
        jr $ra


memcpy:                                 # copia a quantidade num de bytes de um endere?o de memoria para outro (sem procurar por \0)
    add $t0, $zero, $a0                 # escreve o endere?o destination para t0
    add $t1, $zero, $a1                 # escreve o endere?o source para t1
    add $t2, $zero, $zero               # escreve 0 em t2 (i)
    
    memcpy_loop:                        # loop principal
        bge $t2, $a2, end_memcpy        # caso i seja igual a num, encerra a fun??o
        lb $t3, 0($t1)                  # carrega o byte de source em t3
        sb $t3, 0($t0)                  # grava o byte de t3 em destination
        addi $t0, $t0, 1                # incrementa destination
        addi $t1, $t1, 1                # incrementa source
        addi $t2, $t2, 1                # incrementa i
        j memcpy_loop                   # iteracao
        
    end_memcpy:                         # fim da fun??o
        jr $ra                          # retorno