SECTION .text

global start

start:
	mov ebp, esp
	cmp dword [ebp], 4		; checking the number of arguements passed to the application
	je args_correct
	cmp dword [ebp], 2
	je help_func

invalid:				; executed if invalid arguements are passed to the application
	push dword [inv_args_len]	; length of data to print
	push inv_args			; base address of string to print
	call print
	add esp, 8
	call exit

print:
	mov edx, dword [esp + 8]	; implementation of print function which uses write syscall (eax = 4)
	mov ecx, dword [esp + 4]	; function accepts two params, 1st is the base address of string to be printed
	mov ebx, 1			; and 2nd param is the length of the string
	mov eax, 4			; save values in registers before calling this if those values are needed
	int 80h         ; write syscall
	ret

exit:
	mov ebx, 0
	mov eax, 1
	int 80h		; exit syscall
	ret

; stringcmp related labels begin here
stringcmp:
	push ebp			; strcmp like implementation in asm
	mov ebp, esp			; function accepts three arguements
	mov edi, ebp			; first is the address of string and 2nd is the length of this string
	add edi, 12			; third is the address of the string to be compared
	mov eax, dword [ebp + 16]
	mov ebx, dword [ebp + 8]		; If strings are equal eax contains 0 and 1 if they aren't
	xor ecx, ecx
	xor edx, edx

_countFileChars:
    push r10
    push r9

    xor r10, r10
    mov rax, qword[file_descriptor]


    _while_countFileChars:
        mov r9, rax
        mov rdi, rax ;copying fd (assuming it's opened) to rdi
        mov rsi, text_buffer
        mov rdx, 0x1 ; count
        xor rax, rax ;sys_read(rax, *buffer, count)
        syscall

        cmp  rax, 1
        jl _endWhile_countFileChars
        inc r10 

        mov rax, r9
        jmp _while_countFileChars

    _endWhile_countFileChars:
    

   mov qword[text_total], r10

    pop r9
    pop r10
    ret
   
   
_openFile:
    ; open the file
    mov rax, 2 ;sys_open(file_name, flags, mode)
    mov rdi, filename
    mov rsi, 2 ;O_APPEND
    mov rdx, 0666 ; rw-r--r--
    syscall
    mov qword[file_descriptor], rax
    cmp qword[file_descriptor], 0
    jne _return_openFile 
    exit 1
    _return_openFile:
    ret

_closeFile:
    ; close file
    mov rax, 3 ;sys_close(fd)
    mov rdi, qword[file_descriptor]
    syscall
    ret


_readFromToPosFile:
    push r11
    mov r11, qword[text_count]
    sub r11, qword[text_offset] ;char count = text_count - text_offset
    
    mov rdi, qword[file_descriptor] ;file_descriptor
    mov rsi, text_buffer
    mov rdx, r11 ; count
    mov r10, qword[text_offset] ;offset
    mov rax, 17 ;sys_pread64(fd, *buffer, count,offset)
    syscall
    pop r11
    ret

_writeFromToPosFile:
    push r11
    mov r11, qword[text_count]
    sub r11, qword[text_offset] ;char count = text_count - text_offset
    
    mov rdi, qword[file_descriptor] ;file_descriptor
    mov rsi, text_buffer
    mov rdx, r11 ; count
    mov r10, qword[text_offset] ;offset
    mov rax, 18 ;sys_pread64(fd, *buffer, count,offset)
    syscall
    pop r11
    ret
