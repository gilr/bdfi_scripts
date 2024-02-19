@ECHO OFF

IF "%1"=="" GOTO ALL

call perl prix.pl %1 %2 %3 %4
GOTO FIN

:ALL

REM --- France
call perl prix.pl gpi
call perl prix.pl rosny
call perl prix.pl merlin
call perl prix.pl imaginales
call perl prix.pl cosmos
call perl prix.pl verlanger
call perl prix.pl apollo
call perl prix.pl infini
call perl prix.pl eiffel
call perl prix.pl ozone
call perl prix.pl graoully
call perl prix.pl verne
call perl prix.pl ray
call perl prix.pl gprsf

REM --- Belgique
call perl prix.pl morane
call perl prix.pl masterton

REM --- Canada
call perl prix.pl aurora
call perl prix.pl boreal
call perl prix.pl solaris
call perl prix.pl -a gpsffq

REM --- USA
call perl prix.pl -j hugo
call perl prix.pl -j nebula
call perl prix.pl -j wfa
call perl prix.pl -j stoker
call perl prix.pl campbell
call perl prix.pl sturgeon
call perl prix.pl sidewise
call perl prix.pl -j locus
call perl prix.pl dick
call perl prix.pl tiptree
call perl prix.pl -j ihg
call perl prix.pl ifa

REM --- GB
call perl prix.pl bsfa
call perl prix.pl bfa
call perl prix.pl clarke

REM --- Australie
call perl prix.pl ditmar
call perl prix.pl aurealis

REM --- Espagne
call perl prix.pl ignotus
call perl prix.pl upc

:FIN
