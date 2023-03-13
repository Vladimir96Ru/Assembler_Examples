 .386
      .model flat, stdcall
      option casemap :none   ; case sensitive
 
      include \masm32\include\windows.inc
      include \masm32\macros\macros.asm
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\msvcrt.inc
 
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\msvcrt.lib
 
 
.data
point_delay     dd      100       ; длительность звука "точка" 
dash_delay      dd      300       ; длительность звука "тире" 
point db '*', NULL
dash  db '-', NULL
space db ' ', NULL
morse   label   byte            ; таблица преобразования символов в код морзе (1 - точка, 2 - тире)
        db      'a', 1, 2, 0
        db      'b', 2, 1, 1, 1, 0
        db      'c', 2, 1, 2, 1, 0
        db      'd', 2, 1, 1, 0
        db      'e', 1, 0
        db      'f', 1, 1, 2, 1, 0
        db      'g', 2, 2, 1, 0
        db      'h', 1, 1, 1, 1, 0
        db      'i', 1, 1, 0
        db      'j', 1, 2, 2, 2, 0
        db      'k', 2, 1, 2, 0
        db      'l', 1, 2, 1, 1, 0
        db      'm', 2, 2, 0
        db      'n', 2, 1, 0
        db      'o', 2, 2, 2, 0
        db      'p', 1, 2, 2, 1, 0
        db      'q', 2, 2, 1, 2, 0
        db      'r', 1, 2, 1, 0
        db      's', 1, 1, 1, 0
        db      't', 2, 0
        db      'u', 1, 1, 2, 0
        db      'v', 1, 1, 1, 2, 0
        db      'w', 1, 2, 2, 0
        db      'x', 2, 1, 1, 2, 0
        db      'y', 2, 1, 2, 2, 0
        db      'z', 2, 2, 1, 1, 0
 
        db      '1', 1, 2, 2, 2, 2, 0
        db      '2', 1, 1, 2, 2, 2, 0
        db      '3', 1, 1, 1, 2, 2, 0
        db      '4', 1, 1, 1, 1, 2, 0
        db      '5', 1, 1, 1, 1, 1, 0
        db      '6', 2, 1, 1, 1, 1, 0
        db      '7', 2, 2, 1, 1, 1, 0
        db      '8', 2, 2, 2, 1, 1, 0
        db      '9', 2, 2, 2, 2, 1, 0
        db      '0', 2, 2, 2, 2, 2, 0
 
tab_length      dd      $ - offset morse        ; длина таблицы в байтах - текущее смещение минус адрес начала таблицы
 
.code
 
wait_key proc
    invoke FlushConsoleInputBuffer, rv(GetStdHandle,STD_INPUT_HANDLE)
  @@:
    call crt__kbhit
    test eax, eax
    jz @B
    call crt__getch
    ret
wait_key endp
 
 Main proc
   LOCAL hOutPut          :DWORD ;хэндл для вывода
   LOCAL nWriten          :DWORD ;напечатано байт
 
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov hOutPut, eax
 
_loop:
 call wait_key
 cmp     eax, 27         ; ESC ?
 jz      EXIT            ; если да - выходим
 cmp     eax, ' '
 jz      _space
 lea     edi, morse               ; çàãðóæàåì àäðåñ òàáëèöû â ðåãèñòð di
 mov     ecx, tab_length ; ðàçìåð òàáëèöû
 repne   scasb           ; èùåì â òàáëèöå ñèìâîë íàáðàííûé ñ êëàâèàòóðû
 jnz     _loop           ; ñèìâîë íå íàéäåí
 mov     esi, edi        ; si = di - ïîçèöèÿ â òàáëèöå íàéäåíîãî ñèìâîëà
_out_morseCode:
        invoke   Sleep, point_delay
        lodsb                   ; çàãðóæàåì öèôðó èç òàáëèöû
        cmp     al, 1           ; öèôðà 1?
        jz      _point          ; çíà÷èò âûâîäèì òî÷êó
        cmp     al, 2           ; 2?
        jz      _dash           ; âûâîäèì òèðå
        or      al, al          ; 0?
        jz      _loop           ; äîøëè äî êîíöà ñòðîêè
        jmp     _loop           ; íà ýòó ñòðîêó ïåðåéäåì òîëüêî åñëè åñòü îøèáêà â òàáëèöå
_point:
        
        invoke WriteConsole, hOutPut, addr point, 1, addr nWriten,NULL
        mov     edx, point_delay ; óñòàíàâëèâàåì ïàóçó ñîîòâåòñòâóþùóþ òî÷êå
        invoke   Beep, 1000, point_delay ; ïèùèì
        jmp     _out_morseCode  ; íà ñëåäóþùèé ñèìâîë â òàáëèöå
_dash:
        invoke WriteConsole, hOutPut, addr dash, 1, addr nWriten,NULL
 
        mov     edx, dash_delay  ;  ïàóçà äëÿ òèðå
        invoke   Beep, 1000, dash_delay ; çâó÷èì
        jmp     _out_morseCode  ; íà ñëåäóþùèé ñèìâîë â òàáëèöå
_space:
        invoke WriteConsole, hOutPut, addr space, 1, addr nWriten,NULL
        jmp     _loop
 
EXIT:
invoke Sleep, 20
invoke ExitProcess,0
 
Main endp
end Main
