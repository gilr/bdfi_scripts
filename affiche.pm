#===========================================================================
# Module AFFICHE.PM
#
# Utilitaires d'affichages references
#
# aff_titre
# aff_support
#
#
#===========================================================================
require "home.pm";
require "bdfi.pm";

#---------------------------------------------------------------------------
# Subroutine affichage titre
#
# Parametres :
#   - canal de sortie
#   - enregistrement
#   - format (non utilisé pour l'instant)
#
# Dans un premier temps
#  format = 1 (sans lien mˆme si recueil)
#  format = 2 (avec lien si recueil)
#
# Futur : 
#   Format du format : "%T [%C] (%V, %O) de %A Trad. %F"
# Actuel : 
#  format = "TCVOAF"
#---------------------------------------------------------------------------
sub aff_titre ($$$) {
   local($canal)=$_[0];
   local($record)=$_[1];
   local($format)=$_[2];

   # Affichage Titre
   #-----------------------
   my $titre=$record->{TITRE_SEUL};
   my $alias_recueil=$record->{ALIAS_RECUEIL};
   my $cycle=$record->{CYCLE};

   my $cp=$cycle->{CP};
   my $ip=$cycle->{IP};
   my $cs=$cycle->{CS};
   my $is=$cycle->{IS};

#  if ($record->{AFF_TYPE} ne "")
#  {
#     print $canal &tohtml("<i>");
#  }

   # Si format = 2 (affichage lien recueil)
   # et si class‚ dans les recueils OU si Fix-Up avec sommaire
   if (($format eq 2) &&
       (($record->{TYPE} eq "N") || ($record->{TYPE} eq "n") || ($record->{TYPE} eq "R") || ($record->{TYPE} eq "r") ||
        ($record->{TYPE} eq "A") || ($record->{TYPE} eq "C") || ($record->{TYPE} eq "Y") ||
        ($record->{TYPE} eq "P") || ($record->{TYPE} eq "T") || ($record->{TYPE} eq "U")) &&
       ($record->{SOUSTYPE} ne " "))
   {
      if ($alias_recueil ne "")
      {
         $idrec=idrec($alias_recueil, "", "");
      }
      else
      {
         $idrec=idrec($titre, $cp, $cs);
      }
      $url_antho=url_antho($idrec);
      $url_antho="${url_antho}.php";
      print $canal &tohtml("<span class='fr'><a class='antho' href='../../recueils/pages/$url_antho'>$titre</a>");
   }
   else {
      if ($record->{AFF_TYPE} ne "")
      {
         print $canal &tohtml("<span style='color:#666;'>$titre");
      }
      else
      {
         print $canal &tohtml("<span class='fr'>$titre");
      }
   }
   # --- Fin en cours : 

   # Affichage Cycle
   #-----------------------
   if ($cs ne "")
   {
      # Pas de lien pour l'instant
      # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
      print $canal &tohtml(" [$cs");
      if (($is ne "") && ($is != 0))
      {
         print $canal &tohtml(" - $is");
      }
      print $canal "]\n";
   }
   if ($cp ne "")
   {
      # nom du lien sur le cycle
      $lien_serie=&url_serie($cp);
      print $canal &tohtml(" [<a class=\"cycle\" href=\"../../series/pages/$lien_serie.php\">");
      if (($titre_seul eq $cp) && ($ip eq "")) {
         print $canal "*";
      }
      else {
         print $canal &tohtml("$cp");
      }
      print $canal "</a>";
      if (($ip ne "") && ($ip != 0))
      {
         print $canal &tohtml(" - $ip");
      }
      print $canal "]\n";
   }
   print $canal "</span>";

   if ($record->{VODATE} ne "")
   {
      if ($record->{AFF_TYPE} ne "")
      {
         print $canal &tohtml(" <span style='color:#446;'>($record->{VODATE}");
      }
      else
      {
         print $canal &tohtml(" <span class=\"vo\">($record->{VODATE}");
      }
      if ($record->{VOTITRE} ne "")
      {
         print $canal &tohtml(", $record->{VOTITRE}");
      }
      print $canal ")</span>";
   }

   $nb_aut = 0;
   while ($nb_aut < $record->{NB_AUTEUR})
   {
      # nom du lien, et initiale
      $lien_auteur=&url_auteur($record->{AUTEUR}[$nb_aut]);
      $initiale_lien=substr ($lien_auteur, 0, 1);
      $initiale_lien=lc($initiale_lien);
   
      #mot intermediaire : "avec " / ", " /  " et "
      if ($nb_aut == 0) {
         if (($record->{TYPE} eq "Y") && ($record->{SOUSTYPE} ne " ")) {
            print $canal ", collecte de ";
         }
	 else {
            print $canal " de ";
         }
      }
      elsif ($nb_aut+1 == $record->{NB_AUTEUR}) { print $canal " et "; }
      else  { print $canal ", "; }

      $url_test=$local_dir . "/auteurs/${initiale_lien}/${lien_auteur}.php";
      $nf=1;
# print STDERR "$url_test\n";
      open(AUTHOR, "<$url_test") or $nf=0;
      if ($nf == 1)   # si le lien existe
      {
         print $canal &tohtml("<a class='auteur' href=\"../../auteurs/$initiale_lien/$lien_auteur.php\">");
         print $canal &tohtml("$record->{AUTEUR}[$nb_aut]");
         print $canal "</a>";
      } else {
         print $canal &tohtml("<span class='auteur'>$record->{AUTEUR}[$nb_aut]</span>");
      }

      $nb_aut++;
   }

#  if (($record->{NB_AUTEUR} > 0) && ($record->{NB_ANTHOLOG} > 0))
#  { 
#     print $canal ", "; 
#  }
  
   $nb_aut = 0;
   while ($nb_aut < $record->{NB_ANTHOLOG})
   {
      # nom du lien, et initiale
      $lien_auteur=&url_auteur($record->{ANTHOLOG}[$nb_aut]);
      $initiale_lien=substr ($lien_auteur, 0, 1);
      $initiale_lien=lc($initiale_lien);

      # A FAIRE : si antho "***", ne pas afficher ou mettre "inconnu" sans lien

      #mot intermediaire : "avec " / ", " /  " et "
      if (($nb_aut == 0) && ($record->{NB_ANTHOLOG} > 1)) { print $canal ", anthologistes "; }
      elsif ($nb_aut == 0) { print $canal ", anthologiste "; }
      elsif ($nb_aut+1 == $record->{NB_ANTHOLOG}) { print $canal " et "; }
      else  { print $canal ", "; }

      if ($record->{ANTHOLOG}[$nb_aut] eq '***')
      {
         print $canal "inconnu";
      }
      else
      {
         $url_test=$local_dir . "/auteurs/${initiale_lien}/${lien_auteur}.php";
         $nf=1;
# print STDERR "$url_test\n";
         open(AUTHOR, "<$url_test") or $nf=0;
         if ($nf == 1)   # si le lien existe
         {
            print $canal &tohtml("<a class=\"auteur\" href=\"../../auteurs/$initiale_lien/$lien_auteur.php\">");
            print $canal &tohtml("$record->{ANTHOLOG}[$nb_aut]");
            print $canal "</a>";
         } else {
            print $canal &tohtml("<span class='auteur'>$record->{ANTHOLOG}[$nb_aut]</span>");
         }
      }

      $nb_aut++;
   }

#  if ($record->{AFF_TYPE} ne "")
#  {
#     print $canal &tohtml("</i>");
#  }
   if ($record->{CMT_TYPE} ne "")
   {
      if ($record->{AFF_TYPE} eq "NO")
      {
         print $canal &tohtml(" <span style='color:#226'>$record->{CMT_TYPE}</span>");
      }
      else
      {
         print $canal &tohtml(" <span class=\"cmt\">$record->{CMT_TYPE}</span>");
      }
   }

}

sub aff_section ($$$)
{
   local($canal)=$_[0];
   local($record)=$_[1];
   local($format)=$_[2];

   # Affichage Titre
   #-----------------------
   my $titre=$record->{TITRE_SEUL};
   my $cycle=$record->{CYCLE};

   my $cp=$cycle->{CP};
   my $ip=$cycle->{IP};
   my $cs=$cycle->{CS};
   my $is=$cycle->{IS};

   print $canal &tohtml("<b><span class=\"cmt\">Groupement de textes</span></b> - <span class=\"fr\">$titre");

   # Affichage Cycle
   #-----------------------
   if ($cs ne "")
   {
      # Pas de lien pour l'instant
      # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
      print $canal &tohtml(" [$cs");
      if (($is ne "") && ($is != 0))
      {
         print $canal &tohtml(" - $is");
      }
      print $canal "]\n";
   }
   if ($cp ne "")
   {
      # nom du lien sur le cycle
      $lien_serie=&url_serie($cp);
      print $canal &tohtml(" [<a class=\"cycle\" href=\"../../series/pages/$lien_serie.php\">");
      if (($titre_seul eq $cp) && ($ip eq "")) {
         print $canal "*";
      }
      else {
         print $canal &tohtml("$cp");
      }
      print $canal "</a>";
      if (($ip ne "") && ($ip != 0))
      {
         print $canal &tohtml(" - $ip");
      }
      print $canal "]\n";
   }
   print $canal "</span>";

   if ((($record->{VODATE} ne "") && ($record->{VODATE} ne "?")) ||
       (($record->{VOTITRE} ne "") && ($record->{VOTITRE} ne "?")))
   {
      print $canal &tohtml(" <span class=\"vo\">(");
      if ($record->{VODATE} ne "?") {
         print $canal &tohtml("$record->{VODATE}, ");
      }
      if ($record->{VOTITRE} ne "")
      {
         print $canal &tohtml("$record->{VOTITRE}");
      }
      print $canal ")</span>";
   }

   if ($record->{CMT_TYPE} ne "")
   {
      print $canal &tohtml(" <span class=\"cmt\">$record->{CMT_TYPE}</span>");
   }
#   print $canal "\n";
}


#---------------------------------------------------------------------------
# Subroutine affichage publication (support)
#
# Parametres :
#   - canal de sortie
#   - enregistrement
#   - format (non utilisé pour l'instant)
#   - reference sur le tableau des sigles
#
#---------------------------------------------------------------------------
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
   $loc_date=$record->{DATE};
	
   if ($record->{IN} == 0)
   {
      $loc_type=$record->{TYPE};
   }
   else
   {
      $loc_type=$record->{IN_TYPE};
      $loc_soustype=$record->{IN_SOUSTYPE};
      $loc_in_titre=$record->{IN_TITRE};
      ($loc_in_titre_seul, $loc_in_scycle, $loc_in_cycle)=split (/\[/,$loc_in_titre);
      $loc_in_scycle=~s/\]//o;
      $loc_in_scycle=~s/\]//o;
      $loc_in_cycle=~s/\]//o;
      $loc_in_cycle=~s/\]//o;
#   print STDERR "DBG loc_in_titre_seul : [$loc_in_titre_seul] \n";
#   print STDERR "DBG loc_in_scycle : [$loc_in_scycle] \n";
#   print STDERR "DBG loc_in_cycle : [$loc_in_cycle] \n";

      # Extraire l'alias recueil s'il est indiqu‚
      #-----------------------------------------------
      ($loc_in_titre_seul, $loc_in_alias_recueil)=split (/\(\(/, $loc_in_titre_seul, 2);
      $loc_in_titre_seul=~s/ +$//o;
      $loc_in_alias_recueil=~s/ +$//o;
      $loc_in_alias_recueil=~s/\)\)$//o;

      $loc_in_titre_seul=~s/ +$//o;
      if ($loc_in_scycle ne "")
      {
         $loc_in_scycle=~s/\]//o;
         if ($loc_in_cycle ne "")
         {
            $loc_in_cycle=~s/\]//o;
         }
         else
         {
            $loc_in_cycle=$loc_in_scycle;
            $loc_in_scycle="";
         }
      }
      ($loc_in_cycle, $loc_in_indice_cycle)=split (/ \- /,$loc_in_cycle);
      ($loc_in_scycle, $loc_in_indice_scycle)=split (/ \- /,$loc_in_scycle);
      # on retire les [[ ... ]] pour les titres "in"
#     $loc_in_title=~s/\[\[.*\]\]//o;
      # et on retire aussi les [ ... ] pour les titres "in"
#     $loc_in_title=~s/\[.*\]//o;
   }

   foreach $toto (@sigles)
   {
      $refsig=$toto;
      chop($refsig);
      $sigle=substr ($refsig, 2, 7);
      $reste=substr ($refsig, 10);
      ($edc, $periode)=split (/þ/,$reste);
      ($edc2, $trucs)=split (/ \[/,$edc);
      $edc2=~s/ +$//o;
      if ($sigle eq $loc_coll)
      {
         $coll=$edc2;
      }
   }

   if ($coll eq "")
   {
      print STDERR "Erreur coll [$coll] - sigle [$loc_coll]\n";
      $coll="(Erreur ‚diteur/collection)";
   }
   if ($coll eq "?")
   {
      $coll="(Editeurs/collections non connus)";
   }

   if ($record->{IN} == 1)
   {
      print $canal "<b>in</b> ";

      # si recueil, anthologie, ou omnibus, indiquer le titre du recueil
      #  (ne PAS afficher ce titre si magazine/revue/fanzine)
      # ------------------------------------------------------------------------
      if (($loc_type ne "M") && ($loc_type ne "Q"))
      {
#        if (($antho == 1) && ($loc_type ne 'P'))
         if (($loc_type ne 'P') && ($loc_soustype ne ' ')) {
            if ($loc_in_alias_recueil ne "")
            {
               $loc_idrec=idrec($loc_in_alias_recueil, "", "");
            }
            else
            {
               $loc_idrec=idrec($loc_in_titre_seul, $loc_in_cycle, $loc_in_scycle);
            }

            $loc_url_antho=url_antho($loc_idrec);
            $loc_url_antho="${loc_url_antho}.php";
            print $canal &tohtml("<i><a class='in-antho' href='../../recueils/pages/$loc_url_antho'>$loc_in_titre_seul</a>");
         }
         else {
            print $canal &tohtml("<i>$loc_in_titre_seul");
         }
         if ($loc_type eq "U")
         {
            print $canal &tohtml(" <span class=\"cmt\">(Fix-Up)</span>");
         }
         print $canal "</i>, ";
      }
   }
   print $canal &tohtml("$coll");

   if (($loc_num ne '?') && ($loc_typnum ne 'i'))
   {
      $pos1 = index $loc_num,"(";
      $pos2 = index $loc_num,")";
      if ($pos1 == -1)
      {
         print $canal &tohtml(" nø $loc_num");
      }
      else
      {
         $utile=substr($loc_num, $pos1+1, $pos2-1);
         print $canal " (~$utile)";
      }
   }

   print $canal &tohtml(", $loc_date");

   if ($record->{NB_REED} != 0)
   {
      print $canal &tohtml(" (<span class=\"reed\">r&eacute;&eacute;d.</span> $record->{REED}[0]");
      $nb_reed = 1;
      while ($nb_reed < $record->{NB_REED})
      {
         print $canal &tohtml(", $record->{REED}[$nb_reed]");
         $nb_reed++;
      }
      print $canal ")";
   }
   else
   {
      print $canal ".";
   }

}

#---------------------------------------------------------------------------
# Fin du module AFFICHE
#---------------------------------------------------------------------------
1;


