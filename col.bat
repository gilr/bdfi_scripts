@ECHO OFF
IF "%2"=="" GOTO ALL
grep %1 %2*.col | more
GOTO FIN

:ALL
grep %1 *.col | more

:FIN
