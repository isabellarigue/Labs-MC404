.bss
.align 4
isr_stack: # Final da pilha das ISRs
.skip 1024 # Aloca 1024 bytes para a pilha
isr_stack_end: # Base da pilha das ISRs

.align 4
stack: # Final da pilha do programa
.skip 1024 # Aloca 1024 bytes para a pilha
stack_end: # Base da pilha do programa

.data
.globl _system_time
_system_time: .word 0


.text
.globl _start
.align 2
_start:
    la t0, main_isr # Carrega o endereço da main_isr
    csrw mtvec, t0 # em mtvec

    # Configura mscratch com o topo da pilha das ISRs.
    la t0, isr_stack_end # t0 <= base da pilha
    csrw mscratch, t0 # mscratch <= t0

    la sp, stack_end # sp <= base da pilha do programa

    # Habilita Interrupções Externas
    csrr t1, mie # Seta o bit 11 (MEIE)
    li t2, 0x800 # do registrador mie
    or t1, t1, t2
    csrw mie, t1
    
    # Habilita Interrupções Global
    csrr t1, mstatus # Seta o bit 3 (MIE)
    ori t1, t1, 0x8 # do registrador mstatus
    csrw mstatus, t1

    # Habilita Interrupções Timer
    li t3, 0xFFFF0100
    addi t3, t3, 8
    li t4, 100
    sw t4, 0(t3)

    jal main



.globl main_isr
main_isr:
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -128 # Aloca espaço na pilha da ISR

    sw x0, 0(sp) # Salva x0
    sw x1, 4(sp) # Salva x1
    sw x2, 8(sp) # Salva x2
    sw x3, 12(sp) # Salva x3
    sw x4, 16(sp) # Salva x4
    sw x5, 20(sp) # Salva x5
    sw x6, 24(sp) # Salva x6
    sw x7, 28(sp) # Salva x7
    sw x8, 32(sp) # Salva x8
    sw x9, 36(sp) # Salva x9
    sw x10, 40(sp) # Salva x10
    sw x11, 44(sp) # Salva x11
    sw x12, 48(sp) # Salva x12
    sw x13, 52(sp) # Salva x13
    sw x14, 56(sp) # Salva x14
    sw x15, 60(sp) # Salva x15
    sw x16, 64(sp) # Salva x16
    sw x17, 68(sp) # Salva x17
    sw x18, 72(sp) # Salva x18
    sw x19, 76(sp) # Salva x19
    sw x20, 80(sp) # Salva x20
    sw x21, 84(sp) # Salva x21
    sw x22, 88(sp) # Salva x22
    sw x23, 92(sp) # Salva x23
    sw x24, 96(sp) # Salva x24
    sw x25, 100(sp) # Salva x25
    sw x26, 104(sp) # Salva x26
    sw x27, 108(sp) # Salva x27
    sw x28, 112(sp) # Salva x28
    sw x29, 116(sp) # Salva x29
    sw x30, 120(sp) # Salva x30
    sw x31, 124(sp) # Salva x31

    # # Habilita Interrupções Timer
    li t3, 0xFFFF0100
    addi t3, t3, 8
    li t4, 100
    sw t4, 0(t3)

    # Incrementa o contador de tempo em 10 ms
    la t2, _system_time
    lw t4, 0(t2)
    addi t4, t4, 100
    sw t4, 0(t2)

    # Recupera o contexto
    lw x31, 124(sp) # Recupera x31
    lw x30, 120(sp) # Recupera x30
    lw x29, 116(sp) # Recupera x29
    lw x28, 112(sp) # Recupera x28
    lw x27, 108(sp) # Recupera x27
    lw x26, 104(sp) # Recupera x26
    lw x25, 100(sp) # Recupera x25
    lw x24, 96(sp) # Recupera x24
    lw x23, 92(sp) # Recupera x23
    lw x22, 88(sp) # Recupera x22
    lw x21, 84(sp) # Recupera x21
    lw x20, 80(sp) # Recupera x20
    lw x19, 76(sp) # Recupera x19
    lw x18, 72(sp) # Recupera x18
    lw x17, 68(sp) # Recupera x17
    lw x16, 64(sp) # Recupera x16
    lw x15, 60(sp) # Recupera x15
    lw x14, 56(sp) # Recupera x14
    lw x13, 52(sp) # Recupera x13
    lw x12, 48(sp) # Recupera x12
    lw x11, 44(sp) # Recupera x11
    lw x10, 40(sp) # Recupera x10
    lw x9, 36(sp) # Recupera x9
    lw x8, 32(sp) # Recupera x8
    lw x7, 28(sp) # Recupera x7
    lw x6, 24(sp) # Recupera x6
    lw x5, 20(sp) # Recupera x5
    lw x4, 16(sp) # Recupera x4
    lw x3, 12(sp) # Recupera x3
    lw x2, 8(sp) # Recupera x2
    lw x1, 4(sp) # Recupera x1
    lw x0, 0(sp) # Recupera x0

    addi sp, sp, 128 # Desaloca espaço da pilha da ISR
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente
    mret # Retorna da interrupção


.globl play_note
play_note:
# a0 = canal, a1 = id instrumento, a2 = nota, a3 = velocidade da nota, a4 = duracao da nota
    li t0, 0xFFFF0300 #base 
    sb a0, 0(t0) 

    addi t0, t0, 2
    sh a1, 0(t0)

    addi t0, t0, 2
    sb a2, 0(t0)

    addi t0, t0, 1
    sb a3, 0(t0)

    addi t0, t0, 1
    sh a4, 0(t0)

    ret
