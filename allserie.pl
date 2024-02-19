#
#   lancement  pour une seule initiale :
#    initiale "page" ou initiale "reelle"
#
# A FAIRE :
#   - Header
#
#   - Faire comme pour les anthos :
#     fichier serie.res = "serie (tabulation) idserie"
#      --- cela devrait en plus permettre a terme de mettre un bouquin dans
#      --- deux idseries, pour les romans appartenant a deux cycles
#
#
#
#
push  (@INC, "c:/util/");
require "bdfi.pm";

$choix="";
if ($ARGV[0] ne "")
{
   $choix=uc($ARGV[0]);
   print STDERR "initiale $choix\n";
}

#---------------------------------------------------------------------------
# Lecture du fichier series/cycles
#---------------------------------------------------------------------------
$file="series.res";
open (f_cyc, "<$file");
@cyc=<f_cyc>;
close (f_cyc);

$icyc=0;
foreach $serie (@cyc)
{
   $icyc++;

   chop ($serie);
   $url_serie=url_serie($serie);
   $init=uc(substr($url_serie,0,1));

   if (($choix ne $init)
    && (($choix ne "0") || ($init lt "0") || ($init gt "9"))) { next; }

   #
   # rejeter les s‚ries contenant "[" (trait‚ dans la s‚rie g‚n‚rale)
   #
   ($a1, $a2) = split(/\[(.*)\]/, $serie);
   if ($a2 eq '')
   {
      print STDERR "[$icyc - $serie] ";

      $cmd="perl c:\\util\\bibserie.pl ^\"${serie}\"\$";
      system $cmd;
   }
}
