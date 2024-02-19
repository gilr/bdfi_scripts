@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="-h" GOTO USAGE
REM
REM Appel Sublime text
REM
START /B "C:\Program Files\Sublime Text 3\sublime_text" %1&
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO Usage : sublime (nom) : ouvre dans une fenˆtre Sublime Text 3
ECHO.

:FIN
