  global _start

  extern  _GetStdHandle@4
  extern  _WriteFile@20
  extern  _ExitProcess@4

  section .text

call_stack_tamper1:
  push    call_stack_tamper2

  mov     ebp, esp
  sub     esp, 4
  push    ecx
  push    0
  lea     eax, [ebp - 4]
  push    eax
  push    (tamper_now1_end - tamper_now1)
  push    tamper_now1
  push    ebx
  call    _WriteFile@20
  pop     ecx
  add     esp, 4
  ret

call_stack_tamper2:
  add     ecx, 0x50
  add     ecx, 0xD5
  push    ecx
  ret

hello:
  ; Not Execute this insn
  mov     ebp, esp
  ; Function starts from this insn(hello + 2)
  mov     ebp, esp

  ; print message
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

  ; Obfuscate constants(use for call-stack-tampering
  mov     ecx, hello + 2
  sub     ecx, 0x100
  sub     ecx, 0x025

  ; hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)
  ;       (STD_OUTPUT_HANDLE = -11)
  push    -11
  call    _GetStdHandle@4
  mov     ebx, eax

  call    call_stack_tamper1
  ; Never return below

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

tamper_now1:
  db      'Tamper Now1...', 10
tamper_now1_end:
