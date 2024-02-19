#===========================================================================
#
# Script d'extraction des guides; encyclo...
#
#---------------------------------------------------------------------------
# Historique :
#
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
#
#===========================================================================
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
my $livraison_site=$local_dir . "/series/pages";

my $ref_en_cours="NOUV_REF";
my $in=0;
my $oldin=0;
my $old_titre="";
my $old_cmt="";
my $canal=0;
my $NOCYC=0;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$no_coll=0;

#---------------------------------------------------------------------------
# Lecture du fichier sigles
#---------------------------------------------------------------------------
$file="sigles.res";
open (f_sig, "<$file");
@sigles=<f_sig>;
close (f_sig);

#---------------------------------------------------------------------------
# Lecture du fichier ouvrages
#---------------------------------------------------------------------------
$file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

#@ext=grep(/$choix/, @ouv);
#$nb=$#ext+1;


foreach $ligne (@ouv)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   chop ($lig);

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $prem=substr ($lig, 0, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   if (($ref_en_cours eq "NOUV_REF") && ($prem eq 'o'))
   {
      #----------------------------------------------
      # Nouvelle reference support
      #----------------------------------------------
      if ($flag_collab_suite eq '&')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <& xxx> non pr�c�d� de <xxx &> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($flag_collab_suite eq '/')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " </ xxx> non pr�c�d� de <xxx /> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($prem ne 'o')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " nouvelle ref et abscene 'o' :\n";
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
         $coll=substr ($lig, $coll_start, $coll_size);
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
           REED=>["","","","","","","","","",""],
           NUM=>"$num",
           TYPNUM=>"$typnum",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","",""],
           CMT_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
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

      if ($reference->{NB_REED} < 10)
      {
         $reference->{REED}[$reference->{NB_REED}] = "$date";
         $reference->{NB_REED} = $reference->{NB_REED} + 1;
      }
      else
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " plus de 10 reeditions ?!\n";
         printf STDERR "$lig\n";
         exit;
      }
   }
   elsif ($prem eq '}')
   {
#     printf STDERR "Tiens, une couverture !\n";
      next;
   }
   elsif ($prem eq ">")
   {
#     printf STDERR "Oh Oh, une note... !\n";
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
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","",""],
           CMT_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
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
      }
      # ligne contenu
      $auteur=substr ($lig, $author_start, $author_size-1);
      $auteur=~s/ +$//o;
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      #-----------------------------------------------------
      # si ligne support : creation d'une nouvelle reference
      #-----------------------------------------------------
      $genre=substr ($lig, $genre_start, 1);
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);

      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      $cycle="";
      $titre_seul="";
      # suppression des doubles [[ et ]]
      #----------------------------------
      $titre =~s/\[\[/\[/go;
      $titre =~s/\]\]/\]/go;
      # separation titre / serie
      #--------------------------
      ($titre_seul, $scycle, $cycle)=split (/\[/,$titre);
      $titre_seul=~s/ +$//o;
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
      if ($indice_cycle eq '') { $indice_cycle = $NOCYC; }
      if ($indice_scycle eq '') { $indice_scycle = $NOCYC; }

      $reference->{GENRE} = "$genre";
      $reference->{TITRE} = "$titre";
      $reference->{TITRE_SEUL} = "$titre_seul";
      $reference->{TYPE} = "$type";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";
      $reference->{CYCLE} = "$cycle";
      $reference->{INDICE} = $indice_cycle;
      $reference->{CYCLE_S} = "$scycle";
      $reference->{INDICE_S} = $indice_scycle;

      # Recherche des anthologistes (marque '*' devant)
      if (substr ($lig, $auttyp_start, 1) eq '*')
      {
         $reference->{NB_ANTHOLOG} = 1;
         $reference->{ANTHOLOG}[0] = "$auteur";
      }
      else
      {
         $reference->{NB_AUTEUR} = 1;
         $reference->{AUTEUR}[0] = "$auteur";
      }
   }
   elsif ($ref_en_cours eq "COLLAB")
   {
      #---------------------------------------------------
      # Collaboration d'auteurs : mise a jour reference
      #---------------------------------------------------
      $auteur=substr ($lig, $author_start, $author_size-1);
      $auteur=~s/ +$//o;
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
            if ($reference->{NB_ANTHOLOG} < 5)
            {
               $reference->{ANTHOLOG}[$reference->{NB_ANTHOLOG}] = "$auteur";
               $reference->{NB_ANTHOLOG} = $reference->{NB_ANTHOLOG} + 1;
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

      # Si OK, ajout au tableau

      if (($type eq "G") || ($type eq "E") || ($type eq "b") || ($type eq "D"))
          ($type eq "h") || ($type eq "I") || ($type eq "B"))
      {
         push (@etudes, $reference);
      }
   }
   $old=$lig;
}


# Affichage resultats
#---------------------

foreach $item (@etudes) { &AFFICHE ($item, 0); }

close (OUTP);


#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference
#---------------------------------------------------------------------------
sub AFFICHE {
   local($aa)=$_[0];
   local($type)=$_[1];

   print "| 
   # auteurs
   # date parution, r��ds.
   # titre
   # date copyr + titre VO + trad
   # edition
   $titre_seul=$aa->{TITRE_SEUL};
   $cycle=$aa->{CYCLE};
   $scycle=$aa->{CYCLE_S};

   if ($type == 0) { $ind = $aa->{INDICE};   }
   else            { $ind = $aa->{INDICE_S}; }

   if ((uc($aa->{TITRE}) ne uc($old_titre))
       || ($aa->{CMT_TYPE} ne $old_cmt)
       || ($aa->{VODATE} ne $old_vodate)
       || ($aa->{AUTEUR}[0] ne $old_aut))
   {
         print $canal "<dt>";
         if ($ind != $NOCYC) {
            &web_data ("<b>$ind.</b> ");
         }
         else
         {
            &web_data ("<b>*</b>&nbsp;&nbsp; ");
         }
         # Si anthologie, chercher idrec
         if ($antho == 1) {
            $idrec=idrec($titre_seul, $cycle, $scycle);
            $url_antho=url_antho($idrec);
            $url_antho="${url_antho}.php";
            &web_data ("<span class='fr'><a class='antho' href='../../recueils/pages/$url_antho'>$titre_seul</a></span> ");
         }
         else {
            &web_data ("<span class='fr'>$titre_seul</span> ");
         }

      $old_titre=$aa->{TITRE};
      $old_cmt=$aa->{CMT_TYPE};
      $old_vodate=$aa->{VODATE};
      $old_aut=$aa->{AUTEUR}[0];

#     if (($aa->{VODATE} ne "") && ($aa->{VODATE} != 0))
      if ($aa->{VODATE} ne "")
      {
            &web_data ("<span class='vo'>($aa->{VODATE}");
            if ($aa->{VOTITRE} ne "")
            {
               &web_data (", $aa->{VOTITRE}");
            }
            &web_data (")</span>");
      }

      $nb_aut = 0;
      while ($nb_aut < $aa->{NB_AUTEUR})
      {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         #mot intermediaire : "avec " / ", " /  " et "
         if ($nb_aut == 0) { print $canal "de "; }
         elsif ($nb_aut+1 == $aa->{NB_AUTEUR}) { print $canal " et "; }
         else  { print $canal ", "; }

            &web_data ("<a class='auteur' href='../../auteurs/$initiale_lien/$lien_auteur.php'>");
            &web_data ("$aa->{AUTEUR}[$nb_aut]");
            &web_data ("</a>");

         $nb_aut++;
       }

       if (($aa->{NB_AUTEUR} > 0) && ($aa->{NB_ANTHOLOG} > 0))
       { 
          print $canal ", "; 
       }
  
       $nb_aut = 0;
       while ($nb_aut < $aa->{NB_ANTHOLOG})
       {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{ANTHOLOG}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         #mot intermediaire : "avec " / ", " /  " et "
         if (($nb_aut == 0) && ($aa->{NB_ANTHOLOG} > 1)) { print $canal " anthologistes "; }
         elsif ($nb_aut == 0) { print $canal " anthologiste "; }
         elsif ($nb_aut+1 == $aa->{NB_ANTHOLOG}) { print $canal " et "; }
         else  { print $canal ", "; }

         if ($aa->{ANTHOLOG}[$nb_aut] ne "***") {
            &web_data ("<a class='auteur' href='../../auteurs/$initiale_lien/$lien_auteur.php'>");
            &web_data ("$aa->{ANTHOLOG}[$nb_aut]");
            &web_data ("</a>");
         }
         else {
            &web_data ("inconnu");
         }

         $nb_aut++;
      }

      if ($aa->{CMT_TYPE} ne "")
      {
         &web_data (" <span class='cmt'>$aa->{CMT_TYPE}</span>");
      }
      print $canal "</dt>\n";
   }

   if ($no_coll == 0)
   {
      print $canal "<dd>";
      &aff_support($canal, $aa, 1, \@sigles);
      print $canal "</dd>\n";
   }
}

# --- fin ---
