# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 01
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues

# Escreva um programa que executa os seguintes passos:
# Recebe uma string (S) do usuário;
# Recebe um char (C1) do usuário;
# Recebe outro char (C2) do usuário;
# Substitui todas as ocorrências do char C1 na string S pelo char C2;
# Imprime a nova string com os caracteres substituídos


.data

  fstMsg: .asciiz	"Enter a string: "
  sndMsg: .asciiz	"Enter first character: "
  thrMsg: .asciiz	"\nEnter second character: "
  resMsg: .asciiz	"\nResults: "

  strInput: .space	50
    
.text
  main:
    
    # pede ao usuario para digitar uma string
    li $v0, 4                 # seleciona syscall para print
    la $a0, fstMsg            # carrega o endereço da primeira frase em $a0 para printar
    syscall
    
    # lê a string do usuário
    li $v0, 8                 # seleciona syscall para ler uma string
    la $a0, strInput          # carrega o endereço salvo para a string
    li $a1, 50                # carrega o tamanho da string em $a1
    syscall
    
    # pede ao usuario para digitar o primeiro caractere
    li $v0, 4                 # seleciona syscall para print
    la $a0, sndMsg            # carrega o endereço da segunda frase em $a0 para printar
    syscall
    
    # lê o primeiro caractere do usuário
    li $v0, 12                # seleciona syscall para ler um caractere
    syscall
    move $s0, $v0             # tira o caractere recebido em $v0 para $s0
    
    
    # pede ao usuario para digitar o segundo caractere
    li $v0, 4                 # seleciona syscall para print
    la $a0, thrMsg            # carrega o endereço da terceira frase em $a0 para printar
    syscall
    
    # lê o segundo caractere do usuário
    li $v0, 12                # seleciona syscall para ler um caractere
    syscall
    move $s1, $v0             # tira o caractere recebido em $v0 para $s1
    
    
    # substituição dos caracteres
    la $s2, strInput          # carrega o endereço de strInput em $s2
    
    
  # itera pela string verificando os caracteres
  loop:  
    lbu $t0, 0($s2)           # armazena em $t0 o próximo byte de $s2
    beq $t0, $zero, result    # se $t0 == 0, a palavra chegou ao final
    beq $t0, $s0, swap        # se $t0 == $s0 (C1), troca
    j increment
    
  # Troca o caractere
  swap: 
    sb $s1, 0($s2)            # substitui C1 por C2 ($s1 no lugar do char que é igual a C2)
  
  # muda o endereço para o próximo caractere
  increment: 
    addi $s2, $s2, 1          # incrementa o valor de $s2 para o próximo char da string
    j loop
    
  # printa o resultado
  result: 
    li $v0, 4                 # seleciona o syscall para print
    la $a0, resMsg            # carrega o endereço da quarta frase em $a0 para printar
    syscall
    
    li $v0, 4                 # seleciona o syscall para print
    la $a0, strInput          # carrega o endereço da quarta frase em $a0 para printar
    syscall
    