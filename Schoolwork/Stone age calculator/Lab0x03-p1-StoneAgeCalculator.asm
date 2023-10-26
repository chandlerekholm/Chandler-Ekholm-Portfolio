;; DEFINITIONS

section .data
    SYS_READ equ 3
    SYS_WRITE equ 4
    STDIN equ 0
    STDOUT equ 1
    SYS_EXIT equ 1
    
    msgWelcome db "Welcome to the stone age", 0x0A, "We do math with pebbles.", 0x0A
    msgWelcomeLen equ $ - msgWelcome        ;; welcome message and length
    
    msgHurtHead db "Ug! What that? You hurt Grog head!", 0x0A
    msgHurtHeadLen equ $ - msgHurtHead  ;; error message
    
    msgEqual db "=" ;; equal symbol
    msgEqualLen equ $ - msgEqual
    
    msgNothing db "Ug! Number can't below nothing", 0x0A
    msgNothingLen equ $ - msgNothing    ;; error message for negative pebble

    
    tooMany db "Ug! Number too big!", 0x0A      ;; overflow error message
    tooManyLen equ $ - tooMany
    
    exitMsg db "...returning to your proper time in history.", 0x0A
    exitMsgLen equ $ - exitMsg  ;; exit message
    
    msgNewLine db 0x0A  ;; newline
    msgNewLineLen equ $ - msgNewLine
    
    pebbleMsg db "o"    ;; pebble character
    pebbleMsgLen equ $ - pebbleMsg

section .bss 
    INPUT_BUFFER resb 1024
    IN_BUF_SIZE equ $ - INPUT_BUFFER
    OP_SYMBOL resb 2        ;; stores the add, sub, mul, or div symbol
    OP_SYMBOL_SIZE equ $ - OP_SYMBOL
    LENGTH_OF_INPUT resb 1024
    RUNNING_INPUT resb 1024     ;; stores the running total
    RUNNING_INPUT_LEN equ $ - RUNNING_INPUT
   
    OP_TEST_SIZE resb 1
    
    ascii resb 8
   
    NEW_PEBBLE_INPUT resb 1024
    NEW_PEBBLE_INPUT_SIZE equ $ - NEW_PEBBLE_INPUT
   
    tester resb 1024
    
    new_input_length resb 1024
section .text
    global _start
_start:

hello_world:
    mov eax, 4 ; putting 4 into EAX to do a sys_write
    mov ebx, STDOUT
    mov ecx, msgWelcome ; doing a sys_write
    mov edx, msgWelcomeLen ; putting length of bytes to write
    
    int 0x80 ; trigger an interrupt
    
    mov edx, 0  ;;zeroing out
 
    mov edi, 0
 
    mov [RUNNING_INPUT], edx
    
equal_print:

    cmp edi, 0      ;; checking for negative pebble
    jl below_nothing_error
    
    cmp edi, 255    ;; checking for overflow
    jg overflow
    
    mov eax, 4      ;; printing equal symbol
    mov ebx, STDOUT
    mov ecx, msgEqual
    mov edx, msgEqualLen
    
    int 0x80 

print_all_pebbles:  

    cmp edi, 0
    je equal_print2     ;; checks if out of pebbles to print
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, pebbleMsg
    mov edx, pebbleMsgLen
    
    int 0x80
    dec edi ;; decrements and loops until all pebbles printed
    
    jmp print_all_pebbles
    
    
   
equal_print2:   ;; prints newLine
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msgNewLine
    mov edx, msgNewLineLen
    
    int 0x80   
    
pebble_reader:      ;; reads in the operating symbol, then moves pebble size into position

    xor esi, esi        ;; reset esi
    mov byte [tester], 0 ;; reset tester

    ;; reading operation symbol 
    mov eax, SYS_READ
    mov ebx, STDIN                  ;; reading in symbol
    mov ecx, OP_SYMBOL
    mov edx, 1
    
    int 0x80 
    
    mov [tester], eax
    mov esi, [tester]
    dec esi
    
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, NEW_PEBBLE_INPUT
    mov edx, NEW_PEBBLE_INPUT_SIZE
    
    
    
    dec edx
   ; inc ecx
    
    int 0x80
    
    mov [new_input_length], eax
    mov esi, [new_input_length]
    dec esi
    mov [new_input_length], esi
    
    jmp check_calculation_symbol

check_calculation_symbol:   ;; picks the correct action based on the operation symbol

    mov edi, [OP_SYMBOL]
    
    mov ebx, 99     ;; checks for 'c'
    cmp edi, ebx
    je clearInput
    
    mov ebx, 120    ;; checks for 'x'
    cmp edi, ebx
    je exitMessage
    
    mov ebx, 43     ;; checks for '+'
    cmp edi, ebx
    je addition
    
    mov ebx, 45     ;; checks for '-'
    cmp edi, ebx
    je subtraction
    
    mov ebx, 42     ;; checks for 'x'
    cmp edi, ebx
    je multiplication
    
    mov ebx, 47     ;; checks for '/'
    cmp edi, ebx
    je division
    
    mov ebx, 37     ;; checks for '%'
    cmp edi, ebx
    je modulo
    
    jmp no_instruction_error    ;; catches any other symbol
    
addition:       ;; performs addition to the running input

    mov eax, [new_input_length]
    mov esi, [RUNNING_INPUT]
    
    add esi, eax
    
    mov [RUNNING_INPUT], esi
    
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    

subtraction:    ;; performs subtraction to the running input

    mov eax, [new_input_length]
    mov esi, [RUNNING_INPUT]
    
    sub esi, [new_input_length]
    
    mov [RUNNING_INPUT], esi
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print

multiplication: ;; performs multiplication to the running input

    mov eax, [new_input_length]
    mov esi, [RUNNING_INPUT]
    mov ecx, [RUNNING_INPUT]
    mov ebx, 1
    
    cmp eax, ebx
    je multiplication3
    
multiplication2:    
    
    
    add esi, ecx
    dec eax
    cmp ebx, eax
    jl multiplication2
    
multiplication3:
    
    mov [RUNNING_INPUT], esi
    mov edi, [RUNNING_INPUT]

    jmp equal_print

division:    ;; performs division to the running input

    mov eax, [new_input_length]
    mov esi, [RUNNING_INPUT]
    mov ebx, 0
    mov ecx, 0
        
    sub esi, eax
    cmp ecx, esi
    jg divisionFail
    inc ebx
    
division2:

    sub esi, eax
    cmp ecx, esi
    jg returnDivision
    inc ebx

    jmp division2
    
returnDivision:

    mov [RUNNING_INPUT], ebx
    mov edi, [RUNNING_INPUT]
    jmp equal_print
    
divisionFail:

    mov [RUNNING_INPUT], ecx
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
modulo: ;; performs modulus function

    mov eax, [new_input_length]
    mov esi, [RUNNING_INPUT]
    mov edx, [RUNNING_INPUT]
    mov ecx, 0
    
modulo2:
    
    sub esi, eax
    cmp ecx, esi
    jg moduloFail
    
modulo3:
    
    cmp esi, eax
    jl moduloExit
    
modulo4:

    sub esi, eax
    cmp eax, esi
    jle modulo4
        
moduloExit:

    mov [RUNNING_INPUT], esi
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
moduloFail:

    mov [RUNNING_INPUT], edx
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
no_instruction_error:   ;; general error message

    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msgHurtHead
    mov edx, msgHurtHeadLen
    
    int 0x80
    
    mov eax, 0
    mov [RUNNING_INPUT], eax
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
    
pebble_printer_test:    
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, NEW_PEBBLE_INPUT
    mov edx, NEW_PEBBLE_INPUT_SIZE
    
    int 0x80
    
    
below_nothing_error:    ;; error message for negative result that resets running
                        ;; input to zero and returns

    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msgNothing
    mov edx, msgNothingLen
    
    int 0x80
    
    mov edx, 0
    mov [RUNNING_INPUT], edx
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
overflow:       ;; error message for overflow result that resets running input
                ;; to zero and returns

    mov eax, 4
    mov ebx, STDOUT
    mov ecx, tooMany
    mov edx, tooManyLen
    
    int 0x80
    
    mov edx, 0
    mov [RUNNING_INPUT], edx
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
clearInput:     ;; clears result to 0 and returns

    mov edx, 0
    mov [RUNNING_INPUT], edx
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print
    
exitMessage:    ;; message played before exit

    mov eax, 4
    mov ebx, STDOUT
    mov ecx, exitMsg
    mov edx, exitMsgLen
    
    int 0x80
    
    jmp exit
    
exit:   ;; proper program exit

    mov eax, SYS_EXIT   
    mov ebx, 0          
    int 0x80            
