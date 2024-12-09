#ideal: bitmap 4 x 4 x 256 x 256, tam_casa 8 e tam_peca 4

    .data

enderecos_casas:
    .space  256

tamanho_casa:
    .word   8
tamanho_horizontal:
    .space  4
qtd_casas:
    .word   8

casas_nao_pretas:
    .word   0xffffff

tamanho_peca:
    .word   4
cor_peca_A:
    .word   0xff

eixo_x:
    .word   0x0
eixo_y:
    .word   0x0
direcao_x:
    .word   0x0
direcao_y:
    .word   0x0

    .text

# Inicializa o tabuleiro
    lw      s0, tamanho_casa
    lw      s1, qtd_casas
    mul     s2, s0, s1
    sw      s2, tamanho_horizontal

    li      s3, 0                   #isso vai ser o endereco inicial da casa da peca q vou imprimir
    li      s4, 0                   #isso vai ser a cor da peca a ser impressa

    li      t0, 0                   # Índice do tabuleiro
    li      t1, 0                   # Linha
    li      t2, 0                   # Coluna

loop_linhas:

    bge     t1, s1, main            # Se a linha é 8, termina
# Inicia a coluna
    li      t2, 0                   # Reseta coluna

loop_colunas:
    blt     t2, s1, verificacao     # Se a coluna é 8, vai para a próxima linha
    addi    t1, t1, 1               # Incrementa a linha
    j       loop_linhas

verificacao:
# Determina a cor da casa
    andi    t3, t1, 0x01            # Verifica se a linha é par ou ímpar. Se impar, t3 = 1
    andi    t4, t2, 0x01            # Verifica se a coluna é par ou ímpar

# Se linha e coluna têm a mesma paridade, xor dá 0 e é casa branca; caso contrário, é casa preta
    xor     t5, t3, t4
    beqz    t5, imprime_casa        # Se t5 é 1, é casa branca
    lw      t5,casas_nao_pretas

#CORRIGIR, PRIMEIRA CASA ESTA SAINDO PRETA

imprime_casa:

#aqui eu vou entrar num loop IJ, para cada MxN (casas) do tabuleiro, onde t7 sera é o primeiro pixel delas

    li      t3, 0                   #linha
    li      t4, 0                   #coluna

#parede esquerda
    mul     t6,s2,t1
    mul     t6,t6,s0
    mul     t6,t6,4

    add     t7,gp,t6
    mul     t6,s0,t2
    mul     t6,t6,4
    add     t7,t7,t6                #isso aqui é o que pega o primeiro endereco da matriz da casa de m e n (t1 t2)

linhas_casa:

    bge     t3, s0, armazena_casa

    mul     t8,t3,s2
    mul     t8,t8,4
    add     t8,t8,t7

    li      t4, 0

colunas_casa:

    mul     t9,t4,4
    add     t9,t9,t8
    sw      t5,0(t9)

    add     t4,t4,1
    blt     t4, s0, colunas_casa
    add     t3,t3,1
    j       linhas_casa

armazena_casa:

    sw      t7,enderecos_casas(t0)
    addi    t0, t0, 4               # Incrementa o índice do tabuleiro
    addi    t2, t2, 1               # Incrementa a coluna
    j       loop_colunas

imprime_peca:

#algum reg vem com o endereço inicial da casa
#algum reg vem com a cor (para poder apagar tbm)
#pega o tamanho da casa, pega o tamanho da peça, coloca a peça bem no meio do quadrado da casa mexendo no endereço

    lw      t1,tamanho_peca         #t1 vai ser tamanho peca
    sub     t2,s0,t1
    and     t8,t2,0x1
    beq     t8,0,razao_CaPe_par
#add t2,t2,1
    add     t1,t1,1
razao_CaPe_par:

    div     t2,t2,2                 #t2 aqui é o espaço esquerdo e superior que a peça vai deixar no tabuleiro
    mul     t3,t2,4

    lw      t5,tamanho_horizontal
    mul     t5,t5,4                 #t5 vai ser os bytes do tamanho horizontal
    mul     t4,t5,t2
    
    add     t2,s3,t3
    add     t2,t2,t4                #t2 oficialmente vai ser o primeiro pixel da peca encaixada na regiao central da casa

    li      t3,0                    #t3 vai ser o contador i
linhas_peca:

    blt     t3,t1,continuarLP
    jr      ra
continuarLP:

    mul     t6,t3,t5
    add     t6,t2,t6                #t6 vai ser o endereco do primeiro pixel dessa linha

    li      t4,0                    #t4 vai ser o contador j
colunas_peca:

    mul     t7,t4,4
    add     t7,t6,t7                #t7 vai ser o endereco de cada pixel de cada coluna da linha t6

    sw      s4,0(t7)
    add     t4,t4,1

    blt     t4,t1,colunas_peca
    add     t3,t3,1
    j       linhas_peca

#com esse novo endereço, impressão ij com max do tam_peça

#--------------- Aqui PH pegou a v4 e fez a função main e turno_peça baseado no esqueleto que passei

main:
# reseta o indice do tabuleiro
    li      t0, 0

    la      t1,enderecos_casas
    lw      s3,128(t1)
    lw      s4,cor_peca_A

#li v0, 12 #Pausar a execucao antes de desenhar a peca (pausado por enquanto)
#syscall

    jal     imprime_peca

loop_eterno:
    jal     turno_peca
    j       loop_eterno

turno_peca:

    addi    t0,ra,0
    jal     movimento
    addi    ra,t0,0

    lw      t1,eixo_x
    lw      t2,eixo_y
    lw      t3,direcao_x
    lw      t4,direcao_y
    addi    s5,s3,0

#testa se movimento diagonal
    and     t6,t1,t2
    bne     t6,1,finalizar_checagem

    beqz    t1,ignorar_x

    lw      t6,tamanho_casa
    mul     t6,t6,4
    beqz    t3, x_negativo
    add     s3, s3, t6
    j       ignorar_x
x_negativo:
    sub     s3, s3, t6

ignorar_x:
    beqz    t2,ignorar_y

    lw      t6,tamanho_horizontal
    mul     t6,t6,32
    beqz    t4, y_negativo
    sub     s3, s3, t6
    j       ignorar_y
y_negativo:
    add     s3, s3, t6

ignorar_y:
    addi    t0,ra,0
    lw      s4,132(s3)
    addi    s6,s3,0
    addi    s3,s5,0
    jal     imprime_peca
    lw      s4,cor_peca_A
    addi    s3,s6,0
    jal     imprime_peca
    addi    ra,t0,0

finalizar_checagem:
    jr      ra

movimento:

    li      v0, 12
    syscall

#definir se a peca anda no eixo X

    andi    t1,v0,0x1
    andi    t2,v0,0x2
    andi    t3,v0,0x4
    andi    t4,v0,0x8

    srl     t2,t2,1
    srl     t3,t3,2
    srl     t4,t4,3

    xori    t4,t4,1
    xori    t1,t1,1
    and     t5,t4,t3
    and     t5,t5,t1

    xori    t1,t1,1
    and     t6,t4,t2
    and     t6,t6,t1
    or      t5,t5,t6

    xori    t3,t3,1
    xori    t2,t2,1
    and     t6,t3,t2
    and     t6,t6,t1
    or      t5,t5,t6

    la      t6,eixo_x
    sw      t5,0(t6)

#definir se a peca anda no eixo Y

    andi    t1,v0,0x1
    andi    t2,v0,0x2
    andi    t3,v0,0x4
    andi    t4,v0,0x8

    srl     t2,t2,1
    srl     t3,t3,2
    srl     t4,t4,3

    xori    t2,t2,1
    xori    t3,t3,1
    and     t5,t4,t3
    and     t5,t5,t2

    xori    t4,t4,1
    xori    t2,t2,1
    and     t6,t4,t3
    and     t6,t6,t2
    or      t5,t5,t6

    and     t6,t4,t3
    and     t6,t6,t1
    or      t5,t5,t6

    and     t6,t4,t2
    and     t6,t6,t1
    or      t5,t5,t6

    la      t6,eixo_y
    sw      t5,0(t6)

#definir a direcao do eixo X

    andi    t1,v0,0x1
    andi    t2,v0,0x2
    andi    t3,v0,0x4
    andi    t4,v0,0x8

    srl     t2,t2,1
    srl     t3,t3,2
    srl     t4,t4,3

    xori    t2,t2,1
    xori    t3,t3,1
    and     t5,t4,t3
    and     t6,t2,t1
    and     t7,t5,t6

    xori    t2,t2,1
    xori    t3,t3,1
    xori    t4,t4,1
    xori    t1,t1,1
    and     t5,t4,t3
    and     t6,t2,t1
    and     t5,t5,t6
    or      t7,t7,t5

    xori    t3,t3,1
    xori    t1,t1,1
    and     t5,t4,t3
    and     t6,t2,t1
    and     t5,t5,t6
    or      t5,t5,t7

    la      t6,direcao_x
    sw      t5,0(t6)

#definir a direcao do eixo Y

    andi    t1,v0,0x1
    andi    t2,v0,0x2
    andi    t3,v0,0x4
    andi    t4,v0,0x8

    srl     t2,t2,1
    srl     t3,t3,2
    srl     t4,t4,3

    xori    t2,t2,1
    xori    t3,t3,1
    and     t5,t4,t3
    and     t5,t5,t2

    xori    t4,t4,1
    xori    t3,t3,1
    xori    t2,t2,1
    and     t6,t4,t3
    and     t7,t2,t1
    and     t6,t6,t7
    or      t5,t5,t6

    la      t6,direcao_y
    sw      t5,0(t6)

    jr      ra
