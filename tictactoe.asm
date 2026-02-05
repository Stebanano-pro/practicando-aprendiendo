;este codigo bien insano estuvo vibecoudeado en su tiempo se arreglo gracias a romperse la cabeza y no se por que funciona igual muy probablemente la ia se lo robo de algun lado;
data segment       
    nueva_linea db 13, 10, "$"
    
    dibujo_juego db "_|_|_", 13, 10
                 db "_|_|_", 13, 10
                 db "_|_|_", 13, 10, "$"    
                  
    puntero_juego db 9 DUP(?)  
    
    bandera_ganador db 0 
    jugador db "0$" 
    
    mensaje_fin_juego db "FIN DEL JUEGO", 13, 10, "$"    
    mensaje_inicio_juego db "TIC TAC TOE", 13, 10, "$"
    mensaje_jugador db "JUGADOR $"   
    mensaje_ganador db " GANO!$"   
    mensaje_tipo db "SELECCIONA UNA POSICION ENTRE 1 Y 9: $"
ends


stack segment
    dw   128  dup(?)
ends         

extra segment
    
ends

code segment
inicio:
    ; establecer registros de segmento
    mov     ax, data
    mov     ds, ax
    mov     ax, extra
    mov     es, ax

    ; inicio del juego   
    call    establecer_puntero_juego    
            
bucle_principal:  
    call    limpiar_pantalla   
    
    lea     dx, mensaje_inicio_juego 
    call    imprimir
    
    lea     dx, nueva_linea
    call    imprimir                      
    
    lea     dx, mensaje_jugador
    call    imprimir
    lea     dx, jugador
    call    imprimir  
    
    lea     dx, nueva_linea
    call    imprimir    
    
    lea     dx, dibujo_juego
    call    imprimir    
    
    lea     dx, nueva_linea
    call    imprimir    
    
    lea     dx, mensaje_tipo    
    call    imprimir            
                        
    ; leer posicion de dibujo                   
    call    leer_teclado
                       
    ; calcular posicion de dibujo                   
    sub     al, 49               
    mov     bh, 0
    mov     bl, al                                  
                                  
    call    actualizar_dibujo                                  
                                                          
    call    verificar  
                       
    ; verificar si el juego termina                   
    cmp     bandera_ganador, 1  
    je      fin_juego  
    
    call    cambiar_jugador 
            
    jmp     bucle_principal   


cambiar_jugador:   
    lea     si, jugador    
    xor     ds:[si], 1 
    
    ret
      

actualizar_dibujo:
    ; Comprobar si la posicion ya esta ocupada
    mov     bl, puntero_juego[bx]  ; obtener la posicion desde el puntero del juego
    mov     bh, 0
    
    ; Comprobar si la posicion en el tablero sigue disponible
    mov     al, ds:[bx]           ; Cargar el carácter actual en la posicion
    cmp     al, "_"               ; Compararlo con el marcador de posicion
    jne     posicion_ocupada      ; Si no es "_", la posicion esta ocupada
    
    ; Si la posicion esta disponible, proceder a dibujar
    lea     si, jugador
    
    cmp     ds:[si], "0"
    je      dibujar_x     
                  
    cmp     ds:[si], "1"
    je      dibujar_o 

dibujar_x:
    mov     cl, "x"
    jmp     actualizar

dibujar_o:          
    mov     cl, "o"  
    jmp     actualizar    

posicion_ocupada:
    ; Imprimir un mensaje de error

    call    imprimir
    
    ; Limpiar AL para evitar datos inválidos
    xor     al, al  
    
    ; Solicitar entrada nuevamente
    jmp     leer_teclado  ; Volver a leer la entrada

actualizar:         
    mov     ds:[bx], cl      ; Actualizar el tablero del juego con el marcador del jugador
    ret 
       
       
verificar:
    call    verificar_linea
    ret     
       
       
verificar_linea:
    mov     cx, 0

  jmp bucle_verificar_linea
    bucle_verificar_linea:     
    cmp     cx, 0
    je      primera_linea
    
    cmp     cx, 1
    je      segunda_linea
    
    cmp     cx, 2
    je      tercera_linea  
    
    call    verificar_columna
    ret    
        
    primera_linea:    
    mov     si, 0   
    jmp     realizar_verificacion_linea   

    segunda_linea:    
    mov     si, 3
    jmp     realizar_verificacion_linea
    
    tercera_linea:    
    mov     si, 6
    jmp     realizar_verificacion_linea        

    realizar_verificacion_linea:
    inc     cx
  
    mov     bh, 0
    mov     bl, puntero_juego[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      bucle_verificar_linea
    
    inc     si
    mov     bl, puntero_juego[si]    
    cmp     al, ds:[bx]
    jne     bucle_verificar_linea 
      
    inc     si
    mov     bl, puntero_juego[si]  
    cmp     al, ds:[bx]
    jne     bucle_verificar_linea
                 
                         
    mov     bandera_ganador, 1
    ret         
       
       
verificar_columna:
    mov     cx, 0
    
    bucle_verificar_columna:     
    cmp     cx, 0
    je      primera_columna
    
    cmp     cx, 1
    je      segunda_columna
    
    cmp     cx, 2
    je      tercera_columna  
    
    call    verificar_diagonal
    ret    
        
    primera_columna:    
    mov     si, 0   
    jmp     realizar_verificacion_columna   

    segunda_columna:    
    mov     si, 1
    jmp     realizar_verificacion_columna
    
    tercera_columna:    
    mov     si, 2
    jmp     realizar_verificacion_columna        

    realizar_verificacion_columna:
    inc     cx
  
    mov     bh, 0
    mov     bl, puntero_juego[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      bucle_verificar_columna
    
    add     si, 3
    mov     bl, puntero_juego[si]    
    cmp     al, ds:[bx]
    jne     bucle_verificar_columna 
      
    add     si, 3
    mov     bl, puntero_juego[si]  
    cmp     al, ds:[bx]
    jne     bucle_verificar_columna
                 
                         
    mov     bandera_ganador, 1
    ret        


verificar_diagonal:
    mov     cx, 0
    
    bucle_verificar_diagonal:     
    cmp     cx, 0
    je      primera_diagonal
    
    cmp     cx, 1
    je      segunda_diagonal                         
    
    ret    
        
    primera_diagonal:    
    mov     si, 0                
    mov     dx, 4 ;distancia del salto
    jmp     realizar_verificacion_diagonal   

    segunda_diagonal:    
    mov     si, 2
    mov     dx, 2
    jmp     realizar_verificacion_diagonal       

    realizar_verificacion_diagonal:
    inc     cx
  
    mov     bh, 0
    mov     bl, puntero_juego[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      bucle_verificar_diagonal
     
    add     si, dx
    mov     bl, puntero_juego[si]    
    cmp     al, ds:[bx]
    jne     bucle_verificar_diagonal 
      
    add     si, dx
    mov     bl, puntero_juego[si]  
    cmp     al, ds:[bx]
    jne     bucle_verificar_diagonal
                 
                         
    mov     bandera_ganador, 1
    ret  
           

fin_juego:        
    call    limpiar_pantalla   
    
    lea     dx, mensaje_inicio_juego 
    call    imprimir
    
    lea     dx, nueva_linea
    call    imprimir                          
    
    lea     dx, dibujo_juego
    call    imprimir    
    
    lea     dx, nueva_linea
    call    imprimir

    lea     dx, mensaje_fin_juego
    call    imprimir  
    
    lea     dx, mensaje_jugador
    call    imprimir
    
    lea     dx, jugador
    call    imprimir
    
    lea     dx, mensaje_ganador
    call    imprimir 

    jmp     fin    
  
     
establecer_puntero_juego:
    lea     si, dibujo_juego
    lea     bx, puntero_juego          
              
    mov     cx, 9   
    
    bucle_1:
    cmp     cx, 6
    je      agregar_1                
    
    cmp     cx, 3
    je      agregar_1
    
    jmp     agregar_2 
    
    agregar_1:
    add     si, 1
    jmp     agregar_2     
      
    agregar_2:                                
    mov     ds:[bx], si 
    add     si, 2
                        
    inc     bx               
    loop    bucle_1 
 
    ret  
         
       
imprimir:      ; imprimir el contenido de dx  
    mov     ah, 9
    int     21h   
    
    ret 
    

limpiar_pantalla:       ; obtener y establecer modo de video
    mov     ah, 0fh
    int     10h   
    
    mov     ah, 0
    int     10h
    
    ret
       
    
leer_teclado:  ; leer teclado y devolver contenido en ah
    mov     ah, 1       
    int     21h  
    
    ; Validar entrada: verificar si esta entre '1' (0x31) y '9' (0x39)
    cmp     al, '1'
    jb      entrada_invalida
    cmp     al, '9'
    ja      entrada_invalida
    
    ret  ; Entrada valida, regresar

entrada_invalida:
    ; Imprimir un mensaje de error y solicitar entrada nuevamente

    call    imprimir

    ; Limpiar AL para evitar datos invalidos
    xor     al, al  

    jmp     leer_teclado  ; Repetir lectura de entrada    
      
      
fin:
    jmp     fin         
      
code ends

end inicio

