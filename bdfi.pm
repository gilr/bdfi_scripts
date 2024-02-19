#===========================================================================
# Module BDFI.PM
#
# v1.0 - 14/10/2011 - 2 niveaux de cycles seulement
# v1.1 - ../../.... - Ajout d'un troisiŠme niveau (sous_sous_cycle)
# v1.2 - ../../.... - Gestion des titres alternatifs de s‚ries
# v1.3 - ../../.... - Suppression du "#" en d‚but d'URL
# v1.4 - ../../.... - Ajout de l'affichage de sections (groupe de textes)
# v1.5 - ../../.... -  
# v1.6 - 28/05/2020 - Ajout d'utilitaire extraction ligne couverture
# v1.7 - ../../2020 - Ajout du traitement des ""
# v2.0 - 23/12/2020 - Suppression des alias, g‚r‚ au format ((Nom page))
#
# Utilitaires traitements chaines
#   noacc
#   tohtml
#   totxt
#   dos2win
#   win2dos
#
# Utilitaire lecture des enregistrements
#   decomp_reference
#   decomp_titre
#   idrec
#   genre
#
# Utilitaire generation d'URL
#   url_antho
#   url_serie
#   url_auteur
#
# Divers...
#   exist_auteur
#   aff_auteur
#   str_auteur
#   convmois
#
#===========================================================================
#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------
#--- support
$coll_start=2;                                $coll_size=7;
$num_start=10;                                $num_size=5;
$typnum_start=15;
$date_start=17;                               $date_size=4;
$mois_start=22;                               $mois_size=2;
$mark_start=31;                               $mark_size=4;
$isbn_start=36;                               $isbn_size=13;

#--- intitule
$genre_start=3;
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;


#---------------------------------------------------------------------------
# Suppression des accents
#---------------------------------------------------------------------------
sub noacc
{
   $chaine=$_[0];

   $chaine=~tr/ …ƒ„Æ‚ˆŠ‰¡‹Œ¢•“”ä£—–˜ì¤‡›/aaaaaeeeeiiiiooooouuuuyyncOo/d;
   $chaine=~s//E/g;
   return $chaine;
}

sub analys_ligne
{
   my $ligne = $_[0];
}

#---------------------------------------------------------------------------
# Decomposition ligne "utile" (depuis auteur) en auteur, titres, date, titre_vo, traducteur
#---------------------------------------------------------------------------
sub decomp_reference
{
   my $lig = $_[0];

   my ($auteur, $titres, $vodate, $votitre, $trad) = ("", "", "", "", "");

   $auteur=substr ($lig, $author_start, $author_size-1);
   $auteur=~s/ +$//o;

   $suite=substr ($lig, $title_start);

   ($titres, $vo, $trad)=split (/ş/,$suite);

   $titres=~s/ +$//o;

   $trad=~s/^ +//o;
   $trad=~s/ +$//o;
   $trad=~s/Trad. //o;
   $trad=~s/Adapt. //o;

   ($vodate, @tabvotitre)=split (/ /,$vo);
   $votitre=join(' ', @tabvotitre);
   $vodate=~s/ +$//;
   $votitre=~s/ +$//;

   # Date circa ("ca.")
   if (substr($vodate, 0, 1) eq "c") { $vodate = "ca. " . substr($vodate, 1); }

   return ($auteur, $titres, $vodate, $votitre, $trad);
}

#---------------------------------------------------------------------------
# Decomposition titre en titre, cycle, souscycle et indices
# Aujourd'hui :
# OK [souscycle1 - x]<[cycle1 - x]
# OK [cycle1 - x]+[cycle2 - x]
# OK [cycle1 - x]+[cycle2 - x]+[cycle3 - x]
# OK [souscycle1 - x]<[cycle1 - x]+[cycle2 - x]
# OK [souscycle1 - x]|[souscycle2 - x]<[cycle2 - x]
# OK [souscycle1 - x]|[souscycle2 - x]|[souscycle3 - x]<[cycle - x]
# OK [souscycle1 - x]|[souscycle2 - x]<[cycle1 - x]+[cycle2 - x]
#
# KO [souscycle1 - x]<[cycle1 - x]+[souscycle2 - x]<[cycle2 - x]
# KO [souscycle - x]<[cycle - x]<[univers - x]
#
# Recherche des cycles distincts (de plus haut niveau)
# [C1]+[C2]+[C3]
#
# Recherche des sous-cycles (dans un cycle seulement : le premier)
# ([C1])+[C2]+[C3]
#  -> [SC1.1]<[C1]  ( ou [SC1.1][C1] )   1 seul niveau aujourd'hui
#
#  Dans le sous-cycle, recherche de cycles alternatifs :
#  [(SC1.1)]<[C1]+[C2]+[C3]
#   -> [SC1.1a]|[SC1.1b]|[SC1.1c]
#
#   [SC1.1a]|[SC1.1b]|[SC1.1c]<[C1]+[C2]+[C3]
#
#---------------------------------------------------------------------------
sub decomp_titre
{
   my $titre = $_[0];
   my $nblig = $_[1];
   my $lig = $_[2];

   my ($titre_seul, $alias_recueil,
       $sous_sous_cycle, $indice_sous_sous_cycle,
       $sous_cycle, $indice_sous_cycle,
       $sous_cycle2, $indice_sous_cycle2,
       $sous_cycle3, $indice_sous_cycle3,
       $cycle, $indice_cycle,
       $cycle2, $indice_cycle2,
       $cycle3, $indice_cycle3)=("", "", "", $NOCYC, "", $NOCYC, "", $NOCYC, "", $NOCYC, "", $NOCYC, "", $NOCYC, "", $NOCYC);

   # suppression des doubles [[ et ]]
   #----------------------------------
   $titre =~s/\[\[/\[/go;
   $titre =~s/\]\]/\]/go;

   # separation titre / series
   #--------------------------
   if (substr($titre, 0, 1) eq '[')
   {
     # Pour les quelques titres qui commencent par '['
     $titre_seul = $titre;
   }
   else
   {
      ($titre_seul, $pattern_cycles)=split (/\[/, $titre, 2);
      $titre_seul=~s/ +$//o;
      $pattern_cycles=~s/ +$//o;

      #-------------------------------------------------------------------------
      # Recherche des cycles multiples distincts
      #  s‚par‚s par des "+" (obligatoire) [cycle 1]+[cycle 2]
      #-------------------------------------------------------------------------
      (@cycles)=split (/\]\+\[/, $pattern_cycles);

      $numero_cycle = 0;
      foreach $item (@cycles)
      {
         $numero_cycle++;
         $item=~s/\]$//o;
         $item=~s/^\[//o;
         if ($numero_cycle == 3) {
            # Init cycle 3
            ($cycle3, $indice_cycle3)=split (/ \- /,$item);
            if ($indice_cycle3 eq '') { $indice_cycle3 = $NOCYC; }
         }
         elsif ($numero_cycle == 2)
         {
            # Init cycle 2
            ($cycle2, $indice_cycle2)=split (/ \- /,$item);
            if ($indice_cycle2 eq '') { $indice_cycle2 = $NOCYC; }
         }
         elsif ($numero_cycle == 1)
	 {
            #-------------------------------------------------------------------------
            # Seul le cycle 1 (le premier dans la liste) peut avoir des sous-cycles
            #  => recherche s'il y a des sous-cycles
            #-------------------------------------------------------------------------
            ($sous_sous_cycle, $liste_sous_cycles, $cycle)=split (/\]<?\[/,$item);

            if ($cycle eq "")
            {
               $cycle=$liste_sous_cycles;
               $liste_sous_cycles=$sous_sous_cycle;
               $sous_sous_cycle="";
            }
            if ($cycle eq "")
            {
               $cycle=$liste_sous_cycles;
               $liste_sous_cycles=$sous_sous_cycle;
               $sous_sous_cycle="";
            }

            # Init sous-sous-cycle si non vide
            if ($sous_sous_cycle ne "")
            {
               ($sous_sous_cycle, $indice_sous_sous_cycle)=split (/ \- /,$sous_sous_cycle);
               if ($indice_sous_sous_cycle eq '') { $indice_sous_sous_cycle = $NOCYC; }
            }
            # Init cycle 1
            ($cycle, $indice_cycle)=split (/ \- /,$cycle);
            if ($indice_cycle eq '') { $indice_cycle = $NOCYC; }
            # Recherche si plusieurs sous-cycles
            if ($liste_sous_cycles ne "")
            {
               (@sous_cycles) = split (/\]\|\[/, $liste_sous_cycles);
               $numero_sous_cycle = 0;
               foreach $item2 (@sous_cycles)
               {
                  $numero_sous_cycle++;
                  $item2=~s/\]$//o;
                  $item2=~s/^\[//o;
                  if ($numero_sous_cycle == 1) {
                     ($sous_cycle, $indice_sous_cycle)=split (/ \- /,$item2);
                     if ($indice_sous_cycle eq '') { $indice_sous_cycle = $NOCYC; }
                  }
                  elsif ($numero_sous_cycle == 2) {
                     ($sous_cycle2, $indice_sous_cycle2)=split (/ \- /,$item2);
                     if ($indice_sous_cycle2 eq '') { $indice_sous_cycle2 = $NOCYC; }
                  }
                  elsif ($numero_sous_cycle == 3) {
                     ($sous_cycle3, $indice_sous_cycle3)=split (/ \- /,$item2);
                     if ($indice_sous_cycle3 eq '') { $indice_sous_cycle3 = $NOCYC; }
                  }
                  else {
                     # erreur, arret
                     printf STDERR "*** Error line $nblig ***\n";
                     printf STDERR " plus de 3 sous-cycles ?!\n";
                     printf STDERR "$lig\n";
                     exit;
                  }
               }
            }
         }
         else {
            # erreur, arret
            printf STDERR "*** Error line $nblig ***\n";
            printf STDERR " plus de 3 cycles ?!\n";
            printf STDERR "$lig\n";
            exit;
         }
      }
   }

   # Extraire l'alias recueil s'il est indiqu‚
   #-----------------------------------------------
   ($titre_seul, $alias_recueil)=split (/\(\(/, $titre_seul, 2);
   $titre_seul=~s/ +$//o;
   $alias_recueil=~s/ +$//o;
   $alias_recueil=~s/\)\)$//o;

   return ($titre_seul, $alias_recueil,
	   $sous_sous_cycle, $indice_sous_sous_cycle,
           $sous_cycle, $indice_sous_cycle,
           $sous_cycle2, $indice_sous_cycle2,
           $sous_cycle3, $indice_sous_cycle3,
           $cycle, $indice_cycle,
           $cycle2, $indice_cycle2,
           $cycle3, $indice_cycle3);
}

#---------------------------------------------------------------------------
# Generation de l'ID s‚rie
#   Attention => non g‚r‚ aujourd'hui car ‡a dupliquerait la ligne titre
#   Conserv‚ pour information
#   
#   NOTA:
#   les transformations d'URL pour cause de pbs (#, aux) sont dans url_serie
#---------------------------------------------------------------------------
@idcyc_alias = ( 
   { ALIAS=>"Les Pierres de sang", ID=>"John Shannow" },
   { ALIAS=>"Les Chroniques de Kh‰rad”n", ID=>"Le Cycle de Lahm" },
   { ALIAS=>"L'Elfe de Lune", ID=>"Luna" },
);

sub idcyc
{
   #--- Prise en compte des alias
   foreach $record (@idcyc_alias)
   {
      if ($idcyc eq $record->{ALIAS})
      {
         $idcyc = $record->{ID};
      }
   }
   return $idcyc;
}

#---------------------------------------------------------------------------
# Generation de l'ID recueil
#
# A FAIRE : 
#  - 20 <-> vingt etc... (doubler tout ce qui commence par chiffre ou nombre)
#  - PB avec les "int‚grales"
# OK :
#  - si idrec différent mais url identique, Exemple : "Histoires de fant“mes" et "Histoires fant“mes" : mˆme idrec mais pas url
#      et contenu ne groupe pas les deux (=> url diff‚rente, ou grouper)
#    ==> ajouter les url dans le fichier antho (nom  id  url) : [ OK ]
#    ==> url groupant les deux idrec (modif bibantho)         : [ OK ]
#
# Fichiers COL :
#  - eviter les "no i" dans les anthos & recueils : remplacer par - i ou - numéro i, ou utiliser les ((nom))
#
# Extra muros : M ou A ?
# Nouvelles -> beurk
#---------------------------------------------------------------------------
sub idrec
{
   my $titre = $_[0];
   my $cycle = $_[1];
   my $scycle = $_[2];
   my $idrec = "";
#print "SUB idrec : titre " . $titre . " - " . $cycle . " - " . $scycle . "=> idrec= " . $idrec . "\n";

   if ($scycle ne "")
   {
      $scycle=~s/\]//o;
      if ($cycle ne "")
      {
         $cycle=~s/\]//o;
      }
      else
      {
         $cycle=$scycle;
         $scycle="";
      }
   }
   ($cycle, $indice_cycle)=split (/ \- /,$cycle);
   ($scycle, $indice_scycle)=split (/ \- /,$scycle);
   if ($cycle eq '')
   {
      $idrec=$titre;

      #--- Supprimer numero, volume, tome...
      $idrec=~s/ - Num‚ro [0-9]+$//o;
      $idrec=~s/ - Volume [0-9]+$//o;
      $idrec=~s/ - Vol. [0-9]+$//o;
      $idrec=~s/ - Tome [0-9IV]+$//o;
      $idrec=~s/ \(Tome [0-9IV]+\)$//o;
      $idrec=~s/ \(Vol. [0-9IV]+\)$//o;
      $idrec=~s/ - [0-9IV]+$//o;
      $idrec=~s/, s‚rie [0-9IV]+$//o;
      $idrec=~s/, Arcane .*$//o;

# Pas cool, supprime par exemple le "La chambre no 6" !
#     $idrec=~s/ nø [0-9]+$//o;
#     $idrec=~s/ nø[0-9]+$//o;         # temporaire si propre...
# => eviter les "no i" dans les anthos & recueils ! (remplacer par - i ou - numéro i)
#    sauf si " ... - no i"

#print "SUB idrec : titre " . $titre . " - " . $cycle . " - " . $scycle . "=> idrec= " . $idrec . "\n";

      #--- supprimer "[,] et [x ]autres (nouvelles|recits|legendes|contes|textes|romans|histoires|ecrits|poemes])"
      $idrec=~s/,? (et|&)( [0-9]+)? autres (aventures|nouvelles|r‚cits|l‚gendes|textes|contes|romans|histoires|‚crits|moralit‚s|poŠmes).*$//o;
      #--- supprimer ", ou..."
      $idrec=~s/, ou.*$//o;
      #--- supprimer "[,] suivi de .."
      #--- supprimer "[,] pr‚c‚d‚ de .." "[,] pr‚c‚d‚ de .."
      $idrec=~s#<sup>##o;
      $idrec=~s#</sup>##o;
      $idrec=~s/,? suivi d'.*$//o;
      $idrec=~s/,? suivi de.*$//o;
      $idrec=~s/,? suivi du.*$//o;
      $idrec=~s/,? suivie d'.*$//o;
      $idrec=~s/,? suivie de.*$//o;
      $idrec=~s/,? suivie du.*$//o;
      $idrec=~s/,? suivis de.*$//o;
      $idrec=~s/,? pr‚c‚d‚ de.*$//o;
      $idrec=~s/,? pr‚c‚d‚ du.*$//o;
      $idrec=~s/,? pr‚c‚d‚s de.*$//o;
      $idrec=~s/,? pr‚c‚d‚ par.*$//o;

      #--- specifique "quatrieme dimension", El Borak, Espace et spasmes
      $idrec=~s/Nouvelles histoires de la/La/o;
      $idrec=~s/Les meilleures histoires de la/La/o;
      $idrec=~s/^El Borak.*$/El Borak/o;
      $idrec=~s/, (cinq|huit) nouvelles de science-fiction//o;

      $idrec=~s/^([0-9]+ )?[Nn]ouvelles histoires/Histoires/o;
      $idrec=~s/^([0-9]+ )?[Nn]ouvelles histoires/Histoires/o;
      $idrec=~s/22 histoires de /Histoires de /o;

      #--- Suppression "yyy" de "xxx : yyy" ou "xxx - yyy" ou "xxx (yyy)"
      $idrec=~s/ \(.*\)$//o;
      $idrec=~s/ - .*$//o;
      $idrec=~s/ : .*$//o;
      #--- essai avec xxx / yyy
      $idrec=~s/ \/ .*$//o;
      $idrec=~s/\/.*$//o;

      #--- 3 points en debut ou fin
      $idrec=~s/ *\.\.\.$//o;
      $idrec=~s/^\.\.\. *//o;

      $idrec=~s#/[0-9]+$##o;
      $idrec=~s/ \*\*$//o;
# Pas cool, supprime par exemple le "La chambre no 6" ... (voir plus haut)
#     $idrec=~s/ [0-9\/\-]+$//o;

   }
   else
   {
      $idrec=$cycle;
   }
#print "SUB idrec : return " . $idrec ."\n";
   return $idrec;
}
#---------------------------------------------------------------------------
# Fonction de lecture genre(s)
#---------------------------------------------------------------------------
sub genre
{
   my $genre = $_[0];
   my $g1 = $_[1];
   my $g2 = $_[2];
   my $sep = "";
   my $sep2 = ", ";
   my $texte="";

   if ($genre eq "?")
   {
      $texte="Genre a confirmer";
      $sep = " / ";
   }
   elsif ($genre eq "x")
   {
      $texte="Hors genres";
      $sep = " / ";
   }
   elsif ($genre eq "!")
   {
      $texte="Hors genres, non r‚f‚renc‚(s)";
      $sep = " / ";
   }
   elsif ($genre eq "p")
   {
      $texte="Partiellement hors genres";
      $sep = " / ";
   }
   $texte = $texte . $sep . &sgenre($g1);

   if (($g2 ne " ") && ($g2 ne "."))
   {
      $texte = $texte . $sep2 . &sgenre($g2);
   }

   printf STDERR "[$genre][$g1][$g2] ==> $texte\n";
   return $texte;
}

sub sgenre
{
   my $g = $_[0];
   if    ($g eq 'A') { return "Aventure"; }
   elsif ($g eq 'B') { return "Thriller"; }
   elsif ($g eq 'C') { return "Chevalerie"; }
   elsif ($g eq 'D') { return "Guerre"; }
   elsif ($g eq 'E') { return "Espionnage"; }
   elsif ($g eq 'F') { return "Fantastique"; }
   elsif ($g eq 'G') { return "Gore"; }
   elsif ($g eq 'H') { return "Historique"; }
   elsif ($g eq 'I') { return "SF-F-F"; }
   elsif ($g eq 'J') { return "Humour"; }
   elsif ($g eq 'K') { return "Etrange et insolite"; }
   elsif ($g eq 'L') { return "Mainstream"; }
   elsif ($g eq 'M') { return "Merveilleux"; }
   elsif ($g eq 'N') { return "Contes et l‚gendes"; }
   elsif ($g eq 'O') { return "Mythologie"; }
   elsif ($g eq 'P') { return "Policier"; }
   elsif ($g eq 'Q') { return "Erotique"; }
   elsif ($g eq 'R') { return "Romance"; }
   elsif ($g eq 'S') { return "SF"; }
   elsif ($g eq 'T') { return "Terreur"; }
   elsif ($g eq 'U') { return "Fusion"; }
   elsif ($g eq 'V') { return "R‚alisme magique"; }
   elsif ($g eq 'W') { return "Western"; }
   elsif ($g eq 'X') { return "Porno"; }
   elsif ($g eq 'Y') { return "fantasy"; }
   elsif ($g eq 'Z') { return "Fiction pr‚historique"; }
   elsif ($g eq '-') { return "Texte"; }
   elsif (($g eq '?') || ($g eq '.')|| ($g eq ' '))
                     { return "?"; }
  else               { return "$g (sigle non reconnu)"; }
}

#---------------------------------------------------------------------------
# Fonction de generation d'un lien recueil et antho
#---------------------------------------------------------------------------
sub url_antho
{
   $chaine=$_[0];
   $chaine=noacc($chaine);
   $chaine=lc($chaine);
   $chaine=~s/^(La |Les |Le |L'|Du |Des |De |D'|Un |Une |Et |Au )//gi;
   $chaine=~s/^(la |les |le |l'|du |des |de |d'|un |une |et |au )/ /gi;
   $chaine=~s/ (la |les |le |l'|du |des |de |d'|un |une |et |au )/ /gi;
   $chaine=~s/ (la |les |le |l'|du |des |de |d'|un |une |et |au )/ /gi;
   $chaine=~s/ /_/g;
   $chaine=~s/\./_/g;
   $chaine=~s/'/_/g;
   $chaine=~s#/#_#g;
   $chaine=~s/ & /_/g;
   $chaine=~s/&//g;
   $chaine=~s/;//g;
   $chaine=~s/#//g;
   $chaine=~s/[ ,\-\ø]/_/g;
   $chaine=~s/[\.!:"=\?\(\)\+\*]//g;
   $chaine=~s/_+/_/g;
   $chaine=~s/_$//;
   $chaine=~s/^_//;
   $chaine=~s/chroniques/chron/g;
   $chaine=~s/chronique/chron/g;
   $chaine=~s/aventures/av/g;
   $chaine=~s/aventure/av/g;
   $chaine=~s/sequences/seq/g;
   $chaine=~s/sequence/seq/g;
   $chaine=~s/_litteratures/_litt/g;
   $chaine=~s/_litterature/_litt/g;
   $chaine=~s/anthologie/antho/g;
   $chaine=~s/science.fiction/sf/g;

   return $chaine;
}

#---------------------------------------------------------------------------
# Fonction de generation d'un lien cycle et s‚rie
#---------------------------------------------------------------------------
sub url_serie
{
   $chaine=$_[0];
   $chaine=noacc($chaine);
   $chaine=lc($chaine);

   # Suppression des articles
   $chaine=~s/^(La |Les |Le |L'|Du |Des |De |D'|Un |Une |Et |Au )//gi;
   $chaine=~s/ (la |les |le |l'|du |des |de |d'|un |une |et |au )/ /gi;
   $chaine=~s/ (la |les |le |l'|du |des |de |d'|un |une |et |au )/ /gi;

   # Gestion des caractŠres non alphanum
   $chaine=~s/ /_/g;
   $chaine=~s/'/_/g;
   $chaine=~s/[ ,\-\&ø]/_/g;
   $chaine=~s/[\.!:"\?\/]//g;
   $chaine=~s/_+/_/g;
   $chaine=~s/_$//;
   $chaine=~s/^_//;

   # raccourcissement de certains mots
   $chaine=~s/chroniques/chron/g;
   $chaine=~s/chronique/chron/g;
   $chaine=~s/aventures/av/g;
   $chaine=~s/aventure/av/g;
   $chaine=~s/sequences/seq/g;
   $chaine=~s/sequence/seq/g;

   # Transformations pour causes de problŠmes de liens ou de pages
   $chaine=~s/^#//;   # pour #8PM
# inutile car renomm‚ en "Le Faucheur" :
#   $chaine=~s/^aux$/les_aux/; 

   return $chaine;
}

#---------------------------------------------------------------------------
# Fonction de generation d'un lien interne sous-sycle (#name)
#---------------------------------------------------------------------------
sub url_name_sous_serie
{
   $chaine=$_[0];
   $chaine=~tr/ …ƒ„Æ‚ˆŠ‰¡‹Œ¢•“”ä£—–˜ì¤‡›/aaaaaeeeeiiiiooooouuuuyyncOo/d;
   $chaine=lc($chaine);

   # Suppression de tout les caractŠres suivants : "*.&'(),
   $chaine=~s/["\*\.\&',]//go;
   $chaine=~s/[\(\)]//go;

   # Les espaces et tirets deviennent des underscore (1 seul, ni en debut ni en fin)
   $chaine=~s/[ \-]/_/go;
   $chaine=~s/_+/_/g;
   $chaine=~s/_$//;
   $chaine=~s/^_//;

   return $chaine;
}

#---------------------------------------------------------------------------
# Fonction de generation d'un lien auteur
#---------------------------------------------------------------------------
sub url_auteur
{
   $chaine=$_[0];

   $chaine=~tr/ …ƒ„Æ‚ˆŠ‰¡‹Œ¢•“”ä£—–˜ì¤‡›/aaaaaeeeeiiiiooooouuuuyyncOo/d;
   $chaine=lc($chaine);

#  $chaine=~s/[ …ƒ„Æ]/a/go;
#  $chaine=~s/[‚Šˆ‰]/e/go;
#  $chaine=~s/[¡‹Œ]/i/go;
#  $chaine=~s/[¢•“”ä]/o/go;
#  $chaine=~s/[£—–]/u/go;
#  $chaine=~s/‡/c/go;
#  $chaine=~s/˜/y/go;
#  $chaine=~s/¤/n/go;

   # Suppression de tout les caractŠres suivants : "*.&'()
   $chaine=~s/["\*\.\&']//go;
   $chaine=~s/[\(\)]//go;

   # Les espaces et tirets deviennent des underscore (1 seul, ni en debut ni en fin)
   $chaine=~s/[ \-]/_/go;
   $chaine=~s/_+/_/g;
   $chaine=~s/_$//;
   $chaine=~s/^_//;

   return $chaine;
}

#---------------------------------------------------------------------------
# Fonction de transformation en HTML
#---------------------------------------------------------------------------
sub tohtml
{
   $chaine=$_[0];

   $chaine=~s/ /&aacute\;/g;
   $chaine=~s/…/&agrave\;/g;
   $chaine=~s/ƒ/&acirc\;/g;
   $chaine=~s/„/&auml\;/go;
   $chaine=~s/Æ/&atilde\;/go;
   $chaine=~s/µ/&Aacute\;/g;

   $chaine=~s/‚/&eacute\;/g;
   $chaine=~s/Š/&egrave\;/g;
   $chaine=~s/ˆ/&ecirc\;/g;
   $chaine=~s/‰/&euml\;/g;

   $chaine=~s/¡/&iacute\;/g;
   $chaine=~s//&igrave\;/g;
   $chaine=~s/Œ/&icirc\;/g;
   $chaine=~s/‹/&iuml\;/g;

   $chaine=~s/¢/&oacute\;/g;
   $chaine=~s/•/&ograve\;/g;
   $chaine=~s/“/&ocirc\;/g;
   $chaine=~s/”/&ouml\;/g;
   $chaine=~s/ä/&otilde\;/go;
   $chaine=~s//&Oslash\;/g;
   $chaine=~s/›/&oslash\;/g;

   $chaine=~s/£/&uacute\;/g;
   $chaine=~s/—/&ugrave\;/g;
   $chaine=~s/–/&ucirc\;/g;
   $chaine=~s//&uuml\;/g;

   $chaine=~s/˜/&yuml\;/go;
   $chaine=~s/ì/&yacute\;/g;
   $chaine=~s/‡/&ccedil\;/g;
   $chaine=~s/ø/&deg\;/g;
   $chaine=~s/¤/&ntilde\;/g;
   $chaine=~s/& /&amp; /g;
   $chaine=~s/á/&szlig;/g;

   $chaine=~s/š/&Uuml\;/g;
   $chaine=~s//&Eacute\;/g;
   return $chaine;

}

#---------------------------------------------------------------------------
# Fonction de transformation en texte DOS ou WINDOWS
#---------------------------------------------------------------------------
sub totxt
{
   $chaine=$_[0];
   if ($sortie eq "FICHIER_WIN")
   {
      return &dos2win($chaine);
   }
   else
   {
      return $chaine;
   }
}

#---------------------------------------------------------------------------
# Fonction de transformation DOS vers WINDOWS
#---------------------------------------------------------------------------
sub dos2win
{
   $chaine=$_[0];

   $chaine=~tr/ …ƒ„Æˆ‰‚Š¡Œ‹¢•“”ä£—–˜¤‡ø/áàâäãêëéèíìîïóòôöõúùûüÿñç°Ø/;

   return $chaine;
}

#---------------------------------------------------------------------------
# Fonction de transformation WINDOWS vers DOS
#---------------------------------------------------------------------------
sub win2dos
{
   $chaine=$_[0];

   $chaine=~tr/áàâäãêëéèíìîïóòôöõúùûüÿñç°Ø/ …ƒ„Æˆ‰‚Š¡Œ‹¢•“”ä£—–˜¤‡ø/;

   return $chaine;
}

#---------------------------------------------------------------------------
# test d'existence d'un lien auteur, et retour avec le lien
#---------------------------------------------------------------------------
sub exist_auteur
{
   my $url_relative = $_[0];
   my $nom_prenom = $_[1];

   my $lien_auteur=&url_auteur($nom_prenom);
   my $initiale=substr ($lien_auteur, 0, 1);
   $initiale=lc($initiale);
   my $url_test="$local_dir/auteurs/$initiale/${lien_auteur}.php";
   my $url="$url_relative/$initiale/${lien_auteur}.php";
   # print "--- $url\n";
   
   my $nf=1;
   open(AUTHOR, "<$url_test") or $nf=0;
   if ($nf == 1)   # lien existe
   {
      close AUTHOR;
   }
   return ($nf, $url);
}

#---------------------------------------------------------------------------
# affichage d'un nom d'auteur, avec lien si existe
#---------------------------------------------------------------------------
sub aff_auteur
{
   my $lien = $_[0];
   my $auteur = $_[1];
   $lien=~s/ +$//o;

   # nom du lien, et initiale
   my $lien_auteur = &url_auteur($lien);
   my $initiale = substr ($lien_auteur, 0, 1);
   $initiale = lc($initiale);
   my $url = "../bdfi/auteurs/${initiale}/${lien_auteur}.php";
   my $url="$local_dir/auteurs/$initiale/${lien_auteur}.php";
   
   my $nf = 1;
   open(AUTHOR, "<$url") or $nf=0;
#  print $canal &tohtml("    <font color=\"#B00000\">");
   if ($nf == 1)   # lien existe
   {
      close AUTHOR;
      print $canal &tohtml("<a class=\"auteur\" href=\"../auteurs/$initiale/$lien_auteur.php\">");
      print $canal &tohtml("$auteur");
      print $canal &tohtml("</a>");
   }
   else
   {
      print STDERR "$url \n";
      print $canal &tohtml("<span class=\"nom\">$auteur</span>");
   }
#  print $canal &tohtml("</font>");
}

#---------------------------------------------------------------------------
# affichage d'un nom d'auteur, avec lien si existe
#   Ne sert a priori que pour "theme", d'ou le chemin en dur
# A FAIRE : ameliorer
#---------------------------------------------------------------------------
sub str_auteur
{
   my $lien = $_[0];
   my $auteur = $_[1];
   $lien=~s/ +$//o;
   my $str="";

   # nom du lien, et initiale
   my $lien_auteur = &url_auteur($lien);
   my $initiale = substr ($lien_auteur, 0, 1);
   $initiale = lc($initiale);
   my $url="${lien_auteur}.php";
   $url="../bdfi/auteurs/$initiale/${lien_auteur}.php";
   my $nf = 1;
   open(AUTHOR, "<$url") or $nf=0;
   $str= &tohtml("<font color=\"#B00000\">");
   if ($nf == 1)   # lien existe
   {
      close AUTHOR;
      $str = $str . &tohtml("<a class=\"auteur\" href=\"../../auteurs/$initiale/$lien_auteur.php\">");
      $str = $str . &tohtml("$auteur");
      $str = $str . &tohtml("</a>");
   }
   else
   {
      print STDERR "$url \n";
      $str = $str . &tohtml("$auteur");
   }
   $str = $str . &tohtml("</font>");

#   print $str;
   return $str;
}

#---------------------------------------------------------------------------
# Subroutine de conversion des mois
#---------------------------------------------------------------------------
@listmois=("janvier", "fevrier", "mars", "avril",
           "mai", "juin", "juillet", "aout",
           "septembre", "octobre", "novembre", "decembre");

sub convmois
{
   my $mois=$_[0];
   if ($mois ne "")
   {
      return $listmois[$mois];
   }
}


#---------------------------------------------------------------------------
# Subroutine de d‚composition ligne couverture
#---------------------------------------------------------------------------
#   ($couv, $illustrateur, $dessinateurs) = &extract_couv ($ligne);
#---------------------------------------------------------------------------
sub extract_couv
{
   my $ligne = $_[0];

   my $couv="";
$scan_start= 1;                               $scan_size=17;
$illu_start= 18;                              $illu_size=28;

   # On autorise un nom d'image plus long que la zone pr‚vue initialement
   # => recherche du premier " _" 
   my $illu_start_dyn = index ($ligne, " _", $illu_start - 2);
   my $scan_size_dyn = $illu_start_dyn - $scan_start + 1;
   $couv=substr ($ligne, $scan_start, $scan_size_dyn - 1);
   $couv=~s/ +$//o;
   $couv=~s/^ +//o;
   $couv=~s/\.jpg$//o;
   $couv=$couv . ".jpg";

   # Pour l'instant, la zone reste de longueur identique, le reste de la ligne est juste d‚cal‚
   #  => pr‚voir un autre "_" pour marquer le d‚but des dessinateurs d'illustrations int‚rieures ?
   #  => s'il existe un deuxiŠme " _", c'est le d‚but. Sinon, on prend … la position
   my $zone_dessinateurs="";
   my $illustrateur_couv="";
   my $illustrateur_int="";

   $zone_dessinateurs = substr ($ligne, $illu_start_dyn + 1, -1);
   $zone_dessinateurs =~ s/ +$//o;
   # Recherche si autre s‚parateur " _"
   my $dess_start_dyn = index ($zone_dessinateurs, " _");
   if ($dess_start_dyn eq -1)
   {
      # Pas de nouveau s‚parateur
      $illustrateur_couv = substr ($zone_dessinateurs, 1, $illu_size);
      $illustrateur_int = substr ($zone_dessinateurs, $illu_size + 1);
      # print "DBG: Zone  [$zone_dessinateurs]\n";
   }
   else
   {
      # Pr‚sence d'un nouveau s‚parateur
      $illustrateur_couv = substr ($zone_dessinateurs, 1, $dess_start_dyn - 1);
      $illustrateur_int = substr ($zone_dessinateurs, $dess_start_dyn + 2);
      # print "DBG: Z___  [$zone_dessinateurs]\n";
   }
   if ($illustrateur_int eq "N") {
      $illustrateur_int = "n/a";
   }
   elsif (substr($illustrateur_int,0,2) eq "O:") {
      $illustrateur_int = substr($illustrateur_int,2);
   }

   $illustrateur_couv=~s/^_//o;
   $illustrateur_couv=~s/^ +//o;
   $illustrateur_couv=~s/ +$//o;

   $illustrateur_int=~s/^_//o;
   $illustrateur_int=~s/^ +//o;
   $illustrateur_int=~s/ +$//o;

   # print "DBG: Couv. [$illustrateur_couv]\n";
   # print "DBG: Illus [$illustrateur_int]\n\n";

   return ($couv, $illustrateur_couv, $illustrateur_int);
}

#---------------------------------------------------------------------------
# Fin du module BDFI
#---------------------------------------------------------------------------
1;

