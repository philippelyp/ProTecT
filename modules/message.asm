;*
;*
;*  message.asm
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

;********** Display an error message if we can't validate decryption

main:			mov			cx,cs
				xor			bx,bx
				mov			ax,10
				mov			ds,cx
				add			bx,ax
				xchg		si,bx
				lodsw
				cmp			ax,0
				je			ok
not_ok:			mov			ax,cs
				mov			bx,0B800h
				mov			ds,ax
				mov			es,bx
				mov			di,0
go_message:		mov			si,OFFSET message
				add			si,12
				mov			bl,13
				mov			cx,11
				mov			ah,8ch
print_message:	lodsb
				xor			al,bl
				stosw
				add			bl,al
				loop		print_message
				cmp			di,4000h
				jb			go_message
				jmp			not_ok

;********** Encrypted error message

message			db			93,47,160,110,239,168,87,249,65,40,138

;********** All good

ok:				ret

;********** Padding the module to 64 bytes

				db			8 dup (13)

END
