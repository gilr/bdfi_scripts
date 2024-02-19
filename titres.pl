#===========================================================================
# Generation de la liste des titres (pour sfseek)
#---------------------------------------------------------------------------
# Historique :
#
#  0.1  - 28/05/2004 : Creation
#  0.2  - 24/02/2004 : Reprise pour sfseek a partir de isbn.pl
#  0.3  - 17/04/2011 : upload automatique
#
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
# A FAIRE : supprimer les doublons
#
# A FAIRE : rendre multi-auteurs !!!
#
# possibilit‚ ajouter premierevo et titrevo
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

printf "titres.pl   : generation du fichier des titres (titres.res)      [    ]\r";
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

@titres=();

#---------------------------------------------------------------------------
# Extraction des titres
#---------------------------------------------------------------------------
foreach $ligne (@ouv)
{
   $lig=$ligne;
   chop ($lig);

   #----------------------------------------------------------
   # test : ouvrage non hors genre (x,#) ni genre inconnu (*)
   #----------------------------------------------------------
   $prem=substr ($lig, 0, 1);
#
# Peut-ˆtre laisser les "x" ?
#
   if (($prem eq "-") || ($prem eq ":") || ($prem eq "="))
   {
      # test : type different de "."
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $genre=substr ($lig, $genre_start, 1);
      if (($type ne ".") && (($genre eq 'o') || ($genre eq 'p')))
      {
         ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

         $record="$titre	$auteur";
         push (@titres, $record);
      }
   }
}

#---------------------------------------------------------------------------
# tri, puis suppression des doublons
#---------------------------------------------------------------------------
@tri = sort @titres;

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
# sortie dans le fichier titres
#---------------------------------------------------------------------------
$file="titres.res";
open (INP, ">$file");

foreach $tit (@uniq)
{
   print INP "$tit\n";
}
close (INP);

# Upload site, dans data
$cwd = "/www/data";
&bdfi_upload($file, $cwd);


# Puis copie dans le r‚pertoire data local
$cmd="cp ${file} E:\\laragon\\www\\bdfi\\data";
system $cmd;

printf "titres.pl   : generation du fichier des titres (titres.res)      [ OK ]\n";

exit;
