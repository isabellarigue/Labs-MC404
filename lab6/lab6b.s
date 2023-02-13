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

    addi s2, s2, 5 # pula o 255
    li a7, 2200 # syscall setPixel


    mv s5, a3 # largura
    mv s6, a4 # altura
    addi s5, s5, -1
    addi s6, s6, -1
    li t3, 0 # i
    for:
        addi t3, t3, 1 # i++
        bge t3, s6, cont
        add a1, t3, 0 # y
        li t4, 1 # j
        for2:
            bge t4, s5, for
            mv a0, t4 # x
            jal aplicaFiltro
            jal setPixel
            addi t4, t4, 1 # j++
            j for2
        j for
    
    cont: #os pixels da borda da imagem Mout devem ser inicializados com a cor preta 
        li t3, 0 # i
        mv a1, t3
        jal borda_coluna
        mv t3, s6 # i
        mv a1, t3
        jal borda_coluna

        li t4, 0 # j
        mv a0, t4 
        jal borda_linha
        mv t4, s5 # j
        mv a0, t4 
        jal borda_linha



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

aplicaFiltro:
    li a6, 0 # supondo que o valor seja em a6 mesmo
    li t5, -1 # k
    li t1, 3 # auxiliar no somatorio
    li s4, 1 # auxiliar no if
    
    for_matriz:
        addi t5, t5, 1 # k++
        bge t5, t1, end2
        li t6, 0 # q
        for_matriz2:
            mv a5, s2 # endereço do inicio da matriz
            bge t6, t1, for_matriz

            mv s0, t3 # i da formula
            add s0, s0, t5
            addi s0, s0, -1

            mv s1, t4 # j da formula
            add s1, s1, t6
            addi s1, s1, -1

            # linha atual * colunas (sem contar 0)  + coluna atual 
            mv s3, s0
            mul s3, s3, a3
            add s3, s3, s1

            add a5, a5, s3 # endereço Win
            lbu t0, 0(a5) # pega o valor do pixel

            beq t5, s4, verifica
            filtro1:
                li s4, -1
                mul t0, t0, s4
                bne t5, s4, pula
                bne t6, s4, pula
            verifica:
                beq t6, s4, filtro8
                bne t6, s4, filtro1
            filtro8:
                li s4, 8
                mul t0, t0, s4
                #li s4, 1
            pula:
                li s4, 1

            add a6, a6, t0 # somatorio

            addi t6, t6, 1 # q++
            j for_matriz2
        j for_matriz

    end2: 
        li s4, 0
        blt a6, s4, abaixo 
        li s4, 255
        blt s4, a6, acima
        ret
        abaixo:
            li a6, 0x00 # cor preta 
            ret
        acima:
            li a6, 0xff # cor branca
            ret

borda_coluna:
    li t4, 0 # j
    li a2, 0x000000ff # cor preta
    li a7, 2200 # syscall setPixel
    for_borda1:
        bge t4, a3, fim1
        mv a0, t4 # x
        ecall
        addi t4, t4, 1 # j++
        j for_borda1
fim1:
    ret 

borda_linha:
    li t3, 0 # i
    li a2, 0x000000ff # cor preta
    li a7, 2200 # syscall setPixel
    for_borda2:
        bge t3, a4, fim2
        mv a1, t3 # y
        ecall
        addi t3, t3, 1 # i++
        j for_borda2
fim2:
    ret

setPixel: 
    mv a2, a6 # R
    li t2, 256
    mul a2, a2, t2
    add a2, a2, a6 # G
    mul a2, a2, t2
    add a2, a2, a6 # B
    mul a2, a2, t2
    addi a2, a2, 0xff # A
    ecall
    ret