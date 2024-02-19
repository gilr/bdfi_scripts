@ECHO OFF
echo .
IF "%2"=="" GOTO ALL
grep %1 C:\sf\auteurs.txt
GOTO FIN

:ALL
grep %1 C:\sf\auteurs.txt

:FIN
