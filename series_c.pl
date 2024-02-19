#===========================================================================
# Sp‚cifique pour seed BDFI_V2 : r‚cup de l'arbre complet des s‚ries
#---------------------------------------------------------------------------
# Historique :
#
#  0.1  - 01/07/2023 : Creation d'aprŠs series.pl
#
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";
my $livraison_site=$local_dir . "/data";

printf "series.pl   : generation du fichier de seed cycles bdfi v2      [    ]\r";
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
# Lecture du fichier ouvrages
#---------------------------------------------------------------------------
my $file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

@series=();
$nblig=0;

#---------------------------------------------------------------------------
# Extraction des cycles/series
#---------------------------------------------------------------------------
foreach $ligne (@ouv)
{
   $lig=$ligne;
   $nblig++;
   chop ($lig);

   #----------------------------------------------------------
   # test : ouvrage non hors genre (x,#) ni genre inconnu (*)
   #----------------------------------------------------------
   $prem=substr ($lig, 0, 1);
#
# Peut-ˆtre laisser les "x"
#
   if (($prem eq "-") || ($prem eq ":") || ($prem eq "="))
   {
      # test : type different de "."
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $genre=substr ($lig, $genre_start, 1);
      if (($type ne ".") && (($genre eq 'o') || ($genre eq 'p')))
      {
         # 24 si on prend le &, 23 sinon
         $texte=substr($lig, $title_start);
#        printf STDOUT "$texte \n";
         ($titre, $vo, $trad)=split (/þ/,$texte);
#        printf STDOUT "$titre \n";
#
         ($titre_seul, $alias_recueil,
          $ssssc, $issssc,
          $sc1, $isc1, $sc2, $isc2, $sc3, $isc3,
          $c1, $ic1, $c2, $ic2, $c3, $ic3) = decomp_titre ($titre, $nblig, $lig);

         # Attention, si il semble y avoir un bug, ‡a peut venir de series.alt !
       
         if ($c1 ne '') {
            # Ajout de la serie c1
            push (@series, $c1);

            if ($sc1 ne '') {
               # Ajout de la sous-s‚ries sc1 de c1
               push (@series, "$sc1 [$c1]");
            }
            if ($sc2 ne '') {
               # Ajout de la sous-s‚ries sc2 de c1
               push (@series, "$sc2 [$c1]");
            }
            if ($sc3 ne '') {
               # Ajout de la sous-s‚ries sc3 de c1
               push (@series, "$sc3 [$c1]");
            }
            if ($ssssc ne '') {
               # ATTENTION - Contraireement … series.pl le parent devient le sous-cycle :
               # Ajout de la sous-sous-s‚ries ssssc de c1
               push (@series, "$ssssc [$sc1]");
            }
         }
         if ($c2 ne '') {
            # Ajout de la serie c2
            push (@series, $c2);
         }
         if ($c3 ne '') {
            # Ajout de la serie c3
            push (@series, $c3);
         }
      }
   }
}

# Ajout des exceptions - Tarzan n'est PAS une exception !
#------------------------------------------------------------
#push (@series, "Tarzan");
push (@series, "Trilogie Joe Kurtz");

#
#  TRI des fichiers
#------------------------------------------------------------
@tri = sort @series;
$old="";
@uniq=();
foreach $serie (@tri)
{
   if ($old ne $serie)
   {
      push (@uniq, $serie);
   }
   $old=$serie;
}

#---------------------------------------------------------------------------
# sortie dans le fichier series
#  series.see en local
#---------------------------------------------------------------------------
$file="series.see";
open (INP, ">$file");
foreach $serie (@uniq)
{
#  printf STDOUT "$serie \n";
   print INP "$serie\n";
}
close (INP);

printf "series.pl   : generation du fichier de seed cycles bdfi v2      [ OK ]\r";

