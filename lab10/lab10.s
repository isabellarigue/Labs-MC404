.align 4
stack: # Final da pilha do programa
.skip 1024 # Aloca 1024 bytes para a pilha
stack_end: # 0xFFFF0100 da pilha do programa


.text
.align 4

int_handler:
    ###### Tratador de interrupções e syscalls ######

    li t0, 10
    beq a7, t0, set_engine
    li t0, 11
    beq a7, t0, hand_break
    li t0, 15
    beq a7, t0, get_position

    set_engine:
        li t1, -5
        beq a0, t1, steering

        # engine
        li t0, 0xFFFF0100
        addi t0, t0, 0x21
        sb a0, (t0) # carro anda 
        beq a1, t1, pula

        steering:
            li t0, 0xFFFF0100
            addi t0, t0, 0x20
            sb a1, (t0) # carro vira

        j pula

    hand_break:
        li t0, 0xFFFF0100
        addi t0, t0, 0x22
        sb a0, (t0) # freio
        j pula

    get_position:
        li t0, 0xFFFF0100
        li t2, 1
        sb t2, (t0) #Storing “1” triggers the GPS device to start reading the coordinates and rotation of the car.

        addi t0, t0, 0x10 # x
        lw a0, (t0)

        addi t0, t0, 0x04 # y
        lw a1, (t0)

        addi t0, t0, 0x04 # z
        lw a2, (t0)
        
        j pula

    pula: 
        csrr t0, mepc  # carrega endereço de retorno (endereço 
                        # da instrução que invocou a syscall)
        addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
        csrw mepc, t0  # armazena endereço de retorno de volta no mepc
        mret           # Recuperar o restante do contexto (pc <- mepc)
  


.globl _start
_start:

  la t0, int_handler  # Carregar o endereço da rotina que tratará as interrupções
  csrw mtvec, t0      # (e syscalls) em no registrador MTVEC para configurar
                      # o vetor de interrupções.

# Escreva aqui o código para mudar para modo de usuário e chamar a função 
# user_main (definida em outro arquivo). Lembre-se de inicializar a 
# pilha do usuário para que seu programa possa utilizá-la.
    # mudando o modo de usuário
    csrr t1, mstatus # Update the mstatus.MPP
    li t2, ~0x1800 # field (bits 11 and 12)
    and t1, t1, t2 # with value 00 (U-mode)
    csrw mstatus, t1
    la t0, user_main # Loads the user software
    csrw mepc, t0 # entry point into mepc
    mret # PC <= MEPC; mode <= MPP;

    # Inicializa a pilha do usuário
    la sp, stack_end

    # Chama a função user_main
    call user_main
    

.globl logica_controle
logica_controle:
    # implemente aqui sua lógica de controle, utilizando apenas as 
    # syscalls definidas.

    addi sp, sp, -16
    sw ra, 0(sp)
    jal position

    mv t4, a0
    mv t6, a2

    li s5, 0
    li s0, 2000
    avancada:
        blt s0, s5, parar # se s0 < s5, pula para parar
        jal andaFrente
        addi s5, s5, 1
        j avancada

    parar:
        jal paraCarro
        jal viraEsquerda

    loop01:
        li s5, 0
        li s0, 250
        loop02:
            blt s0, s5, loop
            jal viraEsquerda
            jal andaFrente
            addi s5, s5, 1
            j loop02

    loop:
        li s5, 0
        li s0, 800
        loop2:
            blt s0, s5, loop3 
            jal andaFrente
            addi s5, s5, 1
            j loop2
    loop3:
        jal paraVirada
        li s5, 0
        li s0, 30
        loop4:
            blt s0, s5, segue_reto
            jal paraCarro
            addi s5, s5, 1
            j loop4

    segue_reto:
        li s5, 0
        li s0, 3500
        loop5:
            blt s0, s5, fim
            jal andaFrente
            addi s5, s5, 1
            j loop5

    fim:
        jal freio
        lw ra, 0(sp)
        addi sp, sp, 16
        ret

paraCarro:
    li a1, -5
    li a0, 0
    li a7, 10
    ecall
    ret

paraVirada:
    li a0, -5
    li a1, 0
    li a7, 10
    ecall
    ret

freio:
    li a0, 1
    li a7, 11
    ecall
    ret

andaFrente:
    li a1, -5
    li a0, 1
    li a7, 10
    ecall
    ret

viraDireita:
    li a0, -5
    li a1, 30
    li a7, 10
    ecall
    ret

viraEsquerda:
    li a0, -5
    li a1, -127
    li a7, 10
    ecall
    ret

position:
    li a7, 15
    ecall
    ret

produtoInterno:
# (s1, s2) e (s3, s4)
    li s3, -19 # (x, z) -> (z, -x)
    li s4, -73
    sub s1, s1, t4 # transladando para a origem
    sub s2, s2, t6
    mul s6, s1, s3
    mul s7, s2, s4
    add s6, s6, s7
    ret