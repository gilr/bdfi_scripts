@ECHO OFF
REM -----------------------------------------------------------
REM  Generation des index alphabetiques HTML par pays
REM   --- Utilise le programme perl ix_pays.pl
REM -----------------------------------------------------------

IF "%1"=="" GOTO USAGE
IF "%1"=="ALL" GOTO ALL
REM ---------------------------------------------
REM Generation de la page pour un pays
REM ---------------------------------------------
call perl c:\util\ix_pays.pl %1
IF "%2"=="" GOTO FIN
call perl c:\util\ix_pays.pl %2
IF "%3"=="" GOTO FIN
call perl c:\util\ix_pays.pl %3
IF "%4"=="" GOTO FIN
call perl c:\util\ix_pays.pl %4
IF "%5"=="" GOTO FIN
call perl c:\util\ix_pays.pl %5
IF "%6"=="" GOTO FIN
call perl c:\util\ix_pays.pl %6
IF "%7"=="" GOTO FIN
call perl c:\util\ix_pays.pl %7
IF "%8"=="" GOTO FIN
call perl c:\util\ix_pays.pl %8
GOTO FIN

:USAGE
REM ---------------------------------------------
REM Affichage de l'aide
REM ---------------------------------------------
ECHO.
ECHO IX_PAYS [pays]... : gÇnäre le(s) fichier(s) html correspondant(s)
ECHO IX_PAYS ALL       : gÇnäre tous les fichiers html
ECHO.
GOTO FIN

:ALL
REM ---------------------------------------------
REM  Generation de tous les index
REM ---------------------------------------------
call perl c:\util\ix_pays.pl allemagne
call perl c:\util\ix_pays.pl argentine
call perl c:\util\ix_pays.pl australie
call perl c:\util\ix_pays.pl autriche
call perl c:\util\ix_pays.pl belgique
call perl c:\util\ix_pays.pl brÇsil
call perl c:\util\ix_pays.pl bulgarie
call perl c:\util\ix_pays.pl canada
call perl c:\util\ix_pays.pl chili
call perl c:\util\ix_pays.pl colombie
call perl c:\util\ix_pays.pl croatie
call perl c:\util\ix_pays.pl cuba
call perl c:\util\ix_pays.pl danemark
call perl c:\util\ix_pays.pl egypte
call perl c:\util\ix_pays.pl espagne
call perl c:\util\ix_pays.pl etats-unis
call perl c:\util\ix_pays.pl finlande
call perl c:\util\ix_pays.pl france
call perl c:\util\ix_pays.pl ghana
call perl c:\util\ix_pays.pl grece
call perl c:\util\ix_pays.pl guatemala
call perl c:\util\ix_pays.pl hongrie
call perl c:\util\ix_pays.pl inde
call perl c:\util\ix_pays.pl irlande
call perl c:\util\ix_pays.pl islande
call perl c:\util\ix_pays.pl israel
call perl c:\util\ix_pays.pl italie
call perl c:\util\ix_pays.pl jamaique
call perl c:\util\ix_pays.pl japon
call perl c:\util\ix_pays.pl kirgyzstan
call perl c:\util\ix_pays.pl lituanie
call perl c:\util\ix_pays.pl mexique
call perl c:\util\ix_pays.pl moldavie
call perl c:\util\ix_pays.pl norväge
call perl c:\util\ix_pays.pl nouvelle_zelande
call perl c:\util\ix_pays.pl pakistan
call perl c:\util\ix_pays.pl pays-bas
call perl c:\util\ix_pays.pl pologne
call perl c:\util\ix_pays.pl portugal
call perl c:\util\ix_pays.pl republique_tcheque
call perl c:\util\ix_pays.pl roumanie
call perl c:\util\ix_pays.pl royaume_uni
call perl c:\util\ix_pays.pl russie
call perl c:\util\ix_pays.pl serbie
call perl c:\util\ix_pays.pl suäde
call perl c:\util\ix_pays.pl suisse
call perl c:\util\ix_pays.pl tunisie
call perl c:\util\ix_pays.pl ukraine
call perl c:\util\ix_pays.pl uruguay
call perl c:\util\ix_pays.pl yougoslavie
:FIN
