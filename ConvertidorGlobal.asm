# Para hacer print
.macro print(%string)
li $v0 4
la $a0 %string
syscall
.end_macro 

#Input de un numero Binario
.macro inputBinario(%input)
li $v0 8
la $a0 %input
li $a1 33
syscall
.end_macro 

#Input de un numero Hexadecimal
.macro inputHexadecimal(%input)
li $v0 8
la $a0 %input
li $a1 9
syscall
.end_macro 

#Mensaje de Error en el primer Menu
.macro error
print(mensajeError)
b menuLoop
.end_macro 

#Mensaje de Error en el segundo Menu
.macro error2
print(mensajeError)
b menuConvertir
.end_macro 

#Finalizar el programa
.macro exit
li $v0 10
syscall
.end_macro 


.data

cadenaBinario: .space 33
cadenaHexadecimal: .space 9
tablaHex: .asciiz "0123456789ABCDEF"

mensajeMenuPrincipal: .asciiz "Bienvenido al conversor de sistemas númericos -MARM-\nIntroduzca el número del menú asociado a el tipo de sistema númerico con el cual introducira su cadena:\n\n1-Binario complemento a 2\n2-Decimal Empaquetado\n3-Base 10\n4-Octal\n5-Hexadecimal\n\n------------------>"
mensajeInput: .asciiz "\nIntroduzca el número--------> "
mensajeSistemaConvertir: .asciiz "\nIntroducir el número del menú, al sistema númerico que desea convertir:\n\n1-Binario complemento a 2\n2-Decimal Empaquetado\n3-Base 10\n4-Octal\n5-Hexadecimal\n\n------------------>"
mensajeOutput:  .asciiz "\nSu número ya convertido es -->"
mensajeError: .asciiz "\nEl dato introducido es Erróneo! \n \n"
mensajeExit: .asciiz "\n1-Introducir otro número\n\n2-Finalizar programa\n\n------>"

.text

menuLoop:

print(mensajeMenuPrincipal)

#Escoge opcion del sistema numerico
li $v0, 5 
syscall

move $t0 $v0

beq $t0, 1, Binario
beq $t0, 2, decimalEmpaquetado
beq $t0, 3, base10
beq $t0, 4, Octal
beq $t0, 5, Hexadecimal

#Si el input no es igual al del Menu, lanza error
error


### BINARIO ###
Binario:
	
	print(mensajeInput)
	
	inputBinario(cadenaBinario)
	
	#Guardamos el input en $t0
	li $t0 0
	
	#Contador (bytes) [Shifts]
	li $t1 0
	
	loopBinario:
	
		#Si el contador es mayor a 31 (bytes), sale del loop
		bgt $t1 31 finLoopBinario
		#Carga en $t2 el valor en la posicion $t1  
		lbu $t2 cadenaBinario($t1)
	
		#Una vez cargado, lo transformamos a ASCII
		addi $t2, $t2, -0x30 #48 decimal
	
		#Hacemos un shift logico hacia la izquierda 
		sll $t0 $t0 1
	
		#Realizamos una operacion OR para armar la cadena
		or $t0 $t0 $t2
	
		#Añadimos 1 al contador
		add $t1, $t1, 1
	
		#Reiniciamos el Loop
		b loopBinario
	
	finLoopBinario:
	
		b menuConvertir


### DECIMAL EMPAQUETADO ###
decimalEmpaquetado:


### BASE 10 ###
base10:



### OCTAL ###
Octal:


### HEXADECIMAL ###
Hexadecimal:

	print(mensajeInput)
	
	inputHexadecimal(cadenaHexadecimal)
	
	#Guardamos el input en $t0
	li $t0 0
	
	#Contador (bytes) [Shifts]
	li $t1 0
	
	loopHexadecimal:

   		beq $t1 8 finLoopRegistro
    		lbu $t2 cadenaHexadecimal($t1)
    		bge $t2 65 letter
    
    		number:
      			add $t2 $t2 -48
    			b continuation
    		letter:
      			add $t2 $t2 -55
      			b continuation
      			
      	continuation:  
 
    		sll $t0 $t0 4
    		or $t0 $t0 $t2
    		add $t1 $t1 1
  		b loopHexadecimal

	finLoopRegistro:
	
		b menuConvertir
		

### MENU CONVERTIR ###

menuConvertir:

	print(mensajeSistemaConvertir)
	
	#Escoge opcion del sistema numerico
	li $v0, 5 
	syscall
	
	move $t1 $v0
	
	beq $t1, 1, binarioConvertir
	beq $t1, 2, decimalEmpaquetadoConvertir
	beq $t1, 3, base10Convertir
	beq $t1, 4, octalConvertir
	beq $t1, 5, hexadecimalConvertir

	#Si el input no es igual al del MenuConvertir, lanza error2
	error2

binarioConvertir:
decimalEmpaquetadoConvertir:
base10Convertir:
octalConvertir:
hexadecimalConvertir:

	#Guardamos el resultado en $t1
	la $t1,  cadenaHexadecimal
	#Cargamos los 8 shifts de checkeo
	li $t2, 7
	
	loop:
	#Hace una mascara de los primeros 4 bits
	andi $t3, $t0, 0xF
	#Hace shift del numero 4 bits a la derecha
	srl $t0, $t0, 4
	#Suma la posicion a la cadena
	addu $t4, $t1, $t2
	#Obtiene el caracter hexadecimal 
	lb $t5, tablaHex($t3)
	#Almacena el caracter en la cadena
	sb $t5, 0($t4)
	#Resta los shifts
	subu $t2, $t2, 1
	#Si los shifts es mayor o igual a cero, continua el loop
	bgez $t2, loop
	#Si el numero es cero 
	beqz $t0, exitLoop
	
	exitLoop:
	
	print(mensajeOutput)
	print(cadenaHexadecimal)
	exit






