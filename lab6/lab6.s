.globl _start

.data
pula_linha: .asciz "\n" 
input_file: .asciz "imagem.pgm"
input_adress: .skip 0x4000F  

.text 
_start:
    la a0, input_file    # endereço do caminho para o arquivo
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # modo
    li a7, 1024          # syscall open 
    ecall

    #li a0, 0 # file descriptor = 0 (stdin)
    la a1, input_adress #  buffer
    li a2, 262159 # size (lendo apenas 1 byte, mas tamanho é variável)
    li a7, 63 # syscall read (63)
    ecall

    la s2, input_adress # endereço do buffer
    addi s2, s2, 3 # pula o cabeçalho

    li s4, 0 # numero base
    li t1, 48 # 0 em ascii
    li t2, 10 # auxiliar 
    li s0, ' '
    jal lerNumero
    mv a3, s4 # largura
    addi s2, s2, 1 # pula o espaço
    li s0, '\n'
    li s4, 0 
    jal lerNumero
    mv a4, s4 # altura

    jal setCanvasSize #instrucao 67

    addi s2, s2, 5 # pula o 255, ficar atenta!
    li a7, 2200 # syscall setPixel

    li t3, 0 # i
    for:
        bge t3, a4, end
        mv a1, t3 # y
        addi t3, t3, 1 # i++
        li t4, 0 # j
        for2:
            bge t4, a3, for
            mv a0, t4 # x
            jal setPixel
            addi s2, s2, 1 # proximo pixel
            addi t4, t4, 1 # j++
            j for2
        j for

    end: 
        li a0, 0
        li a7, 93
        ecall


lerNumero: #retorna o numero final em s4
    lbu t0, 0(s2) # pega o proximo digito
    beq t0, s0, fim # se for espaco acaba
    sub t0, t0, t1 # converte para inteiro
    mul s4, s4, t2 
    add s4, s4, t0 
    addi s2, s2, 1 # incrementa o endereço do buffer
    j lerNumero
fim:
    ret

setCanvasSize:
    mv a0, a3 # largura
    mv a1, a4 # altura
    li a7, 2201
    ecall
    ret

setPixel: 
    lbu t0, 0(s2) 
    mv a2, t0 # R
    li t2, 256
    mul a2, a2, t2
    add a2, a2, t0 # G
    mul a2, a2, t2
    add a2, a2, t0 # B
    mul a2, a2, t2
    addi a2, a2, 0xff # A
    ecall
    ret