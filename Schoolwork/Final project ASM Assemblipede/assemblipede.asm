; define some symbols (constants)
   maxLvlBufferSize equ 4000 ;; maximum size of level
   maxSegmentIndex equ maxLvlBufferSize - 1 ;; refers to the body of the worm
   ;;added pausing, growing when eating, ending game when worm collides with wall or boundary of game, starting the game without shrinking, score, and portals
section .data
    usageMsg db " Usage: Assemblipede levelFileName",0x0A,0x00
    openFileFailMsg db "Failed to open level file.",0x0A,0x00
    badFileFormatMsg db "Invalide File Format.",0x0A,0x00
    portalErrorMsg db "Error, can only have 0 or 2 portals",0x0A,0x00
    readModeStr db "r",0x00
    startOfGame equ 1
    
    ;scanf formats
    oneIntFmt db "%d",0x00    ; format string for scanf reading one integer
    twoIntFmt db "%d %d",0x00 ; format string for scanf reading two integers
    
    ;printf formats
    dbgIntFmt db " Debug: %d %d",0x0A,0x00
    messageTest db "WASD to move, Space to pause/unpause, Q to quit "
    messageTestLen equ $ - messageTest
    int_format db "Score %d",0x0A,0x00
    
    
section .bss
    lvlFilePtr resb 4   ;; storing a file pointer to the level file when its opened

    lvlWidth resb 4     ;; storing the width and heigh
    lvlHeight resb 4
    
    lvlBuffer resb maxLvlBufferSize ; this stores that actual game level as a grid of asci text characters
                                    ; this is the "picture" of the game which is redrawn each game tick
    lvlBufSize equ $ - lvlBuffer

    xStep resb 4     ; -1, 0, or 1, how far to step horizontally per tick 
    yStep resb 4     ; -1, 0, or 1, how far to step vertically per tick 
    yDelta resb 4    ; amount to change address of head to move exacly one line up or down (should be lvlWidth+1)
    
    segmentX resb 4    ; place to temporarily store X coordinate of a body segment (or head)
    segmentY resb 4    ; place to temporarily store X coordinate of a body segment (or head)
    
    headAddressInLvlBuffer resb 4 ; address of millipede (player) head in the lvlBuffer = lvlBuffer + Y*yDelta + X
                       ; note: we never need to keep track of X & Y position separately
                       ; if we want to go "up" or "down" one step, we subtract or add yDelta (which is lvlWidth+1)
                       
    bodySegmentAddresses times maxLvlBufferSize resb 4  ;array of pointers to location of body segments in the lvlBuffer
    headIndex  resb 4  ; index of the head Address in bodyAddresses
    tailIndex  resb 4  ; index of the tail Address (last body segmeent) in bodyAddresses
                       ; note that that headIndex and tailIndex "chase" each other around within the bodyAddresses array
                       ; and can wrap around so the head can be chasing the tail (when head is chasing tail, the entries in between are garbage data)
    bodyLength resb 4  ; length of the millipede body -- should equal 1 + ( headIndex-tailIndex(modulo maxLvlBufferSize) )
                       ; "modulo" or "clock arithmetic" because head/tail indexes can "wrap around"
    

    

    my_int resb 4    
    portalCounter resb 4
    
    
    dbgBuffer resb 1000 ;; debug buffer
    portal1Address resb 4
    portal2Address resb 4
    
    startOfGame2 resb 1
    flag resb 0
    
;; std C lib functions
extern printf
extern fscanf
extern fgets
extern fopen
extern fclose
extern getchar
extern gets

;; ncurse lib functions
extern initscr
extern cbreak
extern clear
extern endwin
extern printw ;; for printing to game screen
extern getch
extern curs_set
extern noecho
extern timeout
extern notimeout

global _start

section .text

_start:

   ;follow cdecl -- we will be using command line arguments
   mov esi, 1
   mov [startOfGame2], esi
   mov esi, 0
   mov [flag], esi
   mov esi, 0
   mov [my_int], esi
   mov esi, 0
   mov [portalCounter], esi
   push EBP
   mov  EBP, ESP

   ; [EBP+4] is the arg count
   ; [EBP+8,12,16,...] are pointers to strings
   ; [EBP+8] is the command itself (usually the program name)
   ; [EBP+12] is first argument...  
   
   ; verify the first argument
   push dword [EBP+12] ;; pointer to a string? this is where the pointer to the text of the command line argument that is the file name will
   call printf
   add esp,4
   
   ; the args will be used by _LoadLevel -- getting the filename of the level data to load
   ; loadlevel is purely internal to this program and does not need cdecl
   call _LoadLevel 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize ncurses stuff...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call initscr  ; ncurses: initscr -- initialize the screen, ready for ncurses stuff...
    call cbreak   ; ncurses: cbreak -- disables line buffering so we can get immediate key input
    call clear    ; ncurses: clear -- clear the screen
    push 0 ;; pushes parameter to curs_set
    call curs_set ; ncurses: curs_set(0) makes cursor invisible
    add esp, 4  ;; works as a 'pop'
    call noecho   ; ncurses: noecho -- don't echo type characters to screen
    push 250    ;; parameter for timeout
    call timeout  ; ncurses: timeout(milliseconds) set how long getch() will wait for a keypress (determines game speed)
    add esp, 4

; game loop
_GameLoop:
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; _DisplayLevel
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call clear      ; ncurses: clear --  clears screen and puts print position in the top left corner

    push dword lvlBuffer  ; lvlBuffer should just contain one large multiline string...
    call printw           ; ncurses: printw -- works just like printf, except printing starts from current print position on the ncurses screen
                          ;                    here we are just using it to print entire lvlBuffer
    add esp,4
push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov eax, dword [my_int]
    push eax
    push dword int_format
    call printw
    add esp, 8
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; _Update lvlBuffer based on player movement & game "AI"
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call _GameTick
;; getting past this jump is the key to adding a "quit" function
    jmp _GameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_exit:
    ;wrapup ncurses stuff...
    call endwin  ; cleanup/deallocate ncurses stuff (probably won't matter much since we're about to exit anyway... but let's keep things clean)
    
    ;wrapup cdecl
    mov     esp, ebp
    pop     ebp
    
    ;sys_exit
    mov     eax, 1 ; sys_exit
    xor     ebx, ebx
    int     80H


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  _GameTick
;;      handle a single tick fo the game clock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



_GameTick:
    
    
    mov eax, startOfGame
    mov ebx, [startOfGame2] ;; tracking start of game so know when to do the pause
    cmp eax, ebx
    je _keyPause2

    call getch     ; the ncurses getch (allows us to not wait indefinitely -- google ncurses nodelay timeout
                    ; the single return character should be in AL
    
        
    ;  check for wasd and update player step in horizontal&vertical directions
    cmp AL, 'w'
    je _keyUp
    cmp AL, 'a'
    je _keyLeft
    cmp AL, 's'
    je _keyDown
    cmp AL, 'd'
    je _keyRight
    cmp AL, ' '
    je _keyPause
    
    
    jmp _continue

    ; [xStep] and [yStep] act as a sort of "velocity" or "step size per tick", can be either 1, 0 or -1
    _keyUp:
       mov dword [xStep],0
       mov dword [yStep],-1
       jmp _continue
       
    _keyLeft:
       mov dword [xStep],-1
       mov dword [yStep],0
       jmp _continue
    
    _keyDown:
       mov dword [xStep],0
       mov dword [yStep],1
       jmp _continue
    
    _keyRight:
       mov dword [xStep],1
       mov dword [yStep],0
       jmp _continue
       
    _keyPause:
    
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov eax, 4
    mov ebx, 1
    mov ecx, messageTest ;; printing scoreboard
    mov edx, messageTestLen
    int 0x80
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    _keyPause3:
    
       call getch
       cmp AL, ' '
       je _continue
       cmp AL, 'q'
       je _keyExit
       
       jmp _keyPause3
         
       
     
    _keyPause2:
    call getch
       
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov eax, 4
    mov ebx, 1
    mov ecx, messageTest ;; printing scoreboard
    mov edx, messageTestLen
    int 0x80
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
       
       _keyPause4:
       call getch
       cmp AL, 'w'
       je _continue2
       cmp AL, 'a'
       je _continue3
       cmp AL, 's'
       je _continue4
       cmp AL, 'd'
       je _continue5
       
       jmp _keyPause4
    
    
    
    _keyExit:
       jmp _exit
    
    _continue2:;; different options for start of game depending on first key pressed
        mov ebx, 2
        mov [startOfGame2], ebx
        jmp _keyUp
    _continue3:
        mov ebx, 2
        mov [startOfGame2], ebx
        jmp _keyLeft
    _continue4:
        mov ebx, 2
        mov [startOfGame2], ebx
        jmp _keyDown
    _continue5:
        mov ebx, 2
        mov [startOfGame2], ebx
        jmp _keyRight

    _continue:

       mov esi, [headIndex]

       mov eax, [bodySegmentAddresses + 4*esi]
       add eax, [xStep]
       mov ecx, [yDelta]
       imul ecx, [yStep]
       add eax, ecx
       cmp byte [eax], '*' ;; checking for pellet
       je _skipTail2
       cmp byte [eax], '-' ;; checking for wall
       je _exit
       cmp byte [eax], '+' ;; checking for wall
       je _exit
       cmp byte [eax], '|' ;; checking for wall
       je _exit
       cmp byte [eax], 'o' ;; checking for self
       je _exit
       cmp byte [eax], '0' ;; checking for portal
       je _enterPortal
       cmp byte [eax], ' ' ;; checking that in legal space
       jne _exit
       
       jmp _passHere
       
_enterPortal:
       ; fetch head & tail INDEXES into ESI & EDI
       mov esi, [headIndex]
       mov edi, [tailIndex] 
       ; fetch head & tail ADDRESSES into EAX & EBX
       mov eax, [bodySegmentAddresses + 4*esi]
       mov ebx, [bodySegmentAddresses + 4*edi]
       
       ; replace current head with a body segment
       mov byte [eax], 'o'
       ; replace current tail with a space
       mov byte [ebx], ' '
       jmp _skipJumper2 
       
_passHere:       
       ; fetch head & tail INDEXES into ESI & EDI
       mov esi, [headIndex]
       mov edi, [tailIndex] 
       ; fetch head & tail ADDRESSES into EAX & EBX
       mov eax, [bodySegmentAddresses + 4*esi]
       mov ebx, [bodySegmentAddresses + 4*edi]
       
       ; replace current head with a body segment
       mov byte [eax], 'o'
       ; replace current tail with a space
       mov byte [ebx], ' '
       jmp _skipJumper
       
    _skipTail2:
        mov esi, 1
        add [my_int], esi
        jmp _skipTail
       
    _skipTail:
       mov esi, 1
       add [flag], esi
       
      
       
    ; fetch head & tail INDEXES into ESI & EDI
       mov esi, [headIndex]
       mov edi, [tailIndex] 
       ; fetch head & tail ADDRESSES into EAX & EBX
       mov eax, [bodySegmentAddresses + 4*esi]
       mov ebx, [bodySegmentAddresses + 4*edi]
       
       ; replace current head with a body segment
       mov byte [eax], 'o'
       
       jmp _skipJumper
       
    _incrementorForTailIncrease:
    
        dec edi
        mov byte [flag], 0
        jmp _skipWrapTailIndex   
       
    _skipJumper:
       ; increment headIndex (wrap if >= maxLvlBufferSize)
       add esi, 1
       cmp esi, maxSegmentIndex
       jl _skipWrapHeadIndex
       sub esi, maxSegmentIndex
    _skipWrapHeadIndex:
       mov [headIndex], esi      ; store the new head index back into memory
       ; now do the same for the tail index
       add edi, 1
       
       cmp edi, maxSegmentIndex
       jl _skipWrapTailIndex
       cmp byte [flag], 1
       je _incrementorForTailIncrease
       sub edi, maxSegmentIndex
       
    _skipWrapTailIndex:
       cmp byte [flag], 1
       je _incrementorForTailIncrease    
       mov [tailIndex], edi

       ; get new location of head and put '@' there
       add eax, [xStep]   ; add -1,1 or 0 to current address of head
       mov ecx, [yDelta]  ; [yDelta] -- the number of bytes to wrap around to same position on next or previous line: lvlWidth+1 
       imul ecx, [yStep]  ; multiply [ydelta] by -1,1, or 0, depending on whether we are moving up/down/neither
       add eax, ecx       ; add it to the head position address
       mov byte [eax],'@' ; put the head in the new location
       mov [bodySegmentAddresses + 4*esi],eax ; save the new head address in bodySementAddressees[headIndex]
       mov esi, 0
       mov [flag], esi
       
   
       
    ret
    
    _skipJumper2:
       ; increment headIndex (wrap if >= maxLvlBufferSize)
       add esi, 1
       cmp esi, maxSegmentIndex
       jl _skipWrapHeadIndex2
       sub esi, maxSegmentIndex
    _skipWrapHeadIndex2:
       mov [headIndex], esi      ; store the new head index back into memory
       ; now do the same for the tail index
       add edi, 1
       
       cmp edi, maxSegmentIndex
       jl _skipWrapTailIndex2
       cmp byte [flag], 1
       sub edi, maxSegmentIndex
    
    _skipWrapTailIndex2:
       mov [tailIndex], edi

       ; get new location of head and put '@' there
       ;;mov eax, [portal2Address]
       add eax, [xStep]   ; add -1,1 or 0 to current address of head
       mov ecx, [yDelta]
       imul ecx, [yStep]
       add eax, ecx
       cmp eax, [portal2Address]
       je _teleportToPortal1
       
       push esi
       mov esi, [xStep]
       NEG esi ;; reverses the direction
       mov [xStep], esi
       mov esi, [yStep]
       NEG esi
       mov [yStep], esi
       pop esi
       
       
       mov eax, [portal2Address]
       add eax, [xStep]
       mov ecx, [yDelta]  ; [yDelta] -- the number of bytes to wrap around to same position on next or previous line: lvlWidth+1 
       imul ecx, [yStep]  ; multiply [ydelta] by -1,1, or 0, depending on whether we are moving up/down/neither
       add eax, ecx       ; add it to the head position address
       mov byte [eax],'@' ; put the head in the new location
       mov [bodySegmentAddresses + 4*esi],eax ; save the new head address in bodySementAddressees[headIndex]
    _return:  
       
    ret
    
    _teleportToPortal1:
       push esi
       mov esi, [xStep]
       NEG esi
       mov [xStep], esi
       mov esi, [yStep]
       NEG esi ;; reverses the direction
       mov [yStep], esi
       pop esi
    
       mov eax, [portal1Address]
       add eax, [xStep]
       mov ecx, [yDelta]  ; [yDelta] -- the number of bytes to wrap around to same position on next or previous line: lvlWidth+1 
       imul ecx, [yStep]  ; multiply [ydelta] by -1,1, or 0, depending on whether we are moving up/down/neither
       add eax, ecx       ; add it to the head position address
       mov byte [eax],'@' ; put the head in the new location
       mov [bodySegmentAddresses + 4*esi],eax ; save the new head address in bodySementAddressees[headIndex]
       
    jmp _return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  _LoadLevel
;;      Reads the level file, with some rudimentary verification of format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_LoadLevel:


    ;check that we have exactly one arg (in addtion to command)
    mov edx, [EBP+4]
    cmp edx, 2
    jne _usage
    ;ok, try to open the file...
    push readModeStr
    push dword [EBP+12]
    call fopen
    add esp, 8
    ;file pointers should be in EAX now (or null on failure
    cmp eax,0
    jle _openFileFail
    ;OK we have the file, save the filepointer & read the file...
    mov [lvlFilePtr], eax
    
    ;first line should tell us the width&height
    push lvlHeight            ; address to store the height of the level
    push lvlWidth             ; address to store the width of the level
    push twoIntFmt            ; format string for reading a two integers
    push dword [lvlFilePtr]   ; file pointer for the opened level file
    call fscanf
    add esp,16                ; remove scanf parameters from stack   
    
;;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    ; make sure ((width+1) * height) +1 is less than size of lvlBuffer 
    ; "+1" for newline at end of each line
    ; "-1" for null terminator at end of entire level
    ; jump to _LevelExceedsMaximumSize
;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    ; calculat & store yDelta (number of character steps to arrive at exact same position in previous or next line
    mov eax, [lvlWidth]
    inc eax
    mov [yDelta], eax
        
    ; use fgets to read (and ignore) remainder of the last line we read in...
    push dword [lvlFilePtr]
    push lvlBufSize
    push lvlBuffer   ; whatever is still on the line we put here, but it will be overwritten below
    call fgets
    add esp,12

    ; next lvlHeight lines should be the level itself
    
    ; initialize for LoadLevelLoop... (we'll be using registers that are "safe" in cdecl function calls
    mov edi, lvlBuffer ;edx will point successively to beginning of each line
    mov esi, [lvlWidth] ; add 2 to this for newline & null for limit on what fgets will read 
    add esi, 2
    mov ebx, [lvlHeight] ; use ebx to count down lines read
 
_LoadLevelLoop:
    ;fgets
    push dword [lvlFilePtr]   ; file pointer 
    push esi            ; max size of string to read in (included the added null terminator)
    push edi            ; pointer to where we want that string to go (within lvlBuffer)
    call fgets          ; read line from lvl file
    add esp, 12
  
    push edi
    push esi
    push edx
    push ecx
    
    mov ecx, 0
    mov edi, 0
    dec edi
    
_portalCheck:  
    inc edi
    cmp byte [eax+edi], 48 ;; checks for portal character
    je _addPortal
       
_increasePointer:
    cmp [lvlWidth], edi
    jne _portalCheck
    
leavePortalCheckLoop:
    pop ecx
    pop edx
    pop esi
    pop edi
    
    cmp eax,edi         ; check for failure to successfully read -- return value should just be pointer to where the string was stored
    jne _badFileFormat
    jmp _next
    
_addPortal:
    mov ecx, [portalCounter]
    cmp ecx, 0
    je _addFirstPortal
    cmp ecx, 1
    je _addSecondPortal
    jmp _badPortalFileFormat  ;; if more than two portals, quits
    
_addFirstPortal: ;; adds address for first portal
    mov esi, eax
    add esi, edi
    mov [portal1Address], esi
    inc ecx
    mov [portalCounter], ecx
    jmp _increasePointer 

_addSecondPortal: ;; adds address for second portal
    mov esi, eax
    add esi, edi
    mov [portal2Address], esi
    inc ecx
    mov [portalCounter], ecx
    jmp _increasePointer 

;;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    ; verify that line is the correct length, do not overflow the lvlBuffer
    ; if wrong length, jump to _badFileFormat
;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_next:       
    dec ebx
    jz _LoadInitialBody 
    add edi, esi  ;adjust edx to where next line will start in lvlBuffer
    sub edi,1     ;back off 1 because we want to overwrite the null terminators (except the last line)

    jmp _LoadLevelLoop

_LoadInitialBody:
; next line should tell us how many initial body segments
    push bodyLength
    push oneIntFmt
    push dword [lvlFilePtr]
    call fscanf
    add  esp, 12
    
; next bodyLength lines should contain the X,Y coords of the body segments, starting with the head
    mov edi, [bodyLength]  ; edi will be the index into bodySegmentAddresses array
    dec edi                ; decrement by 1 because zero based -- this is index of the head
    mov [headIndex], edi
    mov dword [tailIndex], 0     ; the index of the tailAddress will initially be 0

_LoadBodySegmentsLoop:
cmp byte [portalCounter], 1
    je _badPortalFileFormat        
    ; next line should have the millipede head starting position
    push segmentY  ; remember cdecl reverse order onto the stack -- in lvl file, it is X then Y
    push segmentX
    push twoIntFmt
    push dword [lvlFilePtr]
    call fscanf
    add esp,16    
push eax
push dword edi
push dword [segmentX]
push dbgIntFmt
call printf
add esp, 12
pop eax
 
    ; calculate the body segment's address within lvlBuffer
    ; the store it in appropriate element within bodySegmentAddresses
    mov eax, lvlBuffer
    mov ecx, [segmentY]
    imul ecx, [yDelta]
    add eax, ecx         ; eax now hold the address of this body segment within lvlBuffer
    add eax, [segmentX]
    mov esi, bodySegmentAddresses
    mov [esi + 4*edi],eax            ; storing the address for this body segment in bodySegmentAddresses

    dec edi
    cmp edi,0
    jl  _DrawInitialBody   ; jump if less than 0 -- we want another go around for 0 index
    jmp _LoadBodySegmentsLoop

_DrawInitialBody:
    mov edi, [headIndex]
    mov esi, bodySegmentAddresses
    mov edx, [esi+4*edi]        ; get the head address from bodySegmentAddresses
    mov byte [edx], '@'              ; put the head '@' at that location within lvlBuffer
    
_DrawBodyLoop:
    dec edi
    cmp edi,0
    jl _LoadLevelWrapup         ; break out of loop after last segment
    mov edx, [esi+4*edi]        ; get the segment address from bodySegmentAddresses
    mov byte [edx], 'o'              ; put the segment 'o' at that location within lvlBuffer
    jmp _DrawBodyLoop           ; repeat for next segment
    
    
_LoadLevelWrapup:    
    
    ret     ; internal non-cdecl routine, so nothing else to do but return
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_usage:
    push usageMsg
    call printf
    jmp _exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_openFileFail:
    push openFileFailMsg
    call printf
    jmp _exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_badFileFormat:
    push badFileFormatMsg
    call printf
    jmp _exit
    
;;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    ; _LevelExceedsMaximumSize
;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_badPortalFileFormat:
    push portalErrorMsg
    call printf
    jmp _exit


   
