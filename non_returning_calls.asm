  global _start

  extern  _GetStdHandle@4
  extern  _WriteFile@20
  extern  _ExitProcess@4

  section .text

not_ret_func1:
  mov     eax, 10
  pop     eax
  ret

not_ret_func2:
  mov     eax, 20
  ret

not_returned:
  mov     ebp, esp
  sub     esp, 4
  push    0
  lea     eax, [ebp - 4]
  push    eax
  push    (not_return_msg_end - not_return_msg)
  push    not_return_msg
  push    ebx
  call    _WriteFile@20
  call    exit
  ret

nothing_to_do_func:
  ret

exit:
  ; ExitProcess(0)
  push    0
  call    _ExitProcess@4
  ret

main:
  ; DWORD bytes;
  ; index variable;
  mov     ebp, esp
  sub     esp, 4
  mov     dword [ebp - 8], 0

  ; DWORD bytes;
  ;  <- prepare local variable
  sub     esp,  4

  ; prepare for non-returning calls
  push    not_returned
  push    not_ret_func2

  ; hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)
  ;       (STD_OUTPUT_HANDLE = -11)
  push    -11
  call    _GetStdHandle@4
  mov     ebx, eax

loop:
  ; show 'Hello, World'
  ; WriteFile( hStdOut, msg, length(msg), &size, 0)
  push    0
  lea     eax, [ebp - 4]
  push    eax
  push    (message_end - message)
  push    message
  push    ebx
  call    _WriteFile@20

  call    not_ret_func1

  ; Never execute below
dumy:
  db      'Hello, World', 10
dumy_end:

  ; i += 1
  mov     eax, dword [ebp - 8]
  add     eax, 1
  mov     dword [ebp - 8], eax

  ; jmp loop if i < 0x20
  cmp     dword [ebp - 8],  0x20
  jl      loop
  
  call    exit
  ; never here
  hlt

; Entry point
_start:
  call main

message:
  db      'Hello, World', 10
message_end:

not_return_msg:
  db      'Not Returning', 10
not_return_msg_end:
