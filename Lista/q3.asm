# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 01
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues


#O objetivo desta questão é treinar a implementação de funções — particularmente, 
#funções recursivas. A sequência de Fibonacci têm os elementos 
#F0 = 0 F1 = 1 e 
#Fn = Fn-1 + Fn-2 para n>1
#implemente um programa usando recursividade, isto é, uma função recursiva 
#(loops simples serão desconsiderados) que calcula o n-ésimo elemento de uma série de Fibonacci. 
#O valor de n deve ser obtido a partir de uma entrada do usuário. Imprima o resultado na tela

.text

main:

# Coloque um numero
la $a0,comando   
li $v0,4
syscall
li $v0,5 #se lê o número(n)
syscall
move $t2,$v0 # Salva o número em t2

# Chama a função de fibonacci
move $a0,$t2 #a0 é colcoado em t2
move $v0,$t2 # a0 é alocado para v0
jal fib # fib (n)
move $t3,$v0 #Resultado é armazenado em $t3

# Mensagem do resultado
la $a0,resultado #Printa fib
li $v0,4 #Carrega na pilha
syscall
move $a0,$t2 #Printa o valor
li $v0,1 #Carrega na pilha
syscall
la $a0,resultadoo #Print =
li $v0,4 #Carrega na pilha
syscall
move $a0,$t3 #Print o resultado
li $v0,1 #Carrega na pilha
syscall
la $a0,fim #Printa '\n'
li $v0,4 #Carrega na pilha
syscall

# Fim
li $v0,10 #Carrega na pilha
syscall

fib:
# Relaciona e dá o resultado em fibonacci
beqz $a0,zero #se n=0 return 0
beq $a0,1,um #se n=1 return 1

# fib(n-1)
sub $sp,$sp,4 #Guarda o valor na pilha
sw $ra,0($sp) #Guarda na pilha
sub $a0,$a0,1 #n-1
jal fib #fib(n-1)
add $a0,$a0,1 #Realiza parte da soma
lw $ra,0($sp)#Retorna o RA da pilha
add $sp,$sp,4 #Incrementa na pilha 
sub $sp,$sp,4 #Envia o valor para a pilha
sw $v0,0($sp) #Guarda na pilha
# fib(n-2)
sub $sp,$sp,4 #Guarda o valor na pilha
sw $ra,0($sp) #Guarda na pilha
sub $a0,$a0,2 #n-2
jal fib #fib(n-2)
add $a0,$a0,2 #Realiza parte da soma
lw $ra,0($sp) #Retorna o RA da pilha
add $sp,$sp,4 #Incrementa na pilha
#---------------
lw $s7,0($sp) #Busca o RA da pilha
add $sp,$sp,4 #Incrementa na pilha
add $v0,$v0,$s7 # f(n - 2)+fib(n-1)
jr $ra # Decrementa e pega o próximo valor da pilha

zero:
li $v0,0 #Torna 0
jr $ra #Retorna 0 ao return address
um:
li $v0,1 #torna 1
jr $ra #Retorna 1 ao return address

.data
comando: .asciiz "Coloque um numero: \n"
resultado: .asciiz "Fib "
resultadoo: .asciiz " = "
fim: .asciiz "\n"
