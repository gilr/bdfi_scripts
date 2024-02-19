@ECHO OFF
REM -----------------------------------------------------------
REM  Generation des batchs pour l'initiale fournie (tpm[lettre].bat)
REM   --- Utilise le programme perl ix_aut.pl
REM -----------------------------------------------------------

IF "%1"=="" GOTO USAGE
IF "%1"=="ALL" GOTO ALL
IF "%1"=="all" GOTO ALL
REM ---------------------------------------------
REM Generation de la page pour une lettre
REM ---------------------------------------------
call perl c:\util\ix_aut.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\ix_aut.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\ix_aut.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\ix_aut.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\ix_aut.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\ix_aut.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\ix_aut.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\ix_aut.pl %8
IF "%9"=="" GOTO FIN
call perl c:\util\ix_aut.pl %9
GOTO FIN

:USAGE
REM ---------------------------------------------
REM Affichage de l'aide
REM ---------------------------------------------
ECHO.
ECHO IX_AUT (a-z)... : g‚nŠre le(s) fichier(s) html correspondant(s)
ECHO IX_AUT ALL      : g‚nŠre tous les fichiers batchs de reg‚n‚ration des pages auteurs
ECHO.
GOTO FIN

:ALL
REM ---------------------------------------------
REM  Generation de tous les index
REM ---------------------------------------------
call perl c:\util\ix_aut.pl a
call perl c:\util\ix_aut.pl b
call perl c:\util\ix_aut.pl c
call perl c:\util\ix_aut.pl d
call perl c:\util\ix_aut.pl e
call perl c:\util\ix_aut.pl f
call perl c:\util\ix_aut.pl g
call perl c:\util\ix_aut.pl h
call perl c:\util\ix_aut.pl i
call perl c:\util\ix_aut.pl j
call perl c:\util\ix_aut.pl k
call perl c:\util\ix_aut.pl l
call perl c:\util\ix_aut.pl m
call perl c:\util\ix_aut.pl n
call perl c:\util\ix_aut.pl o
call perl c:\util\ix_aut.pl p
call perl c:\util\ix_aut.pl q
call perl c:\util\ix_aut.pl r
call perl c:\util\ix_aut.pl s
call perl c:\util\ix_aut.pl t
call perl c:\util\ix_aut.pl u
call perl c:\util\ix_aut.pl v
call perl c:\util\ix_aut.pl w
call perl c:\util\ix_aut.pl x
call perl c:\util\ix_aut.pl y
call perl c:\util\ix_aut.pl z
:FIN
