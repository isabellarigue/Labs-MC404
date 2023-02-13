.globl _start

.data
input_adress: .skip 0x16  # buffer (ficar atenta)
output_adress: .skip 0x16 # buffer (ficar atenta)
pula_linha: .asciz "\n" 

.text 
_start:

# read 
    li a0, 0 # file descriptor = 0 (stdin)
    la a1, input_adress # buffer
    li a2, 20 # size (lendo apenas 1 byte, mas tamanho é variável)
    li a7, 63 # syscall read (63)
    ecall

    li t2, 32 # espaço em ascii

    lb s1, input_adress + 0 # s1 = input_adress[0]
    lb s2, input_adress + 1 
    lb s3, input_adress + 2
    lb s4, input_adress + 3

    jal charParaInt 
    add s1, s5, 0 # copiando s5 em s1
    jal raizQuadrada
    add s5, s2, 0 #copiando s2 em s5
    jal intParaChar
    sb s1, output_adress + 3, t6
    sb s2, output_adress + 2, t6
    sb s3, output_adress + 1, t6
    sb s4, output_adress + 0, t6
    sb t2, output_adress + 4, t6

    lb s1, input_adress + 5 # s1 = input_adress[1]
    lb s2, input_adress + 6 
    lb s3, input_adress + 7
    lb s4, input_adress + 8

    jal charParaInt 
    add s1, s5, 0 # copiando s5 em s1
    jal raizQuadrada
    add s5, s2, 0 #copiando s2 em s5
    jal intParaChar
    sb s1, output_adress + 8, t6 
    sb s2, output_adress + 7, t6 
    sb s3, output_adress + 6, t6 
    sb s4, output_adress + 5, t6
    sb t2, output_adress + 9, t6

    lb s1, input_adress + 10 # s1 = input_adress[1]
    lb s2, input_adress + 11 
    lb s3, input_adress + 12
    lb s4, input_adress + 13

    jal charParaInt 
    add s1, s5, 0 # copiando s5 em s1
    jal raizQuadrada
    add s5, s2, 0 #copiando s2 em s5
    jal intParaChar
    sb s1, output_adress + 13, t6
    sb s2, output_adress + 12, t6
    sb s3, output_adress + 11, t6
    sb s4, output_adress + 10, t6 
    sb t2, output_adress + 14, t6

    lb s1, input_adress + 15
    lb s2, input_adress + 16
    lb s3, input_adress + 17
    lb s4, input_adress + 18

    jal charParaInt 
    add s1, s5, 0 # copiando s5 em s1
    jal raizQuadrada
    add s5, s2, 0 #copiando s2 em s5
    jal intParaChar
    sb s1, output_adress + 18, t6 
    sb s2, output_adress + 17, t6
    sb s3, output_adress + 16, t6
    sb s4, output_adress + 15, t6
    sb t2, output_adress + 19, t6

    li t0, 10
    sb t0, output_adress + 19, t6 # colocando o \n
 
    # write
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_adress # buffer
    li a2, 20           # size
    li a7, 64           # syscall write (64)
    ecall

    end: 
        li a0, 0
        li a7, 93
        ecall
    




raizQuadrada: #raiz quadrada de um número usando Babylonian method
    li a1, 2 #a1 = 2
    div s2, s1, a1 #s2 = y/2 = k

    # 10 iteracoes
    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    div s3, s1, s2 #s3 = y/k
    add s3, s3, s2 #s3 = y/k + k
    div s2, s3, a1 #s2 = (y/k + k)/2 = k'

    ret

charParaInt: #por ex 5337, s1 = 35 (5 em ascii), s2 = 33 (3 em ascii), s3 = 33 (3 em ascii), s4 = 37 (7 em ascii)
    li a0, 48 #a0 = 48
    sub s1, s1, a0 #s1 = s1 - a0 = 35 - 30 = 5
    sub s2, s2, a0 #s2 = s2 - a0 = 33 - 30 = 3
    sub s3, s3, a0 #s3 = s3 - a0 = 33 - 30 = 3
    sub s4, s4, a0 #s4 = s4 - a0 = 37 - 30 = 7
    
    #numero += s4 * 10
    #numero += s3 * 100
    #numero += s2 * 1000
    #numero += s1 * 10000
    li t0, 1
    mul s4, s4, t0 #s4 = s4 * 10  
    li s5, 0
    add s5, s5, s4 #s5 = s5 + s4
    li t0, 10
    mul s3, s3, t0 #s3 = s3 * 100
    add s5, s5, s3 #s5 = s5 + s3
    li t0, 100
    mul s2, s2, t0 #s2 = s2 * 1000
    add s5, s5, s2 #s5 = s5 + s2
    li t0, 1000
    mul s1, s1, t0 #s1 = s1 * 1000
    add s5, s5, s1 #s5 = s5 + s1

    ret #retorna o numero em s5

intParaChar: #o numero esta em s5
 # por ex 5337
    li t0, 10

    rem s1, s5, t0 #s1 = s5 % 10 = 7
    addi s1, s1, 48 #s1 = s1 + 30 = 37 (7 em ascii)
    div s5, s5, t0 #s5 = s5 / 10 = 533

    rem s2, s5, t0 #s2 = s5 % 10 = 3
    addi s2, s2, 48 #s2 = s2 + 30 = 33 (3 em ascii)
    div s5, s5, t0 #s5 = s5 / 10 = 53

    rem s3, s5, t0 #s3 = s5 % 10 = 3
    addi s3, s3, 48 #s3 = s3 + 30 = 33 (3 em ascii)
    div s5, s5, t0 #s5 = s5 / 10 = 5

    rem s4, s5, t0 #s4 = s5 % 10 = 5
    addi s4, s4, 48 #s4 = s4 + 30 = 35 (5 em ascii)
    div s5, s5, t0 #s5 = s5 / 10 = 0

    ret


