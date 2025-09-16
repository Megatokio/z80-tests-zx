; ================================================================
;   zasm assembler source for target 'tap'
;   https://github.com/Megatokio/zasm
;   Copyright (c) kio@little-bat.de 2025
;   BSD 2-clause       
; ================================================================


; the #code segment has an additional argument: the sync byte for the block.
; The assembler calculates and appends checksum byte to each segment.


#target tap


; sync bytes:
headerflag:     equ 0
dataflag:       equ 0xff


; some Basic tokens:
tCLEAR      equ     $FD             ; token CLEAR
tLOAD       equ     $EF             ; token LOAD
tCODE       equ     $AF             ; token CODE
tPRINT      equ     $F5             ; token PRINT
tRANDOMIZE  equ     $F9             ; token RANDOMIZE
tUSR        equ     $C0             ; token USR


code_start  equ     24000


; ---------------------------------------------------
;       Basic Loader:
; ---------------------------------------------------

#code PROG_HEADER,0,17,headerflag
        defb    0                       ; Indicates a Basic program
        defb    "mloader   "            ; the block name, 10 bytes long
        defw    variables_end-0         ; length of block = length of basic program plus variables
        defw    10                      ; line number for auto-start, 0x8000 if none
        defw    program_end-0           ; length of the basic program without variables


#code PROG_DATA,0,*,dataflag

        ; ZX Spectrum Basic tokens

; 10 CLEAR 23999
        defb    0,10                    ; line number
        defb    end10-($+1)             ; line length
        defb    0                       ; statement number
        defb    tCLEAR                  ; token CLEAR
        defm    "23999",$0e0000bf5d00   ; number 23999, ascii & internal format
end10:  defb    $0d                     ; line end marker

; 20 LOAD "" CODE 24000
        defb    0,20                    ; line number
        defb    end20-($+1)             ; line length
        defb    0                       ; statement number
        defb    tLOAD,'"','"',tCODE     ; token LOAD, 2 quotes, token CODE
        defm    "24000",$0e0000c05d00   ; number 24000, ascii & internal format
end20:  defb    $0d                     ; line end marker

; 30 RANDOMIZE USR 24000
        defb    0,30                    ; line number
        defb    end30-($+1)             ; line length
        defb    0                       ; statement number
	defb	tPRINT,':'
        defb    tRANDOMIZE,tUSR         ; token RANDOMIZE, token USR
        defm    "24000",$0e0000c05d00   ; number 24000, ascii & internal format
end30:  defb    $0d                     ; line end marker

program_end:

        ; ZX Spectrum Basic variables

variables_end:



; ---------------------------------------------------
;       the machine code block:
; ---------------------------------------------------

#code CODE_HEADER,0,17,headerflag
        defb    3                       ; Indicates binary data
        defb    "mcode     "            ; the block name, 10 bytes long
        defw    code_end-code_start     ; length of data block which follows
        defw    code_start              ; default location for the data
        defw    0                       ; unused


#code CODE_DATA, code_start,*,dataflag

; Z80 assembler code and data
; ATTN: the #included independent source has a ORG statement:
;       this ORG and the origin set in the #code segment should be the same!

#include "z80typeZX.asm"

code_end:












