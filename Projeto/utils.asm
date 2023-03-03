.data
.macro stack_reg
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

.macro unstack_reg
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



buffer_int_to_str: .space 4              # reserve 4 bytes of space for the string

.globl strncmp, strcmp, memcpy, get_ap_index, str_to_int, get_str_size, int_to_string, buffer_int_to_str, 


.text

strcmp:                                 # compara duas strings
    stack_reg
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
    unstack_reg
        jr $ra                          # retorno


strcpy:                                 # copia uma string
    stack_reg
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
    unstack_reg
        jr $ra                          # retorno


strncmp:                                # compara duas strings at? o caracter num
stack_reg
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
        unstack_reg
        jr $ra


memcpy:                                 # copia a quantidade num de bytes de um endere?o de memoria para outro (sem procurar por \0)
    stack_reg
    add $t0, $zero, $a0                 # escreve o endere?o destination para t0
    add $t1, $zero, $a1                 # escreve o endere?o source para t1
    add $t2, $zero, $zero               # escreve 0 em t2 (i)
    addi $t4, $zero, 10
    
    memcpy_loop:                        # loop principal
        bge $t2, $a2, end_memcpy        # caso i seja igual a num, encerra a fun??o
        lb $t3, 0($t1)                  # carrega o byte de source em t3
        beq $t3, $t4, end_memcpy
        sb $t3, 0($t0)                  # grava o byte de t3 em destination
        addi $t0, $t0, 1                # incrementa destination
        addi $t1, $t1, 1                # incrementa source
        addi $t2, $t2, 1                # incrementa i
        j memcpy_loop                   # iteracao
        
    end_memcpy:                         # fim da fun??o
        addi $t0, $t0, 1
        sb $zero, 0($t0)
        unstack_reg
        jr $ra                          # retorno


get_ap_index: # $a0: numero do apartamento (int)
    stack_reg
    add $t0, $zero, $a0
    li $t1, 100
    div		$t0, $t1			# $t0 / $t1
    mflo	$t2					# $t2 = floor($t0 / $t1) 
    addi $t4, $zero, 10
    bgt		$t2, $t4, invalid_ap	# if $t2 > $t1 then goto target
    mfhi	$t3					# $t3 = $t0 % $t1 
    addi $t4, $zero, 4
    bgt		$t3, $t4, invalid_ap	# if $t2 > $t1 then goto target

    
    addi $t2, $t2, -1
    addi $t4, $zero, 4
    mult	$t2, $t4			# $t2 * $t1 = Hi and Lo registers
    mflo	$t2					# copy Lo to $t2
    add $v0, $t2, $t3
    unstack_reg
    jr $ra
    
    invalid_ap:
        unstack_reg
        addi $v0, $zero, -1
        jr $ra



str_to_int:
    stack_reg
    li $t0, 0
    li $t4, 48
    li $t5, 57
    li $t6, 10
    loop_str_int:
        lb $t1, 0($a0)
        beq $t1, $zero, done_str_int
        beq $t1, $t6, done_str_int
        blt $t1, $t4, error_str_int
        bgt $t1, $t5, error_str_int
        sub $t1, $t1, $t4
        mul $t0, $t0, 10
        add $t0, $t0, $t1
        addi $a0, $a0, 1
        j loop_str_int
    error_str_int:
        li $v0, -1
        unstack_reg
        jr $ra
    done_str_int:
        add $v0, $zero, $t0
        unstack_reg
        jr $ra



get_str_size:
    addi $sp, $sp, -4      # Allocate space on the stack
    sw $ra, 0($sp)         # Save the return address on the stack

    move $t0, $a0          # Copy the string address to $t0
    li $t1, 0              # Initialize the counter to 0

    loop_get_str_size:
        lb $t2, 0($t0)         # Load the next character into $t2
        beq $t2, $zero, done_get_str_size   # If the character is null, exit the loop
        addi $t0, $t0, 1       # Increment the address of the string
        addi $t1, $t1, 1       # Increment the counter
        j loop_get_str_size                 # Jump back to the start of the loop

    done_get_str_size:
        lw $ra, 0($sp)         # Restore the return address from the stack
        addi $sp, $sp, 4       # Deallocate the space on the stack
        move $v0, $t1          # Set the function return value to the size of the string
        jr $ra                 # Return to the calling function


# converts an integer to a string with a buffer of 4 bytes
# input:
#   $a0 - the integer to convert
#   $a1 - the maximum length of the output buffer
#   $a2 - pointer to the output buffer
# output:
#   none
int_to_string:
    stack_reg
        li $t0, 1000
        li $t2, 10
    
    its_loop:
        beqz $a1, end_its
        div		$a0, $t0			# $a0 / $t1
        mflo	$t3					# $t2 = floor($a0 / $t1) 
        # beqz $t3, its_zero
        mfhi	$a0					# $t3 = $a0 % $t1

        addi $t3, $t3, 48
        sb $t3, 0($a2)

        div		$t0, $t2			# $t0 / $t2
        mflo	$t0					# $t0 = floor($t0 / $t2) 
        addi $a1, $a1, -1
        addi $a2, $a2, 1
        j its_loop
    
    its_zero:
        div		$t0, $t2			# $t0 / $t2
        mflo	$t0					# $t0 = floor($t0 / $t2) 
        addi $a2, $a2, 1
        addi $a1, $a1, -1
        j its_loop
        
    end_its:
    unstack_reg
        jr $ra
