;*
;*
;*  unp.asm
;*
;*  Copyright 1995 Philippe Paquet
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
.8086

;********** UNP detection
;           Alter decryption depending on detection

main:                   mov               ax,45F6h
                        push              ax
                        pop               ax
                        dec               sp
                        dec               sp
                        pop               bx
                        cmp               ax,bx
                        jne               not_ok
                        mov               ax,cs
                        mov               ds,ax
                        mov               ax,ds:[0000h]
                        sub               ax,0030h
                        mov               ds:[0000h],ax
                        ret
not_ok:                 mov               ax,cs
                        mov               ds,ax
                        mov               ax,ds:[0000h]
                        add               ax,bx
                        mov               ds:[0000h],ax
                        ret

;********** Padding the module to 64 bytes

                        db               41 dup (13)

END
