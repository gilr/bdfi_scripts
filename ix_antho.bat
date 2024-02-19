@ECHO OFF
REM -----------------------------------------------------------
REM  Generation des index alphabetiques HTML (page [lettre].htm)
REM   ainsi que les batchs pour cette initiale (tpm[lettre].bat)
REM   --- Utilise le programme perl ix_antho.pl
REM -----------------------------------------------------------

IF "%1"=="" GOTO USAGE
IF "%1"=="ALL" GOTO ALL
IF "%1"=="all" GOTO ALL
REM ---------------------------------------------
REM Generation de la page pour une lettre
REM ---------------------------------------------
call perl c:\util\ix_antho.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\ix_antho.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\ix_antho.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\ix_antho.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\ix_antho.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\ix_antho.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\ix_antho.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\ix_antho.pl %8
GOTO FIN

:USAGE
REM ---------------------------------------------
REM Affichage de l'aide
REM ---------------------------------------------
ECHO.
ECHO IX_ANTHO (a-z ! 0)... : g‚nŠre le(s) fichier(s) html correspondant(s)
ECHO IX_ANTHO ALL      : g‚nŠre tous les fichiers html
ECHO.
GOTO FIN

:ALL
REM ---------------------------------------------
REM  Generation de tous les index
REM ---------------------------------------------
call perl c:\util\ix_antho.pl 0
call perl c:\util\ix_antho.pl a
call perl c:\util\ix_antho.pl b
call perl c:\util\ix_antho.pl c
call perl c:\util\ix_antho.pl d
call perl c:\util\ix_antho.pl e
call perl c:\util\ix_antho.pl f
call perl c:\util\ix_antho.pl g
call perl c:\util\ix_antho.pl h
call perl c:\util\ix_antho.pl i
call perl c:\util\ix_antho.pl j
call perl c:\util\ix_antho.pl k
call perl c:\util\ix_antho.pl l
call perl c:\util\ix_antho.pl m
call perl c:\util\ix_antho.pl n
call perl c:\util\ix_antho.pl o
call perl c:\util\ix_antho.pl p
call perl c:\util\ix_antho.pl q
call perl c:\util\ix_antho.pl r
call perl c:\util\ix_antho.pl s
call perl c:\util\ix_antho.pl t
call perl c:\util\ix_antho.pl u
call perl c:\util\ix_antho.pl v
call perl c:\util\ix_antho.pl w
call perl c:\util\ix_antho.pl x
call perl c:\util\ix_antho.pl y
call perl c:\util\ix_antho.pl z
:FIN
