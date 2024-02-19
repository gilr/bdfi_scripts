#===========================================================================
#
# Mise a jour des pages recueils
#    - d'aprŠs une liste de recueils
#    - d'aprŠs un fichier collection
#   
#---------------------------------------------------------------------------
# Historique :
# date : 24/09/2019 Par copie du fichier maj_bib.pl
#        25/09/2019 Adaptation pour fichier collection
#        08/04/2020 Ajout essais et guides avec contenu
#
#---------------------------------------------------------------------------
# Utilisation :
#  $0 -L <fichier_liste_titre>
#  $0 -C <fichier_col>
#  $0 -P <fichier_parutions>
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";

#---------------------------------------------------------------------------
# Variables de definition des fichiers collection
#---------------------------------------------------------------------------
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Generation du fichier maj_aut.tmp
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "Usage : $0  [-l|-c|-p]<file>\n";
   print STDERR "-------\n";
   print STDERR "        G‚n‚ration des pages recueils, anthos, omnibus et fix-up\n";
   print STDERR "Options : \n";
   print STDERR "---------\n";
   print STDERR "   -l :  d'aprŠs une liste de titres de recueils (fichier liste) \n";
   print STDERR "   -c :  d'aprŠs un fichier au format collection (d'extention quelconque>) \n";
   print STDERR "   -p :  d'aprŠs un fichier parution (fichier <parution.txt>) \n";
   print STDERR "   -h :  affichage de cette aide \n\n";
   exit;
}

#if (($ARGV[0] eq "") || ($ARGV[1] eq ""))
if ($ARGV[0] eq "")
{
   print "1";
   usage;
   exit;
}

while ($ARGV[$i] ne "")
{
   $arg=$ARGV[$i];
   $deb=substr($arg, 0, 2);

   if ($deb eq "-h")
   {
      print "1";
      usage;
      exit;
   }
   elsif ($deb eq "-l")
   {
      $file_type="LISTE";
      $file_name=substr($arg, 2);
#     $file_name=uc($file_name);
   }
   elsif ($deb eq "-c")
   {
      $file_type="COL";
      $file_name=substr($arg, 2);
#     $file_name=uc($file_name);
   }
   elsif ($deb eq "-p")
   {
      $file_type="PARUTION";
      $file_name=substr($arg, 2);
   }
   else
   {
      print "2";
      usage;
      exit;
   }
   $i++;
}
$file_name=~s/^ *//;

#---------------------------------------------------------------------------
# Lecture du fichier collection ou parution
#---------------------------------------------------------------------------
if ($file_type eq "PARUTION")
{
   $file_name=~s/.txt//;
   $file_name = "parutions/" . $file_name . ".txt";
}
elsif ($file_type eq "COL")
{
   $file_name=~s/ $//;
#--   $file_name=~s/.col//;
#--   $file_name = $file_name . ".col";
}
print "--- genre [$gentype] fichier [$file_name] type [$file_type]\n";
open (f_file, "<$file_name");
@file=<f_file>;
close (f_file);

@liste=();

if ($file_type eq "LISTE")
{
   foreach $ligne (@file)
   {
      $recueil=$ligne;
      chop ($recueil);
      push (@liste, $recueil);
   }
}
elsif ($file_type eq "COL")
{
   #---------------------------------------------------------------------------
   # Extraction des recueils, anthologie, omnibus et certains fix-up
   #---------------------------------------------------------------------------
   foreach $ligne (@file)
   {
      $lig=$ligne;
      chop ($lig);

      # test : ouvrage non hors genre (x,#) ni genre inconnu (*)
      # ---  c:\mkstoolk\grep "^[#ox:=&-]" tmp01 >> ouvrages.res
      $prem=substr ($lig, 0, 1);
      if (($prem eq "-") || ($prem eq "=") || ($prem eq ":") || ($prem eq "&"))
      {
         $type_c=substr ($lig, $type_start, $type_size);
         $type=substr ($type_c, 0, 1);
         $stype=substr ($type_c, 1, 1);

         if ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") ||
              ($type eq "A") || ($type eq "C") || ($type eq "Y") || ($type eq "U") ||
              ($type eq "P") || ($type eq "T") || ($type eq "E") || ($type eq "G"))
          && ($stype ne " "))
         {
            ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

            ($titre_seul, $alias_recueil,
             $ssssc, $issssc,
             $sc1, $isc1, $sc2, $isc2, $sc3, $isc3,
             $c1, $ic1, $c2, $ic2, $c3, $ic3) = decomp_titre ($titre, $nblig, $lig);

            # FAIRE peut-ˆtre : remplacer les apostrophes et autres car ‚sot‚riques par des points
            if ($alias_recueil ne "")
            {
               push (@liste, $alias_recueil);
            }
            else
            {
               push (@liste, $titre_seul);
            }
         }
      }
   }
}
elsif ($file_type eq "PARUTION")
{
   #---------------------------------------------------------------------------
   # Extraction des recueils
   #---------------------------------------------------------------------------
   foreach $ligne (@file)
   {
      $lig=$ligne;
      chop ($lig);

      $nom="";
      $prenom="";
      ($nom, $prenom, $titre, $cycle, $indice_cycle, $votitre, $genre, $rnf, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn) = split ("	", $lig);
      $type=lc($rnf);
      if (($type eq "anthologie") || ($type eq "omnibus") || ($type eq "recueil"))
      {
         push (@liste, $recueil);
      }
   }
}

#---------------------------------------------------------------------------
# tri, puis suppression des doublons
#---------------------------------------------------------------------------
@tri = sort @liste;

$old="";
@uniq=();
foreach $record (@tri)
{
   $record=~s/ +$/  /;
   if ($old ne $record)
   {
      push (@uniq, $record);
   }
   $old=$record;
}

# test
#foreach $nom (@uniq)
#{
#   print "$nom\n";
#}
#exit;

#---------------------------------------------------------------------------
# sortie dans le fichier de noms
#---------------------------------------------------------------------------
$file="maj.tmp";
open (INP, ">$file");

foreach $record (@uniq)
{
   print INP "$record\n";
}
close (INP);
print STDOUT " ==> fichier maj.tmp termin‚.\n";

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Generation du fichier maj.tmp
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

# Lecture du fichier de noms temporaire
#---------------------------------------------------------------------------
$file="maj.tmp";
open (f_liste, "<$file");
@liste=<f_liste>;
close (f_liste);

#---------------------------------------------------------------------------
# 
#---------------------------------------------------------------------------

$nb=$#liste+1;
if ($nb == 0)
{
   print STDERR " Aucun enregistrement dans le fichier [${file_name}] ?!\n";
   exit;
}
else
{
   print "$nb pages a generer\n";
}

$outB="batchs/tmp_ant.bat";
open (OUTB, ">$outB");
$canalB=OUTB;
print $canalB "echo off\n";

#---------------------------------------------------------------------------
$i=0;
foreach $nom (@liste)
{
   chop ($nom);

   #
   # inserer eventuellement un rejet de certains noms
   #

   $i++;

   print $canalB "echo Traitement de : \"$nom\"\n";

   print $canalB "perl c:\\util\\bibantho.pl -s \"\^$nom\$\"\n";
}

close (OUTB);
print STDOUT " ==> fichier batchs/tmp_ant.bat termin‚.\n";

$cmd="batchs\\tmp_ant.bat";
system $cmd;

print STDOUT " double appel termin‚.\n";

exit;

# --- fin ---

