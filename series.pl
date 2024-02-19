#===========================================================================
# Generation des fichiers liste de s‚ries et cycles
#---------------------------------------------------------------------------
# Historique :
#
#  0.1  - 03/11/2002 : Creation d'aprŠs biblio.pl
#  0.2  - 29/08/2003 : Prise en compte du nouveau format de la base
#  0.2b - 24/01/2004 : Pas une s‚rie si le titre commence par [
#  0.3  - 26/11/2007 : Genere egalement le fichier "étendu"
#                        (avec url, et incluant ALT et VO)
#  0.3b - 28/11/2007 : Ajout exceptions (Tarzan)
#  0.4  - 11/11/2010 : Ajout gestion sous-cycles et cycles suppl‚mentaires
#  0.5  - 17/04/2011 : Upload automatique par defaut
#  0.6  - 14/10/2011 : Ajout d'un troisiŠme niveau de cycle
#  1.0  - 23/12/2020 : Prise en compte des alias recueils int‚gr‚s ((Nom))
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

printf "series.pl   : generation des fichier de cycles (series(_2).res)  [    ]\r";
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
@series2=();
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

            $url = &url_serie($c1);
            $record = "$c1\t$c1\t$url";
            push (@series2, $record);

            if ($sc1 ne '') {
               # Ajout de la sous-s‚ries sc1 de c1
               push (@series, "$sc1 [$c1]");

               $record = "$sc1 [$c1]\t$c1\t$url";
               push (@series2, $record);                  
            }
            if ($sc2 ne '') {
               # Ajout de la sous-s‚ries sc2 de c1
               push (@series, "$sc2 [$c1]");

               $record = "$sc2 [$c1]\t$c1\t$url";
               push (@series2, $record);                  
            }
            if ($sc3 ne '') {
               # Ajout de la sous-s‚ries sc3 de c1
               push (@series, "$sc3 [$c1]");

               $record = "$sc3 [$c1]\t$c1\t$url";
               push (@series2, $record);                  
            }
            if ($ssssc ne '') {
               # Ajout de la sous-sous-s‚ries ssssc de c1
               push (@series, "$ssssc [$c1]");

               $record = "$ssssc [$c1]\t$c1\t$url";
               push (@series2, $record);                  
            }
         }
         if ($c2 ne '') {
            # Ajout de la serie c2
            push (@series, $c2);

            $url = &url_serie($c2);
            $record = "$c2\t$c2\t$url";
            push (@series2, $record);
         }
         if ($c3 ne '') {
            # Ajout de la serie c3
            push (@series, $c3);

            $url = &url_serie($c3);
            $record = "$c3\t$c3\t$url";
            push (@series2, $record);
         }
      }
   }
}

# Ajout des exceptions - Tarzan n'est PAS une exception !
#------------------------------------------------------------
#push (@series, "Tarzan");
push (@series, "Trilogie Joe Kurtz");
#push (@series2, "Tarzan\tTarzan\ttarzan");
push (@series2, "Trilogie Joe Kurtz\tTrilogie Joe Kurtz\ttrilogie_joe_kurtz");

# Ajout des variantes de titres dans le fichier etendu
#------------------------------------------------------------
my $file_cyc_alt="series.alt";
open (f_cyc_alt, "<$file_cyc_alt");
my @cyc_alt=<f_cyc_alt>;
close (f_cyc_alt);

foreach $ligne (@cyc_alt)
{
   $titre_cycle=$ligne;
   chop ($titre_cycle);
   ($titre_cycle_alt, $titre_cycle_ref) = split (/\t/, $titre_cycle);
   $url = &url_serie($titre_cycle_ref);
   $record = "$titre_cycle_alt\t$titre_cycle_ref\t$url";
   push (@series2, $record);
}
#
# Ajout des titres VO dans le fichier etendu
#------------------------------------------------------------
my $file_cyc_vo="series.vo";
open (f_cyc_vo, "<$file_cyc_vo");
my @cyc_vo=<f_cyc_vo>;
close (f_cyc_vo);

foreach $ligne (@cyc_vo)
{
   $titre_cycle=$ligne;
   chop ($titre_cycle);
   ($titre_cycle, $titre_cycle_vo) = split (/\t/, $titre_cycle);
   $url = &url_serie($titre_cycle);
   $record = "$titre_cycle_vo\t$titre_cycle\t$url";
   push (@series2, $record);
}

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
@tri = sort @series2;
$old="";
@uniq2=();
foreach $serie (@tri)
{
   if ($old ne $serie)
   {
      push (@uniq2, $serie);
   }
   $old=$serie;
}
#---------------------------------------------------------------------------
# sortie dans le fichier series
#  series.res en local
#  series_2.res sur rep 'data' de l'arbo livraison
#---------------------------------------------------------------------------
$file="series.res";
open (INP, ">$file");
foreach $serie (@uniq)
{
#  printf STDOUT "$serie \n";
   print INP "$serie\n";
}
close (INP);

# Upload site, dans data
$cwd = "/www/data";
&bdfi_upload($file, $cwd);

# Puis copie dans le r‚pertoire data local
#
$cmd="cp ${file} E:\\laragon\\www\\bdfi\\data";
printf $cmd;
system $cmd;



$file="${livraison_site}/series_2.res";
open (INP, ">$file");
foreach $serie (@uniq2)
{
#  printf STDOUT "$serie \n";
   print INP "$serie\n";
}
close (INP);

# Upload site, dans data
$cwd = "/www/data";
&bdfi_upload($file, $cwd);

printf "series.pl   : generation des fichier de cycles (series(_2).res)  [ OK ]\r";
