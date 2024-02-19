
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";

sub usage
{
   print STDERR "usage : $0 -A | -a<file> | -S | -s<file>\n";
   print STDERR "        Contrìle d'existence de page bibliographique d'auteur ou de sÇrie.\n";
   print STDERR "options :\n";
   print STDERR "   -A :  d'apräs la liste d'auteur compläte (auteurs.res)\n";
   print STDERR "   -a :  d'apräs une liste d'auteur (fichier liste)\n";
   print STDERR "   -S :  d'apräs la liste des sÇries compläte (sÇries.res)\n";
   print STDERR "   -s :  d'apräs une liste de cycles/series (fichier liste)\n";
   print STDERR "   -R :  d'apräs la liste des recueils compläte (anthos.res)\n";
   exit;
}

#---------------------------------------------------------------------------
# Lecture du fichier
#---------------------------------------------------------------------------
$file='';

if ($ARGV[$i] ne "")
{
   $arg=$ARGV[$i];
   $deb=substr($arg, 0, 1);

   if ($deb eq "-")
   {
      if (substr($arg, 1, 1) eq "a")
      {
         $type="AUTEURS";
         $file=substr($arg, 2);
      }
      elsif (substr($arg, 1, 1) eq "A")
      {
         $type="AUTEURS";
         # Par defaut, le fichier auteurs.res
         $file="auteurs.res";
      }
      elsif (substr($arg, 1, 1) eq "s")
      {
         $type="SERIES";
         $file=substr($arg, 2);
      }
      elsif (substr($arg, 1, 1) eq "R")
      {
         $type="RECUEILS";
         # Par defaut, le fichier anthos.res
         $file="anthos.res";
      }
      elsif (substr($arg, 1, 1) eq "S")
      {
         $type="SERIES";
         # Par defaut, le fichier series.res
         $file="series.res";
      }
      else
      {
         # erreur
         usage;
         exit;
      }
   }
   else
   {
      # erreur
      usage;
      exit;
   }
}
else
{
   # erreur
   usage;
   exit;
}

$existf=1;
open (f_file, "<$file") or $existf=0;
if ($existf == 0)   # fichier inexistant
{
   print "fichier $file non trouvÇ\n";
   exit;
}
else
{
   @data=<f_file>;
   close (f_file);
}

# Boucle pour tous les auteurs
$old=" ";
if ($type eq "AUTEURS")
{
   foreach $record (@data)
   {
      chop ($record);
      # nom du lien, et initiale
      $lien=&url_auteur($record);
      $initiale=substr ($lien, 0, 1);
      $initiale=lc($initiale);
      if ($old ne $initiale) { print "($initiale)"; }
      $old=$initiale;
      $url="${local_dir}/auteurs/${initiale}/${lien}.php";

      $nf=1;
      open(AUTHOR, "<$url") or $nf=0;
      if ($nf != 1)   # lien existe
      {
         print "Page absente ($record) $url\n";
      }
      else
      {
         close AUTHOR;
      }
   }
}
elsif ($type eq "SERIES")
{
   foreach $record (@data)
   {
      chop ($record);

      # Specifique : prende ce qui est entre []
      $titre_cycle=$record;
      ($tmp, $titre_surcycle)=split(/\[/, $titre_cycle);
      $titre_surcycle=~s/\]//;
      if ($titre_surcycle ne "") {
         $record=$titre_surcycle;
      }

      # nom du lien
      $lien=&url_serie($record);
      $url="${local_dir}/series/pages/${lien}.php";

      $nf=1;
      open(CYCLE, "<$url") or $nf=0;
      if ($nf != 1)   # lien existe
      {
         print "Page absente ($record) $url\n";
      }
      else
      {
         close CYCLE;
      }
   }
}
else
{
   foreach $record (@data)
   {
      chop ($record);

      ($titre_antho, $id_antho, $page_antho)=split (/	/,$record);

      # nom du lien
      $lien=$page_antho;
      $url="${local_dir}/recueils/pages/${lien}.php";

      $nf=1;
      open(RECUEIL, "<$url") or $nf=0;
      if ($nf != 1)   # lien existe
      {
         print "Page absente ($record) $url\n";
      }
      else
      {
         close RECUEIL;
      }
   }
}

