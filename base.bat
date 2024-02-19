@ECHO OFF
REM -----------------------------------------------------------------
REM  Creation des fichiers necessaires aux generations de pages web
REM   o ouvrages
REM   o sigles
REM   o auteurs
REM   o liste de collections
REM -----------------------------------------------------------------

call c:\util\ouv.bat
call c:\util\sigles.bat
call c:\util\listcol.bat
perl c:\util\auteurs.pl
perl c:\util\extaut.pl
call c:\util\series.bat
perl c:\util\isbn.pl
call c:\util\anthos.bat
call c:\util\mank_som.bat
call c:\util\mank_vo.bat

REM printf "Titres.pl : generation du fichier des titres (titres.res)\n"
perl c:\util\titres.pl

REM call compte.bat
REM ----- recopie en \data -----
REM --- supprim‚s (fait directement par les fichiers scripts)

cp auteurs.sfs e:\laragon\www\bdfi\data\auteurs.sfs

