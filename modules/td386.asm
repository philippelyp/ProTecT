;*
;*
;*  td386.asm
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

;********** Turbo Debugger 386 detection
;           Alter decryption depending on detection

main:				xor			ax,ax
				mov			ds,ax
				mov			ax,ds:[0002h]
				mov			bx,ds:[0086h]
				cmp			ax,bx
				jne			ok
				mov			cx,ds:[008ah]
				cmp			bx,cx
				jne			ok
				mov			ax,cs
				mov			bx,ax
				mov			ds,bx
				mov			ax,ds:[0006h]
				add			ax,bx
				mov			ds:[0006h],ax
				ret
ok:				mov			ax,cs
				mov			bx,ax
				mov			ds,bx
				mov			ax,ds:[0006h]
				sub			ax,0100h
				mov			ds:[0006h],ax
				ret

;********** Padding the module to 64 bytes

				db			26 dup (13)

END
