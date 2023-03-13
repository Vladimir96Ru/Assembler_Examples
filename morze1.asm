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
point_delay     dd      100       ; ������������ ����� "�����" 
dash_delay      dd      300       ; ������������ ����� "����" 
point db '*', NULL
dash  db '-', NULL
space db ' ', NULL
morse   label   byte            ; ������� �������������� �������� � ��� ����� (1 - �����, 2 - ����)
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
 
tab_length      dd      $ - offset morse        ; ����� ������� � ������ - ������� �������� ����� ����� ������ �������
 
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
   LOCAL hOutPut          :DWORD ;����� ��� ������
   LOCAL nWriten          :DWORD ;���������� ����
 
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov hOutPut, eax
 
_loop:
 call wait_key
 cmp     eax, 27         ; ESC ?
 jz      EXIT            ; ���� �� - �������
 cmp     eax, ' '
 jz      _space
 lea     edi, morse               ; ��������� ����� ������� � ������� di
 mov     ecx, tab_length ; ������ �������
 repne   scasb           ; ���� � ������� ������ ��������� � ����������
 jnz     _loop           ; ������ �� ������
 mov     esi, edi        ; si = di - ������� � ������� ��������� �������
_out_morseCode:
        invoke   Sleep, point_delay
        lodsb                   ; ��������� ����� �� �������
        cmp     al, 1           ; ����� 1?
        jz      _point          ; ������ ������� �����
        cmp     al, 2           ; 2?
        jz      _dash           ; ������� ����
        or      al, al          ; 0?
        jz      _loop           ; ����� �� ����� ������
        jmp     _loop           ; �� ��� ������ �������� ������ ���� ���� ������ � �������
_point:
        
        invoke WriteConsole, hOutPut, addr point, 1, addr nWriten,NULL
        mov     edx, point_delay ; ������������� ����� ��������������� �����
        invoke   Beep, 1000, point_delay ; �����
        jmp     _out_morseCode  ; �� ��������� ������ � �������
_dash:
        invoke WriteConsole, hOutPut, addr dash, 1, addr nWriten,NULL
 
        mov     edx, dash_delay  ;  ����� ��� ����
        invoke   Beep, 1000, dash_delay ; ������
        jmp     _out_morseCode  ; �� ��������� ������ � �������
_space:
        invoke WriteConsole, hOutPut, addr space, 1, addr nWriten,NULL
        jmp     _loop
 
EXIT:
invoke Sleep, 20
invoke ExitProcess,0
 
Main endp
end Main