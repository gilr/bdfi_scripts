#===========================================================================
#
# Script de contr“le li‚ aux titres (date et titre vo, genre et type)
#
#---------------------------------------------------------------------------
# Historique :
#
#   0.1 - 15/04/2020 : Creation
#   0.2 - 16/04/2020 : xxx
#   0.5 - 16/01/2022 : Reprise pour cr‚ation
#   0.8 - 23/01/2022 : Mise … jour
#
#---------------------------------------------------------------------------
# A FAIRE :
#
# [OK] Peut-ˆtre exclure les introductions, pr‚faces, postfaces...
# [OK] TBD quoi faire si type et date tous deux diff‚rents (peutˆtre date N < date R)
# [OK] G‚rer les "1979" vs "1979-1987"
# [OK] Prendre en compte avec ou sans ".col" dans le paramŠtre
# [OK] G‚rer les X et t (ts extraits)
# [OK] Tester si fichier existe
# [OK] Retour en arriŠre sur les ".col" dans le paramŠtre => pas de compl‚tion auto pour pouvoir jouer un fichier sans extension
# [..] pas d'erreur de date si mˆme titre mais cycles 1/2 ou 2/3 par ex.
# [..] Si antho et nb identique (ex: A6=A6 ou N4=A4), alors contr“le de la date 
# [..] evolution ++ : plus de grep, mais une comparaison 1 par 1, en rempla‡ant "lc" par qq chose qui supprime aussi :;,.!? ...
#
#===========================================================================
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
$coll_start = 2;                                $coll_size = 7;
$num_start = 10;                                $num_size = 5;
$typnum_start = 15;
$date_start = 17;                               $date_size = 4;
$mois_start = 22;                               $mois_size = 2;

#--- intitule
$genre_start = 3;
$type_start = 11;                               $type_size = 5;
$auttyp_start = $type_start+$type_size+1;
$author_start = $auttyp_start+1;                $author_size = 28;
$title_start = $author_start+$author_size;

$collab_f_pos = $author_start+$author_size-1;
$collab_n_pos = 0;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site = $local_dir . "/series/pages";

my $ref_en_cours="NOUV_REF";
my $in = 0;
my $oldin = 0;
my $old_titre="";
my $old_cmt="";
my $canal = 0;
my $NOCYC = 0;
my $upload = 1;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$type_tri = 0;
$no_coll = 0;

sub usage
{
   print STDERR "Usage : $0 [-h|-a|-v|-f|-m|-g]<file>\n";
   print STDERR "-------\n";
   print STDERR "        Contr“le des titres / dates . \n";
   print STDERR "        sur base d'une liste au format collection (d'extention quelconque>) \n";
   print STDERR "Options : \n";
   print STDERR "---------\n";
   print STDERR "   -h :  affichage de cette aide \n\n";
   print STDERR "   -v :  contr“le copyright & titres VO VO\n";
   print STDERR "   -f :  contr“les des titres fran‡ais complets fr\n";
   print STDERR "   -m :  contr“le des majusucules titre fran‡ais\n";
   print STDERR "   -g :  contr“les des hors-genre\n";
   print STDERR "   -G :  contr“les du genre\n";
   print STDERR "   -c :  contr“le complet pour les recueils\n";
   print STDERR "   -A :  contr“le complet vo & titres (v,f,m)\n";
   print STDERR "   -Z :  contr“le le plus complet et fin\n";
#  print STDERR "   -2 :  contr“les des yyy\n";
   exit;
}

if ($ARGV[0] eq "")
{
   print "1";
   usage;
   exit;
}
$i = 0;

my $check_vo = 0;
#        print "DBG - init check VO ($check_vo)\n";
my $check_fr = 0;
my $check_maj = 0;
my $check_genre = 0;
my $check_genre2 = 0;
my $check_zzz = 0;
my $check_complet_rec = 0;

while ($ARGV[$i] ne "")
{
   $arg = $ARGV[$i];
   $deb = substr($arg, 0, 1);

   if ($deb eq "-")
   {
      if (substr($arg, 1, 1) eq "h")
      {
         print "1";
         usage;
         exit;
      }
      elsif (substr($arg, 1, 1) eq "v")
      {
         $check_vo = 1;
#        print "DBG - check VO ($check_vo)\n";
      }
      elsif (substr($arg, 1, 1) eq "f")
      {
         $check_fr = "1";
      }
      elsif (substr($arg, 1, 1) eq "m")
      {
         $check_maj = 1;
      }
      elsif (substr($arg, 1, 1) eq "g")
      {
         $check_genre = "1";
      }
      elsif (substr($arg, 1, 1) eq "G")
      {
         $check_genre2 = "1";
      }
      elsif (substr($arg, 1, 1) eq "c")
      {
         $check_complet_rec = "1";
      }
      elsif (substr($arg, 1, 1) eq "A")
      {
         $check_vo = 1;
         $check_fr = 1;
         $check_maj = 1;
      }
      elsif (substr($arg, 1, 1) eq "Z")
      {
         $check_vo = 1;
         $check_fr = 1;
         $check_maj = 1;
         $check_genre = 1;
         $check_genre2 = 1;
         $check_complet_rec = "1";
      }
   }
   else
   {
      $file_name = $arg;
#     # FAIRE : si pas d'extention, ajouter .col
#     $file_name=~s/\.col//;
#     if (index($file_name, '.') == -1)
#     {
#        $file_name = $file_name . ".col";
#        print "\nFichier entr‚e : [$file_name] type [COL]\n";
#     }
#     else
#     {
         print "\nFichier entr‚e : [$file_name]\n";
#     }
   }
   $i++;
}

$file_name=~s/^ *//;

#        print "DBG - fin option - check VO ($check_vo)\n";

#---------------------------------------------------------------------------
# Lecture du fichier ouvrages
#---------------------------------------------------------------------------
$file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

#        print "DBG - aprŠs lecture ouvrages - check VO ($check_vo)\n";

#---------------------------------------------------------------------------
# Lecture du fichier collection ou parution
#---------------------------------------------------------------------------
#        print "DBG - ouverture fichier [$file_name] - check VO ($check_vo)\n";
#$file_name=~s/ $//;
$existf = 1;
open (f_file, "<$file_name") or $existf = 0;
if ($existf == 0)   # fichier inexistant
{
   print "fichier $file_name non trouv‚\n";
   exit;
}
else
{
   print "fichier $file_name OK\n";
   @file=<f_file>;
   close (f_file);
}

#        print "DBG - aprŠs lecture fichier $file_name - check VO ($check_vo)\n";

@liste=();

#---------------------------------------------------------------------------
# Extraction des lignes titres
#---------------------------------------------------------------------------


# (nb autre contr“le … faire :  date de tout ce qui est dans r‚f <= date de la ref)

# Solution "simple" (sans gestion des refs complŠtes, multi-auteurs)

# Comparaison fichier INPUT avec "ouvrages.res"
#
#        print "DBG - avant foreach - check VO ($check_vo)\n";
foreach $lig (@file)
{
#        print "DBG - chaque foreach - check VO ($check_vo)\n";
   chop ($lig);
   # Pour chaque ligne de contenu de "INPUT"
   # ... qui est de type contenu...
   $prem = substr ($lig, 0, 1);
   if (($prem eq "-") || ($prem eq "=") || ($prem eq ":"))
   {
#     print "--- DEBUG ligne [$lig]\n";
      # R‚cup "genre" (4) "type" (12), "auteur/antho" (17) "auteur" (18) et "titre_complet"
      $hg = substr ($lig, $genre_start, 1);
      $hg2 = substr ($lig, $genre_start+1, 2);
      $type_c = substr ($lig, $type_start, $type_size);
      $type = substr ($type_c, 0, 1);
      $stype = substr ($type_c, 1, 2);
      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      if (($type eq 'p') || ($type eq 'o')) { next; }
      # Puis titre_complet => titre, cycle, date vo, titre vo
      ($titre_seul, $alias_recueil,
       $ssssc, $indice_ssssc,
       $cycle_s, $indice_s,
       $cycle_s2, $indice_s2,
       $cycle_s3, $indice_s3,
       $cycle, $indice,
       $cycle2, $indice2,
       $cycle3, $indice3) = decomp_titre ($titre, $nblig, $lig);

      # Niveau (1) - Si le titre est trouv‚ identique … un autre titre de ouvrages.res
      #  (d‚filement, ou grep ?)
      # Niveau (2) - Si le titre est trouv‚ "proche" d'un autre titre de ouvrages.res
      # rechercher dans ouvrages.res un titre VO identique, auteur identique
      $cherche = lc($titre_seul);

      # Suppression des caractŠres sp‚ciaux qui posent problŠme au grep
      $cherche=~s/\+/./o;
      $cherche=~s/\*/./go;
      $cherche=~s/\?/./go;
      $cherche=~s/\{/./go;
      $cherche=~s/\{/./go;
      $cherche=~s/\(/./go;
      $cherche=~s/\)/./go;

#     print "--- DEBUG ($auteur) $titre --- $cherche \n";
      @res = grep (m/$cherche/i, @ouv);

      $nb = $#res+1;
      if ($nb >= 1)
      {
         foreach $ouv_lig (@res) {
            chop ($ouv_lig);
            $ouv_hg = substr ($ouv_lig, $genre_start, 1);
            $ouv_hg2 = substr ($ouv_lig, $genre_start+1, 2);
            $ouv_type_c = substr ($ouv_lig, $type_start, $type_size);
            $ouv_type = substr ($ouv_type_c, 0, 1);
            $ouv_stype = substr ($ouv_type_c, 1, 2);
            ($ouv_auteur, $ouv_titre, $ouv_vodate, $ouv_votitre, $ouv_trad) = decomp_reference ($ouv_lig);
#              print "--- DEBUG: $ouv_lig --------- $ouv_vodate\n";

            ($ouv_titre_seul, $ouv_alias_recueil,
             $ouv_ssssc, $ouv_indice_ssssc,
             $ouv_cycle_s, $ouv_indice_s,
             $ouv_cycle_s2, $ouv_indice_s2,
             $ouv_cycle_s3, $ouv_indice_s3,
             $ouv_cycle, $ouv_indice,
             $ouv_cycle2, $ouv_indice2,
             $ouv_cycle3, $ouv_indice3) = decomp_titre ($ouv_titre, $nblig, $ouv_lig);

            $pb = 0;
            if ((lc($titre_seul) eq lc($ouv_titre_seul)) && ($auteur eq $ouv_auteur) && ($type ne "T") && ($ouv_type ne "T")  &&
                ((($stype eq "  ") && ($ouv_stype eq "  ")) ||
                 (($stype ne "  ") && ($ouv_stype ne "  "))))
#                (($check_complet_rec == 1) && ($stype eq $ouv_stype))))
            {
#              print "--- DEBUG: ($titre_seul) ($auteur) ($vodate) // ($ouv_titre_seul) ($ouv_auteur) ($ouv_vodate)\n";
#             print "--- DEBUG: ($stype)($ouv_stype) [[$lig]]\n";
               # Si titre seul et auteur sont identiques, affiche si les conditions suivantes non respect‚es :

               # === Diff‚rence VO
#                 print "DBG - check VO : $check_vo\n";
               if ($check_vo == 1)
               {
                  if ($votitre eq $ouv_votitre)
                  {
                     if (substr($vodate, 0, 4) ne substr($ouv_vodate, 0, 4))
                     {
                        if ($type eq $ouv_type)
                        {
                           print " vD ($ouv_vodate)($vodate) [$lig]\n";
                           $pb = 1;
                        }
                     }
                  }
                  else
                  {
                     if (substr($vodate, 0, 4) eq substr($ouv_vodate, 0, 4))
                     {
                        print " vT ($ouv_votitre)($votitre) Dates ($ouv_vodate)($vodate) [[$lig]]\n";
                     }
                     else
                     {
                        print " v* ($ouv_vodate)($vodate) ($ouv_votitre)($votitre) [[$lig]]\n";
                     }
                     $pb = 1;
                  }
               }

               # === titre complet diff‚rent
               if (($check_fr == 1) && ($titre ne $ouv_titre))
               {
                  print " Fr ($ouv_titre)($titre) [[$lig]]\n";
               }

               # === majuscules diff‚rentes
               if (($check_maj == 1) && ($titre_seul ne $ouv_titre_seul))
               {
                  print " Ma ($ouv_titre_seul)($titre_seul) [[$lig]]\n";
                  $pb = 1;
               }

               # === genre diff‚rent
               if (($check_genre == 1) && ($hg ne $ouv_hg))
               {
                  print " Ge ($ouv_hg)($hg) [[$lig]]\n";
                  $pb = 1;
               }
               $g1 = substr($ouv_hg2,0,1);
               $g2 = substr($ouv_hg2,1,1);
               $m = substr($hg2,0,1);
               if (($check_genre2 == 1) &&
                   ($hg2 ne $ouv_hg2) &&
                   ($m ne $g1) && ($m ne $g2)
                   && ($m ne " ")
		   # Etape 1 : seulement les blancs chez moi - A retirer ensuite
                   && ($g1 eq " ")
                  )
               {
                  print " G2 ($ouv_hg2)($hg2) [[$lig]]\n";
                  $pb = 1;
               }

               # === type diff‚rent
               if (($check_complet_rec == 1) &&
                   (($type ne $ouv_type)
                 && (($type ne 'R') || ($ouv_type ne "X"))
                 && (($type ne 'X') || ($ouv_type ne "R"))
                 && (($type ne 'r') || ($ouv_type ne "x"))
                 && (($type ne 'x') || ($ouv_type ne "r"))
                 && (($type ne 'N') || ($ouv_type ne "x"))
                 && (($type ne 'x') || ($ouv_type ne "N"))
                 && (($type ne 'T') || ($ouv_type ne "t"))
                 && (($type ne 't') || ($ouv_type ne "T"))
                 ))
               {
                  if ($vodate eq $ouv_vodate) {
                     print " Xx ($ouv_type)($type) (mˆme date $vodate) [[$lig]]\n";
                  }
                  else
                  {
                     # type et date diff‚rentes : roman aprŠs nouvelle
                     if (($type eq "N") && ($vodate > $ouv_vodate))
                     {
                        print " Xx ($type, $vodate) > ($ouv_type, $ouv_vodate) [[$lig]]\n";
                     }
                     if (($ouv_type eq "N") && ($vodate < $ouv_vodate))
                     {
                        print " Xx ($type, $vodate) < ($ouv_type, $ouv_vodate) [[$lig]]\n";
                     }
                  }
               }

            }
            # Si au moins une erreur, on sort ... Pas forc‚ment top car si erreur "valide", on ne contr“le pas les non valides...
            # if ($pb == 1) { last; }
         }
      }
   }
   next;
}

