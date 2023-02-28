.data
.text
.globl set_building

set_building:
    
    move $t6, $a0	# salva o endereço de $a0 (building) em $t6
    
    li $t0, 0		# apartment number counter
    li $t1, 0		# floor counter
    li $t2, 0		# apartment counter
    li $t3, 10		# number of floors
    li $t4, 4		# number of apartments per floor
    li $t5, 101		# starting apartment number
    
    apartment_loop:
        blt $t1, $t3, floor_loop	# if floor counter < number of floors, go to floor_loop
        j exit				# else, exit the program
    
    floor_loop:
        blt $t2, $t4, allocate_apartment	# if apartment counter < number of apartments per floor, go to allocate_apartment
        addi $t1, $t1, 1			# else, increment floor counter
   	li $t2, 0				# reset apartment counter to 1
    	addi $t5, $t5, 100			# increment starting apartment number by 100
    	j apartment_loop			# go back to apartment_loop
    
    allocate_apartment:
    
        # set apartment number in building array
        add $t8, $t5, $t2		# add starting apartment number to apartment number counter
        
        sw $t8, ($t6)			# store apartment number in building array
    
        addi $t0, $t0, 1		# increment apartment number counter
        addi $t2, $t2, 1		# increment apartment counter
        addi $t6, $t6, 40		# increment building counter
    
        j floor_loop			# go back to floor_loop
    
    exit:
        jr $ra
