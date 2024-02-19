@ECHO OFF

IF "%1"=="" GOTO USAGE
REM
REM Generation des biblios pour une ou plusieurs initiales
REM
call perl c:\util\biblio.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\biblio.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\biblio.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\biblio.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\biblio.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\biblio.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\biblio.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\biblio.pl %8
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO BIBLIO (nom)... : genere les biblios pour les noms fournis
ECHO.

:FIN
