#
#
# Programme g‚n‚rique de traitement d'un fichier .col (ou d'une partie, … d‚finir comment)
#
# A COMPLETER (images, r‚‚ditions avec infos et ISBN...)
#
# 

push  (@INC, "c:/util/");
require "bdfi.pm";
require "auteurs.pm";
require "affiche.pm";
require "home.pm";
require "html.pm";


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
$isbn_start=36;                               $isbn_size=17;

#--- intitule
$genre_start=3;
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

#--- couverture
$scan_start= 1;                               $scan_size=16;
$illu_start= 18;                              $illu_size=28;
$dess_start= $title_start;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------

my $ref_en_cours="NOUV_REF";
my $into=0;
my $NOCYC=0;
   # NOUV_REF :
   # NUM_MULT :
   # COLLAB :
   # FIN_SUPPORT :
my $in=0;
my $oldin=0;
my $old_titre="";
my $old_cmt="";
$canal=0;
$canalb=0;

%collec=();

#---------------------------------------------------------------------------
# Lecture du fichier 
#---------------------------------------------------------------------------
$file="tmp.tmp";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

foreach $ligne (@ouv)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   $nblig++;
   chop ($lig);

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $prem=substr ($lig, 0, 1);

   if ($prem eq "_") {
      #-----------------------------------------------------
      # M‚mo des collections du fichier
      # ... !!! Habituellement via lecture fichier des sigles ...
      #-----------------------------------------------------
      $collec{substr($ligne, 2, 7)} = substr($ligne, 10, -1);
      next;
   }
   if ($prem eq "?") {
      #-----------------------------------------------------
      # Ligne non valid‚e, sous r‚serve...
      #-----------------------------------------------------
      $ligne = substr ($ligne, 1);
      $lig=$ligne;
      chop ($lig);
      $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
      $prem=substr ($lig, 0, 1);
   }
   if ($prem eq ">") {
      #-----------------------------------------------------
      # Commentaire "officiel"
      #-----------------------------------------------------
      #--- on saute pour l'instant : mais … stocker ! TBD
      #-----------------------------------------------------
      next;
   }
   if ($prem eq "!") {
      #-----------------------------------------------------
      # Commentaire - On saute !
      #-----------------------------------------------------
      next;
   }
   if (length($lig) == 0) { next; }

   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   if (($ref_en_cours eq "NOUV_REF") && ($prem eq 'o'))
   {
      #----------------------------------------------
      # Nouvelle reference, de type support (niv 0)
      #----------------------------------------------
      if ($flag_collab_suite eq '&')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <& xxx> non pr‚c‚d‚ de <xxx &> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($flag_collab_suite eq '/')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " </ xxx> non pr‚c‚d‚ de <xxx /> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($prem ne 'o')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " nouvelle ref et absence 'o' :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      else
      {
         #---------------------------------------------------------------
         # Creation de la nouvelle reference de niveau 0 (type support)
         #---------------------------------------------------------------
         $into=0;
         $coll=substr ($lig, $coll_start, $coll_size);
         $date=substr ($lig, $date_start, $date_size);
         $date=~s/ +$//o;
         $date=~s/^ +//o;
         $mois=substr ($lig, $mois_start, $mois_size);
         $mois=~s/ +$//o;
         $mois=~s/^ +//o;
         $mois=~s/xx//o;
         $mois=&convmois($mois);
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $typnum=substr ($lig, $typnum_start, 1);
         $isbn="";
         $isbn_type=substr ($lig, $mark_start, $mark_size);
         $isbn=substr ($lig, $isbn_start, $isbn_size);
         if ((substr($isbn, 0, 1) eq '-') || ($isbn_type ne 'ISBN'))
         {
            $isbn_type="NREF";
            $isbn="-";
         }
         if ((substr($isbn, 0, 1) eq '.') || (substr($isbn, -1, 1) eq '.'))
         {
            $isbn_type="INCONNU";
            $isbn="?";
         }

         #------
         #---------
         #---       \ Traitement au fil de l'eau : nouvelle r‚f‚rence
         #----------------------------------------------------------------------------------------------
         print "\nSupport : Date [$date] ISBN [$isbn] Collec [$collec{$coll}] num [$num]\n";
         #----------------------------------------------------------------------------------------------
         #---       / 
         #---------
         #------

         $reference = {
           COLL=>"$coll",
           NUM=>"$num",
           TYPNUM=>"$typnum",
           COMPLET=>"",
           NB_REED=>0,
           DATE=>["$date","","","","","","","","","","","","","",""],
           MOIS=>["$mois","","","","","","","","","","","","","",""],
           ISBN_TYPE=>["$isbn_type","","","","","","","","","","","","","",""],
           ISBN=>["$isbn","","","","","","","","","","","","","",""],
           COUV=>["","","","","","","","","","","","","","",""],
           ILLU=>["","","","","","","","","","","","","","",""],
           DESS=>["","","","","","","","","","","","","","",""],
           HG=>"", G1=>"", G2=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           SSSSC=>"",
           INDICE_SSSSC=>0,
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CYCLE_S2=>"",
           INDICE_S2=>0,
           CYCLE_S3=>"",
           INDICE_S3=>0,
           CYCLE2=>"",
           INDICE2=>0,
           CYCLE3=>"",
           INDICE3=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
           %SOMMAIRE=>(),
         };
      }
   }
   elsif ($prem eq '+')
   {
      #-----------------------------------------------------
      # Reedition : complement de la reference niveau 0
      #-----------------------------------------------------
      $date=substr ($lig, $date_start, $date_size);
      $date=~s/ +$//o;
      $date=~s/^ +//o;
      $mois=substr ($lig, $mois_start, $mois_size);
      $mois=~s/ +$//o;
      $mois=~s/^ +//o;
      $mois=~s/xx//o;
      $mois=&convmois($mois);
      $isbn="";
      $isbn_type=substr ($lig, $mark_start, $mark_size);
      $isbn=substr ($lig, $isbn_start, $isbn_size);
      if ((substr($isbn, 0, 1) eq '-') || ($isbn_type ne 'ISBN'))
      {
         $isbn_type="NREF";
         $isbn="-";
      }
      if ((substr($isbn, 0, 1) eq '.') || (substr($isbn, -1, 1) eq '.'))
      {
         $isbn_type="INCONNU";
         $isbn="?";
      }

      if ($reference->{NB_REED} < 14)
      {
         $reference->{NB_REED} = $reference->{NB_REED} + 1;
         $reference->{DATE}[$reference->{NB_REED}] = "$date";
         $reference->{MOIS}[$reference->{NB_REED}] = "$mois";
         $reference->{ISBN_TYPE}[$reference->{NB_REED}] = "$isbn_type";
         $reference->{ISBN}[$reference->{NB_REED}] = "$isbn";

         #------
         #---------
         #---       \ Traitement au fil de l'eau : R‚‚dition
         #----------------------------------------------------------------------------------------------
         print "R‚‚dition : Date [$date] ISBN [$isbn]\n";
         #----------------------------------------------------------------------------------------------
         #---       / 
         #---------
         #------
      }
      else
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " plus de 14 rééditions ?!\n";
         printf STDERR "$lig\n";
         exit;
      }
   }
   elsif ($prem eq '}')
   {
      $couv=substr ($ligne, $scan_start, $scan_size-1);
      $couv=~s/ +$//o;
      $couv=~s/^ +//o;
      $couv=~s/\.jpg$//o;
      $couv=$couv . ".jpg";
      $reference->{COUV}[$reference->{NB_REED}] = "$couv";

      $illustrateur=substr ($ligne, $illu_start, $illu_size-1);
      $illustrateur=~s/^ +//o;
      $illustrateur=~s/ +$//o;
      $reference->{ILLU}[$reference->{NB_REED}] = "$illustrateur";

      $dessinateurs=substr ($ligne, $dess_start, -1);
      $dessinateurs=~s/^ +//o;
      $dessinateurs=~s/ +$//o;
      $reference->{DESS}[$reference->{NB_REED}] = "$dessinateurs";
      #------
      #---------
      #---       \ Traitement au fil de l'eau : ligne couverture
      #----------------------------------------------------------------------------------------------
      print "couverture : scan [$couv] Illu-couv [$illustrateur] illustrations [$dessinateurs]\n";
      #----------------------------------------------------------------------------------------------
      #---       / 
      #---------
      #------
      next;
   }
   elsif ($ref_en_cours eq "NUM_MULT")
   {
      #----------------------------------------------------------
      # Numero multiple : mise a jour reference niveau 0
      #----------------------------------------------------------
      if ($flag_collab_suite eq '/')
      {
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $reference->{NUM} .= "-" . "$num";

         #------
         #---------
         #---       \ Traitement au fil de l'eau : double num‚ro
         #----------------------------------------------------------------------------------------------
         print "  --> + : numero [$num]\n";
         #----------------------------------------------------------------------------------------------
         #---       /
         #---------
         #------
      }
      else
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <xxx /> non suivi de </ xxx> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
   }
   elsif ((($ref_en_cours eq "FIN_SUPPORT") && ($prem eq '-'))
      ||  (($ref_en_cours eq "NOUV_REF") && (($prem eq '=') || ($prem eq ':'))))
   {
      #-----------------------------------------------------
      # ligne "reference" (contenu principal ou inclus)
      #-----------------------------------------------------
      $into=0;
      if (($prem eq '=') || ($prem eq ':'))
      {
         #-----------------------------------------------------------
         # si texte inclus, nouvelle reference
         #-----------------------------------------------------------
         $into=1;
         $reference = {
           NB_REED=>0,
#          COLL=>"",
#          NUM=>"",
#          TYPNUM=>"",
#          DATE=>"",
#          MOIS=>"",
#          COMPLET=>"",
#          ISBN_TYPE=>"",
#          ISBN=>"",
           HG=>"", G1=>"", G2=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           SSSSC=>"",
           INDICE_SSSSC=>0,
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CYCLE_S2=>"",
           INDICE_S2=>0,
           CYCLE_S3=>"",
           INDICE_S3=>0,
           CYCLE2=>"",
           INDICE2=>0,
           CYCLE3=>"",
           INDICE3=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","","","","","","",""],
           CMT_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
           %SOMMAIRE=>(),
         };

         $reference->{COLL} = $ref_support->{COLL};
         $reference->{NUM} = $ref_support->{NUM};
         $reference->{TYPNUM} = $ref_support->{TYPNUM};
         $reference->{COMPLET} = $ref_support->{COMPLET};
         $reference->{NB_REED} = $ref_support->{NB_REED};
         $reference->{DATE} = $ref_support->{DATE};
         $reference->{MOIS} = $ref_support->{MOIS};
         $reference->{ISBN_TYPE} = $ref_support->{ISBN_TYPE};
         $reference->{ISBN} = $ref_support->{ISBN};
         $reference->{COUV} = $ref_support->{COUV};
         $reference->{ILLU} = $ref_support->{ILLU};
         $reference->{DESS} = $ref_support->{DESS};

         $reference->{IN_TITRE} = $ref_support->{TITRE};
         $reference->{IN_VODATE} = $ref_support->{VODATE};
         $reference->{IN_VOTITRE} = $ref_support->{VOTITRE};
         $reference->{IN_TYPE} = $ref_support->{TYPE};
         $reference->{IN_SOUSTYPE} = $ref_support->{SOUSTYPE};
      }
      # ligne contenu
      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      # Substitution NICOT St‚phane
      if ($auteur eq "NICOT St‚phane") { $auteur = "NICOT S." }
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      #-----------------------------------------------------
      # blblblblblblbl
      #-----------------------------------------------------
      $hg=substr ($lig, $genre_start, 1);
      $g1=substr ($lig, $genre_start + 1, 1);
      $g2=substr ($lig, $genre_start + 2, 1);

      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);
      $complet=substr ($lig, $type_start-1, 1);

      $suite=substr ($lig, $title_start);

      # Temporaire...
      $reference->{TRAD}[0] = "$trad";
      $reference->{ISBN} = "$isbn";

      $reference->{COMPLET} = "$complet";
      $reference->{HG} = "$hg";
      $reference->{G1} = "$g1";
      $reference->{G2} = "$g2";
      $reference->{TITRE} = "$titre";
      $reference->{TITRE_SEUL} = "$titre_seul";
      $reference->{ALIAS_RECUEIL} = "$alias_recueil";
      $reference->{TYPE} = "$type";
      $reference->{SOUSTYPE} = "$stype";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";

      ($reference->{TITRE_SEUL}, $reference->{ALIAS_RECUEIL},
       $reference->{SSSSC}, $reference->{INDICE_SSSSC},
       $reference->{CYCLE_S}, $reference->{INDICE_S},
       $reference->{CYCLE_S2}, $reference->{INDICE_S2},
       $reference->{CYCLE_S3}, $reference->{INDICE_S3},
       $reference->{CYCLE}, $reference->{INDICE},
       $reference->{CYCLE2}, $reference->{INDICE2},
       $reference->{CYCLE3},
       $reference->{INDICE3}) = decomp_titre ($titre, $nblig, $lig);

      # Recherche des anthologistes (marque '*' devant)
      if (substr ($lig, $auttyp_start, 1) eq '*')
      {
         $reference->{NB_ANTHOLOG} = 1;
         $reference->{ANTHOLOG}[0] = "$auteur";
#        print STDERR "antho : $auteur\n";
      }
      else
      {
         $reference->{NB_AUTEUR} = 1;
         $reference->{AUTEUR}[0] = "$auteur";
#        print STDERR "auteur : $auteur\n";
      }

      if (($type eq "p") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Pr‚face]";
      }
      elsif (($type eq "o") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Postface]";
      }
      elsif (($type eq "P") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[PoŠme]";
      }
      elsif (($type eq "T") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[PiŠce de th‚ƒtre]";
      }
      elsif (($type eq "H") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[PiŠce radiophonique]";
      }
      elsif (($type eq "a") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Article]";
      }
      elsif (($type eq "l") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Lettre]";
      }
      elsif ((($type eq "X") || ($type eq "x") || ($type eq "t")) && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Extrait]";
      }
      elsif (($type eq "R") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Roman]";
      }
      elsif (($type eq "Y") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Collecte]";
      }
      elsif (($type eq "E") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Essai]";
      }
      elsif (($type eq "G") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Guide]";
      }
      elsif ((($type eq "N") || ($type eq "n") || ($type eq "u") || ($type eq "R") || ($type eq "r")) && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Recueil]";
      }
      elsif (($type eq "E") && ($type eq "N"))
      {
         $reference->{CMT_TYPE} = "[Essai et nouvelles]";
      }
      elsif (($type eq "P") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Recueil de poŠmes]";
      }
      elsif (($type eq "T") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Recueil de piŠces]";
      }
      elsif (($type eq "U") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Fix-Up]";
      }
      elsif (($type eq "C") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Textes li‚s ou enchass‚s]";
      }

      #------
      #---------
      #---       \ Traitement au fil de l'eau : texte ou recueil
      #----------------------------------------------------------------------------------------------
      $genre = "";
      $sep = "";
      if ($hg eq "?")
      {
         $genre="?";
         $sep = " / ";
      }
      elsif ($hg eq "x")
      {
         $genre="HG";
         $sep = " / ";
      }
      elsif ($hg eq "!")
      {
         $genre="HG"; # non r‚f‚renc‚ seul
         $sep = " / ";
      }
      elsif ($hg eq "p")
      {
         $genre="HG Partiel";
         $sep = " / ";
      }
      $genre = $genre . $sep . &sgenre($g1);

      if (($g2 ne " ") && ($g2 ne "."))
      {
         $genre = $texte . $sep2 . &sgenre($g2);
      }

      $auttyp ="Auteur";
      if (substr ($lig, $auttyp_start, 1) eq '*') {
         $auttyp ="Anthologiste";
      }
      if ($into == 0) {
         print "Ouvrage : ";
      }
      else {
         print "Contient : ";
      }

      print "$auttyp [$auteur] genre [$genre] rnf $reference->{CMT_TYPE} titre [$reference->{TITRE_SEUL}] cycle [$reference->{CYCLE}] # [$reference->{INDICE}]";
      print " (c) [$vodate] vo [$votitre] trad [$trad]\n";
      #----------------------------------------------------------------------------------------------
      #---       / 
      #---------
      #------
   }
   elsif ($ref_en_cours eq "COLLAB")
   {
      #---------------------------------------------------
      # Collaboration d'auteurs : mise a jour reference
      #---------------------------------------------------
      $auteur=substr ($lig, $author_start, $author_size-1);
      $auteur=~s/ +$//o;
      # Substitution NICOT St‚phane
      if ($auteur eq "NICOT St‚phane") { $auteur = "NICOT S." }
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      if ($flag_collab_suite ne '&')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <xxx &> non suivi de <& xxx> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      else
      {
         # test si anthologiste (marque '*' devant)
         $lenaut=length($auteur);
         if (substr ($lig, $auttyp_start, 1) eq '*')
         {
            if ($reference->{NB_ANTHOLOG} < 10)
            {
               $reference->{ANTHOLOG}[$reference->{NB_ANTHOLOG}] = "$auteur";
               $reference->{NB_ANTHOLOG} = $reference->{NB_ANTHOLOG} + 1;
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 10 anthologistes ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
         else
         {
            if ($reference->{NB_AUTEUR} < 15)
            {
               $reference->{AUTEUR}[$reference->{NB_AUTEUR}] = "$auteur";
               $reference->{NB_AUTEUR} = $reference->{NB_AUTEUR} + 1;
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 15 auteurs ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
      }
      #------
      #---------
      #---       \ Traitement au fil de l'eau : auteur compl‚mentaire
      #----------------------------------------------------------------------------------------------
      $auttyp ="Auteur";
      if (substr ($lig, $auttyp_start, 1) eq '*') {
         $auttyp ="Anthologiste";
      }
      print "  --> + : $auttyp [$auteur]\n";
      #----------------------------------------------------------------------------------------------
      #---       / 
      #---------
      #------
   }
   else
   {
      #----------------------------------
      # erreur, arret
      #----------------------------------
      printf STDERR "*** Error line $nblig ***\n";
      printf STDERR " (ref_en_cours, prem) non coherent ($ref_en_cours, '$prem')...\n";
      printf STDERR "$lig\n";
      exit;
   }

   if ($flag_collab_a_suivre eq '&')
   {
      # A suivre...
      $ref_en_cours = "COLLAB";
   }
   elsif ($flag_num_a_suivre eq '/')
   {
      # A suivre... (niveau 0 uniquement)
      $ref_en_cours = "NUM_MULT";
   }
   elsif (($prem eq 'o') || ($prem eq '+') || ($prem eq '/') && ($flag_num_a_suivre ne '/'))
   {
      # Fin de support principal (hors indications reeditions)
      #  reference principale (ou indication reeditions) a suivre...
      $ref_en_cours = "FIN_SUPPORT";
   }
   else
   {
      #-----------------------------------------------------
      # La reference est complete
      #-----------------------------------------------------
      $ref_en_cours = "NOUV_REF";

      # Si reference courante de type ouvrage : memo reference comme "ref_support"
      if ($into == 0)
      {
         $ref_support=$reference;
         #------
         #---------
         #---       \ Traitement r‚f‚rence complŠte
         #----------------------------------------------------------------------------------------------
         print "ICI : reference complete OUVRAGE\n";
         #----------------------------------------------------------------------------------------------
         #---       /
         #---------
         #------

      }
      else
      {
         #------
         #---------
         #---       \ Traitement r‚f‚rence complŠte
         #----------------------------------------------------------------------------------------------
         print "ICI : reference complete CONTENU\n";
         #----------------------------------------------------------------------------------------------
         #---       /
         #---------
         #------

      }

#     if ($reference->{HG} eq "x") { print "[i]"; }
#     elsif ($reference->{GENRE} eq "S") { print "[b][color=blue]"; }
#     elsif ($reference->{GENRE} eq "Y") { print "[color=orange]"; }
#     elsif ($reference->{GENRE} eq "F") { print "[color=crimson]"; }

#     print $reference->{NUM} . " ";
#     print $reference->{TITRE} . " (";
#     print $reference->{VODATE} . ", ";
#     print $reference->{VOTITRE} . "), ";
#     print &traite_auteur($reference->{AUTEUR}[0]) . ", ";
#     print $reference->{TRAD}[0] . ", ";
#     print "ISBN : " . $reference->{ISBN};

#     if ($reference->{HG} eq "x") { print " [/i][Hors Genres]"; }
#     elsif ($reference->{GENRE} eq "S") { print " [Science-fiction][/b][/color]"; }
#     elsif ($reference->{GENRE} eq "Y") { print " [b][Fantasy][/b][/color]"; }
#     elsif ($reference->{GENRE} eq "F") { print " [b][Fantastique, paranormal][/b][/color]"; }
#     elsif ($reference->{GENRE} eq "?") { print " [Sans certitudes...]"; }
#     else { print " [Euh ?!][" . $reference->{GENRE} . "]"; }
#     print "\n";


   }
   $old=$lig;
}

sub traite_auteur {
   local($aa)=$_[0];
   $aa1="";
   $aa2="";
   $aa3="";

   ($aa1, $aa2, $aa3)=split (/ /,$aa);

   if ($aa3 eq "") {
      $aa1 = ucfirst(lc($aa1));
      if (substr($aa1, 0, 2) eq "Mc") { substr($aa1, 2, 1) = uc(substr($aa1, 2, 1)); }
      return $aa2 . " " . $aa1;
   }
   else {
      $b22 = substr($aa2, 1, 1);
      if (($b22 ge "A") && ($b22 le "Z"))
      {
         # Fait partie du nom !
         $aa1 = ucfirst(lc($aa1));
         if (substr($aa1, 0, 2) eq "Mc") { substr($aa1, 2, 1) = uc(substr($aa1, 2, 1)); }
         $aa2 = ucfirst(lc($aa2));
         if (substr($aa2, 0, 2) eq "Mc") { substr($aa2, 2, 1) = uc(substr($aa2, 2, 1)); }
         return $aa3 . " " . $aa1 . " " . $aa2;
      }
      else
      {
         # Fait partie du pr‚nom !
         $aa1 = ucfirst(lc($aa1));
         if (substr($aa1, 0, 2) eq "Mc") { substr($aa1, 2, 1) = uc(substr($aa1, 2, 1)); }
         return $aa2 . " " . $aa3 . " " . $aa1;
      }
   }
}

