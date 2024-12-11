_start:
    .equ      memoria 0x000
    .equ      saida_x 0x400
    .equ      saida_y 0x418
    .equ      corTela 0x430
    .equ      entrada 0x448
    .equ      reset   0x460

main:
    # Inicializa o tabuleiro
    li t0, 0              # �ndice do tabuleiro
    li t1, 0              # Linha
    li t2, 0              # Coluna

loop_linhas:
    li t3, 8
    bge t1, t3, fim_desenho       # Se a linha � 8, termina

    # Inicia a coluna
    li t2, 0              # Reseta coluna

loop_colunas:
    li t3, 8
    bge t2, t3, proxima_linha # Se a coluna � 8, vai para a pr�xima linha

    # Determina a cor da casa
    andi t3, t1, 1       # Verifica se a linha � par ou �mpar
    andi t4, t2, 1       # Verifica se a coluna � par ou �mpar

    # Se linha e coluna t�m a mesma paridade, � casa branca; caso contr�rio, � casa preta
    xor t5, t3, t4
    beqz t5, casa_branca  # Se t5 � 0, � casa branca

casa_preta:
    li t6, 0x00       # Casa preta
    j armazena_casa

casa_branca:

    li s0, 0xff
    slli s0,s0,16
    add t6,s0,zero

    li s0, 0xff
    slli s0,s0,8
    add t6,t6,s0

    addi t6,t6,0xff

armazena_casa:
    #la s0, tabuleiro      # Endere�o base do tabuleiro
    #add s0, s0, t0       # Calcula o endere�o da casa
    #sw t6, 0(s0)         # Armazena a cor da casa

    jal ra, impressao
    addi t0, t0, 4       # Incrementa o �ndice do tabuleiro
    addi t2, t2, 1       # Incrementa a coluna
    j loop_colunas

impressao:
    sw t1, saida_x(zero)
    sw t2, saida_y(zero)
    sw t6, corTela(zero)

    #sw s1, saida_x(zero)
    #sw s1, saida_y(zero)
    jr ra

proxima_linha:
    addi t1, t1, 1       # Incrementa a linha
    j loop_linhas

fim_desenho:
    # Imprime o tabuleiro
    li t0, 0              # Reseta o �ndice do tabuleiro

imprime_peca:
	li t2,7
    li t1,4
    li t6,0xff
    jal ra, impressao
    #sw zero, saida_x(zero)
    #sw zero, saida_y(zero)

loop_eterno:
j loop_eterno
