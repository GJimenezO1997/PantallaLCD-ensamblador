PROCESSOR 16F887
INCLUDE <p16F887.inc>
LIST    P=16F887
    
__CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
__CONFIG    _CONFIG2, _WRT_OFF & _BOR21V


CBLOCK	0X20
    AUX1, AUX2, TEST, TEST1
ENDC
	  
ORG 0X00
    
CONFIGURAR_PUERTOS 
    BSF	    STATUS, RP0		;Cambio al Bank 1
    MOVLW   0XFF		;guarda el valor en w
    MOVWF   TRISA		;Permite configurar los bits del puerto A como entradas
    MOVLW   0X00		;guarda el valor en w
    MOVWF   TRISC		;Permite configurar los bits del puerto c, el bit mas significativo en 0
    MOVLW   0X00		;guarda el valor w 
    CLRF    TRISB		;Permite configurar los bits del puerto b como salida
    BSF	    STATUS, RP1		;Cambio al Bank 3
    MOVLW   0X00		;Se le asigna el valor a w
    MOVWF   ANSEL		;Default                            0 Digital
    CLRF    ANSELH		;Asignas el valor 0 a ANSELH        1 Analogico
    BCF	    STATUS, RP0		
    BCF	    STATUS, RP1		;Se posiciona en el banco 0
    CLRF    PORTA		;Limpieza de puertos
    CLRF    PORTB		;Limpieza de puertos
    CLRF    PORTC
    
;Subrutina para inicializar el LCD y manda las letras 
INICIO
    CALL    LCD_INICIALIZAR  
    CALL    MENSAJE_1
    CALL    LCD_LINEA2
    CALL    MENSAJE_2
    GOTO    INICIO
;Subrutinas para poder enviar letras al LCD
MENSAJE_1
    MOVF    TEST, W
    CALL    TABLA_1
    MOVWF   PORTB
    CALL    LCD_ENVIAR_LETRA
    INCF    TEST
    MOVF    TEST, W
    XORLW   d'8'
    BTFSC   STATUS, Z
    GOTO    HELL_1
    GOTO    MENSAJE_1
   
TABLA_1
    ADDWF   PCL, F
    DT	    "Sistemas"
    
HELL_1
    CLRF    TEST
    RETURN
    
MENSAJE_2
    MOVF    TEST1, W
    CALL    TABLA_2
    MOVWF   PORTB
    CALL    LCD_ENVIAR_LETRA
    INCF    TEST1
    MOVF    TEST1, W
    XORLW   d'9'
    BTFSC   STATUS, Z
    GOTO    HELL_2
    GOTO    MENSAJE_2
   
TABLA_2
    ADDWF   PCL, F
    DT	    "Digitales"
    
HELL_2
    CLRF    TEST1
    RETURN
;Subrutina para la inicialización del LCD
LCD_INICIALIZAR
    BCF	    PORTC, 0      ; RS=0 MODO INSTRUCCION
    MOVLW   0X01	  ; El comando 0x01 limpia la pantalla en el LCD
    MOVWF   PORTB
    CALL    LCD_COMANDO	  ; Se da de alta el comando
    MOVLW   0X0C	  ; Selecciona la primera línea
    MOVWF   PORTB
    CALL    LCD_COMANDO   ; Se da de alta el comando
    MOVLW   0X3C	  ; Se configura el cursor
    MOVWF   PORTB
    CALL    LCD_COMANDO   ; Se da de alta el comando
    BSF	    PORTC, 0	  ; Rs=1 MODO DATO
    RETURN
;Subrutina para enviar comandos
LCD_COMANDO
    BSF	    PORTC, 1        ; Pone la ENABLE en 1
    CALL    LOOP	  ; Tiempo de espera
    CALL    LOOP
    BCF	    PORTC, 1	  ; ENABLE=0    
    CALL    LOOP
    RETURN     
;Subrutina para enviar un dato
LCD_ENVIAR_LETRA
    BSF	    PORTC, 0	   ; RS=1 MODO DATO
    CALL    LCD_COMANDO    ; Se da de alta el comando
    RETURN
;Configuración Lineal 2 LCD
LCD_LINEA2
    BCF	    PORTC, 0	   ; RS=0 MODO INSTRUCCION
    MOVLW   0XC0	   ; Selecciona linea 2 pantalla en el LCD
    MOVWF   PORTB
    CALL    LCD_COMANDO    ; Se da de alta el comando
    RETURN
; Subrutina de retardo
LOOP           
    MOVLW   .80
    MOVWF   AUX2 
LOOP_1
    MOVLW   .80
    MOVWF   AUX1
LOOP_2
    DECFSZ  AUX1, 1
    GOTO    LOOP_2
    DECFSZ  AUX2, 1
    GOTO    LOOP_1
    RETURN
    
    END