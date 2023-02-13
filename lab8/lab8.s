.globl _start

# x: 73, y: 1, z: -19 destino
.text 
_start:
    li s0, 0xFFFF0100 # base

    jal xPosition
    mv t4, s1
    jal zPosition
    mv t6, s2

    li t5, 0
    li a5, 500
    avancada:
        blt a5, t5, parar # se a5 < t5
        jal andaFrente
        addi t5, t5, 1
        j avancada

    parar:
        jal paraCarro

    loop:
        li t5, 0
        li a5, 15
        loop2:
            blt a5, t5, loop3 
            jal andaFrente
            addi t5, t5, 1
            j loop2
    loop3:
        jal paraVirada
        li t5, 0
        li a5, 30
        loop4:
            blt a5, t5, continua 
            jal paraCarro
            addi t5, t5, 1
            j loop4

    continua:
        jal xPosition
        jal zPosition
        jal produtoInterno
        
        li s5, 0
        blt s6, s5, direita # se o produto interno for negativo, vira para a direita
        blt s5, s6, esquerda # se o produto interno for positivo, vira para a esquerda

        jal paraVirada
        jal andaFrente # se for zero, anda para frente
        j fim 

    direita:
        jal viraDireita
        j loop

    esquerda:
        jal viraEsquerda
        j loop

    fim:
        jal andaFrente
        #sleep
        jal freio

    end: 
        li a0, 0
        li a7, 93
        ecall


andaFrente:
    addi s0, s0, 0x21 # 33 em decimal
    li a1, 1 # forward
    sb a1, (s0) # carro anda para frente
    addi s0, s0, -33 #voltando a base
    ret

paraCarro:
    addi s0, s0, 0x21 # 33 em decimal
    li a1, 0 # stop
    sb a1, (s0) # carro para
    addi s0, s0, -33 #voltando a base
    ret

xPosition:
    li a1, 1
    sb a1, (s0) #Storing “1” triggers the GPS device to start reading the coordinates and rotation of the car.
    addi s0, s0, 0x10
    lw s1, (s0) # x position 
    addi s0, s0, -16 # 0x10
    ret

zPosition:
    li a1, 1
    sb a1, (s0) #Storing “1” triggers the GPS device to start reading the coordinates and rotation of the car.
    addi s0, s0, 0x18
    lw s2, (s0) # z position 
    addi s0, s0, -24 # 0x18
    ret

viraEsquerda:
    addi s0, s0, 0x20 # 32 em decimal
    li a1, -50 # left
    sb a1, (s0) # carro vira para esquerda
    addi s0, s0, -32 # voltando a base
    ret

viraDireita:
    addi s0, s0, 0x20 # 32 em decimal
    li a1, 50 # right
    sb a1, (s0) # carro vira para direita
    addi s0, s0, -32 # voltando a base
    ret

paraVirada:
    addi s0, s0, 0x20 # 32 em decimal
    li a1, 0 # stop
    sb a1, (s0) # carro para
    addi s0, s0, -32 # voltando a base
    ret

freio:
    addi s0, s0, 0x22 # 34 em decimal
    li a1, 1 # enabled
    sb a1, (s0) # carro freia
    addi s0, s0, -34 # voltando a base
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