echo on

rem blancs en trop ou absents
rem recherche des doubles blancs avant �
pause
grep "  �" *.col | more
pause
rem absence d'espace avant �
pause
grep "[a-zA-Z0-9]�" *.col | more

pause
rem recherche des dates vo invalides
pause
grep " �0" *.col | more
pause
grep " �[3-9]" *.col | more
pause
grep " �1[0-6]" *.col | more
pause
grep " �2[1-9]" *.col | more
pause
grep " �[0-9][0-9][0-9][0-9][a-zA-Z0-9]" *.col | more

pause
grep "�[a-z]" *.col | more
pause
grep " �[B-SU-Z]" *.col | more

rem "recherche des espaces en fin de ligne"
pause
grep "�.* $" *.col | more

rem recherche d'erreurs classiques sur certains mots
echo "<space> pour chercher (fantome)"
pause
grep " [Ff]antome" *.col | more
echo "<space> pour chercher (ile)"
pause
grep "[ ']ile[ $s]" *.col | more
echo "<space> pour chercher (hotel)"
pause
grep " [Hh]otel.*�" *.col | more
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
echo "<space> pour chercher (t�n�breux/se)"
pause
grep "[Tt]�n�breu" *.col | more
echo "<space> pour chercher (z�bre)"
pause
grep " [Zz]�bre" *.col | more
echo "<space> pour chercher (jour ou)"
pause
grep " jour ou" *.col | more
echo "<space> pour chercher (bucher)"
pause
grep " [Bb]ucher" *.col | more
echo "<space> pour chercher (bapt�me)"
pause
grep " [Bb]apt�me" *.col | more

echo "<space> pour chercher les espaces avant (?) dans titre anglais"
pause
grep "�.*[A-Za-z] ?" *.col | more

echo "<space> pour chercher les espaces avant (?) dans titre anglais"
pause
grep "�.*[A-Za-z] !" *.col | more
