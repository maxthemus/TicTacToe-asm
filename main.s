; section for user input buffers and game tile values
section .bss
    currentTurn resb 1
    inputBuf resb 255 
    inputLen resb 1
    printBuf resb 1
    gameWinner resb 1
    boardValues resb 9

    

; section from preset const values
section .data
    spacer db '+-------------------+',10
    spacerLen equ $ - spacer

    mainBannerText db "|    TIC TAC TOE    |", 10
    mainBannerTextLen equ $ - mainBannerText

    mainMenuText db "[0] Start Game",10,"[1] Exit",10, "> "
    mainMenuTextLen equ $ - mainMenuText

    gameOverText db 'GAME OVER'
    gameOverTextLen equ $ - gameOverText

    winnerText db "Winner = "
    winnerTextLen equ $ - winnerText

    boardHorizontal db "---|---|---",10
    boardHorizontalLen equ $ - boardHorizontal

    boardVertical db " | "
    boardVerticalLen equ $ - boardVertical

    currentTurnText db "Current turn = "
    currentTurnTextLen equ $ - currentTurnText

    turnInputText db "Tile num [0 - 8] = "
    turnInputTextLen equ $ - turnInputText

    invalidInputText db "InvalidInput, Please Try again",10
    invalidInputTextLen equ $ - invalidInputText


section .text
    global _start
_start:
    main:
    call mainMenu

    ; Checking input buffer for the 
    mov dl, [inputBuf] 
    cmp dl, 49
    je exit

    call game
    jmp main
    

    exit:
    ; exiting program
    mov rax, 60 
    xor rdi, rdi
    syscall

game:
    mov r12, 0 ;Current turn num
    ;Setting up game
    call resetTurn
    call resetBoard

    gameLoop:
    debug:
    call printBoard
    call getTurnInput

    call placeInput
    call checkGameWin
    cmp rax, 1
    je gameOver

    call switchTurn

    inc r12
    cmp r12, 9
    jl gameLoop
    ret
    
    gameOver: 
    ; printing the game over board
    call printBoard

    call printGameOver
    ret

;Functions

; prints character from given ascii value
printChar:
    mov [printBuf], dil ;moving character into printBuffer

    mov rax, 1
    mov rdi, 1
    mov rsi, printBuf
    mov rdx, 1
    syscall
    ret

;prints buffer in rdi register with length in rsi
printBuffer:
    mov rdx, rsi
    mov rsi, rdi

    mov rax, 1
    mov rdi, 1
    syscall
    ret


;Prints the board given a buffer of 
printBoard:
    ; Creating pointer to index of boardValues
    mov r9, 0
    mov r8, boardValues 

    printLoop:
    mov rdi, ' '
    call printChar

    movzx rdi, byte [r8]
    call printChar
    inc r8

    mov rdi, boardVertical
    mov rsi, boardVerticalLen
    call printBuffer

    movzx rdi, byte [r8]
    call printChar
    inc r8

    mov rdi, boardVertical
    mov rsi, boardVerticalLen
    call printBuffer

    movzx rdi, byte [r8]
    call printChar
    inc r8

    mov rdi, ' '
    call printChar

    mov rdi, 10
    call printChar

    cmp r9, 2
    jge printEnd
    
    printSpacer:
    mov rdi, boardHorizontal
    mov rsi, boardHorizontalLen
    call printBuffer

    inc r9
    cmp r9, 2
    jle printLoop

    printEnd:
    ret

resetBoard:
    mov r9, 0
    mov r8, boardValues
    
    resetLoop:
    mov byte [r8], ' ' 

    inc r8
    inc r9
    cmp r9, 8
    jle resetLoop
    ret


getTurnInput:
    ; Printing spacer
    inputTurnLoop:
    mov rdi, spacer
    mov rsi, spacerLen 
    call printBuffer

    ; Printing current turn
    mov rdi, currentTurnText
    mov rsi, currentTurnTextLen
    call printBuffer

    ; Printing current turn character
    mov rdi, [currentTurn]
    call printChar

    ;Printing new line
    mov rdi, 10
    call printChar

    mov rdi, turnInputText
    mov rsi, turnInputTextLen
    call printBuffer

    mov rax, 0
    mov rdi, 0
    mov rsi, inputBuf
    mov rdx, 255 
    syscall

    ;validating the input
    ;Checking second byte of the input buffer it must be new line for it to be valid input 
    mov cl, [inputBuf + 1] 
    cmp cl, 10
    jne inputTurnLoop 

    ;Checking the first byte to see if value is between 0-8
    mov cl, [inputBuf]
    cmp cl, 48 
    jl inputFailed
    cmp cl, 56 
    jg inputFailed
    
    mov byte [inputLen], al
    ret

    inputFailed:
    mov rdi, spacer
    mov rsi, spacerLen
    call printBuffer

    mov rdi, invalidInputText
    mov rsi, invalidInputTextLen
    call printBuffer

    ; jumping back to inputLoop
    jmp inputTurnLoop


resetTurn:
    mov byte [currentTurn], 79
    ret

switchTurn:
    ; Reading in current turn value
    mov al, byte [currentTurn]
    ; Comparing against X
    cmp rax, 88
    je makeO

    makeX:
    mov byte [currentTurn], 88
    ret
    
    makeO:
    mov byte [currentTurn], 79
    ret

placeInput:
    ;Given the currentTurn and the last input we can place the players turn on the board array  
    movzx rax, byte [inputBuf] ;Index of input
    sub rax, 48
    mov dil, byte [currentTurn]

    ;add rax, boardValues
    mov byte [boardValues + rax], dil
    ret

checkGameWin:
    ; All checks will be hard coded.
    ;Horizontal checks
    horizontalOne:
    movzx r8, byte [boardValues]
    movzx r9, byte [boardValues + 1]
    movzx r10, byte [boardValues + 2]
    cmp r8, r9
    jne horizontalTwo
    cmp r9, r10
    jne horizontalTwo
    cmp r8, ' '
    je horizontalTwo

    mov rax, 1
    mov byte [gameWinner], r8b
    ret

    horizontalTwo:
    movzx r8, byte [boardValues + 3]
    movzx r9, byte [boardValues + 4]
    movzx r10,byte [boardValues + 5]
    cmp r8, r9
    jne horizontalThree
    cmp r9, r10
    jne horizontalThree
    cmp r8, ' '
    je horizontalThree

    mov rax, 1
    mov byte [gameWinner], r8b
    ret

    horizontalThree:
    movzx r8, byte [boardValues + 6]
    movzx r9, byte [boardValues + 7]
    movzx r10, byte [boardValues + 8]
    cmp r8, r9
    jne verticalOne
    cmp r9, r10
    jne verticalOne
    cmp r8, ' '
    je verticalOne

    mov rax, 1
    mov byte [gameWinner], r8b
    ret

    verticalOne:
    movzx r8, byte [boardValues]
    movzx r9, byte [boardValues + 3]
    movzx r10, byte [boardValues + 6]
    cmp r8, r9
    jne verticalTwo
    cmp r9, r10
    jne verticalTwo
    cmp r8, ' '
    je verticalTwo

    mov rax, 1
    mov byte [gameWinner], r8b
    ret

    verticalTwo:
    movzx r8, byte [boardValues + 1]
    movzx r9, byte [boardValues + 4]
    movzx r10, byte [boardValues + 7]
    cmp r8, r9
    jne verticalThree
    cmp r9, r10
    jne verticalThree
    cmp r8, ' '
    je verticalThree

    mov rax, 1
    mov byte [gameWinner], r8b
    ret

    verticalThree:
    movzx r8, byte [boardValues + 2]
    movzx r9, byte [boardValues + 5]
    movzx r10, byte [boardValues + 7]
    cmp r8, r9
    jne diagonalOne
    cmp r9, r10
    jne diagonalOne
    cmp r8, ' '
    je diagonalOne
    

    mov rax, 1
    mov byte [gameWinner], r8b
    ret

    diagonalOne:
    movzx r8, byte [boardValues]
    movzx r9, byte [boardValues + 4]
    movzx r10, byte [boardValues + 8]
    cmp r8, r9
    jne diagonalTwo
    cmp r9, r10
    jne diagonalTwo
    cmp r8, ' ' 
    je diagonalTwo

    mov rax, 1
    mov byte [gameWinner], r8b
    ret


    diagonalTwo:
    movzx r8, byte [boardValues + 2]
    movzx r9, byte [boardValues + 4]
    movzx r10, byte [boardValues + 6]
    cmp r8, r9
    jne allFailed
    cmp r9, r10
    jne allFailed
    cmp r8, ' '
    je allFailed

    mov rax, 1
    mov byte [gameWinner], r8b
    ret


    allFailed:
    mov rax, 0; setting return value
    mov byte [gameWinner], ' '
    ret

printGameOver:
    mov rdi, spacer 
    mov rsi, spacerLen
    call printBuffer

    mov rdi, gameOverText
    mov rsi, gameOverTextLen
    call printBuffer

    mov rdi, 10
    call printChar
    
    mov rdi, winnerText
    mov rsi, winnerTextLen
    call printBuffer

    movzx rdi, byte [gameWinner]
    call printChar

    mov rdi, 10
    call printChar

    mov rdi, spacer 
    mov rsi, spacerLen
    call printBuffer
    ret

mainMenu: 
    mov rdi, spacer
    mov rsi, spacerLen
    call printBuffer

    mov rdi, mainBannerText
    mov rsi, mainBannerTextLen
    call printBuffer

    mainMenuLoop:
    mov rdi, spacer
    mov rsi, spacerLen
    call printBuffer

    ;Printing main menu text
    mov rdi, mainMenuText
    mov rsi, mainMenuTextLen
    call printBuffer

    ;Getting input
    mov rax, 0
    mov rdi, 0
    mov rsi, inputBuf
    mov rdx, 255 
    syscall

    ;Validating the input
    ;Checking second byte of the input buffer it must be new line for it to be valid input 
    mov cl, [inputBuf + 1] 
    cmp cl, 10
    jne mainMenuLoop 

    ;Checking the first byte to see if value is between 0-8
    mov cl, [inputBuf]
    cmp cl, 48 
    jl menuInputFailed
    cmp cl, 49 
    jg menuInputFailed
    
    mov byte [inputLen], al
    ret

    menuInputFailed:
    mov rdi, spacer
    mov rsi, spacerLen
    call printBuffer

    mov rdi, invalidInputText
    mov rsi, invalidInputTextLen
    call printBuffer

    ; jumping back to inputLoop
    jmp mainMenuLoop







