;*
;*
;*  softice.asm
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

;********** Soft-Ice detection
;           Alter decryption depending on detection

main:                   xor               ax,ax
                        mov               si,4647h
                        mov               di,4a4dh
                        int               03h
                        cmp               si,4647h
                        je                ok
                        mov               ax,cs
                        mov               bx,ax
                        mov               ds,bx
                        mov               ax,ds:[0004h]
                        add               ax,bx
                        mov               ds:[0004h],ax
                        ret
ok:                     mov               ax,cs
                        mov               bx,ax
                        mov               ds,bx
                        mov               ax,ds:[0004h]
                        sub               ax,0100h
                        mov               ds:[0004h],ax
                        ret

;********** Padding the module to 64 bytes

                        db                34 dup (13)

END
