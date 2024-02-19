@ECHO OFF
REM -----------------------------------------------------------------
REM  Creation des fichiers necessaires aux generations de pages web SAUF les auteurs
REM   o ouvrages
REM   o sigles
REM   o liste de collections
REM -----------------------------------------------------------------

call c:\util\ouv.bat
call c:\util\sigles.bat
call c:\util\listcol.bat
call c:\util\series.bat
perl c:\util\isbn.pl
call c:\util\anthos.bat

REM printf "Titres.pl : generation du fichier des titres (titres.res)\n"
perl c:\util\titres.pl

REM call compte.bat
REM ----- recopie en \data -----
REM --- supprim‚s (fait directement par les fichiers scripts)


