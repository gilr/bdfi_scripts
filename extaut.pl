#===========================================================================
# Script 
#---------------------------------------------------------------------------
# Historique :
#---------------------------------------------------------------------------
# Utilisation :
#  Generation du fichier auteur pour les requetes dynamiques SFSeek
#
#   27/11/07 : ajout gene fichier auteur etendu pour recherche site
#   17/03/11 : Essai fichier num‚ro 2 avec ajout "pr‚nom nom" en champ 2
#
#  modification : suppression nation et date
#---------------------------------------------------------------------------
#
# Export fichier auteur excel : exporter en Texte (DOS) (*.txt)
#
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";
my $livraison_site=$local_dir . "/data";

printf "extaut.pl   : generation du fichier auteurs etendu (auteurs.ext) [    ]\r";
#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Ouverture des fichiers auteurs.res et auteurs.txt
#---------------------------------------------------------------------------
$file = "auteurs.res";
open (f_aut, "<$file");
@aut0 = <f_aut>;
@aut = sort tri_res @aut0;
close (f_aut);

$file = "auteurs.txt";
open (f_bio, "<$file");
@bio0 = <f_bio>;
@bio = sort tri_txt @bio0;
close (f_bio);

$file="auteurs.ext";
open (SFS, ">$file");
$site="${livraison_site}/auteurs.ext";
open (EXT, ">$site");

print "\n Premier : dans $site\n";

my $k_bio=0;
my @record=split(/	/, $bio[$k_bio]);
my $maxbio=$#bio+1;

foreach $nom (@aut)
{
   next if ($nom=~/^\*/);
   next if ($nom=~/^\?/);
   next if ($nom=~/^---/);
   chomp ($nom);
#  print "NOM RES  = $nom\n";
   $key = $record[0] . " " . $record[1];
   $prenom_nom = $record[1] . " " . $record[0];
   $key =~ s/ +$//g;
   $prenom_nom =~ s/ +$//g;
#  print "NOM TXT  = $key\n";
   while (($key lt $nom) && ($k_bio != $maxbio))
   {
#     print "(NOM TXT < NOM RES) $key < $nom ($k_bio)\n";
      $k_bio++;
      @record=split(/	/, $bio[$k_bio]);
#     print "$record[0]\n";
      $key = $record[0] . " " . $record[1];
      $prenom_nom = $record[1] . " " . $record[0];
      $key =~ s/ +$//g;
      $prenom_nom =~ s/ +$//g;
#     print "NOM TXT = $key\n";
   }
   if ($nom eq $key)
   {
#     $d1=$l[7];
#     $d1=~s#^\.\./##;
#     $d1=~s#^\.\./##;
#     $d1=~s#^\.\.\.\.#?#;
#     $d2=$l[9];
#     $d2=~s#^\.\./##;
#     $d2=~s#^\.\./##;
#     $d2=~s#^\.\.\.\.#?#;
#     print SFS "$nom	$l[1]	$l[6]	$d1	$d2	\n";
      print SFS "$nom	$record[2]	\n";
#     print "OK: $nom	$l[1]	\n";
      $url=&url_auteur($nom);
#      print EXT "$nom	$record[1] $record[0], $record[2]	$record[5]	$record[6]	$url\n";
      print EXT "$nom	$prenom_nom	$prenom_nom, $record[2]	$record[5]	$record[6]	$url\n";
   }
   else
   {
#     print SFS "$nom	?	?	?	?	\n";
      print SFS "$nom	?	\n";
      $url=&url_auteur($nom);
#      print EXT "$nom	?	?	?	$url\n";
      print EXT "$nom	$nom	?	?	?	$url\n";
      ($ess_nom, $ess_prenom) = split (/ /, $nom, 2);
      $newnom = ucfirst(lc($ess_prenom)) . " " . ucfirst(lc($ess_nom));
#     print "ABSENT TXT: $ess_nom\t$ess_prenom\t$newnom\t?\t\t\t\t?\t../../....\t?\t../../....\t\t?\t?\t\n";
   }
}
close (SFS);
close (EXT);

# Upload site, dans data
$cwd = "/www/data";
# marche pas (seulement 1/3 du fichier est upload‚)
&bdfi_upload($site, $cwd);


printf "extaut.pl   : generation du fichier auteurs etendu (auteurs.ext) [ OK ]\n";


# Puis copie dans le r‚pertoire data local
$cmd="cp ${site} C:\\sf";
system $cmd;

print "\n Recopie : $cmd\n";

exit;

sub tri_res
{
 $aa=$a;
 $aa =~ s/\t/ /g;
 $bb=$b;
 $bb =~ s/\t/ /g;

 return $aa cmp $bb;
}

sub tri_txt
{
 @rec_a=split(/	/, $a);
 $aa = $rec_a[0] . " " . $rec_a[1];
 $aa =~ s/ +$//g;
 @rec_b=split(/	/, $b);
 $bb = $rec_b[0] . " " . $rec_b[1];
 $bb =~ s/ +$//g;

 return $aa cmp $bb;
}

