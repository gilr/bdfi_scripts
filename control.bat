echo on

rem blancs en trop ou absents
rem recherche des doubles blancs avant þ
pause
grep "  þ" *.col | more
pause
rem absence d'espace avant þ
pause
grep "[a-zA-Z0-9]þ" *.col | more

pause
rem recherche des dates vo invalides
pause
grep " þ0" *.col | more
pause
grep " þ[3-9]" *.col | more
pause
grep " þ1[0-6]" *.col | more
pause
grep " þ2[1-9]" *.col | more
pause
grep " þ[0-9][0-9][0-9][0-9][a-zA-Z0-9]" *.col | more

pause
grep "þ[a-z]" *.col | more
pause
grep " þ[B-SU-Z]" *.col | more

rem "recherche des espaces en fin de ligne"
pause
grep "þ.* $" *.col | more

rem recherche d'erreurs classiques sur certains mots
echo "<space> pour chercher (fantome)"
pause
grep " [Ff]antome" *.col | more
echo "<space> pour chercher (ile)"
pause
grep "[ ']ile[ $s]" *.col | more
echo "<space> pour chercher (hotel)"
pause
grep " [Hh]otel.*þ" *.col | more
echo "<space> pour chercher (abime)"
pause
grep " [Aa]bime" *.col | more
echo "<space> pour chercher (maitre)"
pause
grep " [Mm]aitre" *.col | more
echo "<space> pour chercher (votre)"
pause
grep " [Vv]otre" *.col | more
echo "<space> pour chercher (chaine)"
pause
grep " [Cc]haine" *.col | more
echo "<space> pour chercher (chateau)"
pause
grep " [Cc]hateau" *.col | more
echo "<space> pour chercher (boite)"
pause
grep " [Bb]oite" *.col | more
echo "<space> pour chercher (crane)"
pause
grep " [Cc]rane" *.col | more
echo "<space> pour chercher (t‚nŠbreux/se)"
pause
grep "[Tt]‚nŠbreu" *.col | more
echo "<space> pour chercher (z‚bre)"
pause
grep " [Zz]‚bre" *.col | more
echo "<space> pour chercher (jour ou)"
pause
grep " jour ou" *.col | more
echo "<space> pour chercher (bucher)"
pause
grep " [Bb]ucher" *.col | more
echo "<space> pour chercher (baptŠme)"
pause
grep " [Bb]aptŠme" *.col | more

echo "<space> pour chercher les espaces avant (?) dans titre anglais"
pause
grep "þ.*[A-Za-z] ?" *.col | more

echo "<space> pour chercher les espaces avant (?) dans titre anglais"
pause
grep "þ.*[A-Za-z] !" *.col | more
