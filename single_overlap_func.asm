; Binary Code Obfuscation Sample
; [Overlapping functions and basic blocks] (single instruction)
; written by Oga
; 2015/12/12
;
; Environment:
;   Windows7 SP1
;   NASM version 2.11.08
;   Microsoft Incremental Linker Version 14.00.23026.0 (Bundled with Visual Studio 2015)
;
; Usage:
;   nasm -fwin32 overlap_func.asm
;   link overlap_func.obj /ENTRY:start /SUBSYSTEM:CONSOLE /defaultlib:kernel32.lib
;   
;   After a build, you have to edit the generated binary.
;   Replace 'B9 EB 0F 90 C3 08' to 'B9 EB 0F 90 EB 08'.
;

  global _start

  extern  _GetStdHandle@4
  extern  _WriteFile@20
  extern  _ExitProcess@4

  section .text

print_msg:
  mov   ebp, esp
  sub   esp, 4

  push  -11
  call  _GetStdHandle@4
  mov   ebx, eax

  push  0
  lea   eax, [ebp - 4]
  push  eax
  push  (message_end - message)
  push  message
  push  ebx
  call  _WriteFile@20

  push  0
  call  _ExitProcess@4

  ; Never reach here
  ret

_start:
  mov   eax, 0xebb907eb
  seto  bl
  or    ch, bh
  jmp   $+0x9
  mov   eax, 0xebbbbbbb
  jmp   $+0x8
  or    ch, bh
  or    ch, bh
  jmp   $-0x10

  call  print_msg
    
  ; never reach here
  hlt

message:
  db      'Hello, World', 10
message_end:
