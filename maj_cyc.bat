@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="-h" GOTO USAGE
REM
REM Generation d'une ou plusieurs pages series
REM
call perl c:\util\maj_cyc.pl -c%1
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO Usage : maj_cyc (nom)... : genere les pages series pour le fichier fourni (au format collection)
ECHO -------
ECHO.
ECHO !!! Ou utiliser le programme perl pour d'autres options :
ECHO.
call perl c:\util\maj_cyc.pl -h

:FIN
