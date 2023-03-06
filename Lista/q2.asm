# [BCC 2022.1] Arquitetura e Organização de Computadores
# Lista de exercícios - Projeto 01
# Questão 01
# Arquitetantes:
# - Gabriel Santos
# - Gilvaney Leandro
# - Joyce Mirelle
# - Ronaldo Rodrigues

#Implemente uma função que calcula o comprimento de uma string. 
#A função deve receber um único parâmetro em $a0 e este parâmetro 
#deve ser o endereço da string (ponteiro) na memória. 
#A string deve ser terminada com o terminador ‘\0’ (NULL). 
#A função deve retornar o comprimento da string (desconsiderando o terminador)
#no registrador $v0.Escreva uma função main que irá:
#Calcular o tamanho da string, empregando a função implementada;
#Imprimir na tela o tamanho da string lida do usuário; 


.data
  
  buff: .space 10  
  string: .asciiz "Daniel"
  printedMessage: .asciiz "O tamanho da string eh: "
  
.text
  main:
  
        la $a0, string          # recebe a string.
        jal strlen              # chama a função strlen.
        jal print
        addi $a1, $a0, 0        # move o endereço da string para $a1
        addi $v1, $v0, 0        # move o tamanho da string para $v1
        addi $v0, $0, 11        # chama o system call para imprimir a mensagem.
        la $a0, printedMessage  # imprime a mensagem
        syscall
        addi $v0, $0, 10        # system call para sair
        syscall

  strlen:
        li $t0, 0               # inicia a contagem do zero
   
  loop:
        lb $t1, 0($a0)          # carrega o próximo caractere em t1
        beqz $t1, exit          # checa se tem caracter NULL
        addi $a0, $a0, 1        # incrementa o ponteiro da string
        addi $t0, $t0, 1        # incrementa o calculo
        j loop                  # volta ao topo do loop
   
  exit:
        jr $ra                  # retorna o valor ao return address

  print:
        li $v0, 4               # adiciona imediatamente o valor no registrador
        la $a0, printedMessage  # imprime a mensagem
        syscall

        li $v0, 1               # adiciona imediatamente o valor no registrador
        move $a0, $t0           # muda o valor de t0 para a0
        syscall

        jr $ra                  # retorna ao ra
