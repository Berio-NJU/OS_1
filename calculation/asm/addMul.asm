%include    'functions.asm'

SECTION .data
inPrompt    db  'Please input x and y :', 0h
one     db '1',0h


SECTION .bss
inStr:  resb    255
xStr:   resb    255
yStr:   resb    255

addop1:     resb    255
addop2:     resb    255
xStrReverse: resb 255
yStrReverse: resb 255
addResultReverse: resb    255
addRes: resb 255
addResult: resb 255
xlen:   resb    4
ylen:   resb    4

multCount:  resb    255
multOp1:    resb    255
multOp2:    resb    255
rMultOp1:  resb    255
rMultOp2:  resb    255
aMultCarry:   resb    1
aMultResStr:    resb    255
aMultResult:    resb    255
zeroCount:      resb    1
multResult:    resb    255

myAddResult:    resb    255
myMultResult:   resb    255

SECTION .text
global _start

_start:
    ; 输出提示字符
    mov     eax, inPrompt
    call    sprintLF

    ; 接受用户输入，保存至inStr
    mov     edx, 255
    mov     ecx, inStr
    mov     ebx, 0
    mov     eax, 3
    int     80h

; 分解用户输入至xStr与yStr中
getXStr:
    mov     eax, inStr
    mov     ebx, xStr

getXStrLoop:
    mov     dh, byte[eax]
    mov     byte[ebx],dh

    inc     eax
    inc     ebx

    cmp     byte[eax],20h
    jne     getXStrLoop

getYStr:
    mov     ebx, yStr

getYhead:
    inc     eax
    cmp     byte[eax],32
    jz      getYhead

getYStrLoop:
    mov     dh, byte[eax]
    mov     byte[ebx],dh

    inc     eax
    inc     ebx

    cmp     byte[eax],0Ah
    jne     getYStrLoop

    ; 加法
    mov     eax,xStr
    mov     ebx,addop1
    call    scopy
    mov     eax,yStr
    mov     ebx,addop2
    call    scopy
    call    myAdd
    mov     eax, addResult
    mov     ebx, myAddResult
    call    scopy

printAdd:
    mov     eax,myAddResult
    call    sprintLF


    ; 乘法
    mov     eax, xStr
    mov     ebx, multOp1
    call    scopy
    mov     eax,yStr
    mov     ebx, multOp2
    call    scopy
    call    myMult
    mov     eax, multResult
    mov     ebx, myMultResult
    call    scopy

printMult:
    mov     eax,myMultResult
    call    sprintLF


exit:
    call    quit

;-----------------------------
; @param addop1,addop2
; @return addResult
myAdd:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi

    mov     eax,xStrReverse
    call    clean
    mov     eax,yStrReverse
    call    clean
    mov     eax,addResultReverse
    call    clean
    mov     eax,addRes
    call    clean
    mov     eax,addResult
    call    clean
    mov     dword[xlen],0
    mov     dword[ylen],0

    ; 获取字符长度
    getLen:
        mov     eax, addop1
        call    slen
        mov     dword[xlen],eax

        mov     eax, addop2
        call    slen
        mov     dword[ylen],eax

    ; 字符翻转
    rx:
        mov     eax,addop1
        mov     ecx,eax
        add     eax,dword[xlen]
        mov     ebx,xStrReverse
        call    reverse

    ry:
        mov     eax,addop2
        mov     ecx,eax
        add     eax,dword[ylen]
        mov     ebx,yStrReverse
        call    reverse

    ;对翻转字符进行相加
    addReverse:
        mov     eax, xStrReverse
        mov     ebx, yStrReverse
        mov     esi, addResultReverse
        mov     edi, 0 ;存进位

    addReverseLoop:
        cmp     byte[eax],0
        jz      xDone
        cmp     byte[ebx],0
        jz      yDone

        mov     ecx,0
        mov     edx,0
        mov     cl,byte[eax]
        sub     cl,48
        mov     dl,byte[ebx]
        sub     dl,48

        ; 两个操作数的单个字符相加
        add     ecx,edi
        mov     edi,0
        add     cl,dl
        cmp     cl,10
        jb      noCarry
        mov     edi,1
        sub     cl,10
        noCarry:
        add     cl,48
        mov     byte[esi],cl
        inc     eax
        inc     ebx
        inc     esi
        jmp     addReverseLoop

    ; 第一个操作数加完
    xDone:
        mov     dl,byte[ebx]
        cmp     dl,0
        jz      Done
        sub     dl,48

        add     edx,edi
        mov     edi,0
        cmp     edx,10
        jb      xNoCarry
        mov     edi,1
        sub     dl,10  
        xNoCarry:
        add     dl,48
        mov     byte[esi],dl
        inc     ebx
        inc     esi
        jmp     xDone

    ; 第二个操作数加完
    yDone:
        mov     cl,byte[eax]
        cmp     cl,0
        jz      Done
        sub     cl,48

        add     ecx,edi
        mov     edi,0
        cmp     ecx,10
        jb      yNoCarry
        mov     edi,1
        sub     cl,10  
        yNoCarry:
        add     cl,48
        mov     byte[esi],cl
        inc     eax
        inc     esi
        jmp     yDone

    ; 两个操作数均加完
    Done:
        cmp     edi,0
        jz      addReverseRecover
        mov     byte[esi],49
        inc     esi

    ; 翻转恢复
    addReverseRecover:
        mov     eax,addResultReverse
        call    slen
        mov     edx,eax

        mov     eax,addResultReverse
        mov     ecx,eax
        add     eax,edx
        mov     ebx,addRes
        call    reverse

    ; 删除结果前置0
    delPreZero:
        mov     ebx,addRes
        delPreZeroLoop:
            mov     eax,ebx
            call    slen
            cmp     eax,1
            jna     addFinish

            mov     dh,byte[ebx]
            cmp     dh,48
            jne     addFinish
            inc     ebx
            jmp     delPreZeroLoop

        addFinish:
            mov     eax,addResult
        addFinishLoop:
            mov     dh,byte[ebx]
            mov     byte[eax],dh
            inc     eax
            inc     ebx
            cmp     byte[ebx],0
            jne     addFinishLoop

    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax    
    ret

;---------------------------
; @Param multOp1,multOp2
; @return multResult
myMult:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi
    ; 初始化
    mov     eax,rMultOp1
    call    clean
    mov     eax,rMultOp2
    call    clean
    mov     eax, multResult
    call    clean
    mov     eax, aMultResult
    call    clean
    mov     eax, aMultResStr
    call    clean
    mov     byte[multResult],48
    mov     byte[aMultCarry],0  
    mov     byte[zeroCount],0

    ; 字符翻转
    rOp1:
        mov     eax,multOp1
        call    slen
        mov     edx,eax
        mov     eax,multOp1
        mov     ecx,eax
        add     eax,edx
        mov     ebx,rMultOp1
        call    reverse

    rOp2:
        mov     eax,multOp2
        call    slen
        mov     edx,eax
        mov     eax,multOp2
        mov     ecx,eax
        add     eax,edx
        mov     ebx,rMultOp2
        call    reverse

    mov     eax, 0
    mov     ebx, 0
    mov     esi,rMultOp2
    myMultLoop:
        mov     edi,rMultOp1
        mov     edx,aMultResStr
        mov     eax, aMultResStr
        call    clean
        mov     eax, aMultResult
        call    clean
        mov     byte[aMultCarry],0

        ; rMultOp2的一位乘rMultOp1，结果存入aMultResStr,并将恢复翻转后的结果存入aMultResult
        aMult:
            aMultLoop:
                mov     al,byte[edi]
                sub     al,48
                mov     bl,byte[esi]
                sub     bl,48
                mul     bl ;ax=al*bl
                add     al,byte[aMultCarry] ;加上进位

                ; 分解两个个位乘法的结果，结果十位数字存在aMultCarry，个位写入aMultResStr
                mov     cl, 10
                idiv    cl
                add     ah,48
                mov     byte[edx],ah
                mov     byte[aMultCarry],al

                inc     edx
                inc     edi
                cmp     byte[edi],0
                jne     aMultLoop

            ; 把最后算的个位乘法结果的进位写入到aMultResStr
            mov     cl,byte[aMultCarry]
            add     cl,48
            mov     byte[edx],cl

            ; rMultOp2的一位乘rMultOp1结果翻转
            mov     eax, aMultResStr
            call    slen
            mov     edx,eax
            mov     eax,aMultResStr
            mov     ecx,eax
            add     eax,edx
            mov     ebx,aMultResult
            call    reverse


        ; 给aMultResult后面加0
        addZero:
            mov     cl,0
            ; ebx存aMult字符串尾地址
            mov     ebx,aMultResult
            mov     eax,aMultResult
            call    slen
            add     ebx,eax
            addZeroLoop:
                cmp     cl,byte[zeroCount]
                jz      aMultAdd
                mov     byte[ebx],48
                inc     ebx
                inc     cl
                jmp     addZeroLoop

        ; 结果multResult加上aMultResult
        aMultAdd:
                mov     eax,multResult
                mov     ebx,addop1
                call    scopy
                mov     eax,aMultResult
                mov     ebx,addop2
                call    scopy
                call    myAdd
                mov     eax, addResult
                mov     ebx, multResult
                call    scopy

        ; op2移动到下一个单字符，并将加0计数加1
        op2next:
        inc     esi
        inc     byte[zeroCount]
        cmp     byte[esi],0
        jne     myMultLoop


    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret
