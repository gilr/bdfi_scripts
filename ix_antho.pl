#===========================================================================
# Generation des index des anthologies, recueils, omnibus...
#---------------------------------------------------------------------------
# Historique :
# date : ../02/2004
#
#  0.0  - ../02/2004 : Creation d'aprŠs ix_antho.pl 
#  1.0  - 04/08/2004 : Utilisation d'un script pour l'alphabet
#                      Nettoyage du code HTML genere (CSE HTML Validator Lite)
#  1.1  - 10/02/2005 : Mise à jour pour CSS - XHTML
#  1.2  - 17/08/2005 : Design xhtml definitif
#  1.3    18/10/2007 : Passage à l'extension php
#  1.4  - 03/08/2010 : upload automatique par defaut
#
#---------------------------------------------------------------------------
# Utilisation :
#    lettre -h : cr‚ation pages xhtml/php seules (x.php)
#    lettre +b : creation fichier batch (bib_X.bat)
#    lettre -u : pas d'upload automatique
#    lettre    : cr‚ation pages html + fichier batch
#---------------------------------------------------------------------------
#
# A FAIRE : (voir BDFI.PM)
#
# Tout ou presque
# 20 <-> vingt etc... (doubler tout ce qui commence par chiffre ou nombre)
#
# Diff‚rencier titre sur ann‚e (d‚cennie) et auteur (lg)
#
# Mˆmes pages pour xxxxxxx, xxxxxxx - i, xxxxxxx (<...>)
#  remplacer les ", Tome i" par " - Tome i"
#
# Mˆmes pages pour xxxxxxx : <...>
#
# Mˆmes pages pour xxxxxxx nø <i>
#
# Mˆmes pages pour xxxxxxx <i>
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/recueils";
my $batch=0;
my $html=1;
my $raz=0;
my $upload=1;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 [-b][-h]|[-r] <lettre>\n";
   print STDERR "        -h : format xhtml/php seul\n";
   print STDERR "        -b : batch seul \n";
   print STDERR "        -u : pas d'upload du fichier\n";
   print STDERR "        -r : raz complet biblios dans le batch \n";
   exit;
}
my $i=0;
while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-h")
   {
      $batch=0;
   }
   elsif ($ARGV[$i] eq "-b")
   {
      $html=0;
   }
   elsif ($ARGV[$i] eq "-r")
   {
      $raz=1;
   }
   elsif ($ARGV[$i] eq "-u")
   {
      $upload = 0;
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
# Lecture du fichier anthos
#---------------------------------------------------------------------------
my $file_ant="anthos.res";
open (f_ant, "<$file_ant");
my @ant=<f_ant>;
close (f_ant);

#my $file_ant_alt="anthos.alt";
#open (f_ant_alt, "<$file_ant_alt");
#my @ant_alt=<f_ant_alt>;
#close (f_ant_alt);

my @anthos=();

#---------------------------------------------------------------------------
# Creation des entr‚es
#
#  Ce qui diff‚rencie deux entr‚es :
#   titre + date cop.
#
#---------------------------------------------------------------------------
foreach $ligne (@ant)
{
   my $enreg=$ligne;
   ($titre, $idrec)=split (/\t/, $enreg);

   my $titre_antho = $titre;

   $titre_antho=~s/ \[(.*)\]//;
   
   $url_antho=url_antho($idrec);

   $url_antho="${url_antho}.php";

   ($titre_index, $titre_index_2)=decomp($titre_antho);
   $record="$titre_index	$url_antho";
   push (@anthos, $record);
   if ($titre_index_2 ne '')
   {
      $record="$titre_index_2	$url_antho";
      push (@anthos, $record);
   }
}

@tri = sort @anthos;

if ($html==1) {
   $outH="${livraison_site}/${lowchoix}.php";
   open (OUTH, ">$outH");
   $canalH=OUTH;

   &web_begin($canalH, "../commun/", "Index des recueils et anthologies de l'imaginaire : $upchoix");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Index des recueils et anthologies, initiale $upchoix");
   &web_head_meta ("keywords", "recueil, anthologie, recueil, anthologie, omnibus,  nouvelles, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
   &web_head_css ("screen", "../styles/bdfi.css");
   &web_head_js ("../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../scripts/outils_v2.js");
   &web_body ();
   &web_menu (1, "recueils");

   &web_data ("<div id='menbib'>Vous &ecirc;tes ici : <a href='..'>BDFI</a>\n");
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='.'>Recueils</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Index\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Initiale $upchoix</div>\n");
   &web_alphab (1, 1);
   &web_data ("<h1>$upchoix</h1>\n\n");
   &web_data ("<table class='index' summary='index des recueils lettre $upchoix'>\n");
}

$iaut=0;
foreach $antho (@tri)
{
   ($index, $page)=split(/	/, $antho);

   # Si la premiŠre lettre correspond … l'initiale
   # (ou seconde si premiŠre='"' ou "(") 
   if (((substr($index, 0, 1) ge '0') && (substr($index, 0, 1) le '9') && ($lowchoix eq "09")) ||
       ((substr($index, 0, 1) eq $upchoix) ||
        (((substr($index, 0, 1) eq '"') || (substr($index, 0, 1) eq '(')) && (substr($index, 1, 1) eq $upchoix))))
   {
      if ($html==1) {
         $iaut++;
         if ($iaut==1) {
            &web_data ("<tr>\n");
         }
         elsif ($iaut%2==1) {
            &web_data ("</tr>\n<tr>\n");
         }
         &web_data ("<td><a href='pages/$page'>$index</a></td>\n");
      }
   }
}
&web_data ("</tr>\n");

if ($html==1) {
   &web_data ("</table>\n\n");
   &web_alphab (1, 1);
   &web_end();
   
   close (OUTH);
   print STDERR " Fichier $outH termin‚\n";
}

if ($upload == 1)
{
   $cwd = "/www/recueils";
   &bdfi_upload($outH, $cwd);
}

#-----------------------------------------------------------------------------
# Recherche des titres 
#-----------------------------------------------------------------------------
sub decomp
{
   my $chaine=$_[0];
   my @liste=split (/[ ']/, $chaine);
   my $mot=$liste[0];
   my $bis='';

   if (($mot eq "Le") ||
       ($mot eq "La") ||
       ($mot eq "Les") ||
       ($mot eq "L") ||
       ($mot eq "Du") ||
       ($mot eq "Des") ||
       ($mot eq "Un") ||
       ($mot eq "Une"))
   {
      $chaine=~s/^$mot//;
      $chaine=~s/^ //;
      $chaine=~s/^'//;
      substr($chaine, 0, 1) = &noacc (substr ($chaine, 0, 1));
      substr($chaine,0, 1) = uc (substr($chaine,0, 1));
      if ($mot eq 'L')
      {
         $resul="$chaine ($mot')";
      }
      else
      {
         $resul="$chaine ($mot)";
      }
      # ajouter ' si L
   }
   else
   {
      $resul="$chaine";
   }

   # Recherche d'un nom significatif diff‚rent :
   # Les (annales|chroniques|aventures|contes|chants|livres|mondes)
   # Les (guerres|histoires|mystŠres|apprentis)
   # Le (cycle|chant|club|livre|monde|grand livre|dit)
   # La (geste|s‚quence|s‚rie|ballade|guerre|l‚gende|saga|quˆte|trilogie|pentalogie)
   # L'(enfant|ere|histoire|archipel)
   # Un (chant)
   # Une (aventure|chronique)

   $chaine=$_[0];
   my ($a1, $a2, $a3) = split(/^((?:Les )?(?:annales|chroniques|aventures|contes|chants|livres|mondes) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:Les )?(?:guerres|histoires|mystŠres|apprentis) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:Le )?(?:cycle|chant|club|grand livre|monde|dit) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:La )?(?:geste|s‚quence|s‚rie|ballade|guerre|l‚gende|saga|quˆte|trilogie|pentalogie) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:L')?(?:enfant|Šre|histoire|archipel) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:Un )?(?:chant) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:Une )?(?:aventure|chronique) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }

   if (substr($bis, 0, 1) eq 'ƒ') { substr ($bis, 0, 1) = 'a'; }
   if (substr($bis, 0, 1) eq '‚') { substr ($bis, 0, 1) = 'e'; }
   if (substr($bis, 0, 1) eq 'Š') { substr ($bis, 0, 1) = 'e'; }
   substr($bis,0, 1) = uc (substr($bis,0, 1));
   return ($resul, $bis);
}

