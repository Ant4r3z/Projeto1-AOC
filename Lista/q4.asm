# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 04
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues
 

# Implementar algumas funções da biblioteca "string.h"
# para linguagem C 

.data
str1: .asciiz "Ronatdo"
str2: .asciiz "Ronaldo"
buff: .space 10

.text
main:
    la $a0, str1
    la $a1, str2
    li $a3, 5
    jal strcat
    add $v1, $v0, $zero
    la $a0, str2
    #li $v0, 1
    #add $a0, $zero, $v1
    #syscall
    jal print_string
    j end



strcpy:                                 # copia uma string
    add $t0, $a1, $zero                 # escreve o endereço source para t0
    add $t1, $a0, $zero                 # escreve o endereço destination para t1

    strcpy_loop:                        # loop principal
        lb $t2, 0($t0)                  # carrega o caracter i de source em t2
        beqz $t2, end_strcpy            # se for \0, encerra a função
        sb $t2, 0($t1)                  # grava o character i de source no endereço i de destination
        addi $t0, $t0, 1                # incrementa source
        addi $t1, $t1, 1                # incrementa destination
        j strcpy_loop                   # reinicia o loop

    end_strcpy:                         # fim da função
        jr $ra                          # retorno
        

memcpy:                                 # copia a quantidade num de bytes de um endereço de memoria para outro (sem procurar por \0)
    add $t0, $zero, $a0                 # escreve o endereço destination para t0
    add $t1, $zero, $a1                 # escreve o endereço source para t1
    add $t2, $zero, $zero               # escreve 0 em t2 (i)
    
    memcpy_loop:                        # loop principal
        bge $t2, $a2, end_memcpy        # caso i seja igual a num, encerra a função
        lb $t3, 0($t1)                  # carrega o byte de source em t3
        sb $t3, 0($t0)                  # grava o byte de t3 em destination
        addi $t0, $t0, 1                # incrementa destination
        addi $t1, $t1, 1                # incrementa source
        addi $t2, $t2, 1                # incrementa i
        j memcpy_loop                   # iteracao
        
    end_memcpy:                         # fim da função
        jr $ra                          # retorno
        

strcmp:                                 # compara duas strings
    add $t0, $zero, $a0                 # escreve o endereço da str1 para t0
    add $t1, $zero, $a1                 # escreve o endereço da str2 para t1
    
    strcmp_loop:                        # loop principal
        lb $t2, 0($t0)                  # carrega o caracter de str1 em t2
        lb $t3, 0($t1)                  # carrega o caracter de str2 em t3
        addi $v0, $zero, 1              # v0 = 1
        bgt $t2, $t3, end_strcmp        # caso t2 seja maior que t3, encerra o programa e o retorno será 1
        addi $v0, $zero, -1             # v0 = -1
	    blt $t2, $t3, end_strcmp        # caso t2 seja menor que t3, encerra o programa e o retorno será -1
	    add $v0, $zero, $zero           # v0 = 0
	    beqz $t2, end_strcmp            # se chegar no fim da string, encerra o programa e o retorno será 0
	    addi $t0, $t0, 1                # incrementa str1
	    addi $t1, $t1, 1                # incrementa str2
	    j strcmp_loop                   # iteracao
	
    end_strcmp:                         # fim da função
        jr $ra                          # retorno


print_string:                           # funcao para printar string
    li  $v0, 4
    syscall

    jr  $ra


strncmp:                                # compara duas strings até o caracter num
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


strcat:
    add $t0, $a0, $zero
    add $t1, $a1, -1
    
    find_str_end:
    	addi $t1, $t1, 1
    	lb $t2, 0($t1)
    	bnez $t2, find_str_end
    	j strcat_loop
    
    strcat_loop:
    	lb $t2, 0($t0)
    	sb $t2, 0($t1)
    	addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	lb $t2, 0($t0)
    	beqz $t2, end_strcat
    	j strcat_loop
    	
    end_strcat:
    jr $ra
    	
    

end:
    li $v0, 10
    syscall


