# Para hacer print
.macro print(%string)
li $v0 4
la $a0 %string
syscall
.end_macro 

#Para hacer print de un registro
.macro printNumero(%$t1)
li $v0 1
la $a0, (%$t1)
syscall
.end_macro 

#Para hacer print direcciones de memoria
.macro printMemoria(%buffer)
li $v0, 4
la $a0, %buffer
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

.macro readString
	la $a0, cadenaBinario
	li $a1, 32 
	li $v0, 8
	syscall
	la $t0, cadenaBinario 
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
cadenaH: .space 10
buffer: .space 33
pila: .space 7
DaH: .space 9





mensajeMenuPrincipal: .asciiz "Bienvenido al conversor de sistemas númericos -MARM-\nIntroduzca el número del menú asociado a el tipo de sistema númerico con el cual introducira su cadena:\n\n1-Binario complemento a 2\n2-Decimal Empaquetado\n3-Base 10\n4-Octal\n5-Hexadecimal\n6-Decimal Fraccionario a Binario\n------------------>"
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
beq $t0, 6, decimalFraccionarioBinario

#Si el input no es igual al del Menu, lanza error
error


####################################
### 				MENU INPUT				 		###
####################################



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
	
	print(mensajeInput)
	inputBinario(cadenaBinario)
	
	li $s1, 0 #decimal medio
	li $t6, 0 #decimal final
	li $t1, 0 #indice
	li $s0, 8 #multiplicador
	li $t2, 1000000 #base elevada a la n
	
	contarDecimalEmp:
	#condicion de parada
	beq $t1, 32, finloopDecEmp
	
	#obtener 0 o 1 en decimal
	lb $t0, cadenaBinario($t1)
	subi $t0, $t0, 48
	
	#si es 0, el multiplicador se anula
	#si es 1, el multiplicador sigue igual
	mul $t0, $t0, $s0
	add $s1, $s1, $t0
	div $s0, $s0, 2
	addi $t1, $t1, 1
	
	#despues de dividir varias veces el multiplicador entre 2, en algun punto llegara a 0
	beq $s0, 0, verificarDecEmp
	b contarDecimalEmp
	
	verificarDecEmp:
	#cuando el decimal guardado sea mayor a 11, se le coloca el signo para finalizar 
	bgt $s1, 11, seguroDecEmp
	
	#multiplica el decimal guardado por la posicion respectiva del decimal empaquetado
	mul $s1, $s1, $t2
	add $t6, $t6, $s1
	
	#reinicia valores
	li $s0, 8
	div $t2, $t2, 10
	li $s1, 0
	b contarDecimalEmp
	
	seguroDecEmp:
	#si el decimal guardado es 12, se queda positivo
	#si es 13, cambia a negativo
	beq $s1, 12, finloopDecEmp
	mul $t6, $t6, -1
		
	finloopDecEmp:

        move $t0, $t6
        b menuConvertir


### BASE 10 ###
base10:

	print(mensajeInput)
	inputBinario(cadenaBinario)
	
	li $t0 0
	li $t1 1
  	li $t5 1
        li $t2 0
        
        loop_dec1_r:
	lbu $t3 cadenaBinario($t1)
  		
  	beq $t3 0 end_loop_dec1_r
	beq $t3 10 end_loop_dec1_r
  		
	add $t3 $t3 -48
	mul $t2 $t2 10
	add $t2 $t2 $t3
  	     
	add $t1 $t1 1
	
	b loop_dec1_r
	
        end_loop_dec1_r:

	lbu $t3 cadenaBinario($zero)
        beq $t3 43 dec_sign
  	mul $t2 $t2 -1
  	
        dec_sign:
        
        move $t0 $t2   
          
        b menuConvertir
	
	


### OCTAL ###
Octal:

	print(mensajeInput)
	inputBinario(cadenaBinario)
	 # Inicializar puntero a la cadena
    	li $t0, 0

    	# Inicializar registro para almacenar el número octal
    	li $t1, 0

	loopOctalinput:
    	# Leer el siguiente carácter de la cadena
    	lb $t2, cadenaBinario($t1)

    	# Si el carácter es nulo (fin de la cadena), salir del bucle
    	beqz $t2, endLoopOctalinput

    	# Convertir el carácter ASCII a un valor octal
    	sub $t2, $t2, 48  # '0' en ASCII es 48

    	# Desplazar el número almacenado en $t1 a la izquierda por 3 bits (un dígito octal)
    	sll $t1, $t1, 3

   	 # Añadir el dígito convertido al número almacenado en $t1
    	or $t1, $t1, $t2

    	# Avanzar al siguiente carácter en la cadena
    	addiu $t0, $t0, 1

    	# Volver al inicio del bucle
    	b loopOctalinput

	endLoopOctalinput:
    	# Guardar el número octal convertido en $t0
    	move $t0, $t1

    	# Imprimir el número octal convertido (para verificación)
    	move $a0, $t0
    	li $v0, 1
    	syscall

   	b menuConvertir


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


#Decimal Fraccionario a Binario
decimalFraccionarioBinario:
print(mensajeInput)
	
# Leer cadena de la entrada estándar
	li $v0, 8
	la $a0, DaH
	li $a1,9
	syscall


	li $t0 0
    # Inicializar registros para los números antes y después del punto
    li $t3, 0  # Números antes del punto
    li $t4, 0  # Números después del punto
    
    li $t6 1
    
    li $t7 10

    # Banderas para determinar si estamos leyendo la parte entera o fraccionaria
    li $t5, 1  # 1 si estamos leyendo la parte entera, 0 si estamos leyendo la parte fraccionaria

loop2:
    # Leer el siguiente carácter de la cadena
    lbu $t1, DaH($t0)
   
    # Si el carácter es nulo (fin de la cadena), salir del bucle
    beqz $t1, done
	
    # Si encontramos un punto, cambiar la bandera
    beq $t1, '.', change_to_fraction

    # Convertir el carácter ASCII a un valor decimal
    sub $t1, $t1, 48  # '0' en ASCII es 48
	
    # Si estamos leyendo la parte entera
    beq $t5, 1, read_integer_part

    # Si estamos leyendo la parte fraccionaria
    j read_fraction_part


change_to_fraction:
    li $t5, 0  # Cambiar la bandera a fraccionaria
    addiu $t0, $t0, 1  # Avanzar al siguiente carácter
    j loop2  # Volver al inicio del bucle

read_integer_part:
    # Desplazar el número almacenado en $t3 a la izquierda por 1 dígito (multiplicar por 10)
    mul $t3, $t3, 10

    # Añadir el dígito convertido al número almacenado en $t3
    add $t3, $t3, $t1

    # Avanzar al siguiente carácter
    addi $t0, $t0, 1
    j loop2

read_fraction_part:

	add $t4, $t4, $t1
	mul $t4, $t4, $t7
	mul $t6, $t6, 10
	addi $t0, $t0, 1
	
    	j loop2

done:
    # Imprimir la parte entera (para verificación)
   # move $a0, $t3
    #li $v0, 1
    #syscall

    # Imprimir un espacio
    #li $a0, ','
    #li $v0, 11
    #syscall

    # Imprimir la parte fraccionaria (para verificación)
    #move $a0, $t4
    #li $v0, 1
    #syscall

	b loopT3	
	
loopT3:
	
	li $t1 23
	
	li $t6 0
	
	imprimirT3:
	
	beq $t1, $t6, loopT4
	
	# Obtener el bit más significativo
   	 srl $t2, $t3, 23
    	andi $t2, $t2, 1

    	# Imprimir el bit
    	addi $a0, $t2, 48  # Convertir bit a carácter ASCII ('0' o '1')
    	li $v0, 11
    	syscall

    	# Desplazar el número a la izquierda para el siguiente bit
    	sll $t3, $t3, 1

    	# Incrementar el contador
    	addi $t6, $t6, 1

    	# Volver al inicio del bucle
   	 j imprimirT3
	
loopT4:

#Imprimir un espacio
    li $a0, ','
    li $v0, 11
    syscall
    
    	li $t1 7
	
	li $t6 0
	
	imprimirT4:
	
	beq $t1, $t6, end
	
	# Obtener el bit más significativo
   	 srl $t2, $t4, 7
    	andi $t2, $t2, 1

    	# Imprimir el bit
    	addi $a0, $t2, 48  # Convertir bit a carácter ASCII ('0' o '1')
    	li $v0, 11
    	syscall

    	# Desplazar el número a la izquierda para el siguiente bit
    	sll $t4, $t4, 1

    	# Incrementar el contador
    	addi $t6, $t6, 1

    	# Volver al inicio del bucle
   	 j imprimirT4
    
 end:
 exit

		
####################################
### 				MENU CONVERTIR				 ###
####################################
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

	#Longitud del decimal
	li $s0, 0 

	#Loop para Dividir entre 2
	loopBinarioOutput:
	#Si el numero es igual cero, sale del Loop
	beqz $t0, printBinario
	#Divide el numero entre 2, y guarda el cociente en $t0
	div $t0, $t0, 2
	#Guarda el residuo en $t2
	mfhi $t2
	#Le aumenta 1 a la longitud del numero
	addi $s0, $s0, 1

	addi $t2, $t2, 48 #ASCII { 0 }
	#En la direccion de memoria, guarda el valor de $t2
	sb $t2, cadenaBinario($s0)

	b loopBinarioOutput

	printBinario:
	#Si la longitud del numero ya fue recorrida, es decir igual a 0, sale del Loop
	beqz, $s0, endLoopBinario
	#Carga en $t0 el valor de la direccion en memoria
	lb $t0, cadenaBinario($s0)

	li $v0, 11
	move $a0, $t0
	syscall

	#Reduce en 1 la longitud del numero
	subi $s0, $s0, 1

	b printBinario

endLoopBinario:

	print(mensajeOutput)
	exit

decimalEmpaquetadoConvertir:

	# En $t8 vas a guardar un flag dependiendo de si el numero es positivo o negativo 0 == Negativo 1 == Positivo
	bltz $t0 casoNegativo
	b casoPositivo

casoPositivo:

	li $t8 1
	b finCasosSignos

casoNegativo:

	li $t8 0
	mul $t0 $t0 -1

	b finCasosSignos

finCasosSignos:

	# En $t1 vamos a ir guardando cada uno de los digitos
	# En $t2 vamos a tener una variable de desplazamiento de la pila
	li $t2 0
	li $s1 10 # En $s1 tenemos la constante 10
loopConstruccionPila:

	# Condicion de Parada
	beqz $t0 finLoopConstruccionPila

	# Dividimos el Numero que tenemos por ahora entre 10
	div $t0 $s1

	# Actualizamos $t0 con el cociente
	mflo $t0
	# En $t1 colocamos el digito leido
	mfhi $t1

	# Guardamos el Digito Leido en la Pila
	sb $t1 pila($t2)

	# Movemos $t2 un espacio hacia adelante
	addi $t2 $t2 1

	b loopConstruccionPila
finLoopConstruccionPila:
	addi $t2 $t2 -1

	# En $t1 quedara el entero representado como decimal empaquetado
	# Usaremos $t2 para recorrer la pila sacando cada Numero
	# En $t3 vamos a cargar cada uno de los digitos de la pila
	li $t1 0
loopConversionBPD:

	# Condicion de Parada
	bltz $t2 finLoopConversionBPD

	# Cargar Un Numero de la Pila
	lb $t3 pila($t2)

	# Colocar el valor de $t3 en $t1
	# Desplazamos los bits de $t1 4 posiciones hacia la izquierda
	sll $t1 $t1 4

	# Colocamos los ultimos 4 bits de $t3 en $t1 haciendo un OR *
	# * Hacemos un OR porque los primeros 28 bits de $t3 tenemos garantizado que van a valer 0
	or $t1 $t3 $t1

	# Mover el Puntero de la Pila un Espacio hacia la Izquierda
	addi $t2 $t2 -1


	b loopConversionBPD
finLoopConversionBPD:

	# Colocar el Signo

	sll $t1 $t1 4

	beqz $t8 casoFlagNegativo
	b casoFlagPositivo

casoFlagPositivo:

	li $t9 0xC
	add $t1 $t1 $t9

	b finCasosFlagSignos

casoFlagNegativo:

	li $t9 0xD
	add $t1 $t1 $t9

	b finCasosFlagSignos

finCasosFlagSignos:
	
	li $t2 31
	
	li $t6 0
	loop:
	
	bltz $t2  finloop
	
	srlv $t3 $t1 $t2
	
	and $t3 $t3 1
	
	addi $t3 $t3 48
	
	sb $t3, cadenaBinario($t6)
	
	addi $t2 $t2 -1
	addi $t6 $t6 1
	
	 b loop 
	

	finloop:

	print(mensajeOutput)
	printMemoria(cadenaBinario)
	exit

base10Convertir:

	#Longitud del decimal
	li $s0, 0 

	#Si el NUMERO A CONVERTIR es mayor o igual 0, salta a Positivo Base
	bgez $t0, positivoBase

	#Valor absoluto
	abs $t0, $t0

	#SIGNO NEGATIVO
	negativoBase:
	#Syscall para imprimir caracter
	li $v0, 11
	li $a0, 45 #ASCII -  {NEGATIVO}
	syscall
	
	b loopOctalOutput
 
	#SIGNO POSITIVO
	positivoBase:
	#Syscall para imprimir caracter
	li $v0, 11
	li $a0, 43 #ASCII +  {POSITIVO}
	syscall

	#Loop para Dividir entre 10
	loopBaseOutput:
	#Si el numero es igual cero, sale del Loop
	beqz $t0, printBase
	#Divide el numero entre 10, y guarda el cociente en $t0
	div $t0, $t0, 10
	#Guarda el residuo en $t2
	mfhi $t2
	#Le aumenta 1 a la longitud del numero
	addi $s0, $s0, 1

	addi $t2, $t2, 48 #ASCII { 0 }
	#En la direccion de memoria, guarda el valor de $t2
	sb $t2, cadenaH($s0)

	b loopBaseOutput

	printBase:
	#Si la longitud del numero ya fue recorrida, es decir igual a 0, sale del Loop
	beqz, $s0, endLoopBase
	#Carga en $t0 el valor de la direccion en memoria
	lb $t0, cadenaH($s0)

	li $v0, 11
	move $a0, $t0
	syscall

	#Reduce en 1 la longitud del numero
	subi $s0, $s0, 1

	b printOctal

endLoopBase:

	print(mensajeOutput)
	printMemoria(cadenaH)
	exit

octalConvertir:

	#Longitud del decimal
	li $s0, 0 

	#Si el NUMERO A CONVERTIR es mayor o igual 0, salta a Positivo Octal
	bgez $t0, positivoOctal

	#Valor absoluto
	abs $t0, $t0

	#SIGNO NEGATIVO
	negativoOCtal:
	#Syscall para imprimir caracter
	li $v0, 11
	li $a0, 45 #ASCII -  {NEGATIVO}
	syscall
	
	b loopOctalOutput
 
	#SIGNO POSITIVO
	positivoOctal:
	#Syscall para imprimir caracter
	li $v0, 11
	li $a0, 43 #ASCII +  {POSITIVO}
	syscall

	#Loop para Dividir entre 8
	loopOctalOutput:
	#Si el numero es igual cero, sale del Loop
	beqz $t0, printOctal
	#Divide el numero entre 8, y guarda el cociente en $t0
	div $t0, $t0, 8
	#Guarda el residuo en $t2
	mfhi $t2
	#Le aumenta 1 a la longitud del numero
	addi $s0, $s0, 1

	addi $t2, $t2, 48 #ASCII { 0 }
	#En la direccion de memoria, guarda el valor de $t2
	sb $t2, cadenaH($s0)

	b loopOctalOutput

	printOctal:
	#Si la longitud del numero ya fue recorrida, es decir igual a 0, sale del Loop
	beqz, $s0, endLoopOctal
	#Carga en $t0 el valor de la direccion en memoria
	lb $t0, cadenaH($s0)

	li $v0, 11
	move $a0, $t0
	syscall

	#Reduce en 1 la longitud del numero
	subi $s0, $s0, 1

	b printOctal

endLoopOctal:

	print(mensajeOutput)
	printMemoria(cadenaH)
	exit


hexadecimalConvertir:
	
	
	blt $t0 0 negativoHex
	
	 negativoHex:
	 li $v0 11 
 	 la $a0 '-'
	syscall
	mul $t0 $t0 -1
	b loop_r_hexa
	
	positivoHex:
	li $v0 11
	la $a0 '+'
	syscall
	b loop_r_hexa
	
	
	
	li $t4 0
        li $t3 0  
        loop_r_hexa:
          #se hacen 8 iteraciones porque el registro tiene 32 bits o 8 nibbles
          beq $t4 8 end_loop_r_hexa
          #copiar $t2 a $t1
          move $t1 $t0
          #shift logico porque hacia la izuqierda
          sllv $t1 $t1 $t3
          #shift logico porque hacia la derecha
          srl $t1 $t1 28
     
          #$t1 va desde 0 a 15
   	  #si es mayor o igual a 10 va add_letter
          bge $t1 10 add_letter
          
          add_number:
            add $t1 $t1 48
          b store_byte
          
          add_letter:
            add $t1 $t1 55
            
          store_byte:   
                   
          sb $t1  cadenaHexadecimal($t4)
          add $t3 $t3 4
          add $t4 $t4 1
          
          b loop_r_hexa
          
        end_loop_r_hexa:
        
	   print(mensajeOutput)
	   print(cadenaHexadecimal)
	   exit

	




