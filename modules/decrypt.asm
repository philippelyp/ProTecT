;*
;*
;*  decrypt.asm
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

;********** Decrypt a number of paragraphs
;           How many paragraphs is passed on the stack

main:				mov			ax,csv
				mov			ds,ax
				mov			bx,ds:[0006h]
				push			bx
				mov			bx,ds:[0004h]
				mov			dx,bx
				sub			ax,bx
				mov			ds,ax
				mov			es,ax
				pop			bx
decrypt_0:			mov			cx,8
				mov			di,0
				mov			si,0
decrypt_1:			lodsw
				xor			ax,bx
				add			bx,ax
				stosw
				loop			decrypt_1
				dec			dx
				jz			ok
				mov			ax,ds
				inc			ax
				mov			ds,ax
				mov			ax,es
				inc			ax
				mov			es,ax
				jmp			decrypt_0
ok:				ret

;********** Padding the module to 64 bytes

				db			25 dup (13)
END
