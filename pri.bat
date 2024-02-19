@ECHO OFF
IF "%2"=="" GOTO ALL
grep %1 s:\newsf\%2*.pri | more
GOTO FIN

:ALL
grep %1 s:\newsf\*.pri | more

:FIN
