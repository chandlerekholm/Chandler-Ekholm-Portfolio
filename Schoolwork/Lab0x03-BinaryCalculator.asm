section .data
    newInput db 0   ;;storing the new input in integer format

    SYS_READ equ 3
    SYS_WRITE equ 4
    STDIN equ 0
    STDOUT equ 1
    SYS_EXIT equ 1
    
    intTest db 0    
       
    msgWelcome db "Welcome to binar!", 0x0A
    msgWelcomeLen equ $ - msgWelcome
    
    msgEqual db "="
    msgEqualLen equ $ - msgEqual
    
    msgNewLine db 0x0A
    msgNewLineLen equ $ - msgNewLine
    
    testString db "11010101"
    testStringLen equ $ - testString
    
    exiting db "Exiting Binar...", 0x0A
    exitingLen equ $ - exiting
    
    overflowMsg db "Error. Result exceeded 255. Resetting running total.", 0x0A
    overflowMsgLen equ $ - overflowMsg
    
    NoInstruction db "Error. Invalid input. Please restart and try again.", 0x0A
    NoInstructionLen equ $ - NoInstruction
    
    negativeResultMsg db "Error. Result negative, cannot compute. Resetting running total.", 0x0A
    negativeResultMsgLen equ $ - negativeResultMsg
    
    msg1 db "1"
    msg1Len equ $ - msg1
    
    msg0 db "0"
    msg0Len equ $ - msg0
    
    shiftBit db 0
    
section .bss
    INPUT_BUFFER resb 1024
    IN_BUF_SIZE equ $ - INPUT_BUFFER
    OP_SYMBOL resb 2                ;;storing the symbol for calculation
    OP_SYMBOL_SIZE equ $ - OP_SYMBOL
    

    LENGTH_OF_INPUT resb 1024
    RUNNING_INPUT resb 1024
    RUNNING_INPUT_LEN equ $ - RUNNING_INPUT
    
    NEW_BINAR_INPUT resb 1024   ;; used for storing the new input
    NEW_BINAR_INPUT_SIZE equ $ - NEW_BINAR_INPUT
    
    new_input_length resb 1024
    
    tester resb 1024
    
section .text
    global _start
_start:

hello_world:        ;;welcome message
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msgWelcome
    mov edx, msgWelcomeLen
    int 0x80
    
    mov edx, 0              ;;zeroing out everything
    mov [intTest], edx
    mov [RUNNING_INPUT], edx
    
    
equal_print:    

    mov ebx, 256        ;; checking for overflow
    mov ecx, [RUNNING_INPUT]
    cmp ecx, ebx
    jge overflowError

    mov ebx, 0      ;; checking for negative result
    mov ecx, [RUNNING_INPUT]
    cmp ebx, ecx
    jg negativeError

    mov eax, 4          ;; printing the equal sign
    mov ebx, STDOUT
    mov ecx, msgEqual
    mov edx, msgEqualLen
    
    int 0x80
    
print_running_total:;; the next series of sections takes the running total and
                    ;; prints out the 0's and 1's based on the number
    mov edi, [RUNNING_INPUT]    
    mov esi, [RUNNING_INPUT]
    mov ecx, 128
    cmp esi, ecx
    jge subtract_128
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80
    
print_running_total2:

    mov esi, [RUNNING_INPUT]
    mov ecx, 64
    cmp esi, ecx
    jge subtract_64
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80
    
print_running_total3:

    mov esi, [RUNNING_INPUT]
    mov ecx, 32
    cmp esi, ecx
    jge subtract_32
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80    
    
print_running_total4:

    mov esi, [RUNNING_INPUT]
    mov ecx, 16
    cmp esi, ecx
    jge subtract_16
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80

print_running_total5:

    mov esi, [RUNNING_INPUT]
    mov ecx, 8
    cmp esi, ecx
    jge subtract_8
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80

print_running_total6:

    mov esi, [RUNNING_INPUT]
    mov ecx, 4
    cmp esi, ecx
    jge subtract_4
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80

print_running_total7:

    mov esi, [RUNNING_INPUT]
    mov ecx, 2
    cmp esi, ecx
    jge subtract_2
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80

print_running_total8:

    mov esi, [RUNNING_INPUT]
    mov ecx, 1
    cmp esi, ecx
    jge subtract_1
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg0
    mov edx, msg0Len
    
    int 0x80
    
    jmp binar_reader
    
subtract_128:       ;; each one of these subtracting functions works to 
                    ;; convert the decimal to binary

    mov ebx, 128
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total2
    
subtract_64:

    mov ebx, 64
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total3

subtract_32:

    mov ebx, 32
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total4

subtract_16:

    mov ebx, 16
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total5

subtract_8:

    mov ebx, 8
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total6

subtract_4:

    mov ebx, 4
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total7

subtract_2:

    mov ebx, 2
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80
    
    jmp print_running_total8

subtract_1:

    mov ebx, 1
    sub esi, ebx
    mov [RUNNING_INPUT], esi
    
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80

binar_reader:

    mov [RUNNING_INPUT], edi

    mov eax, 4      ;; printing newLine
    mov ebx, STDOUT
    mov ecx, msgNewLine 
    mov edx, msgNewLineLen
    int 0x80

    xor esi, esi        ;; zero out esi
    mov byte[tester], 0 
    
    mov eax, SYS_READ   ;; reading op symbol
    mov ebx, STDIN
    mov ecx, OP_SYMBOL
    mov edx, 1
    int 0x80
    
    mov [tester], eax   ;; moving address to correct location
    mov esi, [tester]
    dec esi
    
    mov eax, SYS_READ       ;; reading in rest of input
    mov ebx, STDIN
    mov ecx, NEW_BINAR_INPUT
    mov edx, NEW_BINAR_INPUT_SIZE
    
    dec edx
    
    int 0x80
    
    mov ebx, 1      ;; makes sure if the symbol is 'c' or 'x' that an error isn't called
    cmp eax, ebx
    je check_calculation_symbol
    
    mov ebx, 9      ;; makes sure the input is an operating symbol and 8 digits
    cmp eax, ebx
    jne NoInstructionError 

char_to_binary:

    mov ebx, NEW_BINAR_INPUT
    mov edi, 8  ;; counter variable
    mov esi, 0  ;; counter variable
    
char_to_binary2:    ;; this function works to reverse the input since it's read
                    ;; in reverse order    
    xor eax, eax
    dec edi
    
    shr byte [ebx+edi], 1
    rcl al, 1
    
    clc
    adc byte[shiftBit + esi], al
    
    mov edx, [shiftBit]
    
    inc esi
    
    mov eax, 0
    cmp eax, edi
    jge binar_converter
    
    jmp char_to_binary2
    
    jmp check_calculation_symbol
    
binar_converter:    ;; each of these adds to the integer total for each
                    ;; '1' read in, adding the correct amount depending on
                    ;; the 1's position
    xor ecx, ecx
    mov edx, shiftBit
    add edx, 7
    
    mov ebx, [edx]
    
    cmp ebx, 1
    je add128
    
binar_converter2:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add64
    
    
binar_converter3:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add32
    
binar_converter4:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add16

binar_converter5:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add8

binar_converter6:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add4
    
binar_converter7:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add2

binar_converter8:


    sub edx, 1
    mov ebx, [edx]
    mov edi, 1
    cmp [edx], edi
    je add1
    
    jmp moveTotal
        
add128:     ;; each of these 'add' functions adds the correct amount when
            ;; jumped to and returns after
    mov ecx, 128
    xor esi, esi
    add esi, ecx
    mov edi, 0
    mov [edx], edi
   
    jmp binar_converter2    
    
add64:
    add ecx, 64
    add esi, ecx
    mov edi, 0
    mov [edx], edi
    jmp binar_converter3  
add32:
    add ecx, 32
    add esi, ecx
    mov edi, 0
    mov [edx], edi
    jmp binar_converter4  
add16:
    add ecx, 16
    add esi, ecx
    mov edi, 0
    mov [edx], edi
    jmp binar_converter5
add8:
    add ecx, 8
    add esi, ecx
    mov edi, 0
    mov [edx], edi
    jmp binar_converter6
add4:
    add ecx, 4
    add esi, ecx
    mov edi, 0
    mov [edx], edi
    jmp binar_converter7   
add2:
    add ecx, 2
    add esi, ecx
    mov edi, 0
    mov [edx], edi
    jmp binar_converter8   
add1:
    add ecx, 1
    add esi, ecx
    mov edi, 0
    mov [edx], edi   
    
moveTotal:  ;; puts the correct total in the newInput register

    mov ebx, ecx
    movzx eax, bl
    mov [newInput], al
    mov edx, [newInput]
    
    
check_calculation_symbol:

    mov edi, [OP_SYMBOL]
    
    mov ebx, 43 ;; check for addition
    cmp edi, ebx
    je addition
    
    mov ebx, 45 ;; check for subtraction
    cmp edi, ebx
    je subtraction
    
    mov ebx, 42 ;; check for multiplication
    cmp edi, ebx
    je multiplication
    
    mov ebx, 47 ;; check for division
    cmp edi, ebx
    je division
    
    mov ebx, 37 ;; check for modulo
    cmp edi, ebx
    je modulo

    mov ebx, 99 ;; check for 'c'
    cmp edi, ebx
    je multiplicationFail   ;; this function clears out the running input
                            ;; so I'm reusing it here
    
    mov ebx, 120 ;; check for 'x'
    cmp edi, ebx
    je exitMessage

    jmp NoInstructionError ;; check for everything else

addition:   

    mov eax, [newInput]
    mov esi, [RUNNING_INPUT]
    
    add esi, eax
    mov [RUNNING_INPUT], esi
    mov edi, [RUNNING_INPUT]


    jmp equal_print
    
subtraction:

    mov eax, [newInput]
    mov esi, [RUNNING_INPUT]
    
    sub esi, eax
    mov [RUNNING_INPUT], esi
    mov edi, [RUNNING_INPUT]

    jmp equal_print
    
multiplication:
    
    mov ebx, 0
    cmp ebx, [newInput]
    je multiplicationFail
    cmp ebx, [RUNNING_INPUT]
    je multiplicationFail
    
    mov eax, [newInput]
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
    
multiplicationFail:

    mov ebx, 0
    mov [RUNNING_INPUT], ebx
    mov edi, [RUNNING_INPUT]
    
    jmp equal_print

division:

    mov eax, [newInput]
    mov esi, [RUNNING_INPUT]
    mov ebx, 0
    mov ecx, 0
    
    cmp eax, ebx
    je divisionFail
    cmp esi, ebx
    je divisionFail
        
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
    
modulo:

    mov eax, [newInput]
    mov esi, [RUNNING_INPUT]
    mov edx, [RUNNING_INPUT]
    mov ecx, 0
    
    cmp edx, ecx
    je multiplicationFail
    cmp eax, ecx
    je multiplicationFail
    
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
    
newLine_print:      ;; prints a newLine
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, msgNewLine
    mov edx, msgNewLineLen
    
    int 0x80

overflowError:      ;; prints an error message if the total is over 255
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, overflowMsg
    mov edx, overflowMsgLen
    int 0x80
    
    jmp multiplicationFail

negativeError: ;; prints an error message if the total is negative
    mov eax, 4
    mov ebx, STDOUT
    mov ecx, negativeResultMsg
    mov edx, negativeResultMsgLen
    int 0x80
    
    jmp multiplicationFail

NoInstructionError:     ;; general error message

    mov eax, 4
    mov ebx, STDOUT
    mov ecx, NoInstruction
    mov edx, NoInstructionLen
    int 0x80

exitMessage: ;; message printed when user inputs 'x'

    mov eax, 4
    mov ebx, STDOUT
    mov ecx, exiting
    mov edx, exitingLen
    
    int 0x80

exit:   ;; proper system exit
    
    mov eax, SYS_EXIT
    mov ebx, 0
    int 0x80
