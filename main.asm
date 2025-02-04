.nolist
.include "m328Pdef.inc"
.list

.def seconds_l = R16 ; Segundos (Unidades)
.def seconds_h = R17 ; Segundos (Dezenas)

.def minutes_l = R18 ; Minutos (Unidades)
.def minutes_h = R19 ; Minutos (Dezenas)

.def hours_l = R20 ; Horas (Unidades)
.def hours_h = R21 ; Horas (Dezenas)

.def aux = R22 ; Registrador auxiliar
.def display_mode = R23 ; Modo de exibição
.def count_mode = R24 ; Modo de contagem

.equ LED = PC0  ; Led que separa os displays, simula ":"
.equ B1 = PC1	; Botão que alterna a visualização entre MM:SS e HH:MM
.equ B2 = PC2	; Botão que alterna entre contagem crescente e decrescente

; Vetor de interrupções
.org 0x0000
    RJMP RESET	
.org 0x0008
    RJMP PCINT1_ISR
.org 0x001A
    RJMP TIMER1_OVF_ISR

RESET:
    ; Inicialização do Stack Pointer (SP)
    LDI aux,HIGH(RAMEND)
    OUT SPH,aux
    LDI aux,LOW(RAMEND)
    OUT SPL,aux

    CBI DDRC,B1	; Configura o pino do botão B1 como entrada
    CBI DDRC,B2	; Configura o pino do botão B2 como entrada
    SBI DDRC,LED	; Configura o pino do Led como saída

    ; Configura o pull-up interno dos botões B1 e B2
    SBI PORTC,B1
    SBI PORTC,B2

    ; Configuração de interrupções
    LDI aux,(1 << PCIE1)
    STS PCICR,aux ; Habilita interrupções PCIE1

    LDI aux,(1 << PCINT9) | (1 << PCINT10)
    STS PCMSK1,aux ; Habilita PCINT9 e PCINT10
    

    LDI aux,0xFF
    OUT DDRD,aux  ; Configura os pinos da porta D como saída
    OUT DDRB,aux  ; Configura os pinos da porta B como saída
	
    ; Zera segundos, minutos, horas e modos de operação
    CLR seconds_l
    CLR seconds_h
    CLR minutes_l
    CLR minutes_h
    CLR hours_l
    CLR hours_h
    CLR display_mode
    CLR count_mode

    ; Configura Timer1 para gerar interrupção a cada 1 segundo
    LDI aux,(1 << TOIE1)  ; Habilita interrupção de overflow
    STS TIMSK1,aux
    LDI aux,HIGH(65536 - 15625) ; 15625 = 16MHz / 1024 / 1Hz
    STS TCNT1H,aux
    LDI aux,LOW(65536 - 15625)
    STS TCNT1L,aux
    LDI aux,(1 << CS12) | (1 << CS10) ; Configura prescaler para 1024
    STS TCCR1B,aux

    SEI ; Habilita interrupções globalmente
    
MAIN:
    RCALL ATUALIZA_DISPLAY
    RJMP MAIN   ; Retorna ao loop principal
    
PISCA_LED:
    SBIS PINC,LED  ; Se o Led estiver ligado, pula a próxima instrução
    RJMP LIGA_LED  ; Se o Led estiver desligado, pula para LIGA_LED
    CBI PORTC,LED  ; Desliga o Led
    RET
LIGA_LED:
    SBI PORTC,LED  ; Liga o Led
    RET
	
; Se o count_mode estiver a 0, o tempo vai ser contado normalmente. Se estiver a 1, vai ser contado de forma decrescente.    
ATUALIZA_TEMPO:
    CPI count_mode, 0
    BREQ ATUALIZA_TEMPO_CRESCENTE
    CPI count_mode, 1
    BREQ ATUALIZA_TEMPO_DECRESCENTE
    RET
	
ATUALIZA_TEMPO_DECRESCENTE:
    DEC seconds_l ; Decrementa as unidades dos segundos
    RCALL ATUALIZA_SEGUNDOS_DECRESCENTE
    RCALL ATUALIZA_MINUTOS_DECRESCENTE
    RCALL ATUALIZA_HORAS_DECRESCENTE
    RET
	
ATUALIZA_SEGUNDOS_DECRESCENTE:
    LDI aux, 255
    CPSE seconds_l, aux ; Se seconds_l não for 255, retorna
    RET
    LDI seconds_l, 9 ; Se seconds_l for 255, colocamos ele a 9 
    DEC seconds_h ; e diminuímos seconds_h
    CPSE seconds_h, aux ; Se seconds_h não for 255, retorna
    RET
    LDI seconds_h, 5 ; Se seconds_h for 255, colocamos ele a 5
    DEC minutes_l ; e diminuímos minutes_l
    RET
	
ATUALIZA_MINUTOS_DECRESCENTE:
    LDI aux, 255
    CPSE minutes_l, aux ; Se minutes_l não for 255, retorna
    RET
    LDI minutes_l, 9 ; Se minutes_l for 255, colocamos ele a 9
    DEC minutes_h
    CPSE minutes_h, aux ; Se minutes_h não for 255, retorna
    RET
    LDI minutes_h, 5 ; Se minutes_h for 255, colocamos ele a 5
    DEC hours_l ; e diminuímos hours_l
    RET

ATUALIZA_HORAS_DECRESCENTE:
	LDI aux,255
    CPSE hours_l,aux
	RET
	LDI hours_l,9
	DEC hours_h
	CPSE hours_h,aux
	RET
    LDI hours_h, 2
    LDI hours_l, 3
    RET

ATUALIZA_TEMPO_CRESCENTE:
    INC seconds_l ; Incrementa as unidades dos segundos
    RCALL ATUALIZA_SEGUNDOS_CRESCENTE
    RCALL ATUALIZA_MINUTOS_CRESCENTE
    RCALL ATUALIZA_HORAS_CRESCENTE
    RET
    
ATUALIZA_SEGUNDOS_CRESCENTE:
    LDI aux, 10
    CPSE seconds_l, aux ; Se seconds_l não for 10, retorna
    RET
    CLR seconds_l ; Se seconds_l for 10, colocamos ele a 0 
    INC seconds_h ; e aumentamos seconds_h
    LDI aux, 6
    CPSE seconds_h, aux ; Se seconds_h não for 6, retorna
    RET
    CLR seconds_h ; Se seconds_h for 6, colocamos ele a 0
    INC minutes_l ; e aumentamos minutes_l
    RET
    
ATUALIZA_MINUTOS_CRESCENTE:
    LDI aux, 10
    CPSE minutes_l, aux ; Se minutes_l não for 10, retorna
    RET
    CLR minutes_l ; Se minutes_l for 10, colocamos ele a 0
    INC minutes_h ; e aumentamos minutes_h
    LDI aux, 6
    CPSE minutes_h, aux ; Se minutes_h não for 6, retorna
    RET
    CLR minutes_h ; Se minutes_h for 6, colocamos ele a 0
    INC hours_l ; e aumentamos hours_l
    RET
    
ATUALIZA_HORAS_CRESCENTE:
    CPI hours_h, 2 ; Se hours_h for 2, precisamos verificar 
                   ; se hours_l chegou a 4
    BREQ DIA_SEGUINTE   ; Chamamos a rotina que faz essa verificação
    LDI aux, 10
    CPSE hours_l, aux ; Se hours_l não for 10, retornamos
    RET
    CLR hours_l ; Se hours_l for 10, colocamos ele a 0
    INC hours_h ; e aumentamos hours_h
    RET
    
ZERA_HORAS:
    ; Se chegamos a 24h, colocamos o relógio a 00h
    CLR hours_h
    CLR hours_l
    
DIA_SEGUINTE:
    CPI hours_l, 4 ; Se hours_L for 4, chegamos a 24:00
    BREQ ZERA_HORAS ; e atualizamos para 00:00
    RET
	
ALTERNA_MODO_CONTAGEM:
    LDI aux, 1
    EOR count_mode, aux ; Alterna o valor de count_mode
    RET
	
; Se display_mode = 0, a exibição vai ser MM:SS.
; Se display_mode = 1, a exibição vai ser HH:MM.
ATUALIZA_DISPLAY:
    CPI display_mode, 0
    BREQ DISPLAY_MINUTOS_SEGUNDOS
    CPI display_mode, 1
    BREQ DISPLAY_HORAS_MINUTOS
    RET

DISPLAY_MINUTOS_SEGUNDOS:
    MOV aux, minutes_l
    ; 4 LSL -> desloca os bits para a parte mais significativa de aux
    LSL aux
    LSL aux
    LSL aux
    LSL aux

    OR aux, minutes_h
    OUT PORTD, aux ; Exibe os minutos na porta D
    MOV aux, seconds_l
    LSL aux
    LSL aux
    LSL aux
    LSL aux
    OR aux, seconds_h
    OUT PORTB, aux ; Exibe os segundos na porta B
    RET

DISPLAY_HORAS_MINUTOS:
    MOV aux, hours_l
    LSL aux
    LSL aux
    LSL aux
    LSL aux
    OR aux, hours_h
    OUT PORTD, aux ; Exibe as horas na porta D
    MOV aux, minutes_l
    LSL aux
    LSL aux
    LSL aux
    LSL aux
    OR aux, minutes_h
    OUT PORTB, aux ; Exibe os minutos na porta B
    RET

ATUALIZA_MODO_DISPLAY:
    LDI aux, 1
    EOR display_mode, aux ; Alterna o modo de exibição
    RET

TIMER1_OVF_ISR:
	PUSH aux ; Salva o valor de aux na pilha
    IN aux, SREG
    PUSH aux ; Salva o SREG na pilha
    ; Recarregar o Timer1 para o próximo overflow
    LDI aux, high(49911)
    STS TCNT1H, aux
    LDI aux, low(49911)
    STS TCNT1L, aux

    ; Atualiza o display e pisca o led
    RCALL ATUALIZA_TEMPO
	RCALL PISCA_LED
	POP aux
    OUT SREG, aux ; Restaura o SREG
    POP aux ; Restaura o valor de aux
    RETI

PCINT1_ISR:
    PUSH aux ; Salva o valor de aux na pilha
    IN aux, SREG
    PUSH aux ; Salva o SREG na pilha
    
    SBIS PINC, B1
    RCALL ATUALIZA_MODO_DISPLAY ; Se B1 for pressionado, alterna o modo de exibição
    
    SBIS PINC, B2
    RCALL ALTERNA_MODO_CONTAGEM ; Se B2 for pressionado, alterna o modo de contagem
    
    POP aux
    OUT SREG, aux ; Restaura o SREG
    POP aux ; Restaura o valor de aux
    RETI
