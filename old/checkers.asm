.data
.text
.globl main

main:
    # Inicializa o tabuleiro
    li $t0, 0              # �ndice do tabuleiro
    li $t1, 0              # Linha
    li $t2, 0              # Coluna

loop_linhas:
    bge $t1, 8, fim_desenho       # Se a linha � 8, termina

    # Inicia a coluna
    li $t2, 0              # Reseta coluna

loop_colunas:
    bge $t2, 8, proxima_linha # Se a coluna � 8, vai para a pr�xima linha

    # Determina a cor da casa
    andi $t3, $t1, 1       # Verifica se a linha � par ou �mpar
    andi $t4, $t2, 1       # Verifica se a coluna � par ou �mpar

    # Se linha e coluna t�m a mesma paridade, � casa branca; caso contr�rio, � casa preta
    xor $t5, $t3, $t4
    beqz $t5, casa_branca  # Se $t5 � 0, � casa branca

casa_preta:
    li $t6, 0x000000       # Casa preta
    j armazena_casa

casa_branca:
    li $t6, 0xffffff       # Casa branca

armazena_casa:
    add $t7, $gp, $t0
    sw $t6, 0($t7)         # Imprima casa
    addi $t0, $t0, 4       # Incrementa o �ndice do tabuleiro
    addi $t2, $t2, 1       # Incrementa a coluna
    j loop_colunas

proxima_linha:
    addi $t1, $t1, 1       # Incrementa a linha
    j loop_linhas

fim_desenho:
    # Imprime o tabuleiro
    li $t0, 0              # Reseta o �ndice do tabuleiro

imprime_peca:
    li $t1, 0x1000806c		# Seta posi��o da pe�a
    li $t3, 0x0000ff		# Set cor da pe�a
    sw $t3, 0($t1)		# Imprima pe�a no tabuleiro
    
entrada_movimento:
    li $v0, 12			# Recebe movimento do teclado
    syscall

    li $t5, 'q'			# Anda na diagonal esquerda-superior
    beq $v0, $t5, testa_Q
    
    li $t5, 'e'			# Anda na diagonal direita-superior
    beq $v0, $t5, testa_E
    
    li $t5, 'a'			# Anda na diagonal esquerda-inferior
    beq $v0, $t5, testa_A
    
    li $t5, 'd'			# Anda na diagonal direita-inferior
    beq $v0, $t5, testa_D
    
    j entrada_movimento		# Reseta o loop se n�o for movimento v�lido
    
testa_Q:
    subi $t6, $t1, 32			# Movimento em Y
    blt $t6, $gp, entrada_movimento	# Verifica se o movimento em Y sai do tabuleiro
    subi $t7, $t1, 4			# Movimento em X
    andi $t7, $t7, 0x000000ff
    andi $t8, $t1, 0x000000ff		# Mant�m ultimos 2 casas dos endere�os
    srl $t7, $t7, 5
    srl $t8, $t8, 5			# Faz a divis�o por 32
    beq $t7, $t8, foi_Q			# Verifica se o movimento em X muda de linha
    j entrada_movimento

testa_E: 
    subi $t6, $t1, 32			# Movimento em Y
    blt $t6, $gp, entrada_movimento	# Verifica se o movimento em Y sai do tabuleiro
    addi $t7, $t1, 4			# Movimento em X
    andi $t7, $t7, 0x000000ff
    andi $t8, $t1, 0x000000ff		# Mant�m ultimos 2 casas dos endere�os
    srl $t7, $t7, 5
    srl $t8, $t8, 5			# Faz a divis�o por 32
    beq $t7, $t8, foi_E			# Verifica se o movimento em X muda de linha
    j entrada_movimento

testa_A:
    addi $t6, $t1, 32			# Movimento em Y
    addi $t7, $gp, 256
    bgt $t6, $t7, entrada_movimento	# Verifica se o movimento em Y sai do tabuleiro
    subi $t7, $t1, 4			# Movimento em X
    andi $t7, $t7, 0x000000ff
    andi $t8, $t1, 0x000000ff		# Mant�m ultimos 2 casas dos endere�os
    srl $t7, $t7, 5
    srl $t8, $t8, 5			# Faz a divis�o por 32
    beq $t7, $t8, foi_A			# Verifica se o movimento em X muda de linha
    j entrada_movimento

testa_D:  
    addi $t6, $t1, 32			# Movimento em Y
    addi $t7, $gp, 256
    bgt $t6, $t7, entrada_movimento	# Verifica se o movimento em Y sai do tabuleiro
    addi $t7, $t1, 4			# Movimento em X
    andi $t7, $t7, 0x000000ff
    andi $t8, $t1, 0x000000ff		# Mant�m ultimos 2 casas dos endere�os
    srl $t7, $t7, 5
    srl $t8, $t8, 5			# Faz a divis�o por 32
    beq $t7, $t8, foi_D			# Verifica se o movimento em X muda de linha
    j entrada_movimento
    

foi_Q:
    subi $t2, $t1, 36		# Define a posi��o da pr�xima casa
    lb $t4, 0($t2)		# Olha a cor da pr�xima casa
    sw $t4, 0($t1)		# Pinta a casa atual com a cor da pr�xima
    sw $t3, 0($t2)		# Pinta a pr�xima casa com a cor da casa atual
    move $t1, $t2		# Troca a posi��o da pe�a para a posi��o da pr�xima casa
    j entrada_movimento		# Reseta o loop

foi_E:
    subi $t2, $t1, 28		# Define a posi��o da pr�xima casa
    lb $t4, 0($t2)		# Olha a cor da pr�xima casa
    sw $t4, 0($t1)		# Pinta a casa atual com a cor da pr�xima
    sw $t3, 0($t2)		# Pinta a pr�xima casa com a cor da casa atual
    move $t1, $t2		# Troca a posi��o da pe�a para a posi��o da pr�xima casa
    j entrada_movimento		# Reseta o loop
    
foi_A:
    addi $t2, $t1, 28		# Define a posi��o da pr�xima casa
    lb $t4, 0($t2)		# Olha a cor da pr�xima casa
    sw $t4, 0($t1)		# Pinta a casa atual com a cor da pr�xima
    sw $t3, 0($t2)		# Pinta a pr�xima casa com a cor da casa atual
    move $t1, $t2		# Troca a posi��o da pe�a para a posi��o da pr�xima casa
    j entrada_movimento		# Reseta o loop
    
foi_D:
    addi $t2, $t1, 36		# Define a posi��o da pr�xima casa
    lb $t4, 0($t2)		# Olha a cor da pr�xima casa
    sw $t4, 0($t1)		# Pinta a casa atual com a cor da pr�xima
    sw $t3, 0($t2)		# Pinta a pr�xima casa com a cor da casa atual
    move $t1, $t2		# Troca a posi��o da pe�a para a posi��o da pr�xima casa
    j entrada_movimento		# Reseta o loop
