{***************************************************************************}
{*                                                                         *}
{*  ProTecT v2.5                                                           *}
{*                                                                         *}
{*  Copyright 1995-1996 Philippe Paquet                                    *}
{*                                                                         *}
{*  This program is free software: you can redistribute it and/or modify   *}
{*  it under the terms of the GNU General Public License as published by   *}
{*  the Free Software Foundation, either version 3 of the License, or      *}
{*  (at your option) any later version.                                    *}
{*                                                                         *}
{*  This program is distributed in the hope that it will be useful,        *}
{*  but WITHOUT ANY WARRANTY; without even the implied warranty of         *}
{*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *}
{*  GNU General Public License for more details.                           *}
{*                                                                         *}
{*  You should have received a copy of the GNU General Public License      *}
{*  along with this program.  If not, see <http://www.gnu.org/licenses/>.  *}
{*                                                                         *}
{***************************************************************************}

PROGRAM ProTecT;





USES crt,dos;





TYPE     header_exe=RECORD
                                        signature:                                   word;
                                        longueur_mod_512:                            word;
                                        longueur_div_512:                            word;
                                        nombre_adresses:                             word;
                                        taille_header:                               word;
                                        nombre_mini_paragraphes:                     word;
                                        nombre_maxi_paragraphes:                     word;
                                        contenu_ss:                                  word;
                                        contenu_sp:                                  word;
                                        checksum:                                    word;
                                        contenu_ip:                                  word;
                                        contenu_cs:                                  word;
                                        adresse_table_relogement:                    word;
                                        numero_overlay:                              word;
                                        vide:                        ARRAY [0..3] OF byte;
                                        END;





CONST    taille_link=1363;
                 offset_entree=92;

                 message:                                         STRING [36]=
                 char ($0d)+'ProTecT v2.5 by Philippe Paquet'+char ($1a);





VAR      file_in,file_out:                                       FILE;
                 buffer:                             ARRAY [0..16383] OF word;
                 lu:                                                     word;

                 nom_fichier:                                          STRING;
                 password:                                             STRING;
                 header_fichier:                                   header_exe;
                 taille_fichier:                                      longint;
                 nombre_segments_fichier:                                word;
                 overlay_fichier:                                     boolean;
                 modulo_16:                                              byte;

                 repertoire:                                           dirstr;
                 nom:                                                 namestr;
                 extension:                                            extstr;

                 a,b,c:                                                  word;

                 cle:                                                    word;

                 demande_message:                                      STRING;





PROCEDURE protect_link; EXTERNAL; {$L STUB.OBJ}





BEGIN {* ------------------------------------------------------------------ *}



{* banner *}
writeln;
writeln ('ProTecT v2.5   Copyright 1995-1996 Philippe Paquet');
writeln;
delay (1000);


{* verification de la syntaxe *}
IF (paramcount=0) OR (paramcount>2) THEN
        BEGIN
        writeln ('The ultimate ExE protector - This program is FreeWare');
        writeln;
        writeln ('For any comment : ppaquet@asi.fr');
        writeln ('                  ppaquet@pcmedia.fr');
        writeln;
        writeln ('ProTecT home page : http://www.asi.fr/~ppaquet');
        writeln ('                    http://www.pcmedia.fr/~ppaquet');
        writeln;
        writeln ('Syntax: ProTecT [-m] file');
        halt (0);
        END;
IF (paramcount=2) AND ((paramstr (1)<>'-m') AND (paramstr (1)<>'-M')) THEN
        BEGIN
        writeln ('The ultimate ExE protector - This program is FreeWare');
        writeln;
        writeln ('For any comment : ppaquet@asi.fr');
        writeln ('                  ppaquet@pcmedia.fr');
        writeln;
        writeln ('ProTecT home page : http://www.asi.fr/~ppaquet');
        writeln ('                    http://www.pcmedia.fr/~ppaquet');
        writeln;
        writeln ('Syntax: ProTecT [-m] file');
        halt (0);
        END;


{* complement du nom *}
IF (paramcount=2) THEN nom_fichier:=paramstr (2) ELSE nom_fichier:=paramstr (1);
FOR a:=1 TO length (nom_fichier) DO nom_fichier [a]:=upcase (nom_fichier [a]);
fsplit (nom_fichier,repertoire,nom,extension);
IF extension='' THEN nom_fichier:=nom_fichier+'.EXE';


{* teste l'existance du fichier *}
filemode:=0;
assign (file_in,nom_fichier);
reset (file_in,1);
IF ioresult<>0 THEN
        BEGIN
        writeln ('Unable to find ',nom_fichier,'.');
        halt (0);
        END;


{* lit le header *}
blockread (file_in,header_fichier,32);
seek (file_in,0);
IF ioresult<>0 THEN
        BEGIN
        writeln ('Read error.');
        close (file_in);
        halt (0);
        END;


{* verifie qu'il s'agit d'un executable *}
IF (header_fichier.signature<>$5A4D) AND (header_fichier.signature<>$4D5A) THEN
        BEGIN
        writeln ('Not a valid program.');
        close (file_in);
        halt (0);
        END;


{* verifie qu'il n'y a pas de table de relocation *}
IF header_fichier.nombre_adresses>0 THEN
        BEGIN
        writeln ('Please, compact your program with LZEXE.');
        close (file_in);
        halt (0);
        END;


{* verifie qu'il n'y a pas de message dans la table de relocation *}
IF header_fichier.taille_header>2 THEN
        BEGIN
        writeln ('Not a valid program.');
        close (file_in);
        halt (0);
        END;


{* demande de message *}
IF (paramcount=2) THEN
        BEGIN
        REPEAT
                write ('Signature message : ');
                readln (demande_message);
        UNTIL length (demande_message)<35;
        IF length (demande_message)>0 THEN
                BEGIN
                IF length (demande_message)<34 THEN FOR a:=length (demande_message) TO 33 DO demande_message:=demande_message+' ';
                message:=char ($0d)+demande_message+char ($1a);
                END;
        END;


{* protection *}
writeln;
writeln ('Protection of ',nom_fichier,' in progress ...');


{* calcul la taille *}
IF header_fichier.longueur_mod_512=0 THEN taille_fichier:=longint (header_fichier.longueur_div_512)*512
ELSE taille_fichier:=(longint (header_fichier.longueur_div_512)*512)+longint (header_fichier.longueur_mod_512)-512;


{* taille invalide *}
IF filesize (file_in)<taille_fichier THEN
        BEGIN
        writeln ('Not a valid program.');
        close (file_in);
        halt (0);
        END;


{* teste des overlays *}
IF filesize (file_in)>taille_fichier THEN
        BEGIN
        writeln ('This program may contain an overlay.');
        overlay_fichier:=true;
        END
ELSE overlay_fichier:=false;


{* calcul du nombre de segments *}
nombre_segments_fichier:=(taille_fichier-(header_fichier.taille_header*16)) DIV 16;


{* calcul de la nouvelle taille *}
IF (taille_fichier MOD 16<>0) THEN
            BEGIN
            modulo_16:=(((taille_fichier DIV 16)+1)*16)-taille_fichier;
            taille_fichier:=((taille_fichier DIV 16)+1)*16;
            inc (nombre_segments_fichier);
            END
ELSE modulo_16:=0;
IF (paramcount=2) THEN taille_fichier:=taille_fichier+taille_link+32 ELSE taille_fichier:=taille_fichier+taille_link;
IF (taille_fichier MOD 512)=0 THEN
        BEGIN
        header_fichier.longueur_div_512:=taille_fichier DIV 512;
        header_fichier.longueur_mod_512:=taille_fichier MOD 512;
        END
ELSE
        BEGIN
        header_fichier.longueur_div_512:=(taille_fichier DIV 512)+1;
        header_fichier.longueur_mod_512:=taille_fichier MOD 512;
        END;


{* mise a jour des tailles memoires *}
IF header_fichier.nombre_mini_paragraphes<65446 THEN inc (header_fichier.nombre_mini_paragraphes,(taille_link DIV 16)+1);
IF header_fichier.nombre_maxi_paragraphes<65446 THEN inc (header_fichier.nombre_maxi_paragraphes,(taille_link DIV 16)+1);


{* mise a jour des registres *}
memw [seg (protect_link):ofs (protect_link)+2]:=(nombre_segments_fichier-header_fichier.contenu_cs);
header_fichier.contenu_cs:=nombre_segments_fichier;
memw [seg (protect_link):ofs (protect_link)]:=header_fichier.contenu_ip;
header_fichier.contenu_ip:=offset_entree;
IF (taille_link MOD 16)=0 THEN header_fichier.contenu_ss:=header_fichier.contenu_ss+(taille_link DIV 16)
ELSE header_fichier.contenu_ss:=header_fichier.contenu_ss+(taille_link DIV 16)+1;

{* mise a jour du nombre de segments a d‚chiffrer *}
memw [seg (protect_link):ofs (protect_link)+4]:=nombre_segments_fichier;

{* tirage de la cl‚ au hazard *}
randomize;
b:=random ($FFFF);
memw [seg (protect_link):ofs (protect_link)+6]:=b;

{* recalcul de mauvaises valeur et mise en place du checksum *}
memw [seg (protect_link):ofs (protect_link)+8]:=memw [seg (protect_link):ofs (protect_link)]
                                                                                                +memw [seg (protect_link):ofs (protect_link)+2]
                                                                                                +memw [seg (protect_link):ofs (protect_link)+4]
                                                                                                +memw [seg (protect_link):ofs (protect_link)+6];
memw [seg (protect_link):ofs (protect_link)]:=memw [seg (protect_link):ofs (protect_link)]+$255;
memw [seg (protect_link):ofs (protect_link)+2]:=memw [seg (protect_link):ofs (protect_link)+2]+$100;
memw [seg (protect_link):ofs (protect_link)+4]:=memw [seg (protect_link):ofs (protect_link)+4]+$200;
memw [seg (protect_link):ofs (protect_link)+6]:=memw [seg (protect_link):ofs (protect_link)+6]+$100;

{* nouvelle taille du header pour le message *}
IF (paramcount=2) THEN header_fichier.taille_header:=header_fichier.taille_header+2;

{* ecriture du fichier *}
assign (file_out,'PROTECT.$$$');
filemode:=2;
rewrite (file_out,1);
IF ioresult<>0 THEN
         BEGIN
         writeln ('Write error.');
         close (file_in);
         halt (0);
         END;
blockread (file_in,buffer,32);
IF ioresult<>0 THEN
         BEGIN
         writeln ('Read error.');
         close (file_in);
         close (file_out);
         halt (0);
         END;
IF (paramcount=2) THEN
         BEGIN
         blockwrite (file_out,buffer,28);
         IF ioresult<>0 THEN
                    BEGIN
                    writeln ('Write error.');
                    close (file_in);
                    close (file_out);
                    halt (0);
                    END;
         blockwrite (file_out,message [1],36);
         IF ioresult<>0 THEN
                    BEGIN
                    writeln ('Read error.');
                    close (file_in);
                    close (file_out);
                    halt (0);
                    END;
         END
ELSE
         BEGIN
         blockwrite (file_out,buffer,32);
         IF ioresult<>0 THEN
                    BEGIN
                    writeln ('Write error.');
                    close (file_in);
                    close (file_out);
                    halt (0);
                    END;
         END;
IF (paramcount=2) THEN
         BEGIN
         FOR c:=1 TO (taille_fichier-taille_link-modulo_16-64) DIV 32768 DO
                 BEGIN
                 blockread (file_in,buffer,32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Read error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 FOR a:=0 TO 16383 DO
                         BEGIN
                         buffer [a]:=buffer [a] XOR b;
                         b:=b+(buffer [a] XOR b);
                         END;
                 blockwrite (file_out,buffer,32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Write error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 END;
         IF ((taille_fichier-taille_link-modulo_16-64) MOD 32768)>0 THEN
                 BEGIN
                 blockread (file_in,buffer,(taille_fichier-taille_link-modulo_16-64) MOD 32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Read error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 FOR a:=0 TO 16383 DO
                         BEGIN
                         buffer [a]:=buffer [a] XOR b;
                         b:=b+(buffer [a] XOR b);
                         END;
                 blockwrite (file_out,buffer,(taille_fichier-taille_link-modulo_16-64) MOD 32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Write error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 END;
         END
ELSE
         BEGIN
         FOR c:=1 TO (taille_fichier-taille_link-modulo_16-32) DIV 32768 DO
                 BEGIN
                 blockread (file_in,buffer,32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Read error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 FOR a:=0 TO 16383 DO
                         BEGIN
                         buffer [a]:=buffer [a] XOR b;
                         b:=b+(buffer [a] XOR b);
                         END;
                 blockwrite (file_out,buffer,32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Write error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 END;
         IF ((taille_fichier-taille_link-modulo_16-32) MOD 32768)>0 THEN
                 BEGIN
                 blockread (file_in,buffer,(taille_fichier-taille_link-modulo_16-32) MOD 32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Read error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 FOR a:=0 TO 16383 DO
                         BEGIN
                         buffer [a]:=buffer [a] XOR b;
                         b:=b+(buffer [a] XOR b);
                         END;
                 blockwrite (file_out,buffer,(taille_fichier-taille_link-modulo_16-32) MOD 32768);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Write error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 END;
         END;
IF modulo_16>0 THEN
        BEGIN
        blockwrite (file_out,buffer,modulo_16);
        IF ioresult<>0 THEN
                 BEGIN
                 writeln ('Write error.');
                 close (file_in);
                 close (file_out);
                 halt (0);
                 END;
        END;


{* ecriture de la protection *}
blockwrite (file_out,@protect_link^,taille_link);
IF ioresult<>0 THEN
        BEGIN
        writeln ('Write error.');
        close (file_in);
        close (file_out);
        halt (0);
        END;


{* ecriture de l'overlay *}
IF overlay_fichier THEN
        BEGIN
        REPEAT
                 blockread (file_in,buffer,32768,lu);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Read error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
                 blockwrite (file_out,buffer,lu);
                 IF ioresult<>0 THEN
                            BEGIN
                            writeln ('Write error.');
                            close (file_in);
                            close (file_out);
                            halt (0);
                            END;
        UNTIL lu=0;
        END;


{* ecriture du header *}
seek (file_out,0);
blockwrite (file_out,header_fichier,28);
IF ioresult<>0 THEN
         BEGIN
         writeln ('Write error.');
         close (file_in);
         close (file_out);
         halt (0);
         END;


{* fermeture des fichiers *}
close (file_in);
close (file_out);


{* fermeture des fichiers *}
erase (file_in);
rename (file_out,nom_fichier);
IF ioresult<>0 THEN
        BEGIN
        writeln ('Write error.');
        halt (0);
        END;


{* fin de la protection *}
writeln ('Program protected.');
END.