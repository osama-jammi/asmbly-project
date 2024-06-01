name "GAME XO"
org 100h
 
 .DATA
 
    grid db '1','2','3'  ; definir le tableau 2D grid
         db '4','5','6'
         db '7','8','9'
         
    player db ?  
    
    
    welcomeMsg db 'Bienvenue au XO GAME ! $' ; le terminateur est le signe dollar   
    inputMsg db 'Entrez le numero de la position, le tour du joueur est: $'
    draw db 'Match nul ! $'
    won db 'Joueur a gagne : $'  
    
 .CODE
    main:
         
        mov cx,9              ; boucler 9 fois car le nombre maximum de coups dans un jeu de morpion est 9 (cx de 9 a 1)
        x:   
            call clearScreen  ; efface la console de la boucle precedente pour un meilleur aspect
            call printWelcomeMsg
            call printGrid
             
            
            mov bx, cx
            and bx, 1       ; et de bx avec 1, si le resultat est 0 c'est pair si c'est 1 c'est impair
            cmp bx, 0
            je isEven       ; jmp si cx est pair (egal a 0) 
            mov player,'x'  ; si impair c'est le tour du joueur x
            jmp endif
            isEven:
            mov player,'o'  ; si pair c'est le tour du joueur o
            endif:
            
            notValid:
            call printNewLine
            call printInputMsg
            call readInput ; al contient la position sur la grille (1 => 9)
            
            push cx
            mov cx, 9
            mov bx, 0           ; boucler sur la grille pour trouver la position (bx est utilise comme index pour acceder a la grille, on ne peut pas utiliser cx pour cela)
            y:
            cmp grid[bx],al     ; verifie si la position de la grille est egale a la position prise par l'utilisateur
            je update           ; si vrai, mettre a jour la position avec le joueur (x ou o), si faux ne rien faire, continuer la boucle
            jmp continue
            update:
            mov dl,player       ; deplacer le joueur vers dl car on ne peut pas deplacer la memoire vers la memoire
            mov grid[bx],dl  
            continue:
            inc bx
            loop y
            pop cx
            call checkwin        
        loop x           
        
    
        call printDraw   ; si nous sortons de la boucle et que personne n'a gagne, c'est un match nul
        
        programEnd:   
        
        mov     ah, 0    ; attendre une touche pour interrompre
        int     16h      
    ret              ; %%%%%%%%%%%%%%%%% retour final dans main qui FERME LE PROGRAMME et retourne au systeme d'exploitation %%%%%%%%%%%%%%%%%% 
    
           
        
        
        ; Procedures/Fonctions:
        
        printGrid:
            push cx      ; pousser et depiler cx avant et aprrs la fonction car cx est utilise dans une boucle ou la fonction est appelee
            mov bx,0
            mov cx,3
            x1:
                call printNewLine 
                push cx          ; pousser cx dans la pile pour maintenir l'index de la premiere boucle
                mov cx, 3
                x2:
                    mov dl, grid[bx]  
                    sub al, 30h  ; pour convertir ascii en char 
                    mov ah, 2h   ; l'interruption d'impression de caractere est 2
                    int 21h
                    call printSpace              
                    inc bx       ; incrementer bx pour deplacer l'index a l'element suivant (de 0 a 8)
                loop x2
                pop cx           ; depiler cx de la pile pour obtenir l'index de la premiere boucle             
            loop x1
            pop cx
            call printNewLine                        
        ret 
        
        printNewLine:
            mov dl, 0ah      ; nouvelle ligne en ascii 
            mov ah, 2        
            int 21h
            mov dl, 13       ; retour chariot en ascii 
            mov ah, 2        
            int 21h
        ret 
        
        printSpace:
            mov dl, 32       ; espace en ascii 
            mov ah, 2         
            int 21h
        ret
        
        readInput:
           mov ah, 1 ; 1 pour l'entree, la valeur est dans al
           int 21h
           
           cmp al,'1'
           je valid
           cmp al,'2'
           je valid
           cmp al,'3'
           je valid
           cmp al,'4'
           je valid
           cmp al,'5'
           je valid
           cmp al,'6'
           je valid
           cmp al,'7'
           je valid
           cmp al,'8'
           je valid
           cmp al,'9'
           je valid
           jmp notValid
           valid:        
        ret
        
       printWelcomeMsg:
            lea dx, welcomeMsg  ; charger l'offset du message de bienvenue dans dl.
            mov ah, 9           ; l'interruption d'impression de chane est 9  
            int 21h
        ret
        
       printDraw:
            call printNewLine
            lea dx, draw  
            mov ah, 9             
            int 21h
        ret
        
       printWon:   
            call printNewLine
            call printGrid ; imprimer la grille une derniere fois pour montrer comment le joueur a gagne
            lea dx, won  
            mov ah, 9             
            int 21h
            mov dl, player 
            sub al, 30h   
            mov ah, 2h  
            int 21h
            jmp programEnd
        ret   
        
        printInputMsg:
            lea dx, inputMsg    ; charger l'offset du message de bienvenue dans dl.
            mov ah, 9           ; l'interruption d'impression de chaine est 9  
            int 21h
            mov dl, player      ; imprimer le joueur actuel 
            sub al, 30h   
            mov ah, 2h  
            int 21h 
            call printSpace
        ret
        
        checkWin:
            mov bl, grid[0]
            cmp bl, grid[1]              
            jne skip1      ; sauter si ce n'est pas vrai et verifier les autres victoires possibles, repeter cela pour toutes les 8 victoires possibles
            cmp bl, grid[2]  
            jne skip1 
            call printWon
            skip1:
            
            mov bl, grid[3]
            cmp bl, grid[4]              
            jne skip2  
            cmp bl, grid[5]  
            jne skip2
            call printWon
            skip2: 
            
            mov bl, grid[6]
            cmp bl, grid[7]              
            jne skip3  
            cmp bl, grid[8]  
            jne skip3
            call printWon
            skip3: 
            
            mov bl, grid[0]
            cmp bl, grid[3]              
            jne skip4  
            cmp bl, grid[6]  
            jne skip4
            call printWon
            skip4:   
            
            mov bl, grid[1]
            cmp bl, grid[4]              
            jne skip5  
            cmp bl, grid[7]  
            jne skip5
            call printWon
            skip5:
            
            mov bl, grid[2]
            cmp bl, grid[5]              
            jne skip6  
            cmp bl, grid[8]  
            jne skip6
            call printWon
            skip6:
            
            mov bl, grid[0]
            cmp bl, grid[4]              
            jne skip7  
            cmp bl, grid[8]  
            jne skip7
            call printWon
            skip7:
            
            mov bl, grid[2]
            cmp bl, grid[4]              
            jne skip8  
            cmp bl, grid[6]  
            jne skip8
            call printWon
            skip8:             
        ret
        
        clearScreen:
            mov ax, 3   ; efface l'ecran en ascii
            int 10h
        ret 
        end main