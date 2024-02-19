#===========================================================================
# Generation de la liste des anthos & recueils
#---------------------------------------------------------------------------
# Historique :
#
#  0.1  - 28/05/2004 : Creation
#  0.2  - 15/07/2004 : Utilisation de idrec()
#  0.3  - ../07/2004 : ajout URL dans resultat
#  0.4  - 17/04/2011 : upload automatique
#  0.5  - 
#  0.6  - 26/04/2016 : gestion des collectes (Y)
#  0.7  - 13/01/2018 : ajout des guides & encyclopedies (G)
#  0.8  - 08/04/2020 : corrections essais & guides : seulement si contenu connu ou au moins existant (Ex ou E[1-9])
#  1.0  - 22/12/2020 : Prise en compte des alias en ligne de type ((url_page))
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

printf "anthos.pl   : generation du fichier des recueils (anthos.res)    [    ]\r";
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
# Lecture du fichier ouvrages
#---------------------------------------------------------------------------
$file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

@anthos=();
$nblig=0;

#---------------------------------------------------------------------------
# Extraction des anthos, recueils, omnibus...
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
 
   if (($prem eq "-") || ($prem eq ":") || ($prem eq "="))
   {
      # test : type different de "."
      $genre=substr ($lig, $genre_start, 1);
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);
      if (($type eq "A") ||
          (($type eq 'N') && ($stype ne ' ')) ||
          (($type eq 'n') && ($stype ne ' ')) ||
          (($type eq 'U') && ($stype ne ' ')) ||
          (($type eq 'C') && ($stype ne ' ')) ||
          (($type eq 'Y') && ($stype ne ' ')) ||
          (($type eq 'R') && ($stype ne ' ')) ||
          (($type eq 'G') && ($stype ne ' ')) ||
          (($type eq 'P') && ($stype ne ' ')) ||
          (($type eq 'r') && ($stype ne ' ')) ||
          (($type eq 'E') && ($stype ne ' ')) ||
          (($type eq 'T') && ($stype ne ' ')))
      {
         ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

         ($titre_seul, $alias_recueil,
          $ssssc, $issssc,
          $sc1, $isc1, $sc2, $isc2, $sc3, $isc3,
          $c1, $ic1, $c2, $ic2, $c3, $ic3) = decomp_titre ($titre, $nblig, $lig);

         if ($alias_recueil ne "")
	 {
            $idrec=idrec($alias_recueil, "", "");
	 }
	 else
	 {
            $idrec=idrec($titre_seul, $c1, $sc1);
	 }
         $url=&url_antho($idrec);

         if ($c1 eq '')
         {
            $record="$titre_seul	$idrec	$url";
            push (@anthos, $record);
         }
         else
         {
            $record="$titre_seul	$idrec	$url";
            push (@anthos, $record);
            $record="$c1	$idrec	$url";
            push (@anthos, $record);
         }
      }
   }
}

#---------------------------------------------------------------------------
# tri, puis suppression des doublons
#---------------------------------------------------------------------------
@tri = sort @anthos;

$old="";
@uniq=();
foreach $tit (@tri)
{
   if (($old ne $tit) && ("$tit" ne ""))
   {
      push (@uniq, $tit);
   }
   $old=$tit;
}

#---------------------------------------------------------------------------
# sortie dans le fichier anthos
#---------------------------------------------------------------------------
$file="anthos.res";
open (INP, ">$file");

foreach $tit (@uniq)
{
   print INP "$tit\n";
}
close (INP);

# Upload site, dans data
$cwd = "/www/data";
&bdfi_upload($file, $cwd);

# et sortie ‚galement dans le r‚p. data local
$file="${livraison_site}/anthos.res";
open (INP, ">$file");
foreach $tit (@uniq)
{
   print INP "$tit\n";
}
close (INP);

printf "anthos.pl   : generation du fichier des recueils (anthos.res)    [ OK ]\n";
