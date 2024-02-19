#---------------------------------------------------------------------------
# Ouvrir le fichier des titres en lecture
#---------------------------------------------------------------------------

$file="titres.res";
open (f_titres, "<$file");
@titres=<f_titres>;
close (f_titres);

#---------------------------------------------------------------------------
# ouvrir un fichier de sotie en ecriture
#---------------------------------------------------------------------------
$new_file="adjtri.res";
open (NEWTRI, ">$new_file");
$new_file="adjuniq.res";
open (NEWUNIQ, ">$new_file");

open (AVANTFR, ">avantfr.res");
open (APRESFR, ">apresfr.res");


@listearticle = ("la", "le", "les", "l'");

@liste=();
@titresseul=();

foreach $ligne (@titres)
{
   $nbligne++;
   $ligne=~s/\n$//g;

   ($titre, $auteur) = split (/\t/, $ligne);
   $ligne = $titre;

#  print "Traite : $ligne\n";

   $pcar = substr($ligne, 0, 1);
   if ($pcar eq '"') {
      $ligne = substr($ligne, 1);
   }

   $pcar = substr($ligne, 0, 1);
   if (($pcar ne '(') && ($pcar ne '+') && ($pcar ne '{') && ($pcar ne '[') && (index($ligne, '*') == -1)) {
      @listemots = split (/ |'/, $ligne);

      $prem = lc($listemots[0]);

      if ($prem eq '...')
      {
         shift @listemots;
         $prem = lc($listemots[0]);
      }
      if (($#listemots > 2) && (grep (/^$prem$/, @listearticle))) {
#        print "Retenu : [$#listemots] [$prem] : $ligne\n";
#        print "Retenu [" . $listemots[1] . "]\n";
         push @liste, ucfirst($listemots[1]);


         ($debut, $cycle) = split (/ \[/, $ligne);
         push @titresseul, $debut;
      }
   }
}

@tri = sort @liste;

my %hash = map {$_, 1} @tri;
my @unique = keys %hash;
my @unique2 = sort @unique;

foreach $ligne (@tri) {
   print NEWTRI $ligne . "\n";
}
foreach $ligne (@unique2) {
   print NEWUNIQ $ligne . "\n";
}


@trititres = sort @titresseul;

my %hash = map {$_, 1} @trititres;
my @unique = keys %hash;
my @unique2 = sort @unique;

foreach $ligne (@unique2) {
   print AVANTFR $ligne . "\n";
   $ligne =  traite_fr ($ligne);
   print APRESFR $ligne . "\n";
}







sub traite_fr {
   my $pattern = $_[0];

   #
   # http://monsu.desiderio.free.fr/atelier/captitre.html
   #

   # Si la premiŠre lettre est une minuscule, faire warning + sortir
   #
   $prem = substr($pattern, 0, 1);
   if (($prem ge 'a') && ($prem le 'z'))
   {
      print "WARNING : premier car minuscule $pattern\n";
      return $pattern;
   }
#  @listemots = split (/ |'/, $pattern);
   @listemots = split ("[ ']", $pattern);

   @listeverbes = ("'ai", "as", "a", "avons", "avez", "ont", "avais", "avait", "n'ont", "n'avait", "n'avaient", "n'a",
                   "suis", "es", "est", "sommes", "ˆtes", "sont", "‚tait", "‚taient", 
                   "lŠve", "lŠvera", "tourne", "tournent-elles", "finiront", "sauvera", "contre-attaque", "justifie",
                   "reviennent", "vient", "fait", "chante", "pleurent", "reviendra", "existe-t-elle", "s'invitent", "existent",
                   "c'est",  "s'arrˆteront", "s'ouvrait" , "reconnaŒtrez", "s'est", "tombe", "n'aura", "n'est", "aura-t-elle",
                   "marchait", "l'emporte", "peut", "surgit", "j'adore", "‚teignent", "attaquent", "envieront", "trompent",
                   "meurent", "aiment", "continue", "continuent", "poussent", "souviennent", "vengent", "penche", "ramassent",
                   "joue", "nourissent", "marre", "r‚volte", "cachent", "refroidit", "mit", "posa", "casse", "bougent", "venge", "se porte",
                   "noie", "cr‚ent", "meurt", "rebiffe", "voyagent", "mourront", "viennent", "vinrent", "vieillissent", "rient", "sut",
		   "sonnent", "sonne", "mettent", "voit", "voient", "rˆvent-ils", "rˆvent", "retourne",
		   "n'arrange", "n'existe", "bouge", "s'arrˆte", "m'attarde", "va", "coule", "vit", "hante",
		   "commence", "commencent", "commencera", "commen‡ait"
           );

   # si on ajoute "fait", il faut enlever "qui fait",  "qui a fait", "qu'il fait"
   #  g‚n‚raliser avec les autres verbes...
   # "attaque" … checker... (plus souvent le mot que le verbe)
   # Attention … "l'une rˆve..." / "Le vent souffle"
   # "Le travail bien fait"


   # ATTENTION, ne gŠre pas complŠtement les titres qui sont des phrases !
   #  --> "dans ce cas l…, seule la premiŠre lettre de la pharase est une majuscule"
   #  Si la pharase contient un verbe 
   #  " ont " - " a " - " est " ...
   #  Si le d‚but est "La ", "Le ", "Les ", "L'" et que la lettre suivante est majscule, warning
   #   --> sortir
   #
   foreach $verbe (@listeverbes) {
      if ((index ($pattern, " $verbe ") != -1) ||
          (index ($pattern, " $verbe,") != -1) ||
          ((index ($pattern, " $verbe") != - 1)  &&
           (index ($pattern, " $verbe") == length($pattern) - length($verbe) - 1))) {
#  print "DBG titre : $pattern \n";
#  print "DBG index $verbe " . index ($pattern, " $verbe ") . "\n";
#  print "DBG index $verbe en fin " . index ($pattern, " $verbe") . " == " . (length($verbe) - 1) . "\n";
         # si en plus le mot deux commence par une majuscule, faire un warning
         if ($#listemots > 0) {
            $premmot2 = substr($listemots[1], 0, 1);
            if (($premmot2 ge 'A') && ($premmot2 le 'Z')) {
               print "WARNING : titre avec verbe et mot 2 en majuscule : $pattern\n";
            }
         }
         # on arrˆte tout... sauf s'il s'agit de la forme "qui <verbe> ..."
         #
         if ((index ($pattern, "qui $verbe ") == -1) &&
             (index ($pattern, "qui a $verbe ") == -1) &&
             (index ($pattern, "Le jour o— ") == -1) &&
             (index ($pattern, "L… o— ") == -1))
             {
                return $pattern;
             }
      }
   }

   @listeadjectifs = ("DixiŠme", "DerniŠre", "DerniŠres", "Dernier", "Derniers", "Grande", "Grandes", "Grand", "Grands",
           "Petite", "Petites", "Petit", "Petits", "12", "5", "7", "Jeune", "Jeunes", "Nobles", "SeptiŠme", "Secondes",
           "Deux", "Trois", "Quatre", "Cinq", "Six", "Sept", "Huit", "Neuf", "Dix", 
           "Premier", "PremiŠre", "DeuxiŠme", "DeuxiŠmes", "DouziŠme", 
	   "40", "42210", "24", "81", "500", "56", "1001",
           "‚trange", "‚tranges", "Nouvel", "Nouvelle", "Nouvelles", "Subtil", "Subtile", "CinquiŠme", "Haut", "Haute",
           "NeuviŠme", "Nouveau", "Nouveaux", "10iŠme", "Vieux", "Vieille", "Vieilles", "Folle", "Prochain", "Prochaine", "Inutile",
           "Ultime", "‚trange", "Abominable", "Infernale", "Affreux", "Affreuse", "Autre", "Hallucinant", "Heureux", "Heureuse", "Horrible", "Interminable",
           "Invincible", "Invisible", "‚ternel", "‚tonnant", "‚tonnante", "‚trange", "Bonne", "Merveilleux", "Merveilleuse",
           "Myst‚rieux", "Myst‚rieuse", "12", "13", "20", "200", "3", "4", "7", "100", "Bon", "Meilleur", "Meilleurs", "Meilleure", "Meilleures",
           "Terrible", "Seconde", "Formidable", "Verte", "Long", "Si", "Beau", "Beaux", "Belle", "Belles", "M‚chant", "M‚chants", "M‚chante", "M‚chantes",
           "Gentil", "Gentils", "Gentille", "Gentilles", "Singulier", "Lamentable", "Lamentables", "Plus", "Vrai", "Vraie", "Insolite", "Insolites",
           "Prudent", "Prudents", "Prudente", "Prudentes", "Imprudent", "Imprudents", "Imprudente", "Imprudentes", "Immortel", "Immortelle",
           "MilliŠme", "CentiŠme", "Probable", "Probables", "Improbable", "Improbables", "Inconcevable", "Affolant", "Affolants", "Affolante", "Affolantes",
           "V‚ritable", "V‚ritables", "Incroyable", "Incroyables", "Effroyable", "Effroyables", "Mauvais", "Mauvaise", "Mauvaises"
   );
   # peut pas : fantastique... (la... est OK, mais le... est un nom)

   # Si le d‚but est "La ", "Le ", "Les ", "L'"
   $prem2 = substr($pattern, 0, 2);
   $prem3 = substr($pattern, 0, 3);
   $prem4 = substr($pattern, 0, 4);
   if (($prem2 eq "L'") ||
       ($prem3 eq "Le ") ||
       ($prem3 eq "La ") ||
       ($prem4 eq "Les "))
   {
      # Alors majuscule MAJ sur le mot qui suit
      $listemots[1] = ucfirst($listemots[1]);

      # Si le mot contient "-", la lettre aprŠs le "-" doit ˆtre en majuscule
      $postiret = index($listemots[1], '-');
      if ($postiret != -1) {
         substr($listemots[1], $postiret + 1, 1) = uc(substr($listemots[1], $postiret + 1, 1));
      }

      if (grep (/^$listemots[1]$/, @listeadjectifs)) {
         # et si ce premier mot est un adjectif,
         #  Majuscule MAJ sur le mot suivant
         #  ... sauf si petit mot et, du, de... ; ce qui ‚vite les "Le vieux de ...", "La folle et ..." 
         if ((length($listemots[2]) > 2) &&
             ($listemots[2] ne "des") &&
             ($listemots[2] ne "qui") &&
             ($listemots[2] ne "aux") &&
             ($listemots[2] ne "sur")) {
            $listemots[2] = ucfirst($listemots[2]);
         }

         # Si le mot contient "-", la lettre aprŠs le "-" doit ˆtre en majuscule
         $postiret = index($listemots[2], '-');
         if ($postiret != -1) {
            substr($listemots[2], $postiret + 1, 1) = uc(substr($listemots[2], $postiret + 1, 1));
         }

         if (grep (/^$listemots[2]$/, @listeadjectifs)) {
            # et si ce premier mot est un adjectif,
            #  Majuscule MAJ sur le mot suivant
            #  ... sauf si petit mot et, du, de... ; ce qui ‚vite les "Le vieux de ...", "La folle et ..." 
            if ((length($listemots[3]) > 2) &&
                ($listemots[3] ne "des") &&
                ($listemots[3] ne "qui") &&
                ($listemots[3] ne "aux") &&
                ($listemots[3] ne "sur")) {
               $listemots[3] = ucfirst($listemots[3]);
            }

            # Si le mot contient "-", la lettre aprŠs le "-" doit ˆtre en majuscule
            $postiret = index($listemots[3], '-');
            if ($postiret != -1) {
               substr($listemots[3], $postiret + 1, 1) = uc(substr($listemots[3], $postiret + 1, 1));
            }
         }
      }

   }


   #  Passer au mot suivant et
   #
   #  S'il s'agit d'un " et " => copier dans la liste des titres … v‚rifier (cause : comparaison ou sym‚trie)
   #
   #  Si le titre est suffisemment long, ajouter dans la liste des titres … v‚rifier (cause : v‚rifier si verbe)
   #
   #  Si le titre contient " ou ", ajouter dans la liste des titres … v‚rifier (cause: titre double)
   #

   $chaine = join (' ', @listemots);
#  print "DBG aprŠs FR: [$chaine]\n";

   # r‚cup‚ration des caractŠres diff‚rents (les apostrophes)
   $avant = lc($pattern);
   $apres = lc($chaine);
#  print "DBG $avant - $apres --- " . length($avant) . "\n";

   for ($j = 0 ; $j < length($avant) ; $j++) {
      if (substr($apres, $j, 1) ne substr($avant, $j, 1)) {
         substr($chaine, $j, 1) = substr($avant, $j, 1);
      }
   }
   if ($pattern ne $chaine) {
#     print "DBG traite_fr [$pattern] --> [$chaine]\n";
   }
   return $chaine;
}
