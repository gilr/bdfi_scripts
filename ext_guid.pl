#===========================================================================
#
# Script d'extraction des guides et essais
#
#---------------------------------------------------------------------------
# Historique :
#
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
my $canal=STDOUT;
my $NOCYC=0;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$format="texte";

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 [-t|-x|-w]\n";
   print STDERR "        -t : format texte/csv (separateur=tab) sans liens\n";
   print STDERR "        -l : format texte/csv (separateur=;) avec liens\n";
   print STDERR "        -w, -d : format table dokuwiki\n";
   print STDERR "\n";
   exit;
}
$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-t")
   {
      $format="texte";
   }
   elsif ($ARGV[$i] eq "-x")
   {
      $format="liens";
   }
   elsif (($ARGV[$i] eq "-d") || ($ARGV[$i] eq "-w"))
   {
      $format="doku";
   }
   else
   {
      $choix=&win2dos($ARGV[$i]);
   }
   $i++;
}

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


@etudes=();

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
           AUTEUR=>[""],
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
           AUTEUR=>[""],
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

      # Auteurs et anthologistes regroupés
      $reference->{NB_AUTEUR} = 1;
      $reference->{AUTEUR}[0] = "$auteur";
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
      # A FAIRE
      # Trier le tableau des auteurs & anthologiste ?
#      @listaut=();
#      @listaut1=();
      @listaut = @ { $reference->{AUTEUR} };
      #if (scalar(@listaut) > 2) { print STDERR ">>" . @listaut[0] . " + " . $listaut[1] . "\n"; }
#      $AAA = $listaut[0];
      @listaut1 = sort @listaut;
      # if ($#listaut > 1) { print SDERR sort @listaut; }
#      $BBB = $listaut1[0];
#      if ($AAA ne $BBB) { print STDERR "$AAA (" . $listaut[1]. ") - $BBB (" . $listaut1[1] . ")\n"; }
      @ { $reference->{AUTEUR} } = @listaut1;
      # $BBB = $reference->{AUTEUR}[0];
      
      #-----------------------------------------------------
      # La reference est complete
      #-----------------------------------------------------
      $ref_en_cours = "NOUV_REF";

      # Si reference courante de type ouvrage : memo reference comme "in-ref"
      if ($in == 0)
      {
         $in_ref=$reference;
      }

      # Si OK
      # ajout au tableau

      if (($type eq "G") || ($type eq "E") ||  ($type eq "D") ||
          ($type eq "b") || ($type eq "B") ||  ($type eq "I"))
      {
         if ($in == 0)
         {
            push (@etudes, $reference);
         }
      }
   }
   $old=$lig;
}

# Trier les tableaux
#--------------------
@etudes1=sort tri @etudes;

# Affichage resultats
#---------------------
if ($format eq "doku") {
   print $canal "====== Liste de travail : ouvrages ======\n";
   print $canal "===== inconnu =====\n";
   print $canal "^ auteurs ^ typo ^ titre ^ (c) ^ publi ^ edition ^\n";
}

foreach $item (@etudes1) { &AFFICHE ($item, 0); }

close (OUTP);


#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference
#---------------------------------------------------------------------------
sub AFFICHE {
   local($aa)=$_[0];
   local($type)=$_[1];
   $cycle=$aa->{CYCLE};
   $indice=$aa->{INDICE};
   $scycle=$aa->{CYCLE_S};
   $indice_scycle=$aa->{INDICE_S};
   
   # DEBUT LIGNE
   # voir plus bas

   # Auteur(s)
   $nb_aut = 0;
   while ($nb_aut < $aa->{NB_AUTEUR})
   {
      if ($aa->{AUTEUR}[$nb_aut] ne "***") {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
         if ($nb_aut == 0) {
            if ($initiale_lien ne $old_initiale) {
               print $canal "\n\n===== " . uc($initiale_lien) . " =====\n";
               print $canal "^ auteurs ^ typo ^ titre ^ (c) ^ publi ^ edition ^\n";
            }
            print $canal ($format eq "doku" ? "|" : "");
            $old_initiale=$initiale_lien;
         }
         # intermediaire : ", "
         if ($nb_aut > 0) { print $canal ",\\\\ "; }

         if ($format eq "csv") {
            print $canal &tohtml("<a class='auteur' href='http://www.bdfi.net/auteurs/$initiale_lien/$lien_auteur.php'>");
         }
         elsif ($format eq "doku") {
            print $canal &dos2win("[[http://www.bdfi.net/auteurs/$initiale_lien/$lien_auteur.php|");
         }
         if ($format eq "csv") {
            print $canal &tohtml("$aa->{AUTEUR}[$nb_aut]");
         }
         else {
            print $canal &dos2win("$aa->{AUTEUR}[$nb_aut]");
         }
         if ($format eq "csv") {
            print $canal "</a>";
         }
         elsif ($format eq "doku") {
            print $canal "]]";
         }
      }
      else {
         print $canal ($format eq "doku" ? "|?" : "?");
      }
      $nb_aut++;
    }

   # SEPARATEUR
   print $canal ($format eq "texte" ? "  " : ($format eq "liens" ? ";" : "  |"));
   # type, et hors genres éventuel
   if ($aa->{GENRE} eq "x") { print $canal " HG - " }
   if ($aa->{TYPE} eq "E") { print $canal "Etude" }
   elsif ($aa->{TYPE} eq "G") { print $canal "Guide" }
   elsif ($aa->{TYPE} eq "B") { print $canal "Bibliographie" }
   elsif ($aa->{TYPE} eq "b") { print $canal "Biographie" }
   else { print $canal "?" }
   
   # SEPARATEUR
   print $canal ($format eq "texte" ? "  " : ($format eq "liens" ? ";" : "  |"));
   
   # Titre, titre VO, Traducteur
   $titre_seul = $aa->{TITRE_SEUL};
   if ($format eq "csv") {
      print $canal &tohtml("$titre_seul");
   }
   else
   {
      print $canal &dos2win("$titre_seul");
   }

   if ($aa->{VOTITRE} ne "")
   {
      if ($format eq "csv") {
         print $canal &tohtml(" ($aa->{VOTITRE})");
      }
      else
      {
         print $canal &dos2win(" ($aa->{VOTITRE})");
      }
   }
   if ($aa->{TRAD} ne "")
   {
      if ($format eq "csv") {
         print $canal &tohtml(" - Trad. ($aa->{TRAD})");
      }
      else
      {
         print $canal &dos2win("$titre_seul");
      }
   }
   
   # SEPARATEUR
   print $canal ($format eq "texte" ? "  " : ($format eq "liens" ? ";" : "  |"));
   # date + trad
   print $canal &tohtml("$aa->{VODATE}");
         
   # SEPARATEUR
   print $canal ($format eq "texte" ? "  " : ($format eq "liens" ? ";" : "|"));
   # Date publi   
   print $canal &tohtml("$aa->{DATE}");
   if ($record->{NB_REED} != 0)
   {
      print $canal &tohtml(" (r&eacute;&eacute;d.");
      print $canal &tohtml(" ($record->{REED}[0]");
      $nb_reed = 1;
      while ($nb_reed < $record->{NB_REED})
      {
         print $canal &tohtml(", $aa->{REED}[$nb_reed]");
         $nb_reed++;
      }
   }
   
   # SEPARATEUR
   print $canal ($format eq "texte" ? "  " : ($format eq "liens" ? ";" : "|"));
   # Edition
   &aff_support($canal, $aa, 1, \@sigles);

   # SEPARATEUR
   print $canal ($format eq "doku" ? "  |" : "");

   print $canal &tohtml("\n");
      
}

sub aff_support($$$\@){
   my $canal=$_[0];
   my $record=$_[1];
   my $format=$_[2];
   my @sigles=@{$_[3]};
#print @sigles . "\n";
#foreach $ii (@sigles) { print "$ii"; }
   
   $coll="";
   $loc_coll=$record->{COLL};
   $loc_num=$record->{NUM};
   $loc_typnum=$record->{TYPNUM};
	
   if ($record->{IN} == 0)
   {
      $loc_type=$record->{TYPE};
   }
   else
   {
      $loc_type=$record->{IN_TYPE};
      $loc_in_title=$record->{IN_TITRE};
      # on retire les [[ ... ]] pour les titres "in"
      $loc_in_title=~s/\[\[.*\]\]//o;
      # et on retire aussi les [ ... ] pour les titres "in"
      $loc_in_title=~s/\[.*\]//o;
   }

   foreach $toto (@sigles)
   {
      $refsig=$toto;
      chop($refsig);
      $sigle=substr ($refsig, 2, 7);
      $reste=substr ($refsig, 10);
      ($edc, $periode)=split (/þ/,$reste);
      $edc=~s/ +$//o;
      if ($sigle eq $loc_coll)
      {
         $coll=$edc;
      }
   }

   if ($coll eq "")
   {
      print STDERR "Erreur coll [$coll] - sigle [$loc_coll]\n";
      $coll="(Erreur éditeur/collection)";
   }
   if ($coll eq "?")
   {
      $coll="(Editeurs/collections non connus)";
   }

   print $canal &dos2win("$coll");

   if (($loc_num ne '?') && ($loc_typnum ne 'i'))
   {
      $pos1 = index $loc_num,"(";
      $pos2 = index $loc_num,")";
      if ($pos1 == -1)
      {
         print $canal &dos2win(" nø $loc_num");
      }
      else
      {
         $utile=substr($loc_num, $pos1+1, $pos2-1);
         print $canal " (~$utile)";
      }
   }

}

sub tri
{
   # ----------------------------------------------
   # Auteur
   # Nombre d'auteurs
   # Titre
   # Date publication
   # ----------------------------------------------
   if (uc($a->{AUTEUR}[0]) ne uc($b->{AUTEUR}[0]))
   {
      uc($a->{AUTEUR}[0]) cmp uc($b->{AUTEUR}[0]);
   }
   else
   {
   if ($a->{NB_AUT} != $b->{NB_AUT})
   {
      $a->{NB_AUT} <=> $b->{NB_AUT};
   }
   else
   {
   
   
      if (uc($a->{TITRE}) ne uc($b->{TITRE}))
      {
         uc($a->{TITRE}) cmp uc($b->{TITRE});
      }
      else
      {
         uc($a->{DATE}) cmp uc($b->{DATE});
      }
   }
  }
}

# --- fin ---

