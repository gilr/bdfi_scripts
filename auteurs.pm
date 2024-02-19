#===========================================================================
# Module AUTEURS.PM
#
# Fonction d'affichage des bios
#   aff_bio
#   transfo_date
#   aff_data_bio
#   aff_text_bio
#
#  v 1.0  : 
#  v 1.1  :  
#  v 1.2  :  24-03-2009 - Format auteurs : nom, pr‚nom d‚corr‚l‚s + ajout site
#  v 1.3  :  12-11-2009 - Suppression du "(?)" pour date naissance inconnue
#
#
#===========================================================================

my $pages_auteurs="..";
#---------------------------------------------------------------------------
# Fonction d'affichage bio
#---------------------------------------------------------------------------
sub aff_bio
{
   $choix=$_[0];
   $sortie=$_[1];

# print STDERR "AFF_BIO $choix SUR $sortie\n";
   
   #---------------------------------------------------------------------------
   # Ouverture du fichier auteurs.txt (export MS-DOS txt de excel)
   #---------------------------------------------------------------------------
   #$file="c:/auteurs.txt";
   $file="auteurs.txt";
#  print STDERR "file: $file \n";
   open (f_bio, "<$file");
   @bio=<f_bio>;
   close (f_bio);
   
   # $ibio=0;
   # $maxbio=$#bio;
   
   $ok=0;
   $meme_renvoi='';
   $voir_vrai='';
   $nom_vrai='';
   @liste_pseus=();
   @liste_noms=();
   @cf_renvois=();
   $cf_renvoi=();
   @voir_vrais=();

   #------------------------------------------------------------
   # Recherche de l'auteur dans le fichier
   #  pour affichage informations biographiques de l'auteur
   #  Si renvoi, memorisation pour usage ult‚rieur
   #------------------------------------------------------------
   foreach $lig (@bio)
   {
#     chop($lig);

      #------------------------------------------------------------
      #  pour chaque entree de auteurs.txt
      #------------------------------------------------------------
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$renvoi,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      # gerer les simples ou multiples
      # OLD $key=~s/ +$//g;
      $key="$key1 $key2";
      $key=~s/ +$//g;
      if ($key eq $choix)
      {
         #------------------------------------------------------------
         # l'auteur est trouv‚, on peut commencer a afficher l'entˆte
         #------------------------------------------------------------
         $ok=1;
         $nation=$pays;
         $nation=~s/ +$//o;
         $nation=~s/^ +//o;
         $flag=&noacc(lc($nation));
         $flag=~s/-/_/og;
         $flag=~s/ /_/og;
         print $canal "<div>";
         $memo = "<em><strong>$nom</strong></em><br />";
         $tsite_ok=$tsite;
         $site_ok=$site;

         #------------------------------------------------------------
         # Pseudonyme, indiquer le vrai nom
         #------------------------------------------------------------
         $memo = $memo . ($pseu eq 'P' ? 'Pseudonyme' : '');
         $vrai=~s/ et /<\/b> et <b>/g;
         $vrai=~s/ + /<\/b> et <b>/g;
         $vrai=~s/^ +//g;
         if ($vrai ne '') {
            $memo = $memo . ($pseu eq 'P' ? " de " : '');
            $memo = $memo . "<b>$vrai</b>.";
         }
         $memo = $memo . (($pseu eq 'P') || ($vrai ne '') ? "<br />" : '');
         #------------------------------------------------------------
         # ICI, on pourrait mettre le lien sur le vrai nom si la page existe
         #------------------------------------------------------------
         # print $canal &tohtml(' (Voir les parutions sous ce nom)<br />\n');
   
         if (($renvoi eq '') || ($renvoi eq ' '))
         {
            #------------------------------------------------------------
            # Pas de renvoi,
            #  les informations sont ici, dans l'enregistrement lu
            #  Affichage des donnees biographiques et du texte
            #------------------------------------------------------------
            print $canal "<div style='padding:0; margin:0 10px 0 0; float:right;'>";
            if ($nation eq '?') {
              print $canal "<img src='../../images/drapeaux/incnat.png' alt='nationalit&eacute; inconnu' />";
            }
            else {
              print $canal "<img src='../../images/drapeaux/${flag}.png' alt='Drapeau $nation' />";
            }
            print $canal "</div>";
            print $canal &tohtml($memo);
            $nbrenvoi = 0;
            &aff_data_bio($pays, $sexe, $date1, $date2, $lieu1);
            print $canal &tohtml (&aff_text_bio($bio));
         }
         else
         {
            #------------------------------------------------------------
            # Renvoi
            # Memo du renvoi, pour recherche de renvois equivalents
            # Determiner si renvoi simple ou multiple
            #------------------------------------------------------------
            $cf_renvoi = $renvoi;
            @cf_renvois = split (/\+/, $renvoi);
            $nbrenvoi = $#cf_renvois + 1;
printf STDERR " $nbrenvoi renvoi direct -- $cf_renvoi [$renvoi]\n";
            if ($nbrenvoi > 1)
            {
               #------------------------------------------------
               # Renvoi multiple, v‚rifier la pr‚sence d'infos
               #  et si oui les afficher
               #------------------------------------------------
               print $canal &tohtml (&aff_text_bio($bio));
            }
         }
      }
   }

   #------------------------------------------------------------
   # Pour chaque reference sur lequel l'auteur est renvoy‚,
   #  recherche de l'entr‚e.
   #  Si le renvoi est unique, affichage des infos
   #  Dans tous les cas, memoriser la liste des liens
   #------------------------------------------------------------
   @list_liens_nom=();
   @list_liens_url=();
   foreach $cfr (@cf_renvois)
   {
      $cfr=~s/^ +//;
      $cfr=~s/ +$//;
      #--------------------------------------------------------
      # Recherche de la reference du renvoi
      #--------------------------------------------------------
      foreach $lig (@bio)
      {
#        chop($lig);
         ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
         #$key=~s/ +$//;
         $key="$key1 $key2";
         $key=~s/ +$//g;
         if ($key eq $cfr)
         {
printf STDERR " $nbrenvoi renvoi(s) indirects -- $cfr [$lig]\n";
            if ($nbrenvoi <= 2)
            {
               #--------------------------------------------------------
               # renvoi unique :
               # affichage de la bio (donn‚es et texte) du renvoi
               #--------------------------------------------------------
               $nation=$pays;
               $nation=~s/ +$//o;
               $nation=~s/^ +//o;
               $flag=&noacc(lc($nation));
               $flag=~s/-/_/og;
               $flag=~s/ /_/og;
               if ($nbrenvoi >= 2) {
                  print $canal &tohtml($memo);
                  print $canal "<br />\n";
                  $memo = "";
               }
               print $canal "<div style='padding:0; margin:0 10px 0 0; clear:both; float:right;'>";
               if ($nation eq '?') {
                  print $canal "<img src='../../images/drapeaux/incnat.png' alt='nationalit&eacute; inconnu' />";
               }
               else {
                  print $canal "<img src='../../images/drapeaux/${flag}.png' alt='Drapeau $nation' />";
               }
               print $canal "</div>";
               if ($nbrenvoi == 1) {
                  print $canal &tohtml($memo);
               }
               if ($nbrenvoi >= 2) {
                  print $canal &tohtml("<strong>&nbsp;&rarr;&nbsp;$nom</strong><br />");
               }
               &aff_data_bio($pays, $sexe, $date1, $date2, $lieu1);
               print $canal &tohtml (&aff_text_bio($bio));
            }
            $voir_vrai=$key;
            $nom_vrai=$nom;

            #--------------------------------------------------------
            # Si le lien existe, 
            #  affichage du lien vers le(s) nom(s) v‚ritable(s)
            #  A FAIRE
            #  Memoriser le lien si la page existe
            #--------------------------------------------------------
# printf STDERR "TEST lien $voir_vrai\n";
            ($exist_vrai, $url) = &exist_auteur($pages_auteurs, $voir_vrai);
            if ($exist_vrai == 1)   # lien existe
            {
               push (@list_liens_nom, $nom_vrai);
               push (@list_liens_url, $url );
            }
         }
      }
   }
   #-----------------------------------------------------------------
   # Affichage des liens vers le nom sur lequel l'auteur est renvoy‚
   #-----------------------------------------------------------------
   if ($#list_liens_nom >= 1)
   {
      print $canal &tohtml("Voir ‚galement les parutions sous leurs v‚ritables noms, ");
   }
   elsif ($#list_liens_nom >= 0)
   {
#     print $canal &tohtml("Voir ‚galement les parutions sous son v‚ritable nom, ");
      print $canal &tohtml("Voir ‚galement les parutions sous le nom ");
   }
   $il=0;
   $exist_lien=0;
   foreach $nom_vrai (@list_liens_nom)
   {
      $exist_lien=1;
      if ($il != 0)
      {
         print $canal ", ";
      }
      $url=$list_liens_url[$il];
      print $canal &tohtml("<a class=\"auteur\" href=\"$url\">");
      print $canal &tohtml("$nom_vrai");
      print $canal "</a>";
      $il++;
   }

   #--------------------------------------------------------
   # Recherche des autres pseudo (ou non) pour liens
   #--------------------------------------------------------
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$renvoi,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      #$key=~s/ +$//;
      $key="$key1 $key2";
      #--- Correction GR 16/12/2010
      $key=~s/ +$//;
      #--- Fin correction 16/12/2010
      @renvois = split (/\+/, $renvoi);
      $nbr = $#renvois + 1;
      $renvois[0]=~s/^ +//;
      $renvois[0]=~s/ +$//;
      $renvois[1]=~s/^ +//;
      $renvois[1]=~s/ +$//;
      $cf_renvois[0]=~s/^ +//;
      $cf_renvois[0]=~s/ +$//;
      $cf_renvois[1]=~s/^ +//;
      $cf_renvois[1]=~s/ +$//;
      if (($key ne $choix) &&
         ((($nbr > 0) && ($renvois[0] eq $cf_renvois[0]))
       || (($nbr > 1) && ($renvois[1] eq $cf_renvois[0]))
       || (($nbr > 0) && ($renvois[0] eq $choix))
       || (($nbr > 1) && ($renvois[1] eq $choix))
       || (($nbrenvoi > 0) && ($key ne $choix) && ($renvois[0] eq $cf_renvois[0]))
       || (($nbrenvoi > 1) && ($key ne $choix) && ($renvois[0] eq $cf_renvois[1]))))
      {
print STDOUT "KEY [$key] P[$pseu] RENVOI [$renvoi] CHOIX [$choix] renv0 [$cf_renvoi] \n";

         if ($pseu eq 'P')
         {
            # Pseudos, avec ou sans lien
            # --> Memo des pseudos avec existence du lien
            ($exist, $url) = &exist_auteur($pages_auteurs, $key);
            if ($exist == 1)   # lien existe
            {
               push (@liste_pseus, $lig);
            }
print STDOUT "url [$url]\n";
            # --> Memo des pseudos sans liens ?
         }
         else
         {
            # lien, non pseudo
            # --> Memo des noms avec existence du lien
            ($exist, $url) = &exist_auteur($pages_auteurs, $key);
            if ($exist == 1)   # lien existe
            {
               push (@liste_pseus, $lig);
               push (@liste_noms, $lig);
            }
         }
             
      }
   }

   if (scalar (@liste_pseus) == 0)
   {
      #----------------------------------------------------
      # Pas de liens pseudonymes, fin de l'affichage lien
      #----------------------------------------------------
      if ($exist_vrai == 1)   # lien existe
      {
         print $canal ".<br />\n";
      }
   }
   elsif (scalar (@liste_pseus) > 0)
   {
      #----------------------------------------------------
      # Il existe des liens sur pseudo, les afficher
      #----------------------------------------------------
      if ($exist_lien == 1)   # lien existe
      {
         print $canal &tohtml(", ainsi que celles sous ");
      }
      else
      {
         print $canal &tohtml("Voir ‚galement les parutions sous ");
      }
   
      if (scalar (@liste_pseus) > 1)
      {
         print $canal &tohtml("les signatures ");
      }
      elsif (scalar (@liste_pseus) > 0)
      {
         print $canal &tohtml("la signature ");
      }
      $suite=0;
      #----------------------------------------------------
      # AprŠs le blabla, les liens
      #----------------------------------------------------
      foreach $autre (@liste_pseus)
      {
         if ($suite == 1)
         {
            print $canal ", ";
         }
         $suite=1;
         ($key1,$key2,$nom,$sexe,$pseu,$vrai,$renvoi,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$autre);
         #$key=~s/ +$//;
         $key="$key1 $key2";
         # existence du lien
         ($exist, $url) = &exist_auteur($pages_auteurs, $key);
         if ($exist == 1)   # lien existe
         {
            print $canal &tohtml("<a class=\"auteur\" href=\"$url\">");
            print $canal &tohtml("$nom");
            print $canal &tohtml("</a>");
         }
         else
         {
            print $canal &tohtml(" $nom ");
         }
      }
      if ($suite == 1)
      {
         print $canal ".<br />\n";
      }
#     print $canal "</font>\n";
   }

   #------------------------------------------------
   # Affichage de l'URL vers les sites de l'auteur
   #------------------------------------------------
print STDERR "Pays = $nation, Site = $site_ok, type = $tsite_ok\n";
   if (($site_ok ne "") && ($site_ok ne "?"))
   {
     $type = lc($tsite_ok);
     #------------------------------------------------------------
     # Une url est trouv‚e
     #------------------------------------------------------------
     if ($type eq "perso") {
               print $canal &tohtml("Pour de plus amples informations, consulter le <a href=\"$site_ok\">site personnel</a> de l'auteur.");
     }
     elsif ($type eq "officiel") {
               print $canal &tohtml("Pour d'autres informations, consulter le <a href=\"$site_ok\">site officiel</a> de l'auteur.");
     }
     elsif ($type eq "fan") {
               print $canal &tohtml("Pour d'autres informations, vous pouvez consulter ce <a href=\"$site_ok\">site d'un passionn‚</a>.");
     }
     elsif ($type eq "amis") {
               print $canal &tohtml("Pour d'autres informations, vous pouvez consulter le <a href=\"$site_ok\">site des amis</a> de l'auteur.");
     }
     elsif ($type eq "blog") {
               print $canal &tohtml("Pour d'autres informations, vous pouvez consulter le <a href=\"$site_ok\">blog</a> de l'auteur.");
     }
     elsif ($type eq "flickr") {
               print $canal &tohtml("Pour d'autres informations, vous pouvez consulter le <a href=\"$site_ok\">site Flickr</a> de l'auteur.");
     }
     elsif ($type eq "editeur") {
               print $canal &tohtml("Pour d'autres informations sur l'auteur, consulter la page d'un <a href=\"$site_ok\">‚diteur</a>.");
     }
     elsif ($type eq "revue") {
               print $canal &tohtml("Pour d'autres informations, consulter ce site d'une <a href=\"$site_ok\">revue</a> de l'auteur.");
     }
     elsif ($type eq "site") {
               print $canal &tohtml("Pour d'autres informations sur l'auteur, consulter ce <a href=\"$site_ok\">site</a>.");
     }
     elsif ($type eq "page") {
               print $canal &tohtml("Pour d'autres informations, consulter cette <a href=\"$site_ok\">page</a>.");
     }
     elsif ($type eq "textes") {
               print $canal &tohtml("Pour lire quelques textes, consulter cette <a href=\"$site_ok\">page</a>.");
     }
     elsif ($type eq "wikipedia") {
               print $canal &tohtml("Pour d'autres informations, vous pouvez consulter l'<a href=\"$site_ok\">article sur wikipedia</a>.");
     }
     elsif ($type eq "?") {
               print $canal &tohtml("Pour d'autres informations, consulter ce <a href=\"$site_ok\">site</a>.");
     }
   }

   if ($ok == 1) {
      print $canal "</div>";
      print $canal "<div style='clear:both;'></div>";
   }

}
   
#---------------------------------------------------------------------------
# Fonction de transformation date
#---------------------------------------------------------------------------
sub transfo_date
{
   $date=$_[0];

#--- Si mois en clair (passage en option ?)
#  $date=~s/\/01\// janvier /g;
#  $date=~s/\/02\// f‚vrier /g;
#  $date=~s/\/03\// mars /g;
#  $date=~s/\/04\// avril /g;
#  $date=~s/\/05\// mai /g;
#  $date=~s/\/06\// juin /g;
#  $date=~s/\/07\// juillet /g;
#  $date=~s/\/08\// aout /g;
#  $date=~s/\/09\// septembre /g;
#  $date=~s/\/10\// octobre /g;
#  $date=~s/\/11\// novembre /g;
#  $date=~s/\/12\// d‚cembre /g;

   $date=~s/\.\.\.\.//g;
   $date=~s/\.\.\///g;
   $date=~s/\.\.//g;
   $date=~s/^ +//g;
   $date=~s/ +$//g;
$lg=length($date);
print STDERR "Transfo date : [$date] [len: $lg]\n";
   return $date;
}

#---------------------------------------------------------------------------
# Fonction d'affichage des informations biographiques
# p : pays
# s : sexe
# d1 : date1 = date naissance
# d2 : date2 = date d‚cŠs
# l1 : lieu1 = lieu naissance
#---------------------------------------------------------------------------
sub aff_data_bio
{
   my $p=$_[0];
   my $hf=$_[1];
   my $d1=$_[2];
   my $d2=$_[3];
   my $l1=$_[4];

   $d1=&transfo_date($d1);
   $d2=&transfo_date($d2);

   print $canal &tohtml($p ne '?' ? "$p" : '');
   if (($l1 ne '') || ($d1 ne '') || ($d2 ne ''))
   {
      if ($d2 ne '')
      {
         print $canal &tohtml($l1 ne '?' ? " ($l1, " : ' (');
         print $canal ($d1 ne '' ? "$d1 - " : "? - ");
         print $canal ($d2 ne '' ? "$d2)" : ")");
      }
      else
      {
         if ($d1 eq '')
         {
            print $canal &tohtml($l1 ne '?' ? " ($l1, ?)" : ' ');
         }
         elsif ($hf eq 'H')
         {
            $prefix = (length($d1) == 10 ? "le" : "en");
            print $canal &tohtml($l1 ne '?' ? " ($l1, " : ' (n‚ ' . $prefix . ' ');
            print $canal &tohtml("$d1)");
         }
         elsif ($hf eq 'F')
         {
            $prefix = (length($d1) == 10 ? "le" : "en");
            print $canal &tohtml($l1 ne '?' ? " ($l1, " : ' (n‚e ' . $prefix . ' ');
            print $canal &tohtml("$d1)");
         }
         else
         {
            print $canal &tohtml($l1 ne '?' ? " ($l1, " : ' (');
            print $canal "$d1)";
         }
      }
   }
   print $canal "<br />";
   
}

#---------------------------------------------------------------------------
# Fonction d'affichage du texte de la biographie
#---------------------------------------------------------------------------
sub aff_text_bio
{
   $texte=$_[0];

   # print "--[${texte}]--\n";
   $texte=~s/\n$//g;
   $texte=~s/^ +//g;
   $texte=~s/ +$//g;
   $texte=~s/,$//g;
   $texte=~s/^"//g;
   $texte=~s/"$//g;
   $texte=~s/""/"/g;
   $texte=~s/\.$//g;
   $texte=~s/ +$//g;
   $lnbio=length($texte);
   if (($lnbio > 2) && ($texte ne ""))
   {
      # print STDERR "---${texte}---\n";
      $texte=~s#<br>#<br />#g;
      $texte=~s#<br />#<br />\n#g;
      return "<br />\n${texte}.<br />\n";
   }
}

1;
