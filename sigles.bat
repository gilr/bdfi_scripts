@ECHO OFF
REM --------------------------------------------------------
REM  Generation du fichier des sigles editeur/collection
REM   (a partir de tous les fichiers .col)
REM --------------------------------------------------------
REM
REM  RETRAIT sur sort le 19/12 => pr‚f‚rence ordre des cols, peut aider … faire le lien sous-col <-> col

printf "sigles.bat  : generation du fichier des sigles (sigles.res)      [    ]\r"
touch tmp01
touch tmp02
del tmp01
del tmp02
del sigles.res
for %%f in (*.col) do type %%f >> tmp01

REM
REM grep "^_" tmp01 >> tmp02
REM sort tmp02 > sigles.res
REM del tmp02
REM 

grep "^_" tmp01 >> sigles.res
REM
del tmp01

printf "sigles.bat  : generation du fichier des sigles (sigles.res)      [ OK ]\n"
