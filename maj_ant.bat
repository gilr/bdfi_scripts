@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="-h" GOTO USAGE
REM
REM Generation d'une ou plusieurs pages anthos/recueils
REM
call perl c:\util\maj_ant.pl -c%1
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO Usage : maj_ant (nom)... : genere les pages anthos/recueils pour le fichier fourni (au format collection)
ECHO -------
ECHO.
ECHO !!! Ou utiliser le programme perl pour d'autres options :
ECHO.
call perl c:\util\maj_ant.pl -h

:FIN
