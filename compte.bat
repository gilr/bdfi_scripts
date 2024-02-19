REM ---------------------------------------------------------
REM  o filtre sur romans et nouvelles
REM  o filtre sur ouvrages possedes
REM  o tri par auteur, date, titre, type de ouvrages.res
REM  o tri par titre des nouvelles et romans
REM ---------------------------------------------------------
REM Appeler OUV.BAT avant

wc ouvrages.res

grep " N " ouvrages.res > lis_nouv.res
grep " r " ouvrages.res >> lis_nouv.res
grep " f " ouvrages.res >> lis_nouv.res
grep " R " ouvrages.res > lis_rom.res
grep " F " ouvrages.res >> lis_rom.res
grep " S " ouvrages.res >> lis_rom.res
grep " V " ouvrages.res >> lis_rom.res
grep " [ipvgock_ ]U[x1-9] " ouvrages.res >> lis_rom.res
grep " [ipvgock_ ][rCRNA][x1-9] " ouvrages.res > lis_rec.res
grep " [ipvgock_ ][rCRNA][1-9][0-9] " ouvrages.res >> lis_rec.res
grep " [ipvgock_ ]R[1-9]N[0-9] " ouvrages.res >> lis_rec.res
grep " [ipvgock_ ][rR]N[1-9] " ouvrages.res >> lis_rec.res
grep " [ipvgock_ ][rR]N[1-9][0-9] " ouvrages.res >> lis_rec.res
grep " [ick_ ]M[x0-9] " ouvrages.res > lis_mag.res
grep " [ick_ ]M[1-9][0-9] " ouvrages.res >> lis_mag.res
grep " E " ouvrages.res > lis_ess.res
grep " G " ouvrages.res >> lis_ess.res
grep " b " ouvrages.res >> lis_ess.res
grep " [ipvgock_ ]E[x1-9] " ouvrages.res >> lis_ess.res
grep " [ipvgock_ ]G[x1-9] " ouvrages.res >> lis_ess.res
grep " [ipvgock_ ]E[1-9][0-9] " ouvrages.res >> lis_ess.res
grep " [ipvgock_ ]G[1-9][0-9] " ouvrages.res >> lis_ess.res

grep " R\.\.\.\. " ouvrages.res > jai.res

REM ATTENTION
REM     utile pour d‚tecter des erreurs
REM           pour compl‚ter des infos
REM mais sans plus (les infos collaborations, recueils, ... sont ‚parpill‚es)
REM A REVOIR (supprimer les lignes inutiles, modifier les champs)
c:\cygwin64\bin\sort +0.18  ouvrages.res > tri_aut.res
c:\cygwin64\bin\sort +0.12  ouvrages.res > tri_date.res
c:\cygwin64\bin\sort +0.44  ouvrages.res > tri_titr.res
c:\cygwin64\bin\sort +0.17  ouvrages.res > tri_type.res
c:\cygwin64\bin\sort +0.44  lis_nouv.res > tri_nouv.res
c:\cygwin64\bin\sort +0.44  lis_rom.res > tri_rom.res
c:\cygwin64\bin\sort +0.44  lis_rec.res > tri_rec.res
c:\cygwin64\bin\sort +0.44  lis_mag.res > tri_mag.res
c:\cygwin64\bin\sort +0.44  lis_ess.res > tri_ess.res

c:\cygwin64\bin\sort +0.21 jai.res > jai_tri.res

wc -l auteurs.res
wc -l series.res
wc -l ouvrages.res
grep "^[:=-]" ouvrages.res | wc -l 
REM grep "^[-:=]" ouvrages.res | wc -l
wc -l tri_rom.res tri_nouv.res tri_rec.res tri_mag.res tri_ess.res
