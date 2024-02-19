@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="-h" GOTO USAGE
REM
REM Generation d'un fichier forum
REM
call perl c:\util\forum-c.pl %1
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO Usage : forum-c (nom)... : genere un page forum pour un fichier collection
ECHO -------
ECHO.
call perl c:\util\forum-c.pl

:FIN
