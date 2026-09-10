section .text
 
 
; Принимает код возврата и завершает текущий процесс
exit: 
    mov rax, 60
    syscall
    ;ret 

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
    .loop:
        cmp byte [rdi + rax], 0
        je .done
        inc rax
        jmp .loop
    .done:
        ret


; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rbx
    mov rbx, rdi
    call string_length
    mov rdx, rax
    mov rsi, rbx
    mov rax, 1
    mov rdi, 1
    syscall
    pop rbx
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push rdi
    sub rsp, 8
    mov [rsp], dil
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    add rsp, 8
    pop rdi
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 0xA
    jmp print_char
;    ret

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    xor rax, rax
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    xor rax, rax
    ret

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rax, rax
    .loop:
        mov r8b, [rdi + rax]
        cmp r8b, [rsi + rax]
        jne .not_equal
        test r8b, r8b
        je .equal
        inc rax
        jmp .loop
    .not_equal:
        xor rax, rax
        ret
    .equal:
        mov rax, 1
        ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    sub rsp, 8
    xor rax, rax
    xor rdi, rdi
    mov rsi, rsp
    mov rdx, 1
    syscall
    test rax, rax
    jz .eof
    movzx rax, byte [rsp]
    add rsp, 8
    ret
    .eof:
        add rsp, 8
        xor rax, rax
        ret 

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov rbx, rdi
    mov r13, rsi
    xor r12, r12
.skip_spaces:
    call read_char
    cmp rax, 0
    je .eof
    cmp al, 0x20
    je .skip_spaces
    cmp al, 0x9
    je .skip_spaces
    cmp al, 0xA
    je .skip_spaces
    movzx r14, al
    jmp .read_word
.read_word:
    mov rax, r13
    dec rax
    cmp r12, rax
    jae .too_long
    mov [rbx + r12], r14b
    inc r12
    call read_char
    test rax, rax
    je .eof 
    cmp al, 0x20
    je .done
    cmp al, 0x9
    je .done
    cmp al, 0xA
    je .done
    movzx r14, al
    jmp .read_word
.too_long:
    xor rax, rax
    jmp .done
.eof:
    mov byte [rbx + r12], 0
    mov rax, rbx
    mov rdx, r12
.done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rax, rax
    ret




; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    xor rax, rax
    ret 

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    xor rax, rax
    .loop:
        cmp rax, rdx
        jae .too_long
        mov r8b, [rdi + rax]
        mov [rsi + rax], r8b
        test r8b, r8b
        je .done
        inc rax
        jmp .loop
    .done:
        mov byte [rsi + rax], 0
        ret
    .too_long:
        xor rax, rax
        ret
