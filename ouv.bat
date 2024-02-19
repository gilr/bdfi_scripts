@ECHO OFF

printf "ouv.bat     : generation de la base des ouvrages (ouvrage.res)   [    ]\r"
touch tmp01
del tmp01
del ouvrages.res
for %%f in (*.col) do type %%f >> tmp01
REM anciens fichiers COL
REM grep "^[#ox:=&+-/]" tmp01 >> ouvrages.res
grep "^[o:=&+-/}>]" tmp01 >> ouvrages.res
del tmp01

printf "ouv.bat     : generation de la base des ouvrages (ouvrage.res)   [ OK ]\n"
