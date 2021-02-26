;*
;*
;*  stub.asm
;*
;*  Copyright 1995-1996 Philippe Paquet
;*
;*  This program is free software: you can redistribute it and/or modify
;*  it under the terms of the GNU General Public License as published by
;*  the Free Software Foundation, either version 3 of the License, or
;*  (at your option) any later version.
;*
;*  This program is distributed in the hope that it will be useful,
;*  but WITHOUT ANY WARRANTY; without even the implied warranty of
;*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;*  GNU General Public License for more details.
;*
;*  You should have received a copy of the GNU General Public License
;*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;*
;*

.MODEL SMALL

.CODE
.386

program                 dd                0
paragraphs              dw                0
key                     dw                0
                        dw                0 ; Checksum of the 3 parameters
                        dw                0 ; Flag SI if the checksum is invalid

;********** decryption buffer with the encrypted Intruder detection module already in place

buffer:                 db                62,128,142,86,199,129,141,6,6,178,186,52,144,171
                        db                88,51,118,166,54,67,138,97,68,136,249,116,109,60
                        db                3,122,125,8,231,170,137,132,107,6,231,123,75,192
                        db                14,32,231,182,184,184,187,120,221,33,33,226,104
                        db                184,179,27,21,242,165,165,165,136,210,211,112,118
                        db                118,181,52,75,94,109,96,119,138,153,172,163


main:                   jmp               install_backrun

tracer_on               dw                0
save_int1_off           dw                03f8eh
save_int1_seg           dw                0ff8eh
save_ax                 dw                0fe8eh
tracer_off              dw                03f8eh
tracer_seg              dw                0fe8eh

;********** encrypted module

go_soft_ice:            mov               si,OFFSET soft_ice
                        ret

soft_ice                db                62,128,190,249,67,244,71,29,109,236,16,171,117
                        db                13,226,112,64,219,3,61,154,189,185,193,194,7,36
                        db                46,46,237,125,181,206,8,38,237,176,182,182,155
                        db                227,226,71,131,139,72,67,86,101,120,143,130,145
                        db                164,187,206,221,208,231,250,9,28,19,38,53,72,95
                        db                82,97,116,139,158,173,160,183,202,217,236,227
                        db                246

;********** backrun installation

install_backrun:        push              es ; save ds,es
                        push              ds

;********** put the stack in the middle of the code

                        mov               dx,cs
                        mov               bx,OFFSET smoke_stack+6
                        mov               ax,ss
                        mov               ss,dx
                        xchg              bx,sp
                        mov               dx,ax

;********** garbage

                        cmp               dx,0
                        jne               install_backrun_2+2
                        rep lock test     DWORD PTR es:[0ACE0ACEh],0CACACACAh
                        int               13

;********** backrun installation continued

install_backrun_2:      mov               ax,0fa00h ; cli hidden inside a mov
                        mov               ax,cs
                        xor               cx,cx
                        mov               ds,ax
install_backrun_3:      jmp               install_backrun_3+3
                        mov               di,0c18eh ; mov es,cx hidden inside a mov
                        mov               ax,es:[4]
                        mov               cx,es:[6]
                        mov               save_int1_off,ax
                        mov               di,4
                        mov               save_int1_seg,cx
                        mov               ax,OFFSET tracer
                        mov               cx,cs
                        mov               si,OFFSET tracer_off
                        mov               tracer_off,ax
                        mov               ds,cx
                        mov               tracer_seg,cx
                        mov               cx,2
                        rep movsw
                        sti

;********** remove stack from the middle of the code

                        xchg              bx,sp
                        mov               ss,dx

                        pushf             ; trace mode
                        pop               ax
                        xor               ax,0000000100000000b
                        push              ax
                        popf

                        pop               ds ; restore ds,es
                        pop               es
                        jmp               main_next

;********** encrypted module

go_areplay:             mov               si,OFFSET areplay
                        ret

areplay                 db                62,128,142,86,199,69,73,194,202,178,50,188,24,19
                        db                208,187,254,156,207,154,127,210,17,111,65,232,7
                        db                138,233,154,130,207,32,178,2,25,197,123,88,255
                        db                255,255,252,193,102,104,104,171,167,127,244,210
                        db                108,171,234,236,236,193,25,24,185,189,189,126
                        db                141,128,151,170,185,204,195,214,229,248,15,2,17
                        db                36,59,78

;********** backrun tracer

tracer:                 cmp               tracer_on,0
                        je                end_tracer
                        cmp               tracer_on,1
                        je                tracer_regular
                        dec               tracer_on ; first instruction
                        mov               save_ax,ax
                        pop               ax
                        sub               ax,10
                        push              ax
                        mov               ax,save_ax
                        iret
tracer_regular:         mov               save_ax,ax ; 'regular' backrun
                        pop               ax
                        sub               ax,6
                        push              ax
                        mov               ax,save_ax
end_tracer:             iret

;********** encrypted module

go_tdebug:              mov               si,OFFSET tdebug
                        ret

tdebug                  db                62,128,142,86,199,1,13,134,134,144,220,231,212
                        db                175,88,237,255,121,133,190,25,236,1,145,97,250
                        db                36,90,185,156,220,224,227,32,5,75,75,136,130,82
                        db                233,53,75,136,143,205,209,252,254,255,92,160,164
                        db                103,106,121,140,131,150,165,184,207,194,209,228
                        db                251,14,29,16,39,58,73,92,83,102,117,136,159,146
                        db                161

;********** enable backrun, save registers, decrypt and execute modules

main_next_2:            mov               tracer_on,0
                        jmp               main_end
                        jmp               main_next_2+6
                        int               3
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              ax
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              dx
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              cx
                        mov               ax,OFFSET go_areplay
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              bx
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              ax
                        mov               dx,OFFSET go_unp
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              dx
                        mov               cx,OFFSET go_tdebug
                        jmp               $+8
                        push              si
                        mov               bx,OFFSET go_game_wizard
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              cx
                        mov               ax,OFFSET go_soft_ice
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              ax
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              bx
                        mov               cx,OFFSET go_tdebug_386
                        jmp               $+8
                        push              si
                        mov               bx,OFFSET go_message
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              bx
                        jmp               $+8
                        push              si
                        jmp               $+8
                        push              di
                        jmp               $+8
                        push              cx
                        jmp               $+8
                        push              es
                        mov               dx,OFFSET go_qa
                        mov               ax,OFFSET go_checksum
                        jmp               $+8
                        push              ds
                        mov               bx,OFFSET go_decrypt
                        mov               di,OFFSET buffer
                        mov               cx,OFFSET next
                        mov               si,OFFSET exec
main_next:              mov               tracer_on,2

;********** remove tracer

main_end:               pushf             ; mode trace
                        pop               ax
                        xor               ax,0000000100000000b
                        push              ax
                        popf

                        xor               cx,cx ; restore int 1
                        mov               es,cx
                        add               cx,4
                        mov               bx,cs
                        mov               di,cx
                        mov               ax,OFFSET save_int1_off
                        mov               ds,bx
                        mov               cx,2
                        mov               si,ax
                        rep movsw

;********** execute encrypted modules

                        mov               si,OFFSET buffer
                        ret

;********** compute entry point and restore registers

next:                   mov               ax,cs
                        pop               es
                        mov               bx,WORD PTR program+2
                        sub               ax,bx
smoke_stack:            pop               ds
                        mov               WORD PTR program+2,ax

;********** jump to the entry point

                        jmp               [program]

;********** decrypt and execute a module

exec:                   mov               ax,cs
                        mov               bl,217
                        mov               ds,ax
                        mov               di,OFFSET int_3
                        mov               es,ax
                        sub               bl,ds:[di]
                        mov               di,OFFSET buffer
                        mov               cx,80
exec_0:                 lodsb
                        xor               al,bl
                        add               bl,al
                        stosb
int_3:                  int               03h
                        loop              exec_0
                        ret

;********** encrypted modules

go_message:             mov               si,OFFSET message
                        ret

message                 db                129,80,81,78,200,34,50,188,25,154,68,243,8,67
                        db                166,216,216,172,120,12,196,111,143,55,201,13,35
                        db                248,65,189,189,3,71,183,52,252,12,191,178,117
                        db                142,144,36,200,124,78,109,218,30,198,20,32,81
                        db                174,80,16,226,231,12,5,244,41,149,187,172,154
                        db                141,200,107,67,25,222,237,224,247,10,25,44,35,54

go_qa:                  mov               si,OFFSET qa
                        ret

qa                      db                62,128,142,86,237,1,88,101,153,52,205,41,100,248
                        db                196,226,97,112,71,43,3,214,56,30,212,173,47,19
                        db                219,110,136,142,69,28,154,159,52,196,173,66,208
                        db                32,59,227,157,122,221,25,33,34,231,68,142,142,77
                        db                179,227,143,71,220,58,52,147,130,192,200,229,245
                        db                244,85,157,157,94,109,96,119,138,153,172,163

go_unp:                 mov               si,OFFSET unp
                        ret

unp                     db                181,51,254,80,8,228,184,27,160,21,236,0,144,96
                        db                254,38,119,119,119,90,148,212,119,119,119,180
                        db                182,14,0,196,85,149,149,150,91,248,254,254,61
                        db                204,195,214,229,248,15,2,17,36,59,78,93,80,103
                        db                122,137,156,147,166,181,200,223,210,225,244,11
                        db                30,45,32,55,74,89,108,99,118,133,152,175,162
                        db                177,196

go_checksum:            mov               si,OFFSET checksum
                        ret

checksum:               db                129,82,87,94,238,53,78,161,205,23,10,4,42,240,127
                        db                183,234,199,245,169,74,132,159,101,52,69,129,157
                        db                86,197,175,195,219,216,22,11,104,70,35,204,137
                        db                117,46,187,120,213,234,103,181,96,57,182,11,32
                        db                181,126,134,221,74,79,66,81,100,123,142,157,144
                        db                167,186,201,220,211,230,245,8,31,18,33,52,75

go_tdebug_386:          mov               si,OFFSET tdebug_386
                        ret

tdebug_386              db                62,128,142,86,199,5,9,130,138,52,56,3,176,67,188
                        db                73,67,209,229,222,249,140,97,241,193,90,132,186
                        db                25,60,56,68,71,132,169,171,179,112,250,202,65,141
                        db                163,96,55,49,61,16,106,107,200,8,20,215,218,233
                        db                252,243,6,21,40,63,50,65,84,107,126,141,128,151
                        db                170,185,204,195,214,229,248,15,2,17

go_game_wizard:         mov               si,OFFSET game_wizard
                        ret

game_wizard             db                62,128,142,86,199,197,200,241,3,73,77,57,227,216
                        db                24,106,114,6,250,57,59,225,229,145,79,84,172,54
                        db                54,66,186,54,142,133,65,255,36,123,123,123,86,141
                        db                205,110,112,112,179,191,119,12,202,100,163,242
                        db                244,244,247,52,25,93,93,158,45,32,55,74,89,108
                        db                99,118,133,152,175,162,177,196,219,238,253,240

go_decrypt:             mov               si,OFFSET decrypt
                        ret

decrypt                 db                129,81,239,55,76,76,118,118,37,66,74,118,118,253
                        db                210,255,60,76,136,166,118,45,104,130,146,45,81,81
                        db                239,15,15,162,143,44,177,109,38,218,226,88,40,220
                        db                80,176,0,14,214,106,178,114,252,192,43,75,72,67
                        db                86,101,120,143,130,145,164,187,206,221,208,231
                        db                250,9,28,19,38,53,72,95,82,97,116,139

END
