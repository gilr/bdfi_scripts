#===========================================================================
#
# Script de generation de toutes les pages collections
#
#---------------------------------------------------------------------------
# Historique :
#  v0.1  - xx/11/2006 creation
#  v0.2  - 13/01/2002
#
#
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl ix_coll.pl -t | lettre
#
#---------------------------------------------------------------------------
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/collections";
my $tous=0;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$type_tri=0;
$no_coll=0;
$table_en_cours=0;
$last_multi="";

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 [-t]|<lettre>\n";
   print STDERR "        -t : tous les index \n";
   exit;
}

my $i=0;
while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-t")
   {
      $tous=1;
   }
   else
   {
      $choix=$ARGV[$i];
   }
   $i++;
}

my $upchoix;
my $lowchoix;
if ($choix eq '0')
{
   $upchoix="0-9";
   $lowchoix="09";
}
else
{
   $upchoix=uc($choix);
   $lowchoix=lc($choix);
}

#---------------------------------------------------------------------------
# Lecture du fichier collections
#---------------------------------------------------------------------------
my $file_col="collec.res";
open (f_col, "<$file_col");
my @col=<f_col>;
close (f_col);

#my $file_col_alt="collec.alt";
#open (f_col_alt, "<$file_col_alt");
#my @col_alt=<f_col_alt>;
#close (f_col_alt);

my @collec=();

#---------------------------------------------------------------------------
# Creation des entr‚es
#
#  Ce qui diff‚rencie deux entr‚es :
#   titre + date cop.
#
#---------------------------------------------------------------------------
foreach $ligne (@col)
{
   my $enreg=$ligne;
   chop ($enreg);
   $enreg=~s/ \[(.*)\]//;
   next if (substr ($enreg, 0, 1) eq "#");

#print "DBG: $enreg";
   ($sigle, $typg, $nom, $souscoll, $editeur, $lien)=split (/\t/, $enreg);

   $nom=~s/ \[(.*)\]//;
   $souscoll=~s/ \[(.*)\]//;
   $editeur=~s/ \[(.*)\]//;
   my $type = substr($typg,0,1);
   if ($type eq "C") { $type = "Collection"; }
   elsif ($type eq "K") { $type = "Sous-collection"; }
   elsif ($type eq "S") { $type = "S‚rie"; }
   elsif ($type eq "R") { $type = "Revue"; }
   elsif ($type eq "A") { $type = "Auto-‚dition"; }
   elsif ($type eq "F") { $type = "Fanzine"; }
   elsif ($type eq "E") { $type = "Edition"; }

   my $adeq = substr($typg,1,1);
   if ($adeq eq "2") { $adeq = ""; }
   elsif ($adeq eq "1") { $adeq = " partiellement hors genres "; }
   elsif ($adeq eq "0") { $adeq = " majoritairement hors genres "; }

   my $genre1 = substr($typg,2,1);
   if ($genre1 eq "I") { $genre1 = ""; }
   elsif ($genre1 eq "S") { $genre1 = " de science-fiction"; }
   elsif ($genre1 eq "Y") { $genre1 = " de fantasy"; }
   elsif ($genre1 eq "F") { $genre1 = " de fantastique"; }
   elsif ($genre1 eq "T") { $genre1 = " de terreur"; }
   elsif ($genre1 eq "G") { $genre1 = " de gore"; }
   elsif ($genre1 eq "P") { $genre1 = " de policier"; }
   elsif ($genre1 eq "A") { $genre1 = " d'aventures"; }

   my $genre2 = substr($typg,3,1);
   if ($genre2 eq ".") { $genre2 = ""; }
   elsif ($genre2 eq "S") { $genre2 = " et science-fiction"; }
   elsif ($genre2 eq "Y") { $genre2 = " et fantasy"; }
   elsif ($genre2 eq "F") { $genre2 = " et fantastique"; }
   elsif ($genre2 eq "T") { $genre2 = " et terreur"; }
   elsif ($genre2 eq "G") { $genre2 = " et gore"; }
   elsif ($genre2 eq "P") { $genre2 = " et policier"; }
   elsif ($genre2 eq "A") { $genre2 = " et aventures"; }

   my $cible = substr($typg,4,1);
   if ($cible eq ".") { $cible = ""; }
   elsif ($cible eq "a") { $cible = " - Lectorat : adolescent/adulte"; }
   elsif ($cible eq "P") { $cible = " - Lectorat : partiellement adulte"; }
   elsif ($cible eq "A") { $cible = " - Lectorat : adulte"; }
   elsif ($cible eq "J") { $cible = " - Lectorat : jeunesse"; }

   my $comment= $type . $adeq . $genre1 . $genre2 . $cible;

   $intitule=$editeur;
   if (($intitule=~s/^Editions de l'//) != undefined) { $intitule = $intitule . " (Editions de l')"; }
   elsif (($intitule=~s/^Editions de la//) != undefined) { $intitule = $intitule . " (Editions de la)"; }
   elsif (($intitule=~s/^Editions des//) != undefined) { $intitule = $intitule . " (Editions des)"; }
   elsif (($intitule=~s/^Editions de//) != undefined) { $intitule = $intitule . " (Editions de)"; }
   elsif (($intitule=~s/^Editions du//) != undefined) { $intitule = $intitule . " (Editions du)"; }
   elsif (($intitule=~s/^Editions//) != undefined) { $intitule = $intitule . " (Editions)"; }
   elsif (($intitule=~s/^Ed\. de l'//) != undefined) { $intitule = $intitule . " (Ed. de l')"; }
   elsif (($intitule=~s/^Ed\. de la//) != undefined) { $intitule = $intitule . " (Ed. de la)"; }
   elsif (($intitule=~s/^Ed\. des//) != undefined) { $intitule = $intitule . " (Ed. des)"; }
   elsif (($intitule=~s/^Ed\. de//) != undefined) { $intitule = $intitule . " (Ed. de)"; }
   elsif (($intitule=~s/^Ed\. du//) != undefined) { $intitule = $intitule . " (Ed. du)"; }
   elsif (($intitule=~s/^Ed\.//) != undefined) { $intitule = $intitule . " (Ed.)"; }
   elsif (($intitule=~s#<b>in</b>##i) != undefined) { $intitule = $intitule . " (<b>in</b>)"; }
   $intitule=~s/ +$//;
   $intitule=~s/^ +//;

   push (@collec, $sigle);
}

@tri = sort @collec;

#---------------------------------------------------------------------------
# index par fichier sigle
#---------------------------------------------------------------------------
foreach $toto (@tri)
{

   $cmd="perl c:/util/bibcoll.pl \"${toto}\"";
   system $cmd;
}

# --- fin ---
