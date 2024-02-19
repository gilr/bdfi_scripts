#===========================================================================
#
# Liste tous les romans d'une liste d'auteurs donn‚e
#
#  reprendre … la lettre Q
#
#---------------------------------------------------------------------------
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "auteurs.pm";
require "affiche.pm";
require "home.pm";
require "html.pm";

BEGIN { $| = 1 }

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------
#--- support
$coll_start=2;                                $coll_size=7;
$num_start=10;                                $num_size=5;
$typnum_start=15;
$date_start=17;                               $date_size=4;
$mois_start=22;                               $mois_size=2;

#--- intitule
$genre_start=3;
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------

my $ref_en_cours="NOUV_REF";  # NOUV_REF, NUM_MULT, COLLAB, FIN_SUPP
my $in=0;
my $oldin=0;
$date_min = 1914;
$date_max = 1918;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$no_coll=0;

#---------------------------------------------------------------------------
# Lecture du fichier CLA
#---------------------------------------------------------------------------
$file="cla.col";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

@romans=();
@recueils=();
@nouvelles=();
@poemes=();
@pieces=();
@hors_genre=();
@essais=();
@anthologies=();
@articles=();
$nblig=0;

foreach $ligne (@ouv)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   $nblig++;
   chop ($lig);

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $prem=substr ($lig, 0, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   if ($lig eq '') { next; }
   if ($prem eq ' ') { next; }
   if ($prem eq '_') { next; }
   if ($prem eq '!') { next; }

   if (($ref_en_cours eq "NOUV_REF") && ($prem eq 'o'))
   {
      #----------------------------------------------
      # Nouvelle reference support
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
         printf STDERR " nouvelle ref et abscence 'o' :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      else
      {
         #-----------------------------------------------------
         # si ligne support : creation d'une nouvelle reference
         #-----------------------------------------------------
         $in=0;
#        print STDERR "Nouvelle reference \n";
         $coll=substr ($lig, $coll_start, $coll_size);
#        $coll=~s/ +$//o;
#        $coll=~s/^ +//o;
         $date=substr ($lig, $date_start, $date_size);
         $date=~s/ +$//o;
         $date=~s/^ +//o;
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $typnum=substr ($lig, $typnum_start, 1);

         $reference = {
           COLL=>"$coll",
           DATE=>"$date",
           NB_REED=>0,
           REED=>["","","","","","","","","","","","","","",""],
           NUM=>"$num",
           TYPNUM=>"$typnum",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
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
           AUTEUR=>["","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
         };
      }
   }
   elsif ($prem eq '+')
   {
      $date=substr ($lig, $date_start, $date_size);
      $date=~s/ +$//o;
      $date=~s/^ +//o;
      if ($reference->{NB_REED} < 15)
      {
         $reference->{REED}[$reference->{NB_REED}] = "$date";
         $reference->{NB_REED} = $reference->{NB_REED} + 1;
      }
      else
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " plus de 15 reeditions ?!\n";
         printf STDERR "$lig\n";
         exit;
      }
   }
   elsif ($prem eq '}')
   {
#     printf STDERR "Tiens, une couverture !\n";
      next;
   }
   elsif ($ref_en_cours eq "NUM_MULT")
   {
      #----------------------------------------------
      # Numero multiple : mise a jour reference
      #----------------------------------------------
      if ($flag_collab_suite eq '/')
      {
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $reference->{NUM} .= "-" . "$num";
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
   elsif ((($ref_en_cours eq "FIN_SUPP") && ($prem eq '-'))
      ||  (($ref_en_cours eq "NOUV_REF") && (($prem eq '=') || ($prem eq ':'))))
   {
      #-----------------------------------------------------
      # ligne "reference" (contenu principal ou inclus)
      #-----------------------------------------------------
      $in=0;
      if (($prem eq '=') || ($prem eq ':'))
      {
         # si texte inclus, nouvelle reference
         $in=1;
         $reference = {
           COLL=>"",
           DATE=>"",
           NUM=>"",
           TYPNUM=>"",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
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
           AUTEUR=>["","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
         };

         $reference->{COLL} = $in_ref->{COLL};
         $reference->{DATE} = $in_ref->{DATE};
         $reference->{NB_REED} = $in_ref->{NB_REED};
         $reference->{REED} = $in_ref->{REED};
         $reference->{NUM} = $in_ref->{NUM};
         $reference->{TYPNUM} = $in_ref->{TYPNUM};

         $reference->{IN_TITRE} = $in_ref->{TITRE};
         $reference->{IN_VODATE} = $in_ref->{VODATE};
         $reference->{IN_VOTITRE} = $in_ref->{VOTITRE};
         $reference->{IN_TYPE} = $in_ref->{TYPE};
         $reference->{IN_SOUSTYPE} = $in_ref->{SOUSTYPE};
      }
      # ligne contenu
      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      # Substitution NICOT St‚phane
      if ($auteur eq "NICOT St‚phane") { $auteur = "NICOT S." }
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      #-----------------------------------------------------
      # si ligne support : creation d'une nouvelle reference
      #-----------------------------------------------------
      $genre=substr ($lig, $genre_start, 1);
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);

      $reference->{TITRE} = "$titre";
      $reference->{GENRE} = "$genre";
      $reference->{TYPE} = "$type";
      $reference->{SOUSTYPE} = "$stype";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";

      ($reference->{TITRE_SEUL}, $reference->{ALIAS_RECUEIL}, 
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
#        print STDERR "Mise a jour reference \n";
         # test si anthologiste (marque '*' devant)
         $lenaut=length($auteur);
         if (substr ($lig, $auttyp_start, 1) eq '*')
         {
#            $auteur = substr($auteur,0,$lenaut-1);
            if ($reference->{NB_ANTHOLOG} < 5)
            {
               $reference->{ANTHOLOG}[$reference->{NB_ANTHOLOG}] = "$auteur";
               $reference->{NB_ANTHOLOG} = $reference->{NB_ANTHOLOG} + 1;
#              print STDERR "antho : $auteur\n";
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 5 anthologistes ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
         else
         {
#           print STDERR "auteur : $auteur\n";
            if ($reference->{NB_AUTEUR} < 5)
            {
               $reference->{AUTEUR}[$reference->{NB_AUTEUR}] = "$auteur";
               $reference->{NB_AUTEUR} = $reference->{NB_AUTEUR} + 1;
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 5 auteurs ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
      }
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
      # A suivre...
      $ref_en_cours = "NUM_MULT";
   }
   elsif (($prem eq 'o') || ($prem eq '+') || ($prem eq '/') && ($flag_num_a_suivre ne '/'))
   {
      # Fin de support principal (hors indications reeditions)
      #  reference principale (ou indication reeditions) a suivre...
      $ref_en_cours = "FIN_SUPP";
   }
   else
   {
      #-----------------------------------------------------
      # La reference est complete
      #-----------------------------------------------------
      $ref_en_cours = "NOUV_REF";

      # Si reference courante de type ouvrage : memo reference comme "in-ref"
      if ($in == 0)
      {
         $in_ref=$reference;
      }

      #  print STDERR "$reference->{DATE} - $reference->{VODATE} \n";

      # Si l'auteur cherch‚ fait partie de la liste :
      # ajout au tableau idoine (romans, recueils, nouvelles, anthos...)

      $nb_aut=0;
      if ($reference->{AUTEUR}[0] ne '')
      {
         $reference->{CONTRIB}="a";

            if ((($type eq "N") || ($type eq "n") || ($type eq "r")) && ($stype eq " "))
            {
               # Nouvelle, Short Short ou novella seule
               if ($type eq "r")
               {
                  $reference->{CMT_TYPE} = "[Court roman]";
               }
               elsif ($type eq "n")
               {
                  $reference->{CMT_TYPE} = "[Short short]";
               }
               push (@nouvelles, $reference);
            }
            elsif ((($type eq "R") && ($stype eq " "))
                || (($type eq "U") && ($stype ne " ")))
            {
               # Roman ou Fix-Up
               if ($type eq "U")
               {
                  $reference->{CMT_TYPE} = "[Fix-Up]";
               }
               push (@romans, $reference);
            }
            elsif ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") || ($type eq "A") ||
                    ($type eq "C") || ($type eq "P") || ($type eq "T"))
                && ($stype ne " "))
            {
               # Recueils, Anthologies, Chroniques...
               if ($reference->{GENRE} eq "p")
               {
                  $reference->{CMT_TYPE} = "[Partiel]";
               }
               elsif ($type eq "C")
               {
                  $reference->{CMT_TYPE} = "[Chroniques]";
               }
               elsif ($type eq "P")
               {
                  $reference->{CMT_TYPE} = "[Po‚sies]";
               }
               push (@recueils, $reference);
            }
            elsif (($type eq "X") && ($stype eq " "))
            {
               push (@romans, $reference);
               $reference->{CMT_TYPE} = "[Extrait]";
            }
            elsif (($type eq "Y") && ($stype eq " "))
            {
               push (@pieces, $reference);
               $reference->{CMT_TYPE} = "[Extrait]";
            }
            elsif (($type eq "P") && ($stype eq " "))
            {
               push (@poemes, $reference);
            }
            elsif (($type eq "F") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Novelisation]";
               push (@romans, $reference);
            }
            elsif (($type eq "S") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Novelis. s‚rie TV]";
               push (@romans, $reference);
            }
            elsif (($type eq "V") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Novelis. jeu vid‚o]";
               push (@romans, $reference);
            }
            elsif (($type eq "T") && ($stype eq " "))
            {
               push (@pieces, $reference);
            }
            elsif (($type eq "E") || ($type eq "G"))
            {
               push (@essais, $reference);
            }
            elsif (($type eq "b") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Biographie]";
               push (@essais, $reference);
            }
      }
      else
      {
         $reference->{CONTRIB}="b";
         if ($reference->{ANTHOLOG}[0] ne '')
         {
            if ($reference->{GENRE} eq "x")
            {
               $reference->{CMT_TYPE} = "[Anthologiste de]";
               push (@hors_genre, $reference);
            }
            else
            {
               if ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") || ($type eq "A") ||
                    ($type eq "C") || ($type eq "P") || ($type eq "T"))
                && ($stype ne " "))
               {
                  # Recueils, Anthologies, Chroniques...
                  if ($reference->{GENRE} eq "p")
                  {
                     $reference->{CMT_TYPE} = "[Partiel]";
                  }
               }
               push (@anthologies, $reference);
            }
         }
      }
   }
   $old=$lig;
}


# Trier les tableaux
#--------------------
#
# @romans0=sort tri @romans;
# @recueils0=sort tri @recueils;
# @nouvelles0=sort tri @nouvelles;
# @poemes0=sort tri @poemes;
# @pieces0=sort tri @pieces;
# @hors_genre0=sort tri @hors_genre;
# @antho0=sort tri @anthologies;
# @essais0=sort tri @essais;
@romans0=sort @romans;
@recueils0=@recueils;
@nouvelles0=@nouvelles;
@antho0=@antho;
@essais0=@essais;

# Affichage resultats
#---------------------

   if ($#romans0 + 1 > 0)
   {
      print STDERR " --- Romans :\n";
      foreach $item (@romans0) { &AFFICHE ("ROMAN", $item, 0); }
   }
   if ($#recueils0 + 1 > 0)
   {
      print STDERR "\n --- Recueils, anthologies, omnibus... :\n";
      foreach $item (@recueils0) { &AFFICHE ("ANTHO", $item, 1); }
   }
#  if ($#nouvelles0 + 1 > 0)
#  {
#     print STDERR "\n --- Nouvelles :\n";
#     foreach $item (@nouvelles0) { &AFFICHE ("NOUVELLE", $item, 0); }
#  }
   if ($#antho0 + 1 > 0)
   {
      print STDERR "\n --- Anthologiste de :\n";
      foreach $item (@antho0) { &AFFICHE ("ANTHOLOG", $item, 1); }
   }
   if ($#essais0 + 1 > 0)
   {
      print STDERR "\n --- Essais :\n";
      foreach $item (@essais0) { &AFFICHE ("ESSAI", $item, 0); }
   }


#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference
#---------------------------------------------------------------------------
sub AFFICHE {
   $typetexte=$_[0];
   local($aa)=$_[1];
   $antho=$_[2];

   if (($aa->{COLL} ne "CLA    ") && ($aa->{COLL} ne "CLA_NE ")) { return; }
   $num=$aa->{NUM};
   $titre=$aa->{TITRE};
   $titre_seul=$aa->{TITRE_SEUL};
   $alias_recueil=$aa->{ALIAS_RECUEIL};
   $cycle=$aa->{CYCLE};
   $indice=$aa->{INDICE};
   $sous_cycle=$aa->{CYCLE_S};
   $indice_sous_cycle=$aa->{INDICE_S};
   $sous_cycle2=$aa->{CYCLE_S2};
   $indice_sous_cycle2=$aa->{INDICE_S2};
   $sous_cycle3=$aa->{CYCLE_S3};
   $indice_sous_cycle3=$aa->{INDICE_S3};
   $cycle2=$aa->{CYCLE2};
   $indice2=$aa->{INDICE2};
   $cycle3=$aa->{CYCLE3};
   $indice3=$aa->{INDICE3};

   printf  "Nø %3d ", $num;
   print  "$aa->{DATE} ";
   printf  "%-5s - ", $typetexte;
       
   if ($aa->{CONTRIB} eq "a")
   {
      $nb_aut = 0;
      while ($nb_aut < $aa->{NB_AUTEUR})
      {
         if ($nb_aut != 0) { print  ", "; }
         printf  "%-21s ",$aa->{AUTEUR}[$nb_aut];
         $nb_aut++;
      }
      $nb_aut = 0;
      while ($nb_aut < $aa->{NB_ANTHOLOG})
      {
         if ($nb_aut != 0) { print  ", "; }
         printf  "%-21s ", $aa->{ANTHOLOG}[$nb_aut];
         $nb_aut++;
      }
   }
   else
   {
      $nb_aut = 0;
      while ($nb_aut < $aa->{NB_ANTHOLOG})
      {
         if ($nb_aut != 1) { print  ", "; }
         print  "$aa->{ANTHOLOG}[$nb_aut]";
         $nb_aut++;
      }
      $nb_aut = 0;
      while ($nb_aut < $aa->{NB_AUTEUR})
      {
         if ($nb_aut != 0) { print  ", "; }
         print  "$aa->{AUTEUR}[$nb_aut]";
         $nb_aut++;
      }
   }
   print  &totxt ("$titre");
#  if ($aa->{VOTITRE} ne "")
#  {
#     print  &totxt (" (vo: $aa->{VOTITRE}, ");
#  }
#  else
#  {
#     print  &totxt (" (");
#  }

#  print  "$aa->{VODATE})";
#  print  "	";

   print  "\n";

#
#  A FAIRE : CONSERVER ?
#
#  if ($no_coll == 0)
#  {
#     print  "<br />";
#     &aff_support($canal, $aa, 1, \@sigles);
#     print $canal "\n";
#  }
}

# --- fin ---

