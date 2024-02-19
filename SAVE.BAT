ECHO Sauvegarde rep MSC
e:
cd \msc
i:
cd \msc
xcopy e: i: /M /S

ECHO Sauvegarde rep UTIL
c:
cd \util
i:
cd \util
xcopy c: i: /M /S

ECHO Sauvegarde rep PERSO
i:
cd \perso
e:
cd \perso
xcopy e: i: /M /S 

ECHO Sauvegarde rep PERSO
i:
cd \sf
e:
cd \sf
xcopy e: i: /M /S 
