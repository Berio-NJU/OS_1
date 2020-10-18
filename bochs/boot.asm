    org 07c00h      ;告诉编译器程序加载到7c00处  
    mov ax, cs  
    mov ds, ax  
    mov es, ax  
    call DispStr    ;调用显示字符串例程  
    jmp $  
DispStr:  
    mov ax, BootMessage  
    mov bp, ax  
    mov cx, 16  
    mov ax, 01301h  
    mov bx, 00ch  
    mov dl, 0  
    int 10h  
    ret  
BootMessage:    db "Hello, OS world!"  
    times 510-($-$$) db 0  
    dw 0xaa55  
