#===========================================================================
#
# Mise a jour des pages series
#    - d'aprŠs une liste de s‚rie
#    - d'aprŠs un fichier collection
#   
#---------------------------------------------------------------------------
# Historique :
# date : 24/09/2019 Par copie du fichier maj_bib.pl
#        25/09/2019 Adaptation pour fichier collection
#
#---------------------------------------------------------------------------
# Utilisation :
#  $0 -L <fichier_liste_series>
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
   print STDERR "Usage : $0 [-l|-c|-p]<file>\n";
   print STDERR "-------\n";
   print STDERR "        G‚n‚ration des pages s‚ries et cycles. \n";
   print STDERR "Options : \n";
   print STDERR "---------\n";
   print STDERR "   -l :  d'aprŠs une liste de s‚ries (fichier liste) \n";
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
}
print "--- DEBUG fichier [$file_name] type [$file_type]\n";

open (f_file, "<$file_name");
@file=<f_file>;
close (f_file);

@liste=();

if ($file_type eq "LISTE")
{
   print "DEBUG LISTE\n";
   foreach $ligne (@file)
   {
      print "DEBUG foreach LISTE\n";
      $serie=$ligne;
      chop ($serie);
      push (@liste, $serie);
      print "DEBUG $serie \n";
   }
}
elsif ($file_type eq "COL")
{
   #---------------------------------------------------------------------------
   # Extraction des series
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
         # test : type different de "."
         $type_c=substr ($lig, $type_start, $type_size);
         $type_p=substr ($type_c, 0, 1);
         if ($type_p ne ".")
         {
            # A FAIRE : extraction s‚rie
	    # $serie=substr($lig, $author_start, $author_size-1);
	    # $serie=~s/ +$//o;

            ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

            ($titre_seul, $alias_recueil,
             $ssssc, $issssc,
             $sc1, $isc1, $sc2, $isc2, $sc3, $isc3,
             $c1, $ic1, $c2, $ic2, $c3, $ic3) = decomp_titre ($titre, $nblig, $lig);

            if ($c1 ne "")
            {
               $c1=~s/\(/./;
               $c1=~s/\)/./;
               push (@liste, $c1);
            }
            if ($c2 ne "")
            {
               $c2=~s/\(/./;
               $c2=~s/\)/./;
               push (@liste, $c2);
            }
            if ($c3 ne "")
            {
               $c3=~s/\(/./;
               $c3=~s/\)/./;
               push (@liste, $c3);
            }
         }
      }
   }
}
elsif ($file_type eq "PARUTION")
{
   #---------------------------------------------------------------------------
   # Extraction des series
   #---------------------------------------------------------------------------
   foreach $ligne (@file)
   {
      $lig=$ligne;
      chop ($lig);

      $nom="";
      $prenom="";
      ($nom, $prenom, $titre, $cycle, $indice_cycle, $votitre, $genre, $rnf, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn) = split ("	", $lig);
      $cycle=~s/ $//;
      $cycle=~s/\(/./;
      $cycle=~s/\)/./;
      push (@liste, $cycle);
      @decoup=();
      @decoup=split(" : ", $cycle);
      $decoup=~s/\(/./;
      $decoup=~s/\)/./;
      if ($cycle ne $decoup[0])
      {
         push (@liste, @decoup);
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

$outB="batchs/tmp_cyc.bat";
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

   print $canalB "perl c:\\util\\bibserie.pl -s -v \"\^$nom\$\"\n";
}

close (OUTB);
print STDOUT " ==> fichier batchs/tmp_cyc.bat termin‚.\n";

$cmd="batchs\\tmp_cyc.bat";
system $cmd;

print STDOUT " double appel termin‚.\n";

exit;

# --- fin ---

