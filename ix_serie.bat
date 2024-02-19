@ECHO OFF
REM -----------------------------------------------------------
REM  Generation des index alphabetiques HTML (page [lettre].htm)
REM   ainsi que les batchs pour cette initiale (tpm[lettre].bat)
REM   --- Utilise le programme perl ix_serie.pl
REM -----------------------------------------------------------

IF "%1"=="" GOTO USAGE
IF "%1"=="ALL" GOTO ALL
IF "%1"=="all" GOTO ALL
REM ---------------------------------------------
REM Generation de la page pour une lettre
REM ---------------------------------------------
call perl c:\util\ix_serie.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\ix_serie.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\ix_serie.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\ix_serie.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\ix_serie.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\ix_serie.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\ix_serie.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\ix_serie.pl %8
GOTO FIN

:USAGE
REM ---------------------------------------------
REM Affichage de l'aide
REM ---------------------------------------------
ECHO.
ECHO IX_SERIE (a-z ! 0)... : g‚nŠre le(s) fichier(s) html correspondant(s)
ECHO IX_SERIE ALL      : g‚nŠre tous les fichiers html
ECHO.
GOTO FIN

:ALL
REM ---------------------------------------------
REM  Generation de tous les index
REM ---------------------------------------------
call perl c:\util\ix_serie.pl 0
call perl c:\util\ix_serie.pl a
call perl c:\util\ix_serie.pl b
call perl c:\util\ix_serie.pl c
call perl c:\util\ix_serie.pl d
call perl c:\util\ix_serie.pl e
call perl c:\util\ix_serie.pl f
call perl c:\util\ix_serie.pl g
call perl c:\util\ix_serie.pl h
call perl c:\util\ix_serie.pl i
call perl c:\util\ix_serie.pl j
call perl c:\util\ix_serie.pl k
call perl c:\util\ix_serie.pl l
call perl c:\util\ix_serie.pl m
call perl c:\util\ix_serie.pl n
call perl c:\util\ix_serie.pl o
call perl c:\util\ix_serie.pl p
call perl c:\util\ix_serie.pl q
call perl c:\util\ix_serie.pl r
call perl c:\util\ix_serie.pl s
call perl c:\util\ix_serie.pl t
call perl c:\util\ix_serie.pl u
call perl c:\util\ix_serie.pl v
call perl c:\util\ix_serie.pl w
call perl c:\util\ix_serie.pl x
call perl c:\util\ix_serie.pl y
call perl c:\util\ix_serie.pl z
:FIN
