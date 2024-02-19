@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="-h" GOTO USAGE
REM
REM Generation d'une ou plusieurs pages biblio, series et recueils
REM
call perl c:\util\maj_bib.pl -c%1
call perl c:\util\maj_cyc.pl -c%1
call perl c:\util\maj_ant.pl -c%1
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO Usage : maj_all (nom)... : genere les pages biblio, series et anthos pour le fichier fourni (au format collection)
ECHO -------
ECHO.

:FIN
