@ECHO OFF

printf "listcol.bat : generation des listes de collections (listcol.res) [    ]\r"
touch tmp01
del tmp01
del listcol.res
REM ls -1 *.col >> tmp01
dir /B /L *.col >> tmp01
sort tmp01 > listcol.res
del tmp01

printf "listcol.bat : generation des listes de collections (listcol.res) [ OK ]\n"
