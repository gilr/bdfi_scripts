#===========================================================================
# Generation de la liste des auteurs
# date : 28/04/2000
#---------------------------------------------------------------------------
# Historique :
#
#  0.1  - 28/04/2000 : Creation d'aprŠs biblio.pl
#  0.2  - 29/08/2003 : Prise en compte du nouveau format de la base
#  0.5  - 14/12/2007 : Gestion "en dur" des exceptions (NICOT St‚phane)
#  0.6  - 17/04/2011 : upload automatique
#  0.7  - 19/02/2022 : gestion des collaborations "hors genres" (!, ?)
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

printf "auteurs.pl  : generation du fichier des auteurs (auteurs.res)    [    ]\r";

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
 # my $livraison_site=$local_dir . "/data";

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------
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

@auteurs=();

#---------------------------------------------------------------------------
# Extraction des auteurs
#---------------------------------------------------------------------------
foreach $ligne (@ouv)
{
   $lig=$ligne;
   chop ($lig);

   # test : ouvrage non hors genre (x,#) ni genre inconnu (*)
   $prem=substr ($lig, 0, 1);
   if ($prem eq "&")
   {
      # En toute rigueur, si '&', il faudrait controler le genre de la ligne contenu
      # Solution de repli identique aux articles ('a' en position type) :
      #    utiliser "!" ou "?" si hors genres ou inconnu, comme la ligne principale
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $genre=substr ($lig, $genre_start, 1);
      if ((($type ne ".") && ($type ne "p") && ($type ne "o") && ($type ne "a") && ($type ne "k") && ($type ne "d") && ($type ne "l") && ($type ne "C") && ($type ne "M")) &&
          (($genre eq 'o') || ($genre eq 'p') || ($genre eq ' ')))
      {
         # 24 si on prend le &, 23 sinon
         $auteur=substr($lig, $author_start, $author_size-1);
         # suppression des espaces de fin
         $auteur=~s/ +$//;
         # Traitement des exceptions (refus d'apparaŒtre)
         if ($auteur ne "NICOT St‚phane") {
            push (@auteurs, $auteur);
         }
         else {
            push (@auteurs, "NICOT S.");
         }
      }
   }
   elsif (($prem eq "-") || ($prem eq ":") || ($prem eq "="))
   {
      # test : type different de "." et de "p" et de "o"
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $genre=substr ($lig, $genre_start, 1);
      # En toute rigueur, si '&', il faut controler le genre de la ligne contenu
      if ((($type ne ".") && ($type ne "p") && ($type ne "o") && ($type ne "a") && ($type ne "k") && ($type ne "d") && ($type ne "l") && ($type ne "C") && ($type ne "M")) &&
          (($genre eq 'o') || ($genre eq 'p')))
      {
         # 24 si on prend le &, 23 sinon
         $auteur=substr($lig, $author_start, $author_size-1);
         # suppression des espaces de fin
         $auteur=~s/ +$//;
         # Traitement des exceptions (refus d'apparaŒtre)
         if ($auteur ne "NICOT St‚phane") {
            push (@auteurs, $auteur);
         }
         else {
            push (@auteurs, "NICOT S.");
         }
      }
   }
}

#---------------------------------------------------------------------------
# tri, puis suppression des doublons
#---------------------------------------------------------------------------
@tri = sort nocasse @auteurs;

$old="";
@uniq=();
foreach $aut (@tri)
{
#  # suppression des marques d'anthologistes
#  #-----------------------------------------
#  $aut=~s/\* +$/  /;
#  $aut=~s/\*$//;
#  $aut=~s/ +$//;
#  $aut=~s/\*\*/\*\*\*/;
   if ($old ne $aut)
   {
      push (@uniq, $aut);
   }
   $old=$aut;
}

#---------------------------------------------------------------------------
# sortie dans le fichier auteurs
#---------------------------------------------------------------------------
$file="auteurs.res";
open (INP, ">$file");

foreach $aut (@uniq)
{
   print INP "$aut\n";
}
close (INP);
printf "auteurs.pl  : generation du fichier des auteurs (auteurs.res)    [ OK ]\n";

# Upload site, dans data
$cwd = "/www/data";
&bdfi_upload($file, $cwd);

# Puis copie dans le r‚pertoire data local
$cmd="cp ${file} E:\\laragon\\www\\bdfi\\data";
printf $cmd;
system $cmd;

exit;

#---------------------------------------------------------------------------
# sortie dans le fichier auteurs
#---------------------------------------------------------------------------
sub nocasse
{
   uc($a) cmp uc($b);
}
