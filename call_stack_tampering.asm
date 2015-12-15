  global _start

  extern  _GetStdHandle@4
  extern  _WriteFile@20
  extern  _ExitProcess@4

  section .text

call_stack_tamper1:
  push    hello
  push    call_stack_tamper2
  mov     ebp, esp
  sub     esp, 4
  push    0
  lea     eax, [ebp - 4]
  push    eax
  push    (tamper_now_end - tamper_now)
  push    tamper_now
  push    ebx
  call    _WriteFile@20
  add     esp, 4
  ret

call_stack_tamper2:
  ret

hello:
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
  ;  <- prepare local variable
  mov     ebp, esp
  sub     esp,  4

  ; hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)
  ;       (STD_OUTPUT_HANDLE = -11)
  push    -11
  call    _GetStdHandle@4
  mov     ebx, eax

  call    call_stack_tamper1

  ; show 'Hello, World'
  ; WriteFile( hStdOut, msg, length(msg), &size, 0)
  push    0
  lea     eax, [ebp - 4]
  push    eax
  push    (message_end - message)
  push    message
  push    ebx
  call    _WriteFile@20

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
  db      'Call Stack Tampered', 10
not_return_msg_end:

tamper_now:
  db      'Tamper Now...', 10
tamper_now_end:
