@ECHO OFF

IF "%1"=="" GOTO USAGE
IF "%1"=="ALL" GOTO ALL
IF "%1"=="all" GOTO ALL
REM
REM Generation des biblios pour une ou plusieurs initiales
REM
call  batchs\BIB_%1.BAT
IF "%2"=="" GOTO FIN
call  batchs\BIB_%2.BAT
IF "%3"=="" GOTO FIN
call  batchs\BIB_%3.BAT
IF "%4"=="" GOTO FIN
call  batchs\BIB_%4.BAT
IF "%5"=="" GOTO FIN
call  batchs\BIB_%5.BAT
IF "%6"=="" GOTO FIN
call  batchs\BIB_%6.BAT
IF "%7"=="" GOTO FIN
call  batchs\BIB_%7.BAT
IF "%8"=="" GOTO FIN
call  batchs\BIB_%8.BAT
IF "%9"=="" GOTO FIN
call  batchs\BIB_%9.BAT
GOTO FIN

:USAGE
REM
REM Affichage de l'aide
REM
ECHO.
ECHO GENERE (a-z)... : genere les biblios pour la liste d'initiale (bib_x.bat)
ECHO GENERE ALL      : genere toutes les biblios (träs long, plus de  10 heures)
ECHO.
GOTO FIN

:ALL
REM
REM Toutes les biblios
REM
goto DEBUT

:DEBUT
call batchs\BIB_A.BAT
call batchs\BIB_B.BAT
call batchs\BIB_C.BAT
call batchs\BIB_D.BAT
call batchs\BIB_E.BAT
call batchs\BIB_F.BAT
call batchs\BIB_G.BAT
call batchs\BIB_H.BAT
call batchs\BIB_I.BAT
call batchs\BIB_J.BAT
call batchs\BIB_K.BAT
call batchs\BIB_L.BAT
call batchs\BIB_M.BAT
call batchs\BIB_N.BAT
call batchs\BIB_O.BAT
call batchs\BIB_P.BAT
call batchs\BIB_Q.BAT
call batchs\BIB_R.BAT
call batchs\BIB_S.BAT
call batchs\BIB_T.BAT
call batchs\BIB_U.BAT
call batchs\BIB_V.BAT
call batchs\BIB_W.BAT
call batchs\BIB_Y.BAT
call batchs\BIB_Z.BAT

goto FIN
:FIN
