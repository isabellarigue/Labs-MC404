.globl puts
.globl gets
.globl atoi
.globl itoa
.globl approx_sqrt
.globl imageFilter
.globl sleep
.globl time
.globl exit

#Writes the C string pointed by str to the standard output (stdout) and appends a newline character ('\n').
puts: # a0 eh endereco da string terminada em \0
    mv t0, a0
    mv t5, a0
    li t1, 0 
    li t3, 0 # contador de caracteres
    for_puts:
        lbu t2, 0(t0) # carrega o caractere da string
        beq t2, t1, end_puts
        addi t0, t0, 1
        addi t3, t3, 1
        j for_puts
    end_puts:
        li t4, '\n'
        sb t4, 0(t0)
        addi t3, t3, 1
        mv a2, t3 # esse valor esta contando o caractere \n
        li a0, 1            # file descriptor = 1 (stdout)
        li a7, 64           # syscall write (64)
        mv a1, t5           # buffer
        ecall
        ret

     
gets: # a0 eh endereco do buffer que vai guardar a string lida
    mv t0, a0
    mv t4, a0
    li t1, 0
    li t2, '\n'
    for_gets:
        mv a1, t0 # buffer 
        li a0, 0 # file descriptor = 0 (stdin)
        li a2, 1 # size (tamanho maximo possivel)
        li a7, 63 # syscall read (63)
        ecall
        beq a0, t1, end_gets # se retornou 0, acabou a leitura
        lbu t3, 0(a1) # le o caractere
        beq t3, t2, end_gets # se for \n, acabou a leitura
        addi t0, t0, 1 # proximo caractere
        j for_gets
    end_gets:
        sb t1, 0(t0) # coloca o \0 no final da string
        mv a0, t4
        ret

        
atoi: # a0 eh endereco da string terminada em \0
    li t1, 10
    li t3, 0
    li t4, 0
    lerNumero:
        lbu t0, 0(a0) # pega o proximo digito
        beq t0, t3, fim_atoi # se for \0, acaba
        addi t0, t0, -48 # converte para inteiro
        mul t4, t4, t1 
        add t4, t4, t0 
        addi a0, a0, 1 # incrementa o endereço do buffer
        j lerNumero
    fim_atoi:
        mv a0, t4
        ret

itoa: # apenas base 10 e 16, desconsidera maiusculas e minusculas
# a0 eh o numero a ser convertido, a1 eh a string, a2 eh a base
    li t0, 10
    li t1, 0
    li t2, 0 # contador de digitos
    mv t5, a1
    li t4, 16
    li t6, 10

    beq a2, t4, hexa
    blt t1, a0, digitos # se for negativo, converte para positivo
    negativo: 
        li t3, '-'
        addi sp, sp, -4
        sw t3, 0(sp)
        addi t2, t2, 1 # incrementa o contador de digitos
        neg a0, a0 # converte para positivo 

    digitos:
        beq a0, t1, fim_itoa # se for 0, acaba
        rem a5, a0, t0 #s1 = s5 % 10 = 7
        addi a5, a5, 0x30 #s1 = s1 + 30 = 37 (7 em ascii) 
        addi sp, sp, -4 
        sw a5, 0(sp) # salva na pilha
        addi t2, t2, 1 # incrementa o contador de digitos
        div a0, a0, t0 #s5 = s5 / 10 = 533
        j digitos

    hexa:
        beq a0, t1, fim_itoa # se for 0, acaba
        rem a5, a0, a2 
        bge a5, t6, letras
        addi a5, a5, 0x30 
        blt t6, a5, pula
        letras:
            addi a5, a5, 0x37
        pula:
        addi sp, sp, -4 
        sw a5, 0(sp) # salva na pilha
        addi t2, t2, 1 # incrementa o contador de digitos
        div a0, a0, a2 
        j hexa       

    fim_itoa:
        beq t2, t1, fim2 # se nao tem digitos, retorna
        lw a5, 0(sp) # pega o digito da pilha
        sb a5, 0(a1) # salva no buffer
        addi a1, a1, 1 # incrementa o endereço do buffer
        addi sp, sp, 4 # incrementa o endereço da pilha
        addi t2, t2, -1 # decrementa o contador de digitos
        j fim_itoa
    
    fim2:
        sb t1, 0(a1) # coloca o \0 no final da string
        mv a0, t5
        ret


approx_sqrt: #raiz quadrada de um número usando Babylonian method, a0 eh o numero, a1 eh a qtd de iteracoes
    li t1, 2 
    div t2, a0, t1 #t2 = y/2 = k
    
    li t3, 0
    itera:
        bge t3, a1, end_approx_sqrt 
        div t4, a0, t2 #s3 = y/k
        add t4, t4, t2 #s3 = y/k + k
        div t2, t4, t1 #s2 = (y/k + k)/2 = k'
        addi t3, t3, 1
        j itera
    end_approx_sqrt:
        mv a0, t2
        ret

imageFilter: 
    # empilhar s1, s2, s3, s4, s5, s6, s7
    addi sp, sp, -28
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    sw s4, 12(sp)
    sw s5, 8(sp)
    sw s6, 4(sp)
    sw s7, 0(sp)

    mv t0, a1 # largura
    mv t1, a2 # altura
    addi t0, t0, -1
    addi t1, t1, -1
    li t2, 0 # i
    li a7, 2200 # syscall setPixel
    mv s6, a0 # endereço da imagem 
    mv s7, a3 # endereço do filtro
    for_image:
        addi t2, t2, 1 # i++
        mv a1, t2 # y
        bge t2, t1, cont
        li t3, 1 # j
        for_image2:
            bge t3, a1, for_image
            mv a0, t3 # x
            addi sp, sp, -4
            sw ra, 0(sp)
            jal aplicaFiltro
            lw ra, 0(sp)
            addi sp, sp, 4
            addi sp, sp, -4
            sw ra, 0(sp)
            jal setPixel
            lw ra, 0(sp)
            addi sp, sp, 4
            addi t3, t3, 1 # j++
            j for_image2
        j for_image # isso provavelmente nunca eh executado
    
    cont: #os pixels da borda da imagem Mout devem ser inicializados com a cor preta 
        li t4, 0 # i
        mv a1, t4
        addi sp, sp, -4
        sw ra, 0(sp)
        jal borda_coluna
        lw ra, 0(sp)
        addi sp, sp, 4
        mv t4, a2
        mv a1, t4
        addi sp, sp, -4
        sw ra, 0(sp)
        jal borda_coluna
        lw ra, 0(sp)
        addi sp, sp, 4

        li t4, 0 # j
        mv a0, t4
        addi sp, sp, -4
        sw ra, 0(sp)
        jal borda_linha
        lw ra, 0(sp)
        addi sp, sp, 4
        mv t4, a1 # j
        mv a0, t4
        addi sp, sp, -4
        sw ra, 0(sp)
        jal borda_linha
        lw ra, 0(sp)
        addi sp, sp, 4

        # desempilhar s1, s2, s3, s4, s5, s6, s7
        lw s7, 0(sp)
        lw s6, 4(sp)
        lw s5, 8(sp)
        lw s4, 12(sp)
        lw s3, 16(sp)
        lw s2, 20(sp)
        lw s1, 24(sp)
        addi sp, sp, 28

        ret

aplicaFiltro:
    li t4, -1 # k
    li t6, 3 # auxiliar no somatorio
    li a3, 1 # auxiliar no if
    li a6, 0

    for_matriz:
        addi t4, t4, 1 # k++
        bge t4, t6, fim_aplicaFiltro
        li t5, 0 # q
        for_matriz2:
            mv a4, s6 # endereco do inicio da matriz
            bge t5, t6, for_matriz

            mv a5, t2 # i
            add a5, a5, t4 # i+k
            addi a5, a5, -1 # i+k-1

            mv s1, t3 # j 
            add s1, s1, t5 # j+q
            addi s1, s1, -1 # j+q-1

            # linha atual * colunas (sem contar 0)  + coluna atual 
            mv s2, a5 # i+k-1
            mul s2, s2, a3 # (i+k-1)*largura
            add s2, s2, s1 # (i+k-1)*largura + j+q-1

            add a4, a4, s2 # endereco Win
            lbu s3, 0(a4) # Win[i+k-1][j+q-1]

            mul s4, t4, t6 # k*3 (linha atual * colunas)
            add s4, s4, t5 # k*3 + q (linha atual * colunas + coluna atual)
            mv s5, s7
            add s5, s5, s4 # endereco do filtro
            lbu s4, 0(s5) # filtro[k][q]

            mul s3, s3, s4 # Win[i+k-1][j+q-1] * filtro[k][q]
            add a6, a6, s3 # somatorio

            addi t5, t5, 1 # q++
            j for_matriz2
        j for_matriz
    
    fim_aplicaFiltro:
        li t4, 0
        blt a6, t4, abaixo
        li t4, 255
        blt t4, a6, acima
        ret
        abaixo:
            li a6, 0x00
            ret
        acima:  
            li a6, 0xFF
            ret

borda_coluna:
    li t5, 0 # j
    li a2, 0x000000ff # cor preta
    for_borda1:
        bge t5, a1, fim
        mv a0, t5 # x
        ecall
        addi t5, t5, 1 # j++
        j for_borda1

borda_linha:
    li t5, 0 # i
    li a2, 0x000000ff # cor preta
    for_borda2:
        bge t5, a2, fim
        mv a1, t5 # y
        ecall
        addi t5, t5, 1 # i++
        j for_borda2

setPixel: 
    mv a2, a6 # R
    li t5, 256
    mul a2, a2, t5
    add a2, a2, a6 # G
    mul a2, a2, t5
    add a2, a2, a6 # B
    mul a2, a2, t5
    addi a2, a2, 0xff # A
    ecall
    ret


time:
    addi sp, sp, -32
    
    addi a1, sp, 12 # buffer_timezone
    mv a0, sp # buffer_timeval
    li a7, 169 # chamada de sistema gettimeofday
    ecall

    lw t1, (sp) # tempo em segundos
    lw t2, 8(sp) # fração do tempo em microssegundos
    li t3, 1000
    mul t1, t1, t3
    div t2, t2, t3
    add a0, t2, t1

    addi sp, sp, 32
    
    ret

sleep:
    mv t4, a0 # tempo que deve ser executado
    mv t6, ra
    jal time
    mv ra, t6
    mv t0, a0 # tempo inicial
    continue:
        mv t6, ra
        jal time
        mv ra, t6 
        sub t1, a0, t0 # tempo atual - tempo inicial
        beq t4, t1, fim # se tempo que deve ser executado == tempo atual - tempo inicial
        j continue

exit: 
    li a7, 60
    ecall

fim:
    ret