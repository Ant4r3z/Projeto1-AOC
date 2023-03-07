# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 01
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues

 # O objetivo desta questão é treinar a implementação de funções — particularmente, funções recursivas. 
 # A sequência de Fibonacci têm os elementos: f0 = 0, f1 = 1 e fn = fn-1 +fn-2 paraa n>1
 # Implemente um programa usando recursividade, isto é, 
 # uma função recursiva (loops simples serão desconsiderados) que calcula o n-ésimo elemento de uma 
 # série de Fibonacci. O valor de n deve ser obtido a partir de uma entrada do usuário. 
 # Imprima o resultado na tela


.data
input: .asciiz "Coloque um numero: \n"
resultado: .asciiz "Fib "
resultadoo: .asciiz " = "
Breakline: .asciiz "\n"
.text

main:

# Coloque um numero
li $v0,4                                  # carrega imediatamente o valor no registrador
la $a0,input                              # carrega o valor digitado em a0
syscall

li $v0, 5                                 # carrega imediatamente o valor no registrador
syscall

move $a0,$v0                              #a0 é colcoado em v0
move $t2,$v0                              # t2 é alocado para v0
jal fib                                   # fib (n)
move $t3,$v0                              # Resultado é armazenado em $t3

# Mensagem do resultado
la $a0,resultado                          #Printa fib
li $v0,4                                  # Carrega na pilha
syscall

move $a0,$t2                              # Printa o valor
li $v0,1                                  # Carrega na pilha
syscall

la $a0,resultadoo                          #Print =
li $v0,4                                   # Carrega na pilha
syscall

move $a0,$t3                               # Print o resultado
li $v0,1                                   # Carrega na pilha
syscall

la $a0,Breakline                           # Printa '\n'
li $v0,4                                   # Carrega na pilha
syscall

# Fim
li $v0,10                                  # Carrega na pilha
syscall

fib:
beq $a0, 0, igualzero                      # caso o valor digitado seja 0
beq $a0,1, igualum                         # caso o valor digitado seja 1
addi $sp, $sp, -12                         # abre espaço na pilha 
sw $ra, 8($sp)                             # escreve o endereço na sp
sw $s0, 4($sp)                             # escreve o endereço na sp
sw $s1, 0($sp)                             # escreve o endereço na sp
move $s0, $a0                              # coloca o valor de a0 em s0
li $v0, 1                                  # return value for terminal condition
ble $s0, 2, fim                            # check terminal condition
addi $a0, $s0, -1                          # set args for recursive call to f(n-1)
jal fib
move $s1, $v0                              # store result of f(n-1) to s1
addi $a0, $s0, -2                          # set args for recursive call to f(n-2)
jal fib
add $v0, $s1, $v0                          # add result of f(n-1) to it
jal fim                                    # Envia para o fim

igualzero:
li $v0,0                                   # Torna 0
jr $ra                                     # Retorna 0 ao return address
igualum:
li $v0,1                                   # Torna 1
jr $ra                                     # Retorna 1 ao return address

fim:
lw $ra, 8($sp)                             # recuperando ra
lw $s0, 4($sp)                             # recuperando s0
lw $s1, 0($sp)                             # recuperando s1
addi $sp, $sp, 12                          # retomando na pilha
jr $ra                                     # Retorna o resultado ao return address