.text
.globl strncmp, memcpy

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
        addi $t0, $t0, 1
        sb $zero, 0($t0)
        jr $ra                          # retorno
