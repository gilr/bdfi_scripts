@ECHO OFF
REM -----------------------------------------------------------
REM  blablabla
REM  blablabla
REM   --- Utilise le programme perl ctr_ix.pl
REM -----------------------------------------------------------

IF "%1"=="" GOTO USAGE
IF "%1"=="ALL" GOTO ALL
IF "%1"=="all" GOTO ALL
REM ---------------------------------------------
REM Controle pour paramŠtres fournis
REM ---------------------------------------------
call perl c:\util\ctr_ix.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\ctr_ix.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\ctr_ix.pl %3
GOTO FIN

:USAGE
REM ---------------------------------------------
REM Affichage de l'aide
REM ---------------------------------------------
ECHO.
ECHO IX_AUT (-A ; -S ; -R)... : contr“le s‚ries, anthos ou auteurs
ECHO IX_AUT ALL      : contr“le l'ensemble
ECHO.
GOTO FIN

:ALL
REM ---------------------------------------------
REM  Controle series, anthos et auteurs
REM ---------------------------------------------
call perl c:\util\ctr_ix.pl -S
call perl c:\util\ctr_ix.pl -R
call perl c:\util\ctr_ix.pl -A
:FIN
