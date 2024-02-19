@ECHO OFF

IF "%1"=="" GOTO USAGE
REM
REM Generation des pages anthos/recueils pour une ou plusieurs initiales
REM
call perl c:\util\allantho.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\allantho.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\allantho.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\allantho.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\allantho.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\allantho.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\allantho.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\allantho.pl %8
IF "%9"=="" GOTO FIN
call perl c:\util\allantho.pl %9
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO ALLANTHO (lettre)... : genere les pages recueils pour les initiales fournies
ECHO                        0 pour les anthos d‚butant par 0 … 9
ECHO.

:FIN
