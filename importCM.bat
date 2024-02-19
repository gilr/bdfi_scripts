@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="-h" GOTO USAGE
REM
REM Import du nouveau format de fichier de Christian
REM
call perl c:\util\importCM.pl %1
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO Usage : importCM (nom)... : importe un fichier collection au format CSV <nom>.txt dans un format maison <nom>.pgm
ECHO -------
ECHO.
call perl c:\util\importCM.pl

:FIN
