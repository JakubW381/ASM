;=======================================
;
;	ASEMBLER 8051
;	STRUKTURY STERUJACE
;	© 2013 S. Kotyra
;
$NOPAGING

;=======================================
;	deklaracje specyficzne dla DSM-51
WRITE_DATA	EQU 8102H	;procedura z ROM DSM
CSDB		EQU 38H		;adres bufora segmentow
CSDS		EQU 30H		;adres bufora wyswietlaczy
;=======================================


	ORG	0
	LJMP	START

	ORG	100H

;=======================================
;IF( A == B )	//	a EQual b

START:

	MOV	A, #10H
	MOV	B, #20H

	CJNE	A, B, aEQb_ELSE	;if( a == b )
	ACALL	OK_ON		;	OK_ON();
	SJMP	aEQb_END
aEQb_ELSE:			;else
	ACALL	ERR_ON		;	ERR_ON();
aEQb_END:
	SJMP	$

;=======================================
;IF( A != B )	//	a Not Equal b

	MOV	A, #10H
	MOV	B, #20H

	CJNE	A, B, aNEb_IF	;if( a != b )
	SJMP	aNEb_ELSE
aNEb_IF:			; a != b
	ACALL	OK_ON		;	OK_ON();
	SJMP	aNEb_END
aNEb_ELSE:			;else
	ACALL	ERR_ON		;	ERR_ON();
aNEb_END:
	SJMP	$

;=======================================
;IF( A < B )	//	a Less Then b

	MOV	A, #10H
	MOV	B, #20H

;	CJNE	A, B, aLTb_TEST_CY;if( a < b )
;aLTb_TEST_CY:
	CJNE	A, B, $+3	;if( a < b )
	JC	aLTb_IF
	SJMP	aLTb_ELSE
aLTb_IF:			; a < b
	ACALL	OK_ON		;	OK_ON();
	SJMP	aLTb_END
aLTb_ELSE:			;else
	ACALL	ERR_ON		;	ERR_ON();
aLTb_END:
	SJMP	$

;=======================================
;IF( A > B )	//	a Greater Then b

	MOV	A, #10H
	MOV	B, #20H

	CJNE	A, B, aGTb_TEST_CY;if( a > b )
	SJMP	aGTb_ELSE
aGTb_TEST_CY:
	JC	aGTb_ELSE
aGTb_IF:			; a > b
	ACALL	OK_ON		;	OK_ON();
	SJMP	aGTb_END
aGTb_ELSE:			;else
	ACALL	ERR_ON		;	ERR_ON();
aGTb_END:
	SJMP	$

;=======================================
;IF( A <= B )	//	a Less or Equal b

	MOV	A, #10H
	MOV	B, #20H

	CJNE	A, B, aLEb_TEST_CY;if( a <= b )
	SJMP	aLEb_IF
aLEb_TEST_CY:
	JNC	aLEb_ELSE
aLEb_IF:		 	; a <= b
	ACALL	OK_ON		;	OK_ON();
	SJMP	aLEb_END
aLEb_ELSE:			;else
	ACALL	ERR_ON		;	ERR_ON();
aLEb_END:
	SJMP	$

;=======================================
;IF( A >= B )	//	a Greater or Equal b

	MOV	A, #10H
	MOV	B, #20H

;	CJNE	A, B, aGEb_TEST_CY;if( a >= b )
;aGEb_TEST_CY:
	CJNE	A, B, $+3	;if( a >= b )
	JC	aGEb_ELSE
aGEb_IF:			; a >= b
	ACALL	OK_ON		;	OK_ON();
	SJMP	aGEb_END
aGEb_ELSE:	 		;else
	ACALL ERR_ON		;	ERR_ON();
aGEb_END:
	SJMP	$


;=======================================
;FOR( A = 0; A < B; A++ )

	MOV	A, #00H
	MOV	B, #05H

FORaLTbLOOP:
	CJNE	A, B, $+3
	JNC	FORaLTbEND
	ACALL	BLINK_LED
	INC	A
	SJMP	FORaLTbLOOP
FORaLTbEND:
	SJMP	$

;=======================================
;WHILE( A >= B )

	MOV	A, #10
	MOV	B, #05

WHILEaGTbLOOP:
	CJNE	A, B, $+3
WHILEaGTbNE:
	JC	WHILEaGTbEND
	ACALL	BLINK_LED
	DEC	A
	SJMP	WHILEaGTbLOOP
WHILEaGTbEND:
	LJMP	STOP_LED

;=======================================
;	PRZYKLAD REKURENCJI
;Zadanie: w rejestrze A mamy liczbe osmiobitowa, ktora zapisana w systemie dziesietnym
;moze miec dlugosc od 1 do 3 cyfr. Nalezy wyswietlic ja na wyswietlaczu LCD na mozliwie
;najmniejszej liczbie pozycji poprzedzajac pojedyncza spacja.
;Idea rozwiazania: przyjmijmy, ze A przechowuje wartosc 234. Do B ladujemy wartosc 10.
;W wyniku dzielenia DIV AB w rejestrze A uzyskujemy wynik dzielenia, a w B reszte.
;W naszym przypadku A = 23, B = 4. Nie mozemy jeszcze wyswietlic B
;poniewaz znajduje sie ono na ostatniej pozycji. Wysylamy B na stos i powtarzamy
;dzielenie tym razem 23 / 10. Uzyskujemy A = 2, B = 3. Wysylamy B na stos.
;Jezeli nastepnym razem podzielimy 2 / 3, da to A = 0, B = 3.
;A = 0 jest sygnalem dojscia do szczytu procedury rekurencyjnej.
;Wracajac wyswietlamy odzyskiwane ze stosu kolejne wartosci B.

REKURENCJA:
	MOV	A, #234 	;wartosc do wyswietlenia
	JZ	NO_REKUR	;ten przypdek trzeba potraktowac indywidualnie
	ACALL	REKUR		;przypadek typowy - poczatek procedury rekurencyjnej
	SJMP $			;na koniec trzeba zatrzymac / zawiesic program

NO_REKUR:			;wyswietlanie samego zera
	MOV	A, #' '		;spacja do akumulatora
	LCALL	WRITE_DATA	;wyswietl
	MOV	A, #'0'		;'0' do akumulatora
	LCALL	WRITE_DATA	;wyswietl
	SJMP	$		;na koniec trzeba zatrzymac / zawiesic program

REKUR:
	JZ	REKUR_SPACJA	;czy juz szczyt procedury rekurencyjnej? jezeli tak wyswietl spacje
	MOV	B, #10		;jezeli nie
	DIV	AB		;to dzielimy
	PUSH	B		;i B na stos
	ACALL	REKUR		;a ACC dzielimy rekurencyjnie dalej
	POP	ACC		;zdejmujemy w odwrotnej kolejnosci ze stosu
	ADD	A, #48		;zamieniamy liczbe 0.. 9 na kod ASCII 48.. 57 ('0'.. '9')
	LCALL	WRITE_DATA	;wyswietlamy na LCD
	RET			;powrot

REKUR_SPACJA:
	MOV	A, #' '		;spacja do akumulatora
	LCALL	WRITE_DATA	;wyswietl
	RET

;=======================================
;
;	BLINK_LED
;
BLINK_LED:
	SETB	P1.7		;wylacza diode
	MOV	DPTR, #00H	;maksymalnie dlugi czas do odmierzenia
				;na liczniku 16 bitowym
LOOP_OFF:
	NOP			;przedluza czas
	NOP			;wykonywania petli
	DJNZ	DPL, LOOP_OFF	;petla wewnetrzna
	DJNZ	DPH, LOOP_OFF	;petla zewnetrzna
	CLR	P1.7		;wlacza diode
	CLR	P1.5		;wlacza gwizdek
	DJNZ	DPL, $		;krotkie opoznienie
	SETB	P1.5		;wylacza gwizdek
LOOP_ON:
	NOP			;przedluza czas
	NOP			;wykonywania petli
	DJNZ	DPL, LOOP_ON	;petla wewnetrzna
	DJNZ	DPH, LOOP_ON	;petla zewnetrzna
	SETB	P1.7		;wylacza diode
	RET

;=======================================
;	OK_ON / ERR_ON
;
;	zapala zielona diode OK albo czerwona diode ERR
;
OK_ON:
	MOV	A, #10H;	;czwarty bit odpowiada zielonej diodzie OK
	SJMP	OK_ERR_COMM

ERR_ON:
	MOV	A, #20H;	;piaty bit odpowiada czerwonej diodzie ERR

OK_ERR_COMM:
	MOV	R0, #CSDB	;bufor danych
	MOVX	@R0, A		;ustaw bit OK albo ERR
	MOV	A, #40H		;bit diod F1..F4, OK, ERR
	MOV	R0, #CSDS	;wybor wyswietlacza
	MOVX	@R0, A		;wybierz
	CLR	P1.6		;wlacz
	RET

;=======================================
;	STOP_LED
;
;	wyswietla napis STOP na wyswietlaczu LED
;
STOP_LED:
	MOV	R0, #CSDB	;bufor danych wyswietlacza LED
	MOV	R1, #CSDS	;bufor wyboru wyswietlacza wyswietlacza LED
	MOV	DPTR, #STOP_WZORKI-1	;adres wzorkow w DPTR

STOP_LED_OUTER_LOOP:
	MOV	A, #04H		;wartosci inicjujace
	MOV	B, #10H		;

STOP_LED_IL:
	PUSH	ACC			;zabezpiecza akumulator
	SETB	P1.6			;wylacza wyswietlacz
	MOVC	A, @A+DPTR		;laduje wzorek
	MOVX	@R0, A			;wysyla wzorek do bufora danych
	MOV	A, B			;pobiera wskaznik wyswietlacza
	MOVX	@R1, A			;wybiera wyswietlacz
	CLR	P1.6			;wlacza wyswietlacz
	RR	A			;przesuwa wyswietlacz w prawo
	MOV	B, A			;zapamietuje dla nastepego obrotu
	POP	ACC			;odzyskuje akumulator
	DJNZ	ACC, STOP_LED_IL	;jezeli nie wyswietlil wszystkich 4 liter
	SJMP	STOP_LED_OUTER_LOOP	;przywraca wartosci inicjujace

STOP_WZORKI:
	;	P		O		T		S
	DB	1110011B,	0111111B,	0110001B,	1101101B

	END