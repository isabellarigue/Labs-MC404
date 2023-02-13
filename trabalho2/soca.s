.bss
.align 4
stack: # Final da pilha do programa
.skip 1024 # Aloca 1024 bytes para a pilha
stack_end: # 0xFFFF0300 da pilha do programa


.text
.align 4

int_handler:
    ###### Tratador de interrupções e syscalls ######
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -80 # Aloca espaço na pilha da ISR

    sw s0, 0(sp) # Salva x0
    sw s1, 4(sp) # Salva x1
    sw s2, 8(sp) # Salva x2
    sw s3, 12(sp) # Salva x3
    sw s4, 16(sp) # Salva x4
    sw s5, 20(sp) # Salva x5
    sw s6, 24(sp) # Salva x6
    sw s7, 28(sp) # Salva x7
    sw s8, 32(sp) # Salva x8
    sw s9, 36(sp) # Salva x9
    sw s10, 40(sp) # Salva x10
    sw s11, 44(sp) # Salva x11
    sw t0 , 48(sp) # Salva x12
    sw t1 , 52(sp) # Salva x13
    sw t2 , 56(sp) # Salva x14
    sw t3 , 60(sp) # Salva x15
    sw t4 , 64(sp) # Salva x16
    sw t5 , 68(sp) # Salva x17
    sw t6 , 72(sp) # Salva x18
    sw ra, 76(sp)


    li t0, 10
    beq a7, t0, set_engine
    li t0, 11
    beq a7, t0, hand_break
    li t0, 12
    beq a7, t0, read_sensors
    li t0, 13
    beq a7, t0, read_sensor_distance
    li t0, 15
    beq a7, t0, get_position
    li t0, 16
    beq a7, t0, get_rotation
    li t0, 17
    beq a7, t0, read
    li t0, 18
    beq a7, t0, write
    li t0, 19
    beq a7, t0, draw_line
    li t0, 20
    beq a7, t0, get_systime
    j pula

    set_engine:
        li t0, -1
        bge a0, t0, confere1
        j errado_motor
        confere1:
            li t0, 1
            bge t0, a0, confere2
            j errado_motor
        confere2:
            li t0, -127
            bge a1, t0, confere3
            j errado_motor
        confere3:
            li t0, 127
            bge t0, a1, continua_engine
            j errado_motor

        errado_motor:
            li a0, -1
            j pula

        continua_engine:
            # engine
            li t0, 0xFFFF0300
            addi t0, t0, 0x21
            sb a0, (t0) # carro anda 

            #steering
            li t0, 0xFFFF0300
            addi t0, t0, 0x20
            sb a1, (t0) # carro vira

            li a0, 0
            j pula

    hand_break:
        li t0, 0xFFFF0300
        addi t0, t0, 0x22
        sb a0, (t0) # freio
        j pula

    get_position: 
        li t0, 0xFFFF0300
        li t2, 1
        sb t2, (t0) #Storing “1” triggers the GPS device to start reading the coordinates and rotation of the car.

        busywait_position:
            li t3, 0
            lb t2, (t0) 
            bne t2, t3, busywait_position

        addi t0, t0, 0x10 # x
        lw t3, (t0)
        sw t3, (a0)

        addi t0, t0, 0x04 # y
        lw t3, (t0)
        sw t3, (a1)

        addi t0, t0, 0x04 # z
        lw t3, (t0)
        sw t3, (a2)
        
        j pula

    read_sensors: 
        li t5, 0 # contador
        li t6, 256 # limite
        
        li t0, 0xFFFF0300
        addi t0, t0, 0x1
        li t2, 1
        sb t2, (t0) #Storing “1” triggers

        busywait_sensors:
            li t3, 0
            lb t2, (t0) 
            bne t2, t3, busywait_sensors

        addi t0, t0, 0x23
        loop_readsensors:
            lb t4, (t0) 
            sb t4, (a0)

            addi t0, t0, 0x1
            addi a0, a0, 0x1    
            addi t5, t5, 1
            blt t5, t6, loop_readsensors

        j pula

    read_sensor_distance: 
        li t0, 0xFFFF0300
        addi t0, t0, 0x2
        li t2, 1
        sb t2, (t0) #Storing “1” triggers

        busywait_sensordistance:
            li t3, 0
            lb t2, (t0) 
            bne t2, t3, busywait_sensordistance

        li t0, 0xFFFF0300
        addi t0, t0, 0x1C
        lw a0, (t0) # read the value of the sensor

        j pula

    get_rotation: 
        li t0, 0xFFFF0300
        li t2, 1
        sb t2, (t0) #Storing “1” triggers the GPS device to start reading the coordinates and rotation of the car.

        busywait_rotation:
            li t3, 0
            lb t2, (t0) 
            bne t2, t3, busywait_rotation

        addi t0, t0, 0x04
        lw t3, (t0) # read the value of the sensor x
        sw t3, 0(a0)
        addi t0, t0, 0x04
        lw t3, (t0) # read the value of the sensor y
        sw t3, 0(a1)
        addi t0, t0, 0x04
        lw t3, (t0) # read the value of the sensor z
        sw t3, 0(a2)

        j pula 

    read:
        li t3, 0 # contador
        read_zero:
            li t0, 0XFFFF0500
            addi t0, t0, 0x2
            li t2, 1
            sb t2, (t0) #Storing “1” triggers

            busywait_read0:
                lb t2, (t0) 
                bne t2, zero, busywait_read0

            addi t0, t0, 0x1
            lb t1, (t0) # carregando o valor em t1
            beq t1, zero, read_zero # verificando se ta lendo zero 

        # se é diferente de 0, então armazena no buffer
        sb t1, 0(a1) # escrevendo no buffer
        addi a1, a1, 1 # incrementando o buffer
        addi t3, t3, 1 # incrementando o contador
        bge t3, a2, fim_read # se o contador for maior que o tamanho do buffer, ja atingiu o objetivo

        read_loop:
            li t0, 0XFFFF0500
            addi t0, t0, 0x2
            li t2, 1
            sb t2, (t0) #Storing “1” triggers

        busywait_read:
            lb t2, (t0) 
            bne t2, zero, busywait_read

            addi t0, t0, 0x1
            lb t1, (t0) # carregando o valor em t1
            beq t1, zero, fim_read
            sb t1, 0(a1) # escrevendo no buffer
            addi a1, a1, 1 # incrementando o buffer
            addi t3, t3, 1 # incrementando o contador
            blt t3, a2, read_loop
        
        fim_read:
            mv a0, t3 
            j pula

    write:
        li t3, 0 # contador
        write_loop:
            li t0, 0XFFFF0500
            addi t0, t0, 0x1
            lb t1, 0(a1) # carregando o valor em t1
            sb t1, (t0) # escrevendo no buffer

            addi t0, t0, -1
            li t2, 1
            sb t2, (t0) #Storing “1” triggers

            busywait_write:
                lb t2, (t0) 
                bne t2, zero, busywait_write

            addi a1, a1, 1 # incrementando o buffer
            addi t3, t3, 1 # incrementando o contador

            blt t3, a2, write_loop
        j pula

    draw_line:
        li t0, 0xFFFF0700 # ta certa a base?
        addi t0, t0, 0x2
        li t2, 100
        sh t2, (t0) #Array size

        addi t0, t0, 0x2
        sw zero, (t0) # posicao inicial 

        li t6, 100 # max
        li t5, 0 # contador
        loop100:
            lb t3, 0(a0) 
            li t2, 256
            mul t3, t3, t2
            add t3, t3, a6 # G
            mul t3, t3, t2
            add t3, t3, a6 # B
            mul t3, t3, t2
            addi t3, t3, 0xff # A

            addi t0, t0, 0x4
            sw t3, (t0) # cor
            addi a0, a0, 1 # incrementando o buffer
            addi t5, t5, 1 # incrementando o contador
            blt t5, t6, loop100

        li t0, 0xFFFF0700
        li t2, 1
        sb t2, (t0) #Storing “1” triggers
        busywait_line:
            lb t2, (t0) 
            bne t2, zero, busywait_line

        # de 100 a 200
        li t0, 0xFFFF0700 
        addi t0, t0, 0x2
        li t2, 100
        sh t2, (t0) #Array size

        addi t0, t0, 0x2
        li t2, 100
        sw t2, (t0) # posicao inicial 

        li t6, 100 # max
        li t5, 0 # contador
        loop200:
            lb t3, 0(a0) 
            li t2, 256
            mul t3, t3, t2
            add t3, t3, a6 # G
            mul t3, t3, t2
            add t3, t3, a6 # B
            mul t3, t3, t2
            addi t3, t3, 0xff # A

            addi t0, t0, 0x4
            sw t3, (t0) # cor
            addi a0, a0, 1 # incrementando o buffer
            addi t5, t5, 1 # incrementando o contador
            blt t5, t6, loop200

        li t0, 0xFFFF0700
        li t2, 1
        sb t2, (t0) #Storing “1” triggers
        busywait_line1:
            lb t2, (t0) 
            bne t2, zero, busywait_line1

        # de 200 a 256
        li t0, 0xFFFF0700 
        addi t0, t0, 0x2
        li t2, 56
        sh t2, (t0) #Array size

        addi t0, t0, 0x2
        li t2, 200
        sw t2, (t0) # posicao inicial 

        li t6, 56 # max
        li t5, 0 # contador
        loop256:
            lb t3, 0(a0) 
            li t2, 256
            mul t3, t3, t2
            add t3, t3, a6 # G
            mul t3, t3, t2
            add t3, t3, a6 # B
            mul t3, t3, t2
            addi t3, t3, 0xff # A

            addi t0, t0, 0x4
            sw t3, (t0) # cor
            addi a0, a0, 1 # incrementando o buffer
            addi t5, t5, 1 # incrementando o contador
            blt t5, t6, loop256

        li t0, 0xFFFF0700
        li t2, 1
        sb t2, (t0) #Storing “1” triggers
        busywait_line2:
            lb t2, (t0) 
            bne t2, zero, busywait_line2

        j pula


    get_systime:
        li t0, 0xFFFF0100
        li t2, 1
        sb t2, (t0) #Storing “1” triggers

        busywait_systime:
            li t3, 0
            lb t2, (t0) 
            bne t2, t3, busywait_systime

        addi t0, t0, 0x4
        lw a0, (t0) # read the time 

        j pula

    pula: 
        csrr t0, mepc  # carrega endereço de retorno (endereço 
                        # da instrução que invocou a syscall)
        addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
        csrw mepc, t0  # armazena endereço de retorno de volta no mepc

        lw ra, 76(sp)
        lw t6, 72(sp) # Recupera x31
        lw t5, 68(sp) # Recupera x30
        lw t4, 64(sp) # Recupera x29
        lw t3, 60(sp) # Recupera x28
        lw t2, 56(sp) # Recupera x27
        lw t1, 52(sp) # Recupera x26
        lw t0, 48(sp) # Recupera x25
        lw s11, 44(sp) # Recupera x24
        lw s10, 40(sp) # Recupera x23
        lw s9, 36(sp) # Recupera x22
        lw s8, 32(sp) # Recupera x21
        lw s7, 28(sp) # Recupera x20
        lw s6, 24(sp) # Recupera x19
        lw s5, 20(sp) # Recupera x18
        lw s4, 16(sp) # Recupera x17
        lw s3, 12(sp) # Recupera x16
        lw s2, 8(sp)  # Recupera x15
        lw s1, 4(sp)  # Recupera x14
        lw s0, 0(sp)  # Recupera x13
    
        addi sp, sp, 80 # Desaloca espaço da pilha da ISR
        csrrw sp, mscratch, sp # Troca sp com mscratch novamente


        mret           # Recuperar o restante do contexto (pc <- mepc)
  


.globl _start 
_start:

  la t0, int_handler  # Carregar o endereço da rotina que tratará as interrupções
  csrw mtvec, t0      # (e syscalls) em no registrador MTVEC para configurar
                      # o vetor de interrupções.

    # Inicializa a pilha do usuário
    li sp, 0x07FFFFFC

    # Inicializa a pilha do sistema
    # Configura mscratch com o topo da pilha das ISRs.
    la t0, stack_end # t0 <= base da pilha
    csrw mscratch, t0 # mscratch <= t0

    # mudando o modo de usuário
    csrr t1, mstatus # Update the mstatus.MPP
    li t2, ~0x1800 # field (bits 11 and 12)
    and t1, t1, t2 # with value 00 (U-mode)
    csrw mstatus, t1
    la t0, main # Loads the user software
    csrw mepc, t0 # entry point into mepc
    mret # PC <= MEPC; mode <= MPP;




