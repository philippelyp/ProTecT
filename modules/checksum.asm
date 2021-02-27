;*
;*
;*  checksum.asm
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

;********** Checksum

main:                   mov               bx,cs
                        xor               cx,cx
                        mov               ds,bx
                        xchg              si,cx
                        mov               dx,ds
                        lodsw      
                        push              ax
                        mov               es,dx
                        mov               cx,ax
                        lodsw      
                        xor               dx,dx
                        push              ax
                        add               cx,ax
                        mov               di,dx
                        lodsw      
                        add               cx,ax
                        mov               bx,cs
                        lodsw      
                        mov               dx,12
                        add               cx,ax
                        lodsw      
                        cmp               cx,ax
                        jne               not_ok
                        pop               bx
                        pop               ax
                        stosw      
                        mov               ax,bx
                        stosw      
                        ret      
not_ok:                 mov               ax,dx
                        pop               cx
                        stosw      
                        mov               ax,bx
                        stosw      
                        add               di,6
                        pop               bx
                        stosw
                        ret

;********** Padding the module to 64 bytes

                        db                20 dup (13)

END
