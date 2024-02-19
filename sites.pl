#===========================================================================
#
# Liste les types de site existants, avec nombre par type
#
# A FAIRE : 
#
#  affichage du nombre 
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

sub usage
{
   print STDERR "usage : $0 -h | -a | -c\n";
   print STDERR "        Liste et d‚compte les types de site du fichier auteurs.\n";
   print STDERR "options :\n";
   print STDERR "   -h :  affiche cette aide\n";
   print STDERR "   -a :  laisse les accents\n";
#   print STDERR "   -c :  compte le nombre par type\n";
   exit;
}


#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
$accents="NON";
$compte="NON";

if ($ARGV[$i] ne "")
{
   $arg=$ARGV[$i];
   $deb=substr($arg, 0, 1);

   if ($deb eq "-")
   {
      if (substr($arg, 1, 1) eq "h")
      {
         usage;
         exit;
      }
      elsif (substr($arg, 1, 1) eq "a")
      {
         $accents="OUI";
      }
      elsif (substr($arg, 1, 1) eq "c")
      {
         $compte="OUI";
      }
      else
      {
         # erreur
         usage;
         exit;
      }
   }
}


#---------------------------------------------------------------------------
# Ouverture du fichier auteurs.txt (export MS-DOS txt de excel)
#---------------------------------------------------------------------------
$file="auteurs.txt";
open (f_bio, "<$file");
@bio=<f_bio>;
close (f_bio);
   
@aut=();

#---------------------------------------------------------------------------
# Recherche des auteurs du type de site
#---------------------------------------------------------------------------
foreach $lig (@bio)
{
   ($key1,$key2,$nom,$sexe,$pseu,$vrai,$renvoi,$nation,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);

   if (($renvoi eq '') || ($renvoi eq ' '))
   {
      # Pas de renvoi, info locale :
      if ($accents eq "NON") {
         $tsite = &noacc($tsite);
      }
      push (@aut, $tsite);
   }
}
@tri = sort @aut;
@uniq=();
foreach $record (@tri)
{
   $record=~s/ +$/  /;
   if ($old ne $record)
   {
      push (@uniq, $record."\n");
   }
   $old=$record;
}

$nb=$#uniq+1;
print @uniq;
print "Nombre de types de sites differents : $nb\n";

exit;

# --- fin ---
