;AUTHOR: VIGNESHWAREN SUNDER
;PIC18F458 BASED VOLTMETER (0-5V) 
;CODE MADE AS A PART OF MY COURSEWORK FOR EMBEDDED SYSTEMS

;ASSEMBLY CODE STARTS

LIST P=PIC18F458 
#include P18F458.INC 
CONFIG OSC =HS, OSCS=OFF
CONFIG WDT=OFF
CONFIG BORV=45, PWRT=ON,BOR=ON
CONFIG DEBUG=OFF, LVP=OFF, STVR=OFF

D0       EQU 10H
D1       EQU 11H
ADCONR   EQU 14H
MYREG    EQU 5H
         ORG 000H
         GOTO MAIN           	;Bypass the interrupt vector table
         ORG 0008H				;interrupt vector table
		 BTFSS PIR1, ADIF		;did we get here due to A/D int?
		 RETFIE					;No. Then return to main
		 GOTO AD_ISR            ;Yes. Then go to INT0 ISR



 

         ORG 100H
MAIN
         ;MOVLW 0X32
         ;MOVWF STKPTR
         CLRF TRISC     		;PORTC O/P
         CLRF TRISD				;PORTD O/P
         SETF TRISA				;Make RA0 I/P
		 MOVLW 07H				;
		 MOVWF CMCON
         MOVLW 0X81             ;Fosc/64, ch. 0,A/D
         MOVWF ADCON0			;load ADCON0 with 10 000 001
         MOVLW 04EH				;right justified, Fosc/64, AN0=analog
         MOVWF ADCON1     		;load ADCON1 with 01 001 110   
         MOVLW 0XA9             
         BCF PIR1, ADIF         ;clear ADIF for the first round
 		 BSF PIE1,ADIE			;enable A/D Interrupt
		 BSF INTCON,PEIE		;enable peripheral interrupt
		 BSF INTCON,GIE			;enable interrupt globally
   		 
OVER     CALL DELAY				;wait for Tacq(sample and hold time)
		 BSF ADCON0, GO         ;start conversion
		 BRA OVER               ;wait for EOC

DELAY  	 ORG 00150H             
		 MOVLW 008H
		 MOVWF MYREG             
AGAIN    NOP
		 NOP
		 NOP
		 DECF MYREG,F
 		 BNZ AGAIN
		 RETURN

AD_ISR
         ORG 00200H
         
;START    BSF ADCON0,GO
INCONV   ;BTFSC ADCON0,DONE
         ;BRA INCONV
         ;MOVFF ADRESL,ADCONR
         
		 MOVFF ADRESH,ADCONR     ;Give High byte to ADCONR
         CALL DIVIDE             ;Call Divide Subroutine
         ;CALL DISPLAY           ;Call Display subroutine
         CALL TEN                ;Call Ten Subroutine
         CALL UNIT               ;Call UNIT Subroutine
 		 BCF PIR1, ADIF          ;clear ADIF interrupt flag bit
         ;BRA START
         RETFIE


DIVIDE   CLRF D0                 ;Clears D0
         CLRF D1                 ;Clears D1
         MOVLW D'51'             ;#1 Load 51 into WREG
EVEN     CPFSEQ ADCONR           ;#2
         BRA QUOTIENT            ;#3
         INCF D1,F               ;#4
         SUBWF ADCONR,F          ;#5
QUOTIENT CPFSGT ADCONR           ;#6

         BRA DECIMAL			 ;#7
         INCF D1,F               ;#8 Increment D1 for each time
                                 ;ADCONR is Greater than 51
         
         SUBWF ADCONR,F          ;#9 Subtract 51 from ADCONR
         
         BRA EVEN                ;#10
DECIMAL  MOVLW 0X05              ;#11
REMAIN   CPFSGT ADCONR           ;#12 Checks if ADCONR>5

         BRA DIVDONE             ;#13
         INCF D0,F               ;#14
         SUBWF ADCONR,F          ;#15 Subtract 5
         
         BRA REMAIN
DIVDONE  RETURN                  ;#16
;DISPLAY  MOVFF D1,PORTC         ;#17 Output D1 on integer 7-seg
 ;        MOVFF D0,PORTD         ;#18 Output D0 on fractional 7-seg
 ;        RETURN
 ;        END           


ORG 300H
UNIT
L1    MOVLW D'0'
         CPFSEQ D0
         BRA L2
         MOVLW 0C0H
         MOVWF PORTD
         RETURN
L2    MOVLW D'1'
         CPFSEQ D0
         BRA L3
         MOVLW 0F9H
         MOVWF PORTD
         RETURN
L3    MOVLW D'2'
         CPFSEQ D0
         BRA L4
         MOVLW 0A4H
         MOVWF PORTD
         RETURN
L4    MOVLW D'3'
         CPFSEQ D0
         BRA L5
         MOVLW 0XB0
         MOVWF PORTD
         RETURN
L5    MOVLW D'4'
         CPFSEQ D0
         BRA L6
         MOVLW 099H
         MOVWF PORTD
         RETURN
L6    MOVLW D'5'
         CPFSEQ D0
         BRA L7
         MOVLW 092H
         MOVWF PORTD
         RETURN
L7    MOVLW D'6'
         CPFSEQ D0
         BRA L8
         MOVLW 082H
         MOVWF PORTD
         RETURN
L8    MOVLW D'7'
         CPFSEQ D0
         BRA L9
         MOVLW 0F8H
         MOVWF PORTD
         RETURN
L9    MOVLW D'8'
         CPFSEQ D0
         BRA L10
         MOVLW 080H
         MOVWF PORTD
         RETURN
L10   MOVLW D'9'
         MOVLW 090H
         MOVWF PORTD
         RETURN

ORG 400H
TEN

LOOP1    MOVLW D'0'
         CPFSEQ D1
         BRA LOOP2
         MOVLW B'01000000'
         MOVWF PORTC
         RETURN
LOOP2    MOVLW D'1'
         CPFSEQ D1
         BRA LOOP3
         MOVLW B'01111001'
         MOVWF PORTC
         RETURN
LOOP3    MOVLW D'2'
         CPFSEQ D1
         BRA LOOP4
         MOVLW B'00100100'
         MOVWF PORTC
         RETURN
LOOP4    MOVLW D'3'
         CPFSEQ D1
         BRA LOOP5
         MOVLW B'00110000'
         MOVWF PORTC
         RETURN
LOOP5    MOVLW D'4'
         CPFSEQ D1
         BRA LOOP6
         MOVLW B'00011001'
         MOVWF PORTC
         RETURN
LOOP6    MOVLW D'5'
         MOVLW B'00010010'
         MOVWF PORTC
         RETURN
END
   
 