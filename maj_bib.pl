#===========================================================================
#
# Mise a jour des biblios 
#    - d'aprŠs une liste d'auteur
#    - d'aprŠs un fichier collection
#   
#---------------------------------------------------------------------------
# Historique :
# date : 17/08/2001
#        21/06/2002 utilisation du module bdfi.pm
#        05/05/2003 ajout option depuis un fichier liste d'auteur
#        19/04/2004 Mise … jour pour nouveau format (oubli‚)
#        15/10/2017 Fichier avec nom complet (permet tmp.tmp par exemple)
#
#---------------------------------------------------------------------------
# Utilisation :
#  $0 -L <fichier_liste_aut>
#  $0 -C <fichier_col>
#  $0 -P <fichier_parutions>
#
# FAIRE :
#    - ajout option pour appel du batch cree
#    (ou une seule option pour les deux)
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

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Generation du fichier maj_aut.tmp
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "Usage : $0 [-l|-c|-p]<file>\n";
   print STDERR "-------\n";
   print STDERR "        G‚n‚ration des biblios d'auteurs. \n";
   print STDERR "Options :\n";
   print STDERR "---------\n";
   print STDERR "   -l :  d'aprŠs une liste d'auteur (fichier liste) \n";
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
print "--- DEBUG fichier [$file_name] type [$file_type]\n";
open (f_file, "<$file_name");
@file=<f_file>;
close (f_file);

@liste=();

if ($file_type eq "LISTE")
{
   foreach $ligne (@file)
   {
      $auteur=$ligne;
      chop ($auteur);
      push (@liste, $auteur);
   }
}
elsif ($file_type eq "COL")
{
   #---------------------------------------------------------------------------
   # Extraction des auteurs
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
            $auteur=substr($lig, $author_start, $author_size-1);
            $auteur=~s/ +$//o;
            push (@liste, $auteur);
         }
      }
   }
}
elsif ($file_type eq "PARUTION")
{
   #---------------------------------------------------------------------------
   # Extraction des auteurs
   #---------------------------------------------------------------------------
   foreach $ligne (@file)
   {
      $lig=$ligne;
      chop ($lig);

      $nom="";
      $prenom="";
      ($nom, $prenom, $titre, $cycle, $indice_cycle, $votitre, $genre, $rnf, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn) = split ("	", $lig);
      $nom = &noacc($nom);
      $nom=uc($nom);
      $auteur = "$nom $prenom";
      $auteur=~s/ $//;
      push (@liste, $auteur);
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

$outB="batchs/tmp_bib.bat";
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

   print $canalB "perl c:\\util\\biblio.pl -s -v \"\^$nom\$\"\n";
}

close (OUTB);
print STDOUT " ==> fichier batchs/tmp_bib.bat termin‚.\n";

#system "ls";
#system 'command', '/C', 'call', '"s:\\sf\\batchs\\tmp_bib.bat"';
$cmd="batchs\\tmp_bib.bat";
system $cmd;

print STDOUT " double appel termin‚.\n";

exit;

# --- fin ---

