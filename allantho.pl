#===========================================================================
# Generation des index anthologies & recueils pour une initiale
#---------------------------------------------------------------------------
# Historique :
# date : ../../....
#
#  0.0  - ../../.... : Creation
#  0.1  - 21/07/2004 : 
#
#---------------------------------------------------------------------------
# Utilisation :
#   lancement  pour une seule initiale :
#    initiale "page" ou initiale "reelle"
#
#---------------------------------------------------------------------------#
#
# A FAIRE :
#
#
#---------------------------------------------------------------------------#
push  (@INC, "c:/util/");
require "bdfi.pm";

$choix="";
if ($ARGV[0] ne "")
{
   $choix=uc($ARGV[0]);
   print STDERR "--- initiale $choix\n";
}

#---------------------------------------------------------------------------
# Lecture du fichier anthos
#---------------------------------------------------------------------------
$file="anthos.res";
open (f_ant, "<$file");
@ant=<f_ant>;
close (f_ant);

$iant=0;

#---------------------------------------------------------------------------
# Faire la liste des idrec
#---------------------------------------------------------------------------
foreach $record (@ant)
{
   $lig=$record;
   ($titre_antho, $id_antho, $url_antho)=split (/	/,$lig);
   push (@pages, $id_antho);
}

#---------------------------------------------------------------------------
# Tri et unicit‚
#---------------------------------------------------------------------------
@tri = sort @pages;
$old="";
@uniq=();
foreach $page_antho (@tri)
{
   if ($old ne $page_antho)
   {
      push (@uniq, $page_antho);
   }
   $old=$page_antho;
}

#---------------------------------------------------------------------------
# Generation des pages de sommaires
#---------------------------------------------------------------------------
foreach $idrec (@uniq)
{
   $iant++;

   $url_antho=url_antho($idrec);
   $initiale=uc(substr($url_antho,0,1));

   if (($choix eq $initiale)
    || (($choix eq "0") && ($initiale ge "0") && ($initiale le "9"))) {
      print STDERR "--- [$iant] $idrec --- ";
      $cmd="perl c:/util/bibantho.pl \"^${idrec}\$\"";
      system $cmd;
   }
}
