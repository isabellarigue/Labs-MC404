.globl set_motor
set_motor:
    li a7, 10
    ecall
    ret

.globl set_handbreak
set_handbreak:
    li t0, 0
    beq a0, t0, set_handbreak2
    li t0, 1
    beq a0, t0, set_handbreak2
    j errado_handbreak
    set_handbreak2:
        li a7, 11
        ecall
        li a0, 0
        ret
    errado_handbreak:
        li a0, 1
        ret

.globl read_camera
read_camera:
    li a7, 12
    ecall
    ret

.globl read_sensor_distance
read_sensor_distance:
    li a7, 13
    ecall
    ret

.globl get_position
get_position:
    li a7, 15
    ecall
    ret

.globl get_rotation
get_rotation:
    li a7, 16
    ecall
    ret

.globl filter_1d_image
filter_1d_image:
    addi sp, sp, -256
    mv t0, sp # sp

    lb a4, 0(a1) # carrega o primeiro elemento do filtro
    lb a5, 1(a1) # carrega o segundo elemento do filtro
    lb a6, 2(a1) # carrega o terceiro elemento do filtro

    li t4, 0 # auxiliar
    addi a0, a0, 1
    sb t4, 0(t0)
    addi t0, t0, 1

    li t1, 0 # contador 
    li t2, 254 # aux 
    filter_loop:
        li t4, 0 # auxiliar
        li t5, 0 # auxiliar

        lbu t3, -1(a0)
        mul t5, t3, a4
        add t4, t4, t5

        lbu t3, 0(a0)
        mul t5, t3, a5
        add t4, t4, t5

        lbu t3, 1(a0)
        mul t5, t3, a6
        add t4, t4, t5

        addi a0, a0, 1

        # verificar se t4 > 0 e t4 < 255
        li t6, 0
        blt t4, t6, abaixo
        li t6, 255
        bge t4, t6, acima
        j intervalo_certo

        abaixo:
            li t4, 0
            j intervalo_certo

        acima:
            li t4, 255

        intervalo_certo:
            sb t4, 0(t0)
            addi t0, t0, 1

            addi t1, t1, 1
            bne t1, t2, filter_loop

    li t4, 0 # auxiliar
    sb t4, 0(t0)

    li t1, 0 # contador
    li t2, 256 
    recupera_sp:
        lbu t3, 0(t0)
        sb t3, 0(a0)
        addi t0, t0, -1
        addi a0, a0, -1
        addi t1, t1, 1
        bne t1, t2, recupera_sp

    addi sp, sp, 256
    ret


.globl display_image
display_image:
    li a7, 19
    ecall
    ret

#Writes the C string pointed by str to the standard output (stdout) and appends a newline character ('\n').
.globl puts
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
        li a7, 18           # syscall write (64)
        mv a1, t5           # buffer
        ecall
        ret

.globl gets   
gets: # a0 eh endereco do buffer que vai guardar a string lida
    mv t0, a0
    mv t4, a0
    li t1, 0
    li t2, '\n'
    for_gets:
        mv a1, t0 # buffer 
        li a0, 0 # file descriptor = 0 (stdin)
        li a2, 1 # size (tamanho maximo possivel)
        li a7, 17 # syscall read (63)
        ecall
        beq a0, t1, end_gets # se retornou 0, acabou a leitura
        lbu t3, 0(t0) # le o caractere
        beq t3, t2, end_gets # se for \n, acabou a leitura
        addi t0, t0, 1 # proximo caractere
        j for_gets
    end_gets:
        sb t1, 0(t0) # coloca o \0 no final da string
        mv a0, t4
        ret

.globl atoi      
atoi: # a0 eh endereco da string terminada em \0
    li t1, 10
    li t3, 0
    li t4, 0
    
    checa_sinal:
        li t5, '-'
        lbu t0, 0(a0) # pega o proximo digito
        beq t0, t5, neg_atoi # se for -, multiplica por -1
    lerNumero:
        lbu t0, 0(a0) # pega o proximo digito
        beq t0, t3, fim_atoi # se for \0, acaba 

        li t5, 0x20
        bne t0, t5, continua_lerNumero
        addi a0, a0, 1 # incrementa o endereço do buffer
        j lerNumero

    continua_lerNumero:
        addi t0, t0, -48 # converte para inteiro
        mul t4, t4, t1 
        add t4, t4, t0 
        addi a0, a0, 1 # incrementa o endereço do buffer
        j lerNumero
    neg_atoi:
        addi a0, a0, 1 # incrementa o endereço do buffer
        li t6, -1
        j lerNumero
    fim_atoi:
        li t5, -1
        bne t5, t6, fim_atoi2
        mul t4, t4, t6
        fim_atoi2:
            mv a0, t4
            ret

.globl itoa
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

.globl approx_sqrt
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


.globl get_time
get_time:
    li a7, 20
    ecall
    ret

.globl sleep
sleep:
    addi sp, sp, -16
    sw ra, 0(sp)
    mv t3, a0
    li t4, -1
    jal get_time
    bgtz a0, 8
    mul a0, a0, t4
    add t3, t3, a0
    loop_sleep:
        jal get_time
        bgtz a0, 8
        mul a0, a0, t4
        blt a0, t3, loop_sleep #ficar de olho
    lw ra, 0(sp)
    addi sp, sp, 16
    ret
