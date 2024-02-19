#===========================================================================
# Generation de la liste des ISBN (pour sfseek)
#---------------------------------------------------------------------------
# Historique :
#
#   0.1  - 23/02/2004 : Creation d'aprŠs series.pl
#
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
# A FAIRE : rendre multi-auteurs !!!
#
# possibilit‚ ajouter premierevo et titrevo
#
#===========================================================================

printf "isbn.pl     : generation du fichier des ISBN (isbn.res)          [    ]\r";
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
my $file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

@isbns=();

#---------------------------------------------------------------------------
# Extraction des ISBN
#---------------------------------------------------------------------------
$isbn="KO";
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
   if (($prem eq "o") &&
       (substr ($lig, $mark_start, $mark_size) eq 'ISBN') &&
       (substr($lig, $isbn_start, 1) ne '.') &&
       (substr($lig, $isbn_start, 1) ne '-') &&
       (substr($lig, $isbn_start, 1) ne '?') &&
       (substr($lig, $isbn_start + $isbn_size - 1, 1) ne '.'))
   {
      $isbn="OK";
      $no_isbn=substr($lig, $isbn_start, $isbn_size);
   }
   elsif (($prem eq "-") && ($isbn eq "OK"))
   {
      # test : type different de "."
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $genre=substr ($lig, $genre_start, 1);
      if (($type ne ".") && (($genre eq 'o') || ($genre eq 'p')))
      {
         $auteur=substr ($lig, $author_start, $author_size-1);
         $auteur=~s/ +$//o;
         $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);
         # 24 si on prend le &, 23 sinon
         $texte=substr($lig, $title_start);
#        printf STDOUT "$texte \n";
         ($titre, $vo, $trad)=split (/þ/,$texte);
#        printf STDOUT "$titre \n";
         # suppression des doubles [[ et ]]
         #----------------------------------
         $titre =~s/ *$//go;
         $titre =~s/\[\[/\[/go;
         $titre =~s/\]\]/\]/go;
         # suppression des contenus de [ ]
         #----------------------------------
         $titre =~s/\[.*\]//go;
         $record="$no_isbn	$auteur	$titre";
         push (@isbns, $record);
      }
      $isbn="KO";
   }
}

@tri = sort @isbns;
#$old="";
#@uniq=();
#foreach $serie (@tri)
#{
#   if ($old ne $serie)
#   {
#      push (@uniq, $serie);
#   }
#   $old=$serie;
#}

#---------------------------------------------------------------------------
# sortie dans le fichier isbns
#---------------------------------------------------------------------------
$file="isbn.res";
open (INP, ">$file");

foreach $isbn (@tri)
{
#  printf STDOUT "$isbn \n";
   print INP "$isbn\n";
}
close (INP);
printf "isbn.pl     : generation du fichier des ISBN (isbn.res)          [ OK ]\n";

$cmd="cp ${file} s:\data";
system $cmd;
