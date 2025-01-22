; Skeleton Code for the game "Zumba", the COAL Project of CS-Batch 2023.
; This code is intellectual property of 22i-0932, but may be used by the students of CS-Batch 2023 for their COAL Project.
; The following code has been written in the Irvine32 library, and is meant to be run in the MASM assembler.

; The program does ONLY what the official code uploaded by the lab instructors was supposed to do, except:
; 1. the bullets fire in 8 directions instead of 4, to make the game more challenging.
; 2. the emitter has no functionality yet. find ways to implement it yourself.
; 3. the balls do not change color. find ways to implement it yourself.

; use QWEADZXC keys (omnidirectional) to rotate the player. use spacebar to shoot. and use your brain to code. good luck.

include Irvine32.inc
include macros.inc
includelib Winmm.lib
PlaySound PROTO, pszSound:ptr BYTE, hmod:DWORD, fdwSound:DWORD

.data
    ; Level layout
    level1 BYTE " _____________________________________________________________________________ ", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|--------------------------------------------------------                     |", 0
           BYTE "|                                                        |                    |", 0
           BYTE "|                                                        |                    |", 0
           BYTE "|---------------------------------------------------     |                    |", 0
           BYTE "|                                                   |    |                    |", 0
           BYTE "|                                                   |    |                    |", 0
           BYTE "|                                                   |    |                    |", 0
           BYTE "|                  ----------------  ---            |    |                    |", 0
           BYTE "|                 |                 |   |           |    |                    |", 0
           BYTE "|                 |                 |   |           |    |                    |", 0
           BYTE "|                 |                 |   |           |    |                    |", 0
           BYTE "|                 |     -----------  ---            |    |                    |", 0
           BYTE "|                 |     ----------------------------     |                    |", 0
           BYTE "|                 |                                      |                    |", 0
           BYTE "|                 |                                      |                    |", 0
           BYTE "|                  --------------------------------------                     |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|_____________________________________________________________________________|", 0

           ; Level2 layout
    level2 BYTE " _____________________________________________________________________________ ", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|--------------------------------------------------------                     |", 0
           BYTE "|                                                       |                     |", 0
           BYTE "|---------------------------------------------------    |                     |", 0
           BYTE "|                                                   |   |                     |", 0
           BYTE "|                                                   |   |                     |", 0
           BYTE "|                                                   |   |                     |", 0
           BYTE "|                                                   |   |                     |", 0
           BYTE "|                  ----------------  ---            |   |                     |", 0
           BYTE "|                 |                 |   |           |   |                     |", 0
           BYTE "|                 |                 |   |           |   |                     |", 0
           BYTE "|                 |                 |   |           |   |                     |", 0
           BYTE "|                 |     -----------  ---            |   |                     |", 0
           BYTE "|                 |     ----------------------------    |                     |", 0
           BYTE "|                 |                                     |                     |", 0
           BYTE "|                  --------------------------------------                     |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|                                                                             |", 0
           BYTE "|_____________________________________________________________________________|", 0

    ; Player sprite
    player_right BYTE "   ", 0
                 BYTE " O-", 0
                 BYTE "   ", 0

    player_left BYTE "   ", 0
                BYTE "-O ", 0
                BYTE "   ", 0

    player_up BYTE " | ", 0
              BYTE " O ", 0
              BYTE "   ", 0

    player_down BYTE "   ", 0
                BYTE " O ", 0
                BYTE " | ", 0

    player_upright BYTE "  /", 0
                   BYTE " O ", 0
                   BYTE "   ", 0

    player_upleft BYTE "\  ", 0
                  BYTE " O ", 0
                  BYTE "   ", 0

    player_downright BYTE "   ", 0
                     BYTE " O ", 0
                     BYTE "  \", 0

    player_downleft BYTE "   ", 0
                    BYTE " O ", 0
                    BYTE "/  ", 0

    ; Player's starting position (center)
    xPos db 56      ; Column (X)
    yPos db 15      ; Row (Y)

    xDir db 0
    yDir db 0

    ; Default character (initial direction)
    inputChar db 0
    direction db "d"

    ; Colors for the emitter and player
    color_red db 4       ; Red
    color_green db 2     ; Green
    color_yellow db 14   ; Yellow (for fire symbol)

    current_color db 4   ; Default player color (red)

    emitter_color1 db 2  ; Green
    emitter_color2 db 4  ; Red

    fire_color db 14     ; Fire symbol color (Yellow)

    ; Emitter properties
    emitter_symbol db "#"
    emitter_row db 0    ; Two rows above player (fixed row for emitter)
    emitter_col db 1    ; Starting column of the emitter

    ; Fire symbol properties (fired from player)
    fire_symbol db "*", 0
    fire_row db 0        ; Fire will be fired from the player's position
    fire_col db 0        ; Initial fire column will be set in the update logic

    ; Interface variables
    score db 0          ; Player's score
    lives db 3          ; Player's lives
    levelInfo db 1
    
    ; Counter variables for loops
    counter1 db 0
    counter2 db 0
    
    startsound BYTE "D:\FAST\Semester 3 (Fall ‘24)\Computer Organization & Assembly Language\COAL Lab\Project\Sounds\002 - Menu.wav", 0
    namesound BYTE "D:\FAST\Semester 3 (Fall ‘24)\Computer Organization & Assembly Language\COAL Lab\Project\Sounds\002 - Menu.wav", 0
    dash1 byte "@", 0
    space byte " ", 0
    dash byte "@", 0
    
    enterName byte "Enter your name: ", 0
    
    ;File Handling
    arr byte 500 dup (0)
    stringLength DWORD ?
    error BYTE "Cannot create file", 0dh, 0ah, 0
    output BYTE "Bytes written to file [score.txt]: ", 0
    filename db "score.txt",0

    ;High Score
    highdisp byte "-------- HIGHSCORES --------", 0ah, 0
    x BYTE "score.txt", 0
    fileHandle HANDLE ?
    sizeofarr dd ?
    buffer_size = 1000
    
    ;Instructions
    displayinst byte "-------- INSTRUCTIONS --------", 0ah, 0
    moveinst byte "Use Q, W, E, A, D, Z, X, C for the movement of player", 0ah, 0
    shootinst byte "Use spacebar to shoot", 0ah, 0
    goback byte "Press Any Key to Go Back", 0ah, 0
    user byte 20 DUP (" "), 0

    ;Second Main Menu
    tostart byte "Press S to Start the Game", 0ah, 0
    toexit byte "Press Q to Exit the Game", 0ah, 0
    highscore byte "Press H to Show Highscore", 0ah, 0
    inst byte "Press I to Show Instructions", 0ah, 0

    ;Main Menu
    Pressing byte "Press Any Key to Continue", 0ah, 0
    input byte ?, 0
    zumba BYTE "           ZZZZZZZZZZZZZZZZZZZ  UU               UU  MM      MM      MM  BBBBBBBBBBBBBBBB           AAAAA       ", 0ah
          BYTE "                          ZZZZ  UU               UU  MMM    MMMM    MMM  BB              BB       AA     AA     ", 0ah
          BYTE "                       ZZZZ     UU               UU  MMMM  MMMMMM  MMMM  BB              BB      AA       AA    ", 0ah
          BYTE "                   ZZZZ         UU               UU  MM MMMM    MMMM MM  BBBBBBBBBBBBBBBB       AAAAAAAAAAAAA   ", 0ah
          BYTE "               ZZZZ             UU               UU  MM  MMM    MMM  MM  BB              BB    AAAAAAAAAAAAAAA  ", 0ah
          BYTE "           ZZZZ                 UU               UU  MM   MM    MM   MM  BB              BB   AA             AA ", 0ah
          BYTE "           ZZZZZZZZZZZZZZZZZZZ  UUUUUUUUUUUUUUUUUUU  MM    M    M    MM  BBBBBBBBBBBBBBBB    AA               AA", 0

    ; Ball move
    ball_xdir db 21,22,23,24,25,26,27,28
    ball_ydir db 9,9,9,9,9,9,9,9
    ball_ydir2 db 8,8,8,8,8,8,8,8
    ball_color db 2,2,2,1,1,1,3,3,3
    ball_exist db 1,1,1,1,1,1,1,1
    var1 dword ?
    ind db 0

    initial_ball_xdir db 21,22,23,24,25,26,27,28
    initial_ball_ydir db 9,9,9,9,9,9,9,9
    
    count_del dword 0
    delay_var dword 200
    count_color dword 0

    tun_balx db 72
    tun_bal_en db 13
    tun_bal_ex db 16

    gameOverMsg BYTE "  GGGGGGGGGG      AAAA       MMM      MMM EEEEEEEEEEEEEEE   OOOOOOOOOOO   VVV       VVV EEEEEEEEEEEEEEE RRRRRRRRRRR   ", 0ah
                BYTE " GG              AA  AA      MM M    M MM EE              OO           OO  VV       VV  EE              RR        RR ", 0ah
                BYTE "GG              AA    AA     MM  M  M  MM EE              OO           OO   VV     VV   EE              RR        RR ", 0ah
                BYTE "GG   GGGGGGG   AAAAAAAAAA    MM   MM   MM EEEEEEEEEEEEEEE OO           OO    VV   VV    EEEEEEEEEEEEEEE RRRRRRRRRRR  ", 0ah
                BYTE "GG      GG    AAAAAAAAAAAA   MM        MM EE              OO           OO     VV VV     EE              RR  RR       ", 0ah
                BYTE " GG     GG   AA          AA  MM        MM EE              OO           OO      VVV      EE              RR   RR      ", 0ah
                BYTE "  GGGGGGGG  AA            AA MM        MM EEEEEEEEEEEEEEE   OOOOOOOOOOO         V       EEEEEEEEEEEEEEE RR    RRRR   ", 0ah, 0ah,0ah,0ah,0ah,0ah,0ah,0ah,0

    pauseMsg BYTE "                 PPPPPPPPPP       AAAA       UU      UU  SSSSSSSSSS  EEEEEEEEEEEE  DDDDDDDD    ", 0ah
             BYTE "                 PP         PP   AA  AA      UU      UU SS           EE           DD       DD  ", 0ah
             BYTE "                 PP         PP  AA    AA     UU      UU SS           EE           DD        DD ", 0ah
             BYTE "                 PPPPPPPPPP    AAAAAAAAAA    UU      UU  SSSSSSSSSS  EEEEEEEEEEEE DD         DD ", 0ah
             BYTE "                 PP           AAAAAAAAAAAA   UU      UU           SS EE           DD        DD ", 0ah
             BYTE "                 PP          AA          AA  UU      UU           SS EE           DD       DD  ", 0ah
             BYTE "                 PP         AA            AA UUUUUUUUUU  SSSSSSSSSS  EEEEEEEEEEEE  DDDDDDDD    ", 0

.code
FireBall PROC
    ; Fire a projectile from the player's current face direction

    mov dl, xPos      ; Fire column starts at the player's X position
    mov dh, yPos      ; Fire row starts at the player's Y position

    mov fire_col, dl  ; Save the fire column position
    mov fire_row, dh  ; Save the fire row position

    mov al, direction
    cmp al, "w"
    je fire_up

    cmp al, "x"
    je fire_down

    cmp al, "a"
    je fire_left

    cmp al, "d"
    je fire_right

    cmp al, "q"
    je fire_upleft

    cmp al, "e"
    je fire_upright

    cmp al, "z"
    je fire_downleft

    cmp al, "c"
    je fire_downright

    jmp end_fire

fire_up:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, -1
    jmp fire_loop

fire_down:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, 1
    jmp fire_loop

fire_left:
    mov fire_col, 55         ; Move fire position leftwards
    mov fire_row, 16         ; Center fire position
    mov xDir, -1
    mov yDir, 0
    jmp fire_loop

fire_right:
    mov fire_col, 59         ; Move fire position rightwards
    mov fire_row, 16         ; Center fire position
    mov xDir, 1
    mov yDir, 0
    jmp fire_loop

fire_upleft:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 55         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, -1
    jmp fire_loop

fire_upright:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 59         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, -1
    jmp fire_loop

fire_downleft:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 55         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, 1
    jmp fire_loop

fire_downright:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 59         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, 1
    jmp fire_loop

fire_loop:
    ; Initialise fire position
    mov dl, fire_col
    mov dh, fire_row
    call GoToXY

    ; Loop to move the fireball in the current direction
    L1:

        ; Ensure fire stays within the bounds of the emitter wall
        cmp dl, 20            ; Left wall boundary
        jle end_fire

        cmp dl, 96            ; Right wall boundary
        jge end_fire

        cmp dh, 5             ; Upper wall boundary
        jle end_fire

        cmp dh, 27            ; Lower wall boundary
        jge end_fire

        ; Print the fire symbol at the current position
        movzx eax, fire_color    ; Set fire color
        call SetTextColor

        add dl, xDir
        add dh, yDir
        call Gotoxy

        mWrite "@"

        ; Continue moving fire in the current direction (recursive)
        mov eax, 50
        call Delay

        ; erase the fire before redrawing it
        call GoToXY
        mWrite " "

        jmp L1

    end_fire:
        mov dx, 0
        call GoToXY

    ret
FireBall ENDP

DrawBall Proc
    mov esi,offset ball_xdir
    mov edi,offset ball_color
    mov ecx,lengthof ball_xdir
    mov ebx,offset ball_ydir
    mov var1,offset ball_exist
ball1:
        mov eax,0
        mov dh,[ebx]
        ;mov dh,al
        mov dl,[esi]
        call Gotoxy
        mov eax,0
        mov eax,var1
        mov dl,[eax]
        cmp dl,1
        jne not_exists

        mov dl,tun_balx
        cmp [esi],dl
        jne skp3
        mov dl,tun_bal_en
        cmp [ebx],dl
        jnge skp3
        mov dl,tun_bal_ex
        cmp [ebx],dl
        jle in_tunnel

skp3:
        mov eax,[edi]
        call SetTextColor
        mWrite "*"
        jmp not_exists

in_tunnel:
        mWrite " "
not_exists:
        inc esi
        inc edi
        inc ebx
        inc var1
        loop ball1
    ret
DrawBall ENDP

MoveBall Proc
    call DrawBall
    mov eax, delay_var
    call delay
    mov esi, offset ball_xdir
    mov edi, offset ball_ydir
    mov bl, 1
    mov ecx, lengthof ball_xdir

add_x:
    mov dl, [esi]
    mov dh, [edi]
    call gotoxy
    mWrite " "

    ; Ball reached the player
    mov al, 19
    cmp [edi], al
    jne skp4
    mov al, 50
    cmp [esi], al
    jne skp4

    ; Ball reached the player; decrease life and restart
    call clrscr
    dec lives
    cmp lives, 0
    je exit_game ; Game over if no lives left

    call initialiseGameScreen ; Restart game screen
    call MovePlayer           ; Restart player movement
    ret

exit_game:
    mov dl, 0
    mov dh, 0
    call gotoxy
    mov edx, OFFSET gameOverMsg
    call writestring
    exit

skp4:
    ; Ball boundary collision logic
    cmp dl, 41
    jne l2
    cmp dh, 20
    je neg_add_y

l2:
    cmp dh, 20
    je neg_x_x
    cmp dl, 72
    je add_y

x_x:
    add [esi], bl
    jmp ex
neg_x_x:
    sub [esi], bl
    jmp ex
neg_add_y:
    sub [edi], bl
    jmp ex
add_y:
    add [edi], bl
ex:
    inc esi
    inc edi
    loop add_x
    ret
MoveBall ENDP

DrawWall PROC
	call clrscr

    mov dl,19
	mov dh,2
	call Gotoxy
	mWrite <"Score: ">
	mov eax, Blue + (black * 16)
	call SetTextColor
	mov al, score
	call WriteDec

    mov eax, White + (black * 16)
	call SetTextColor

	mov dl,90
	mov dh,2
	call Gotoxy
	mWrite <"Lives: ">
	mov eax, Red + (black * 16)
	call SetTextColor
	mov al, lives
	call WriteDec

	mov eax, white + (black * 16)
	call SetTextColor

	mov dl,55
	mov dh,2
	call Gotoxy

	mWrite "LEVEL " 
	mov al, levelInfo
	call WriteDec

	mov eax, gray + (black*16)
	call SetTextColor

	mov dl, 19
	mov dh, 4
	call Gotoxy

	mov esi, offset level ;;;;;;;;;;;;;;shere

	mov counter1, 50
	mov counter2, 80
	movzx ecx, counter1
	printcolumn:
		mov counter1, cl
		movzx ecx, counter2
		printrow:
			mov eax, [esi]
			call WriteChar
            
			inc esi
		loop printrow
		
        dec counter1
		movzx ecx, counter1

		mov dl, 19
		inc dh
		call Gotoxy
	loop printcolumn

	ret
DrawWall ENDP

DrawBall2 Proc
    mov esi,offset ball_xdir
    mov edi,offset ball_color
    mov ecx,lengthof ball_xdir
    mov ebx,offset ball_ydir2
    mov var1,offset ball_exist
ball1:
        mov eax,0
        mov dh,[ebx]
        ;mov dh,al
        mov dl,[esi]
        call Gotoxy
        mov eax,0
        mov eax,var1
        mov dl,[eax]
        cmp dl,1
        jne not_exists
        mov dl,tun_balx
        cmp [esi],dl
        jne skp3
        mov dl,tun_bal_en
        cmp [ebx],dl
        jnge skp3
        mov dl,tun_bal_ex
        cmp [ebx],dl
        jle in_tunnel

skp3:
        mov eax,[edi]
        call SetTextColor
        mWrite "*"
        jmp not_exists

in_tunnel:
        mWrite " "
not_exists:
        inc esi
        inc edi
        inc ebx
        inc var1
        loop ball1
    ret
DrawBall2 ENDP

MoveBall2 Proc
  
    call DrawBall2

    mov eax,delay_var
    call delay
    mov esi,offset ball_xdir
    mov edi,offset ball_ydir2
    mov bl,2
    mov ecx,lengthof ball_xdir

add_x:
        mov dl,[esi]
        mov dh,[edi]
        call gotoxy
        mWrite " "
        mov al,19
        cmp [edi],al
        jne skp4
        mov al,50
        cmp [esi],al
        jne skp4

        call clrscr

        mov dl,0
        mov dh,0
        call gotoxy
        mov eax, Red + (black * 16)
	    call SetTextColor
        mov edx,offset gameOverMsg
        call writestring

        exit
skp4:
        cmp dl,41
        jne l2
        cmp dh, 20
        je neg_add_y

        l2:
        cmp dh,20
        je neg_x_x
        cmp dl,72
        je add_y
         
x_x:
      add [esi],bl
      jmp ex
neg_x_x:
        sub [esi],bl
        jmp ex
neg_add_y:
        sub [edi],bl
        jmp ex
add_y:
        add [edi],bl
        jmp ex

ex:
        inc esi
        inc edi
        loop add_x
    
        ret
MoveBall2 ENDP

PrintPlayer PROC
    mov eax, brown + (black * 16)
    call SetTextColor

    mov al, direction
    cmp al, "w"
    je print_up

    cmp al, "x"
    je print_down

    cmp al, "a"
    je print_left

    cmp al, "d"
    je print_right

    cmp al, "q"
    je print_upleft

    cmp al, "e"
    je print_upright

    cmp al, "z"
    je print_downleft

    cmp al, "c"
    je print_downright

    ret

    print_up:
        mov esi, offset player_up
        jmp print

    print_down:
        mov esi, offset player_down
        jmp print

    print_left:
        mov esi, offset player_left
        jmp print

    print_right:
        mov esi, offset player_right
        jmp print

    print_upleft:
        mov esi, offset player_upleft
        jmp print

    print_upright:
        mov esi, offset player_upright
        jmp print

    print_downleft:
        mov esi, offset player_downleft
        jmp print

    print_downright:
        mov esi, offset player_downright
        jmp print

    print:
    mov dl, xPos
    mov dh, yPos
    call GoToXY

    mov counter1, 3
	mov counter2, 4
	movzx ecx, counter1
	printcolumn:
		mov counter1, cl
		movzx ecx, counter2
		printrow:
			mov eax, [esi]
			call WriteChar
            
			inc esi
		loop printrow

		movzx ecx, counter1

		mov dl, xPos
		inc dh
		call Gotoxy
	loop printcolumn
    
ret
PrintPlayer ENDP

InitialiseGameScreen PROC
    call DrawWall
    call PrintPlayer
    ret
InitialiseGameScreen ENDP

zumbaDisplay PROC
    INVOKE PlaySound, OFFSET startsound, NULL, 20001h

    mov eax, Cyan
    call settextcolor

    mov dl, 0
    mov dh, 0
    call gotoxy
    mov edx, OFFSET zumba
    call writestring
    
    ret
zumbaDisplay ENDP

mainMenu PROC
    INVOKE PlaySound, OFFSET startsound, NULL, 20001h

    call zumbaDisplay

    mov dh, 20
    mov dl, 47
    call gotoxy

    mov edx, OFFSET Pressing
    call writestring
    
    mov edi, OFFSET input
    call readchar
    
    call clrscr
    
    ret
mainMenu ENDP

secondmainMenu PROC
    call zumbaDisplay

    INVOKE PlaySound, OFFSET startsound, NULL, 20001h
    mov eax, lightred
    call settextcolor
    
    mov dl, 47
    mov dh, 15
    call gotoxy
    mov edx, OFFSET tostart
    call writestring
    
    mov dl, 47
    mov dh, 17
    call gotoxy
    mov edx, OFFSET highscore
    call writestring

    mov dl, 47
    mov dh, 19
    call gotoxy
    mov edx, OFFSET inst
    call writestring

    mov dl, 47
    mov dh, 21
    call gotoxy
    mov edx, offset toexit
    call writestring

    call ReadChar
    mov input, al

    cmp input, 's'
    je here
    cmp input, 'h'
    je there
    cmp input, 'i'
    je where
    
    exit
    
    here:
        INVOKE PlaySound, OFFSET namesound, NULL, 20001h
        call userenterMenu
        ret
    there:
        INVOKE PlaySound, OFFSET namesound, NULL, 20001h
        call highscoreMenu
        ret
    where:
        INVOKE PlaySound, OFFSET namesound, NULL, 20001h
        call instructionsMenu

    ret
secondmainMenu ENDP

userenterMenu PROC
    call clrscr
    call zumbaDisplay

    mov eax, gray
    call settextcolor
    mov dl, 45
    mov dh, 15
    call gotoxy
    
    mov edx, OFFSET enterName
    call writestring
   
    mov edx, OFFSET user
    mov ecx, LENGTHOF user
    call readstring

    mov user[eax], "."
    mov user[eax + 1], "."
    mov ecx, LENGTHOF user
    mov user[ecx - 1], 0

    ret
userenterMenu ENDP

instructionsMenu PROC
    call clrscr
    call zumbaDisplay

    mov eax, lightcyan
    call settextcolor
    
    mov dl, 45
    mov dh, 10
    call gotoxy
    mov edx, OFFSET displayinst
    call writestring

    mov dl, 35
    mov dh, 12
    call gotoxy
    mov edx, OFFSET moveinst
    call writestring 
    
    mov dl, 35
    mov dh, 14
    call gotoxy
    mov edx, offset shootinst
    call writestring
   
    mov dl, 45
    mov dh, 24
    call gotoxy
    mov edx, offset goback
    call writestring
    
    call readChar
    call clrscr
    
    call secondmainMenu

    ret
instructionsMenu ENDP

highscoreMenu PROC

    call clrscr
    call zumbaDisplay

    mov eax, lightgreen
    call settextcolor

    mov dl, 47
    mov dh, 10
    call gotoxy
    mov edx, OFFSET highdisp
    call writestring
    
    mov dl, 53
    mov dh, 12
    call gotoxy

    ;call fileHandling

    mov edx, OFFSET filename
    call OpenInputFile
    mov fileHandle, eax

    cmp eax, INVALID_HANDLE_VALUE; error opening file ?
    jne file_ok

    mWrite <"Cannot open file", 0dh, 0ah>
    jmp quit
    
    file_ok:
        mov edx, OFFSET sizeofarr
        mov ecx, BUFFER_SIZE
        call ReadFromFile
    
    jnc check_buffer_size
    mWrite "Error reading file. "
    
    call WriteWindowsMsg
    jmp close_file

    check_buffer_size :
        cmp eax, BUFFER_SIZE
        jb buf_size_ok

        mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
        jmp quit
    
    buf_size_ok:
    mov sizeofarr[eax], 0
   
    call WriteDec
    call Crlf

    mov dl, 45
    mov dh, 17
    call GOTOXY
    mov edx, OFFSET sizeofarr
    call WriteString
    call Crlf

    close_file:
        mov eax, fileHandle
        call CloseFile

    quit:
        mov dl, 49
        mov dh, 20
        call gotoxy
        mov edx, OFFSET goback
        call writestring
        call readChar

    call clrscr
    call secondmainMenu
    ret
highscoreMenu ENDP

fileHandling PROC

    mov edx, OFFSET filename
    call OpenInputFile
    mov fileHandle, eax

    cmp eax, INVALID_HANDLE_VALUE; error opening file ?
    jne file_ok1

    mWrite <"Cannot open file", 0dh, 0ah>
    jmp quit1
    
    file_ok1:
        mov edx, OFFSET arr
        mov ecx, BUFFER_SIZE
        call ReadFromFile
        jnc check_buffer_size

        mWrite "Error reading file. "
        call WriteWindowsMsg
        jmp close_file1

    check_buffer_size:
        mov sizeofarr, eax
        cmp eax, BUFFER_SIZE
        jb buf_size_ok1

        mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
        jmp quit1
    
    buf_size_ok1:
        mov arr[eax], 0
        call WriteDec
        call Crlf
        mov dl, 45
        mov dh, 17
        call gotoxy
        mov edx, OFFSET arr
        ; call WriteString
        call Crlf
    
    close_file1:
        mov eax, fileHandle
        call CloseFile

    quit1:
        mov edx, OFFSET filename
        call CreateOutputFile
        mov fileHandle, eax

    cmp eax, INVALID_HANDLE_VALUE; error found ?
    jne file_ok
        
    mov edx, OFFSET error
    call WriteString
    jmp quit

    file_ok:
        mov eax, fileHandle
        mov edx, OFFSET arr
        mov ecx, sizeofarr
        call WriteToFile

    mov ecx, eax
    mov sizeofarr, ecx
    mov stringLength, ecx
    mov edi, OFFSET arr

    mov eax, 0
    mov al, score
    add eax, 0
    aas
    or eax, 303030h
    mov[edi], ah
    inc edi
    mov[edi], al
    inc edi
    mov esi, OFFSET space
    mov dl, [esi]
    mov[edi], dl
    inc edi

    mov eax, 0
    mov al, levelInfo
    add eax, 0
    aas
    or eax, 303030h

    mov[edi], al
    inc edi
    mov esi, offset space
    mov dl, [esi]
    mov[edi], dl
    inc edi

    mov esi,offset user
    mov ecx,lengthof user
    l1:
    mov dl,[esi]
    mov[edi], dl
    inc edi
    inc esi
    loop l1
    mov al,0ah
    mov [edi],al
    inc edi

    mov eax, fileHandle
    add sizeofarr, 27

    mov edx, OFFSET arr
    ;mov stringLength, sizeofarr
    mov ecx, sizeofarr

    call WriteToFile

    mov edx, offset filename
    mov eax, filehandle
    call CloseFile

    mov edx, OFFSET output

    call WriteString

    call WriteDec

    call Crlf

    quit:
    ret

fileHandling ENDP

MovePlayer PROC
    mov dx, 0
    call GoToXY

    checkInput:

    mov eax, 5
    call Delay

    ; Check for key press
    mov eax, 0
    call ReadKey
    mov inputChar, al

    call MoveBall2 ;;;;;;;;;;;;shere

    cmp inputChar, VK_SPACE
    je shoot

    cmp inputChar, "p"
    je paused

    cmp inputChar, "w"
    je move

    cmp inputChar, "a"
    je move

    cmp inputChar, "x"
    je move

    cmp inputChar, "d"
    je move

    cmp inputChar, "q"
    je move

    cmp inputChar, "e"
    je move

    cmp inputChar, "z"
    je move

    cmp inputChar, "c"
    je move

    ; if character is invalid, check for a new keypress
    jmp checkInput

    move:
        mov al, inputChar
        mov direction, al
        jmp chosen

paused:
    mov eax, Cyan
    call settextcolor

    call clrscr

    mov dl, 0
    mov dh, 0
    call gotoxy
    mov edx, OFFSET pauseMsg
    call writestring

waitForResume:
    mov eax, 0
    call ReadKey
    cmp al, "p"
    jne waitForResume
    call initialiseGameScreen
    jmp checkInput   

        
    shoot:
        call FireBall

    chosen:
        call PrintPlayer
        call MovePlayer

    ret
MovePlayer ENDP

main PROC
    call mainMenu
    call secondmainMenu
    call clrscr
    call InitialiseGameScreen

    ; Call Player Cannon movement function(this function is recursive, and will repeat until the game is either won or lost)
    call MovePlayer

    INVOKE ExitProcess, 0
main ENDP
END main