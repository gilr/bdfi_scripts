@ECHO OFF

IF "%1"=="" GOTO USAGE
REM
REM Generation des pages collections d'une ou plusieurs series
REM
call perl c:\util\bibcoll.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\bibcoll.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\bibcoll.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\bibcoll.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\bibcoll.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\bibcoll.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\bibcoll.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\bibcoll.pl %8
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO BIBCOLL (nom)... : genere les pages collections pour les sigles fournis
ECHO.

:FIN
