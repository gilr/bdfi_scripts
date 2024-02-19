@ECHO OFF

IF "%1"=="" GOTO USAGE
REM
REM Generation des pages series/cycles pour une ou plusieurs initiales
REM
call perl c:\util\allserie.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\allserie.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\allserie.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\allserie.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\allserie.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\allserie.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\allserie.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\allserie.pl %8
IF "%9"=="" GOTO FIN
call perl c:\util\allserie.pl %9
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO ALLSERIE (lettre)... : genere les pages series/cycles pour les initiales donn‚es
ECHO                        0 pour les series d‚butant par 0 … 9
ECHO.

:FIN
