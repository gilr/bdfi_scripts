@ECHO OFF

IF "%1"=="" GOTO USAGE
REM
REM Generation d'une ou plusieurs pages anthos/recueils
REM
call perl c:\util\bibantho.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\bibantho.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\bibantho.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\bibantho.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\bibantho.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\bibantho.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\bibantho.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\bibantho.pl %8
IF "%9"=="" GOTO FIN
call perl c:\util\bibantho.pl %9
IF "%10"=="" GOTO FIN
call perl c:\util\bibantho.pl %10
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO BIBANTHO (nom)... : genere les pages anthos/recueils pour les noms fournis
ECHO.

:FIN
