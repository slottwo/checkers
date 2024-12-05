    .data
# Definição do tabuleiro e inicialização (0 = vazio, outras cores podem ser definidas)
    .text
    .globl    main

    main:
# Inicializa o tabuleiro
    li        $t0, 0                   # Índice do tabuleiro
    li        $t1, 0                   # Linha
    li        $t2, 0                   # Coluna

# Desenho do tabuleiro com padrão de cores alternado (preto e branco)
    loop_linhas:
    bge       $t1, 8, fim_desenho      # Se a linha é 8, termina

    li        $t2, 0                   # Reseta coluna

    loop_colunas:
    bge       $t2, 8, proxima_linha    # Se a coluna é 8, vai para a próxima linha

    andi      $t3, $t1, 1              # Verifica se a linha é par ou ímpar
    andi      $t4, $t2, 1              # Verifica se a coluna é par ou ímpar

    xor       $t5, $t3, $t4            # Se linha e coluna têm a mesma paridade, é casa branca
    beqz      $t5, casa_branca

    casa_preta:
    li        $t6, 0x000000            # Casa preta
    j         armazena_casa

    casa_branca:
    li        $t6, 0xffffff            # Casa branca

    armazena_casa:
    add       $t7, $gp, $t0
    sw        $t6, 0($t7)              # Armazena a cor da casa no tabuleiro
    addi      $t0, $t0, 4              # Incrementa o índice do tabuleiro
    addi      $t2, $t2, 1              # Incrementa a coluna
    j         loop_colunas

    proxima_linha:
    addi      $t1, $t1, 1              # Incrementa a linha
    j         loop_linhas

    fim_desenho:
# Reseta o índice do tabuleiro para início do jogo
    li        $t0, 0

# Inicialização de turnos e regras
    li        $s0, 0                   # Turno: 0 para jogador 1, 1 para jogador 2

    entrada_movimento:
# Verifica condições de vitória antes de cada movimento
    jal       verifica_vitoria

# Verifica capturas obrigatórias
    jal       verifica_captura

# Recebe movimento do teclado
    li        $v0, 12                  # Leitura de caractere
    syscall

# Valida e direciona o movimento
    li        $t5, 'q'                 # Movimento na diagonal superior esquerda
    beq       $v0, $t5, valida_movimento

    li        $t5, 'e'                 # Movimento na diagonal superior direita
    beq       $v0, $t5, valida_movimento

    li        $t5, 'a'                 # Movimento na diagonal inferior esquerda
    beq       $v0, $t5, valida_movimento

    li        $t5, 'd'                 # Movimento na diagonal inferior direita
    beq       $v0, $t5, valida_movimento

    j         entrada_movimento        # Recomeça o loop caso a entrada não seja válida

    valida_movimento:
# Valida o movimento escolhido
# Aqui verifica se a peça é do jogador atual e se a casa de destino está vazia.

# Verifica se a peça é do jogador
    add       $t6, $gp, $t1            # Endereço da posição atual
    lb        $t7, 0($t6)              # Carrega a peça na posição atual
    bne       $t7, cor_jogador, movimento_invalido

# Verifica se a casa de destino está vazia
    add       $t6, $gp, $t2            # Endereço da casa de destino
    lb        $t7, 0($t6)              # Carrega a peça na casa de destino
    bnez      $t7, movimento_invalido

# Se passar pelas verificações, executa o movimento
    jal       executa_movimento

    movimento_invalido:
# Exibe mensagem de erro e retorna a entrada de movimento
    li        $v0, 4                   # Chamada para imprimir string
    la        $a0, invalid_msg         # Mensagem de erro
    syscall
    j         entrada_movimento

    executa_movimento:
# Redireciona para a função específica do movimento
    beq       $t5, 'q', testa_Q
    beq       $t5, 'e', testa_E
    beq       $t5, 'a', testa_A
    beq       $t5, 'd', testa_D
    j         entrada_movimento

# Captura obrigatória
    verifica_captura:
# Similar à seção anterior, verifica em todas as direções se há capturas possíveis
# Se encontrar uma captura, forçar que o jogador a realize.
# Caso contrário, permita o movimento normal.
    j         entrada_movimento

# Promoção a Dama
    verifica_promocao:
# Verifica se a peça chegou à última linha (superior ou inferior)
    andi      $t6, $t1, 0x000000ff
    li        $t7, 0x00                # Linha superior
    beq       $t6, $t7, promover_dama
    li        $t7, 0xe0                # Linha inferior
    beq       $t6, $t7, promover_dama
    j         entrada_movimento

    promover_dama:
    li        $t4, 0xff00ff            # Cor especial para dama
    sw        $t4, 0($t1)              # Atualiza a peça para "dama"
    j         entrada_movimento

# Alternância de turnos
    alterna_turno:
    li        $t6, 1
    xor       $s0, $s0, $t6            # Alterna o valor de $s0 entre 0 e 1
    j         entrada_movimento

# Condições de Vitória
    verifica_vitoria:
# Verifica se o adversário não tem mais peças ou movimentos
    li        $t6, 0                   # Contador de peças do adversário
    li        $t8, 0                   # Índice do tabuleiro

    loop_verifica:
    bge       $t8, 256, fim_verifica
    add       $t9, $gp, $t8
    lb        $t10, 0($t9)

# Verifica se a peça do adversário
    bne       $t10, cor_adversaria, proximo_indice

    conta_peca:
    addi      $t6, $t6, 1              # Incrementa contador de peças do adversário
    j         proximo_indice

    proximo_indice:
    addi      $t8, $t8, 4              # Avança para a próxima casa
    j         loop_verifica

    fim_verifica:
    beqz      $t6, jogador_vence

# Caso contrário, continua o jogo
    j         entrada_movimento

    jogador_vence:
# Declara a vitória do jogador atual
    li        $v0, 10                  # Encerrar o programa
    syscall

    testa_Q:
    subi      $t6, $t1, 32             # Movimento em Y
    blt       $t6, $gp, entrada_movimento # Verifica se o movimento em Y sai do tabuleiro
    subi      $t7, $t1, 4              # Movimento em X
    andi      $t7, $t7, 0x000000ff
    andi      $t8, $t1, 0x000000ff     # Mantém ultimos 2 casas dos endereços
    srl       $t7, $t7, 5
    srl       $t8, $t8, 5              # Faz a divisão por 32
    beq       $t7, $t8, foi_Q          # Verifica se o movimento em X muda de linha
    j         entrada_movimento

    testa_E:
    subi      $t6, $t1, 32             # Movimento em Y
    blt       $t6, $gp, entrada_movimento # Verifica se o movimento em Y sai do tabuleiro
    addi      $t7, $t1, 4              # Movimento em X
    andi      $t7, $t7, 0x000000ff
    andi      $t8, $t1, 0x000000ff     # Mantém ultimos 2 casas dos endereços
    srl       $t7, $t7, 5
    srl       $t8, $t8, 5              # Faz a divisão por 32
    beq       $t7, $t8, foi_E          # Verifica se o movimento em X muda de linha
    j         entrada_movimento

    testa_A:
    addi      $t6, $t1, 32             # Movimento em Y
    addi      $t7, $gp, 256
    bgt       $t6, $t7, entrada_movimento # Verifica se o movimento em Y sai do tabuleiro
    subi      $t7, $t1, 4              # Movimento em X
    andi      $t7, $t7, 0x000000ff
    andi      $t8, $t1, 0x000000ff     # Mantém ultimos 2 casas dos endereços
    srl       $t7, $t7, 5
    srl       $t8, $t8, 5              # Faz a divisão por 32
    beq       $t7, $t8, foi_A          # Verifica se o movimento em X muda de linha
    j         entrada_movimento

    testa_D:
    addi      $t6, $t1, 32             # Movimento em Y
    addi      $t7, $gp, 256
    bgt       $t6, $t7, entrada_movimento # Verifica se o movimento em Y sai do tabuleiro
    addi      $t7, $t1, 4              # Movimento em X
    andi      $t7, $t7, 0x000000ff
    andi      $t8, $t1, 0x000000ff     # Mantém ultimos 2 casas dos endereços
    srl       $t7, $t7, 5
    srl       $t8, $t8, 5              # Faz a divisão por 32
    beq       $t7, $t8, foi_D          # Verifica se o movimento em X muda de linha
    j         entrada_movimento


    foi_Q:
    subi      $t2, $t1, 36             # Define a posiçõo da próxima casa
    lb        $t4, 0($t2)              # Olha a cor da próxima casa
    sw        $t4, 0($t1)              # Pinta a casa atual com a cor da próxima
    sw        $t3, 0($t2)              # Pinta a próxima casa com a cor da casa atual
    move      $t1, $t2                 # Troca a posição da peça para a posição da próxima casa
    j         entrada_movimento        # Reseta o loop

    foi_E:
    subi      $t2, $t1, 28             # Define a posição da próxima casa
    lb        $t4, 0($t2)              # Olha a cor da próxima casa
    sw        $t4, 0($t1)              # Pinta a casa atual com a cor da próxima
    sw        $t3, 0($t2)              # Pinta a próxima casa com a cor da casa atual
    move      $t1, $t2                 # Troca a posição da peça para a posição da próxima casa
    j         entrada_movimento        # Reseta o loop

    foi_A:
    addi      $t2, $t1, 28             # Define a posição da próxima casa
    lb        $t4, 0($t2)              # Olha a cor da próxima casa
    sw        $t4, 0($t1)              # Pinta a casa atual com a cor da próxima
    sw        $t3, 0($t2)              # Pinta a próxima casa com a cor da casa atual
    move      $t1, $t2                 # Troca a posição da peça para a posição da próxima casa
    j         entrada_movimento        # Reseta o loop

    foi_D:
    addi      $t2, $t1, 36             # Define a posição da próxima casa
    lb        $t4, 0($t2)              # Olha a cor da próxima casa
    sw        $t4, 0($t1)              # Pinta a casa atual com a cor da próxima
    sw        $t3, 0($t2)              # Pinta a próxima casa com a cor da casa atual
    move      $t1, $t2                 # Troca a posição da peça para a posição da próxima casa
    j         entrada_movimento        # Reseta o loop
