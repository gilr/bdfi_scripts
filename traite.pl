# Faire programme qui, sur tout fichier .col :
#  - [..] Mets des majuscules  si n‚cessaire (d‚finir rŠgle exacte), aux :
#       -> titres fran‡ais
#       -> cycles fran‡ais
#  - [..] Mets des majuscules aux titres vo si l'auteur est anglais, am‚ricain ou australien
#       -> r‚cup fichier CSV "titre BDFI + Pays"
#       -> ne conserver que les auteurs anglophones
#  - [..] Affiche un warning si la permiŠre lettre d'un titre (cf, vo) est une minuscule
#  - [OK] Ajoute "} noimg ... " … toute publi ou r‚‚d


# Check du contenu de ligne selon son type:
#    Compl‚ments et corrections possibles
#    si erreur d‚tect‚e mais non corrigeable, recopier tel que et faire un warning
#
#    --- 2. Compl‚ment date (c)
#    Si il n'y pas de caractŠre "þ" dans la ligne
#       alors ajouter en fin de ligne "þ?"
#
#    --- 3. Titres (r‚f‚rences) => majuscules
#     S'applique … : titres + cycles
#    Exclusion de tout ce qui contient "^L.* est "
#    Prise en compte de tout contient "^[La ][Le ][Les ][L']" -> mot suivant en majuscule... sauf si adjectif, auquel cas mot suivant aussi
#         ( => avoir une liste d'ajectif )
#
#
#
# =========================================================================================================

#---------------------------------------------------------------------------
# Variables de definition des fichiers collections
#---------------------------------------------------------------------------
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

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0      <fichier_col>\n";
   exit;
}

$file=$ARGV[0];

#---------------------------------------------------------------------------
# Ouvrir le fichier .col en lecture
#---------------------------------------------------------------------------
$file=~s/\.col//;
$file=~s/\.COL//;
$file_col=$file;
$file_col=~s/$/.col/;
open (f_col, "<$file_col");
@col=<f_col>;
close (f_col);

#---------------------------------------------------------------------------
#--- Ouvrir la liste des auteurs anglo-saxons
#---------------------------------------------------------------------------
$gb="british.csv";
open (f_gb, "<$gb");
@gb=<f_gb>;
close (f_gb);

#---------------------------------------------------------------------------
# ouvrir le fichier .new en ecriture
#---------------------------------------------------------------------------
$new_file=$file;
$new_file=~s/$/.upd/;
 # DEBUG
 print "old : $file_col\n";
 print "new : $new_file\n";
open (NEW, ">$new_file");
# Pour chaque ligne :
$nbligne=0;
$nbtraite=0;


$backup_file=$file;
$backup_file=~s/$/.kol/;
open (BAK, ">backup/$backup_file");


my $ouvr_debut='0';
my $reed_debut='0';
my $ouvr_couv = "0";
my $reed_couv = "0";
my $decal = "";


#---------------------------------------------------------------------------
# Lire chaque ligne du fichier col
# Pour chaque ligne : 
#---------------------------------------------------------------------------
foreach $ligne (@col)
{
   $nbligne++;
   print BAK "$ligne";
   $ligne=~s/\n$//g;
   $len = length($ligne);
   if ($len == 0)
   {
      # ligne vide : conserver... sauf si debut d'ouvrage
      #------------------------------------------------------------
      if (($ouvr_debut != '1') && ($reed_debut != '1')) {
         print NEW "$ligne\n";
#        print "DBG: ligne vide\n";
      }
   }
   else
   {
      $prem = substr ($ligne, 0, 1);
      $type = $prem;

      #------------------------------------------------------------------
      # si "^?", m‚mo et d‚calage de un caractŠre pour le d‚but de ligne
      # sinon, reset
      #------------------------------------------------------------------
      if (($prem eq "­") || ($prem eq "?")) {
         #--- Ouvrage non paru, suspect, ou hors genre
         #--- Le type est en position 2
         $decal = $prem;
         $type = substr ($ligne, 1, 1);
#        print "DBG: d‚calage [$prem]\n";
      }
      else
      {
         $decal = "";
      }

      #------------------------------------------------------------------
      # Traitement selon le type de ligne
      #------------------------------------------------------------------
      if ($type eq '_') {
         #--- Collection
         $new_ligne = check_collection($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif (($type eq '!') || ($type eq ">")) {
         #--- Commentaire
         print NEW "$ligne\n";
      }
      elsif ($type eq 'o') {
         #--- Ouvrage
         $ouvr_debut = 1;
         $ouvr_couv = 0;
         $new_ligne = check_ouvrage($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
#        print "DBG: ouvrage (o)\n";
      }
      elsif ($type eq '+') {
#        print "DBG: r‚‚dition (+)\n";
         #--- R‚‚dition
         if (($ouvr_debut == 1) && ($ouvr_couv == 0)) {
             # Si aprŠs une ligne "^o", on rencontre une ligne "^-" ou "^+" sans avoir rencontr‚ de "^}",
             #   alors ins‚rer la ligne "^} noimg"
             print NEW "${decal}} noimg          _?                           ?\n";
         }
         $ouvr_debut = 0;
         $ouvr_couv = 0;
         if (($reed_debut == 1) && ($reed_couv == 0)) {
             # Si aprŠs une ligne "^+", on rencontre une ligne "^-" ou "^+" sans avoir rencontr‚ de "^}",
             #   alors ins‚rer la ligne "^} noimg"
             print NEW "${decal}} noimg          _?                           ?\n";
         }
         $reed_debut = 1;
         $reed_couv = 0;
         #--- imprimer la r‚‚dition
         $new_ligne = check_ouvrage($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif ($type eq '}') {
#        print "DBG: couverture (})\n";
         #--- R‚‚dition
         if ($ouvr_debut == 1) {
            if ($ouvr_couv == 1) {
               print "ERREUR  [Lig $nbligne] Double image\n";
            }
            $ouvr_couv = 1;
         }
         elsif ($reed_debut == 1) {
            if ($reed_couv == 1) {
               print "ERREUR  [Lig $nbligne] Double image\n";
            }
            $reed_couv = 1;
         }
         else {
            print "ERREUR  [Lig $nbligne] Image hors zone autoris‚e\n";
         }
         $new_ligne = check_image($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif ($type eq '/') {
#        print "DBG: num multiple (/)\n";
         #--- Num‚ro multiple
         $new_ligne = check_multiple($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif (($type eq '-') || ($type eq ')')) {
#        print "DBG: r‚f‚rence (-)\n";
         #--- R‚f‚rence
         if (($ouvr_debut == 1) && ($ouvr_couv == 0)) {
             # Si aprŠs une ligne "^o", on rencontre une ligne "^-" ou "^+" sans avoir rencontr‚ de "^}",
             #   alors ins‚rer la ligne "^} noimg"
             print NEW "${decal}} noimg          _?                           ?\n";
         }
         $ouvr_debut = 0;
         $ouvr_couv = 0;
         if (($reed_debut == 1) && ($reed_couv == 0)) {
             # Si aprŠs une ligne "^+", on rencontre une ligne "^-" ou "^+" sans avoir rencontr‚ de "^}",
             #   alors ins‚rer la ligne "^} noimg"
             print NEW "${decal}} noimg          _?                           ?\n";
         }
         $reed_debut = 0;
         $reed_couv = 0;
         #--- Imprimer la r‚f‚rence
         $new_ligne = check_texte($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif ($type eq ':') {
#        print "DBG: r‚f‚rence incluse (:)\n";
         #--- R‚f‚rence incluse
         $new_ligne = check_texte($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif ($type eq '=') {
#        print "DBG: r‚f‚rence incluse niveau 2 (=)\n";
         #--- R‚f‚rence incluse niveau 2
         $new_ligne = check_texte($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      elsif ($type eq '&') {
#        print "DBG: collaboration 2 (&)\n";
         #--- Collaboration
         $new_ligne = check_collab($nbligne, $decal, $ligne);
         print NEW "$new_ligne\n";
      }
      else {
         #--- Premier car inconnu
         print "ERREUR  [Lig $nbligne] Premier caractŠre non reconnu [$ligne]\n";
         print NEW "$ligne\n";
      }



      
#     elsif (($prem eq "-") || ($prem eq ":") || ($prem eq "="))
#     {
         # Si lignes de titre, ouvrage ou texte : "-", ":", "="
         #------------------------------------------------------------

         # => split de la ligne en ses composantes
         # => recup titre fr, cycle 1 fr, cycle 2 fr, titre vo
         # TBD
         # => traiter titre français
         # TBD
         # => traiter cycle(s) français
         # TBD

         # => si auteurs anglo-saxon ou si reconnu comme titre anglophone, traiter titre gb
         # auteur dans liste british.csv


         # => ressortir la ligne modifiee en conservant le "reste"
         # TBD
#        print NEW " ( Ligne titre ) \n";
#     }
#     else
#     {
#        # Autre ligne (commentaire, sigles...) : conserver
#        #------------------------------------------------------------
#        print NEW "$ligne\n";
#     }
   }
}

print "fini nb lignes = $nbligne - trait‚ : $nbtraite\n";
close (NEW);


# La premiŠre fois : traitement auto et recopie du .upd en .col
#  Pour les suivantes, non, la copie est manuelle si n‚cessaire
#   + permet de voir et traiter les warnings.

#--- Puis copie de .col en .ba2
# $back2_file=$file;
# $back2_file=~s/$/.ba2/;
# $cmd="cp ${file_col} ${back2_file}";
# system $cmd;


#--- Puis copie de .upd en .col
# $cmd="cp ${new_file} ${file_col}";
# system $cmd;



#---------------------------------------------------------------------------
# V‚rification ligne collection : OK
#---------------------------------------------------------------------------
sub check_collection {
   my $nbligne = $_[0];
   my $decal = $_[1];
   my $ligne = $_[2];

   if (substr ($ligne, $coll_start - 1 + length($decal), 1) ne " ") {
       print "ERREUR  [Lig $nbligne] Pb car 2 [$ligne]\n";
   }
   if (substr ($ligne, $coll_start + length($decal), 1) eq " ") {
       print "ERREUR  [Lig $nbligne] Pb car 3 [$ligne]\n";
   }
   if (substr ($ligne, $coll_start + $coll_size + length($decal), 1) ne " ") {
       print "ERREUR  [Lig $nbligne] Pb car 9 [$ligne]\n";
   }
   if (substr ($ligne, $coll_start + $coll_size + 1 + length($decal), 1) eq " ") {
       print "ERREUR  [Lig $nbligne] Pb car 10 [$ligne]\n";
   }
   return $ligne;
}

#---------------------------------------------------------------------------
# V‚rification ligne ouvrage : A FAIRE
#---------------------------------------------------------------------------
# $num_start=10;                                $num_size=5;
# $typnum_start=15;
# $date_start=17;                               $date_size=4;
# $mois_start=22;                               $mois_size=2;
# $mark_start=31;                               $mark_size=4;
# $isbn_start=36;                               $isbn_size=13;
sub check_ouvrage {
   my $nb = $_[0];
   my $decal = $_[1];
   my $ligne = $_[2];

   if (substr ($ligne, $coll_start - 1 + length($decal), 1) ne " ") {
       print "ERREUR  [Lig $nbligne] Pb car 2 (coll) [$ligne]\n";
   }
   if (substr ($ligne, $coll_start + length($decal), 1) eq " ") {
       print "ERREUR  [Lig $nbligne] Pb car 3 (coll) [$ligne]\n";
   }
   if (substr ($ligne, $coll_start + $coll_size + length($decal), 1) ne " ") {
       print "ERREUR  [Lig $nbligne] Pb car 9 (coll) [$ligne]\n";
   }
   if (substr ($ligne, $num_start + $num_size - 1 + length($decal), 1) eq " ") {
       print "ERREUR  [Lig $nbligne] Pb car 10 (nø) [$ligne]\n";
   }
   if (substr ($ligne, $mark_start + length($decal), 4) ne "ISBN") {
       print "ERREUR  [Lig $nbligne] Pb pos ISBN [$ligne]\n";
   }
   if ((substr ($ligne, $isbn_start + length($decal), 1) ne "-") &&
       (substr ($ligne, $isbn_start + length($decal), 1) ne "?") &&
       (substr ($ligne, $isbn_start + length($decal), 1) ne ".") &&
       ((substr ($ligne, $isbn_start + length($decal), 1) lt "0") ||
        (substr ($ligne, $isbn_start + length($decal), 1) gt "9"))) {
       print "ERREUR  [Lig $nbligne] Pb pos nø isbn [$ligne]\n";
   }
   # A FAIRE : check ISBN
   #

   return $ligne;
}

#---------------------------------------------------------------------------
# V‚rification ligne image : A FAIRE
#---------------------------------------------------------------------------
sub check_image {
   my $nb = $_[0];
   my $decal = $_[1];
   my $ligne = $_[2];

   return $ligne;
}

#---------------------------------------------------------------------------
# V‚rification ligne texte
#---------------------------------------------------------------------------
sub check_texte {
   my $nb = $_[0];
   my $decal = $_[1];
   my $ligne = $_[2];

   if ($decal eq "") {
      $lig = $ligne;
   }
   else {
      $lig = substr($ligne, 1);
   }

   $lastaut = substr($ligne, $title_start-1, 1);
   if (($lastaut ne ' ') && ($lastaut ne '&'))
   {
      print "WARNING [Lig $nbligne] Dernier car avant texte non vide [$lastaut]\n"; 
   }
   
   $auteur=substr ($lig, $author_start, $author_size-1);
   $auteur=~s/ +$//o;
   $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

   $genre=substr ($lig, $genre_start, 1);
   $type_c=substr ($lig, $type_start, $type_size);
   $type=substr ($type_c, 0, 1);
   $stype=substr ($type_c, 1, 1);

   $debut=substr ($lig, 0, $title_start);
   $suite=substr ($lig, $title_start);

   $titre="";$vo="";$trad="";$vodate="";$votitre="";
   # separation titre / vo / traducteur
   #----------------------------------
   ($titre, $vo, $trad)=split (/þ/,$suite);
   $titre=~s/ +$//o;

   #--- Traitement titres FR
   # A FAIRE : pas la bonne m‚thode => remplacer par les indices (n, m) de d‚but et fin de chaque titre, et traiter les substring [n, m-n]
   #
   # Exception : meucs / macs
   #
   $type = "titre";
   $d = 0;
   $type = 'T';
   
   for ($i = 1 ; $i < length($titre) ; $i++)
   {
       # si $i = 1 : ras
       # ou si titre[$i] = "]" et si type en cours = "titre" : ras

       if ((substr($titre, $i, 1) eq "[") && ($type eq 'T')) {
          #--- C'est le d‚but du premier cycle -> traiter le titre avant
          $f = $i - 2;
          # traiter pattern de $d … $f
          #
          substr($titre, $d, $f - $d + 1) = traite_fr (substr($titre, $d, $f - $d + 1));
          #--- Le suivant est un cycle
          $type = 'C';
          $d = $i + 1;
       }
       elsif ((substr($titre, $i, 1) eq "]") && ($type eq 'C')) {
          #--- C'est la fin d'un cycle --> traiter le cycle
          $f = $i - 1;
          #    traiter pattern de $d … $f
          #    $newtitre_seul = traite_fr($titre_seul);      
          #
          substr($titre, $d, $f - $d + 1) = traite_fr (substr($titre, $d, $f - $d + 1));
       }
       elsif ((substr($titre, $i, 1) eq "[") && ($type eq 'C')) {
          #--- C'est le d‚but d'un (second) cycle
          $type = 'C';
          $d = $i + 1;
       }
   }

   if ($type eq 'T') {
      # Si type en cours = "titre" (pas de cycle)
      #  traiter pattern de $d … $f (= traiter le titre complet)
      substr($titre, $d, $i - $d) = traite_fr (substr($titre, $d, $i - $d));
   }

   #----------------------------------
   ($vodate, @tabvotitre)=split (/ /,$vo);
   $votitre=join(' ', @tabvotitre);
   $vodate=~s/ +$//o;
   $votitre=~s/ +$//o;

#  print "DBG ligne avant VO : $lig\n";

   #--- Absence date copyright
   if ($vo eq "") {
      print "ERREUR  [Lig $nbligne] Pb date vo [$ligne]\n";
      $vo = " þ?";
      $newlig = $debut . $titre . $vo;
   }
   elsif ($votitre ne "") {
      #    --- 4. Titre VO si anglais => majuscules
      #        => n‚cessite d'avoir … dispo la liste des auteurs anglo-saxon (uk, irlande, usa, australie, nz)
      if ((is_gb($auteur)) && ($votitre ne '?')) {
         $votitre = traite_gb($votitre);
      }
      $newlig = $debut . $titre . " þ" . $vodate . " " . $votitre;
      if ($trad ne "") {
         # Ajout trad si existe
         $newlig = $newlig . " þ" . $trad;
      }
   }
   else {
      $newlig = $debut . $titre . " þ" . $vodate;
      if ($trad ne "") {
         print "WARNING [Lig $nbligne] Pas de titre vo mais trad... [$ligne]\n";
         # Ajout trad si existe
         $newlig = $newlig . " þ" . $trad;
      }
   }


#  print "DBG ligne aprŠs VO : $newlig\n";
   return "${decal}$newlig";
}

#---------------------------------------------------------------------------
# V‚rification ligne multiple : A FAIRE
#---------------------------------------------------------------------------
sub check_multiple {
   my $nb = $_[0];
   my $decal = $_[1];
   my $ligne = $_[2];

   return $ligne;
}

#---------------------------------------------------------------------------
# V‚rification ligne collaborateur : A FAIRE
#---------------------------------------------------------------------------
sub check_collab {
   my $nb = $_[0];
   my $decal = $_[1];
   my $ligne = $_[2];

   return $ligne;
}

#---------------------------------------------------------------------------
# Traitement des titres et cycles fran‡ais
#---------------------------------------------------------------------------
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
      print "WARNING [Lig $nbligne] Premier car minuscule [$pattern]\n"; 
      return $pattern;
   }
#  @listemots = split (/ |'/, $pattern);
   @listemots = split ("[ ']", $pattern);

   @listeadjectifs = ("DixiŠme", "DerniŠre", "DerniŠres", "Dernier", "Derniers", "Grande", "Grandes", "Grand", "Grands",
           "Petite", "Petites", "Petit", "Petits", "12", "5", "7", "Jeune", "Jeunes", "Nobles", "SeptiŠme", "Secondes",
           "Deux", "Trois", "Quatre", "Cinq", "Six", "Sept", "Huit", "Neuf", "Dix", "Vingt-Quatre",
           "Premier", "PremiŠre", "DeuxiŠme", "DeuxiŠmes", "TroisiŠme", "DouziŠme", 
	   "40", "42210", "24", "81", "500", "56", "1001", "Prodigieux", "Prodigieuse", "Prodigieuses",
           "‚trange", "‚tranges", "Nouvel", "Nouvelle", "Nouvelles", "Subtil", "Subtile", "CinquiŠme", "Haut", "Haute",
           "NeuviŠme", "Nouveau", "Nouveaux", "10iŠme", "Vieux", "Vieille", "Vieilles", "Folle", "Prochain", "Prochaine", "Inutile",
           "Ultime", "‚trange", "Abominable", "Infernale", "Affreux", "Affreuse", "Autre", "Hallucinant", "Heureux", "Heureuse", "Horrible", "Interminable",
           "Invincible", "Invisible", "‚ternel", "‚tonnant", "‚tonnante", "‚trange", "Bonne", "Merveilleux", "Merveilleuse",
           "Myst‚rieux", "Myst‚rieuse", "12", "13", "20", "200", "3", "4", "7", "100", "Bon", "Meilleur", "Meilleurs", "Meilleure", "Meilleures",
           "Terrible", "Seconde", "Formidable", "Verte", "Long", "Longs", "Longue", "Longues", "Si", "Beau", "Beaux", "Belle", "Belles",
	   "M‚chant", "M‚chants", "M‚chante", "M‚chantes",
           "Gentil", "Gentils", "Gentille", "Gentilles", "Singulier", "Lamentable", "Lamentables", "Plus", "Vrai", "Vraie", "Insolite", "Insolites",
           "Prudent", "Prudents", "Prudente", "Prudentes", "Imprudent", "Imprudents", "Imprudente", "Imprudentes", "Immortel", "Immortelle",
           "MilliŠme", "CentiŠme", "Probable", "Probables", "Improbable", "Improbables", "Inconcevable", "Affolant", "Affolants", "Affolante", "Affolantes",
           "V‚ritable", "V‚ritables", "Incroyable", "Incroyables", "Effroyable", "Effroyables", "Mauvais", "Mauvaise", "Mauvaises",
	   "Monstrueuse", "Monstrueuses", "Monstrueux"
   );
   # peut pas : fantastique... (la... est OK, mais le... est un nom)

   @listeverbes = ("'ai", "as", "a", "avons", "avez", "ont", "avais", "avait", "n'ont", "n'avait", "n'avaient", "n'a",
                   "suis", "es", "est", "sommes", "ˆtes", "sont", "‚tait", "‚taient",
                   "lŠve", "lŠvera", "tourne", "tournent-elles", "finiront", "sauvera", "contre-attaque", "justifie", "justifient",
                   "reviennent", "vient", "fait", "chante", "pleurent", "reviendra", "existe-t-elle", "s'invitent", "existent",
                   "c'est",  "s'arrˆteront", "s'ouvrait" , "reconnaŒtrez", "s'est", "tombe", "n'aura", "n'est", "aura-t-elle",
                   "marchait", "l'emporte", "peut", "surgit", "j'adore", "‚teignent", "attaquent", "envieront", "trompent",
                   "meurent", "aiment", "continue", "continuent", "poussent", "souviennent", "vengent", "penche", "ramassent",
                   "joue", "nourissent", "marre", "r‚volte", "cachent", "refroidit", "mit", "posa", "casse", "bougent", "venge", "se porte",
                   "noie", "cr‚ent", "meurt", "rebiffe", "voyagent", "mourront", "viennent", "vinrent", "vieillissent", "rient", "sut",
		   "sonnent", "sonne", "mettent", "voit", "voient", "rˆvent-ils", "rˆvent", "retourne", "regarde", "regardent", "regardait",
		   "n'arrange", "n'existe", "bouge", "s'arrˆte", "m'attarde", "va", "coule", "vit", "hante", "bat",
		   "commence", "commencent", "commencera", "commen‡ait"
           );

   # si on ajoute "fait", il faut enlever "qui fait",  "qui a fait", "qu'il fait"
   #  g‚n‚raliser avec les autres verbes...
   # "attaque" … checker... (plus souvent le mot que le verbe)
   # Attention … "l'une rˆve..." / "Le vent souffle"
   # "Le travail bien fait"



   # Si le d‚but est "La ", "Le ", "Les ", "L'"
   $prem2 = substr($pattern, 0, 2);
   $prem3 = substr($pattern, 0, 3);
   $prem4 = substr($pattern, 0, 4);
   if (($prem2 eq "L'") ||
       ($prem3 eq "Le ") ||
       ($prem3 eq "La ") ||
       ($prem4 eq "Les "))
   {
      #----------------------------------------------------------------------------------
      # D'abord on regarde s'il y a un verbe dans la phrase
      #----------------------------------------------------------------------------------
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
            #--- TBC : A FAIRE : condition compl‚mentaire : le verbe est au moins le troisiŠme mot (aprŠs le deuxiŠme espace)
            #------------------------------------------------------------------------
            # si en plus le mot deux commence par une majuscule, faire un warning
            #------------------------------------------------------------------------
            if ($#listemots > 0) {
               $premmot2 = substr($listemots[1], 0, 1);
               if (($premmot2 ge 'A') && ($premmot2 le 'Z')) {
                  print "WARNING [Lig $nbligne] Titre avec verbe et mot 2 en majuscule [$pattern]\n";
               }
            }
            #------------------------------------------------------------------------
            # on arrˆte tout... sauf s'il s'agit de la forme "qui <verbe> ..."
            #------------------------------------------------------------------------
            if ((index ($pattern, "qui $verbe ") == -1) &&
                (index ($pattern, "qui a $verbe ") == -1) &&
                (index ($pattern, "Le jour o— ") == -1) &&
                (index ($pattern, "L… o— ") == -1))
                {
                   return $pattern;
                }
         }
      }

      #----------------------------------------------------------------------------------
      # Si pas de verbe, alors majuscule MAJ sur le mot qui suit
      #----------------------------------------------------------------------------------
      $listemots[1] = ucfirst($listemots[1]);

      #----------------------------------------------------------------------------------
      # Si le mot contient "-", la lettre aprŠs le "-" doit ˆtre en majuscule
      #----------------------------------------------------------------------------------
      $postiret = index($listemots[1], '-');
      if ($postiret != -1) {
         substr($listemots[1], $postiret + 1, 1) = uc(substr($listemots[1], $postiret + 1, 1));
      }

      if (grep (/^$listemots[1]$/, @listeadjectifs)) {
         #----------------------------------------------------------------------------------
         # et si ce premier mot est un adjectif,
         #  Majuscule MAJ sur le mot suivant
         #  ... sauf si petit mot et, du, de... ; ce qui ‚vite les "Le vieux de ...", "La folle et ..." 
         #----------------------------------------------------------------------------------
         if ((length($listemots[2]) > 2) &&
             ($listemots[2] ne "des") &&
             ($listemots[2] ne "qui") &&
             ($listemots[2] ne "aux") &&
             ($listemots[2] ne "sur")) {
            $listemots[2] = ucfirst($listemots[2]);
         }

         #----------------------------------------------------------------------------------
         # Si le mot contient "-", la lettre aprŠs le "-" doit ˆtre en majuscule
         #----------------------------------------------------------------------------------
         $postiret = index($listemots[2], '-');
         if ($postiret != -1) {
            substr($listemots[2], $postiret + 1, 1) = uc(substr($listemots[2], $postiret + 1, 1));
         }

         if (grep (/^\Q$listemots[2]\E$/, @listeadjectifs)) {
            #----------------------------------------------------------------------------------
            # et si ce premier mot est un adjectif,
            #  Majuscule MAJ sur le mot suivant
            #  ... sauf si petit mot et, du, de... ; ce qui ‚vite les "Le vieux de ...", "La folle et ..." 
            #----------------------------------------------------------------------------------
            if ((length($listemots[3]) > 2) &&
                ($listemots[3] ne "des") &&
                ($listemots[3] ne "qui") &&
                ($listemots[3] ne "aux") &&
                ($listemots[3] ne "sur")) {
               $listemots[3] = ucfirst($listemots[3]);
            }

            #----------------------------------------------------------------------------------
            # Si le mot contient "-", la lettre aprŠs le "-" doit ˆtre en majuscule
            #----------------------------------------------------------------------------------
            $postiret = index($listemots[3], '-');
            if ($postiret != -1) {
               substr($listemots[3], $postiret + 1, 1) = uc(substr($listemots[3], $postiret + 1, 1));
            }
         }
      }

   }


   #  Passer au mot suivant et
   #  S'il s'agit d'un " et " => copier dans la liste des titres … v‚rifier (cause : comparaison ou sym‚trie)
   #  Si le titre est suffisemment long, ajouter dans la liste des titres … v‚rifier (cause : v‚rifier si verbe)
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
      print "ERREUR  [Lig $nbligne] : traite_fr [$pattern] --> [$chaine]\n";
      $nbtraite++;
   }
   return $chaine;
}

sub is_gb {
   my $auteur = $_[0];
   $cherche = ($auteur ne "***") && ($auteur ne "?") && grep (/$auteur/, @gb);
#  print "DBG : is gb ? [$auteur] -> [$cherche]\n";

   return $cherche;
}

#---------------------------------------------------------------------------
# Traitement des titres anglo-saxons
#---------------------------------------------------------------------------
sub traite_gb {
   my $pattern = $_[0];

   @list = split (/ /, $pattern);
   @list2 = ();

   #
   # Majuscule au premier mot, puis
   # On boucle sur tous les mots (incluant le ' dans les mots) :
   #
   # Chercher une rŠgle officielle !
   #
   #  Si le mot est :
   #   the, a, an, and, or, nor, but, as, in, on, for, of, to, at, by, from, yet, so, if, much, soon, even, only, when, then, just, now, once, 
   #   who, why, both, also, such, many, than, 
   #
   @smallwords = ('the', 'a', 'an', 'and', 'or', 'nor', 'but', 'as', 'in', 'on', 'for', 'of', 'to', 'at', 'by', 'from', 'yet', 'so', 'if', 'much', 'soon', 'even', 'only', 'when', 'then', 'just', 'now', 'once', 'who', 'why', 'both', 'also', 'such', 'many', 'than');

   foreach $word (@list)
   {
      $cherche = grep (/^\Q$word\E$/, @smallwords);
      if ($cherche == 0) {
         push @list2, ucfirst($word);
      }
      else {
         push @list2, $word;
      }
   }
   $list2[-1] = ucfirst($list2[-1]);

   return join(' ', @list2);
}



