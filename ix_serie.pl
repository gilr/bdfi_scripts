#===========================================================================
# Generation des index des series
#---------------------------------------------------------------------------
# Historique :
# date : 03/11/2002
#
#  0.0  - 03/11/2002 : Creation d'aprŠs ix_biblio.pl
#  0.2  - 01/05/2003 : tri un peu plus potable, plus titres "alternatifs"
#  0.3a - 04/06/2003 : Menu par fonction javascript (un seul menu_xxx.js)
#  0.3b - 29/08/2003 : nettoyages
#  0.4  - 20/02/2004 : Prise en compte de nom diff‚rents pour "s‚rie"
#  0.4a - 12/05/2004 : Deplacement des scripts javascript
#  0.5  - 04/08/2004 : Utilisation d'un script pour l'alphabet
#                       Nettoyage du code HTML genere (CSE HTML Validator Lite)
#                       Ajout lien index pays et page recherche
#  0.6  - 24/01/2005 : Mise a jour pour CSS et XHTML 1.0 strict
#  0.7  - 09/08/2005 : Mise a jour du design d‚finitif (xhtml)
#  1.0    18/10/2007 : Passage à l'extension php
#                      Utilisation de la librairie de fonction web_xxx
#  1.1  - 03/08/2010 : upload automatique par defaut
#  1.2  - 11/11/2010 : gestion cycles et sous-cycles multiples
#
#---------------------------------------------------------------------------
# Utilisation :
#    lettre -h : cr‚ation pages xhtml/php seules (X.php)
#    lettre -u : pas d'upload automatique
#    lettre +b : creation fichier batch (bib_X.bat)
#    lettre    : cr‚ation pages + fichier batch
#---------------------------------------------------------------------------
#
# A FAIRE :
#
#   Pr‚voir les titres alternatif de sous-s‚ries
#   Trier sans prendre en compte le premier caractŠre si '"'
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/series";
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
   print STDERR "        -r : raz complet biblios dans le batch \n";
   print STDERR "        -u : pas d'upload du fichier\n";
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
# Lecture du fichier series
#---------------------------------------------------------------------------
my $file_cyc="series.res";
open (f_cyc, "<$file_cyc");
my @cyc=<f_cyc>;
close (f_cyc);
push (@cyc, "Tarzan\n");
push (@cyc, "Les dames du lac\n");

my $file_cyc_alt="series.alt";
open (f_cyc_alt, "<$file_cyc_alt");
my @cyc_alt=<f_cyc_alt>;
close (f_cyc_alt);

my @series=();

#---------------------------------------------------------------------------
# Creation des entr‚es
#---------------------------------------------------------------------------
foreach $ligne (@cyc)
{
   my $titre_fichier=$ligne;
   chop ($titre_fichier);
   my $titre_cycle = $titre_fichier;

   $titre_cycle=~s/ \[(.*)\]//;
   my ($tmp, $titre_surcycle)=split(/\[/, $titre_fichier);
   $titre_surcycle=~s/\]//;
   
   #--- Si on veut une page html par s‚rie mais pas par sous-s‚rie
   if ($titre_surcycle ne '') {
      $url_cycle=url_serie($titre_surcycle);
   }
   else
   {
      $url_cycle=url_serie($titre_cycle);
   }

   # Si on voulait une page html par s‚rie ou sous-s‚rie
   #--------------------------------------------------------
   #  $url_cycle=url_serie($titre_cycle);

   $url_cycle="${url_cycle}.php";

   ($titre_index, $titre_index_2)=decomp($titre_cycle);
   $record="$titre_index	$titre_surcycle	$url_cycle	$titre_cycle";
   push (@series, $record);
   if ($titre_index_2 ne '')
   {
      $record="$titre_index_2	$titre_surcycle	$url_cycle	$titre_cycle";
      push (@series, $record);
   }
}

foreach $ligne (@cyc_alt)
{
   $titre_cycle=$ligne;
   chop ($titre_cycle);
   ($titre_cycle, $titre_cycle_ref) = split (/\t/, $titre_cycle);

   $url_cycle=url_serie($titre_cycle_ref);
   $url_cycle="${url_cycle}.php";
   ($titre_index, $titre_index_2)=decomp($titre_cycle);
   $record="$titre_index		$url_cycle";
   push (@series, $record);
   if ($titre_index_2 ne '')
   {
      $record="$titre_index_2		$url_cycle";
      push (@series, $record);
   }
}

@tri = sort @series;

if ($html==1) {
   $outH="${livraison_site}/${lowchoix}.php";
   open (OUTH, ">$outH");
   $canalH=OUTH;
   
   &web_begin ($canalH, "../commun/", "Index des cycles et s&eacute;ries de l'imaginaire : $upchoix");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Index des cycles et s&eacute;ries : lettre $upchoix");
   &web_head_meta ("keywords", "series, serie, cycles, cycle, romans, nouvelles, auteur, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
   &web_head_css ("screen", "../styles/bdfi.css");
   &web_head_js ("../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../scripts/outils_v2.js");
   &web_body ();
   &web_menu (1, "series");

   &web_data ("<div id='menbib'>Vous &ecirc;tes ici : <a href='..'>BDFI</a>\n");
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='.'>S&eacute;ries</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Index\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Initiale $upchoix</div>\n");

   &web_alphab (1, 1);
   &web_data ("<h1>$upchoix</h1>\n\n");
   &web_data ("<table class='index'>\n");
}

$iaut=0;
foreach $serie (@tri)
{
#  printf STDOUT "$serie \n";
   ($index, $surcycle, $page, $cycle_ini)=split(/	/, $serie);
   # Si la premiŠre lettre correspond … l'initiale
   # (ou seconde si premiŠre='"')
   if (((substr($index, 0, 1) ge '0') && (substr($index, 0, 1) le '9') && ($lowchoix eq "09")) ||
       ((substr($index, 0, 1) eq $upchoix) ||
        (((substr($index, 0, 1) eq '"') || (substr($index, 0, 1) eq '(')) && (substr($index, 1, 1) eq $upchoix))))
   {
      if ($html==1) {
         $iaut++;

         if ($iaut==1) {
             &web_data ("<tr>");
         }
         elsif ($iaut%2==1) {
            &web_data ("</tr>\n<tr>");
         }
         &web_data ("<td>");
         if ($surcycle eq '') {
            &web_data ("<a href='pages/$page'>$index</a>");
         }
         else {
            $name = &url_name_sous_serie ($cycle_ini);
            &web_data ("<a href='pages/$page#$name'>$index</a>");
            &web_data (" ($surcycle)");
         }
         &web_data ("</td>\n");
      }
   }
}
print $canalH "</tr>\n";

if ($html==1) {
   &web_data ("</table>\n\n");
   &web_alphab (1, 1);
   &web_end();
   
   close (OUTH);
   print STDERR " Fichier $outH termin‚\n";
}

if ($upload == 1)
{
   $cwd = "/www/series";
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
   # Les (guerres|enfants|histoires|mystŠres|chevaliers|apprentis)
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
   ($a1, $a2, $a3) = split(/^((?:Les )?(?:guerres|enfants|histoires|mystŠres|chevaliers|apprentis) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:Le )?(?:cycle|chant|club|livre|grand livre|monde|dit) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et '))
   {
      $a2=~s/ $//;
      $bis = "$a3 ($a2)";
   }
   $chaine=$_[0];
   ($a1, $a2, $a3) = split(/^((?:La )?(?:geste|s‚quence|s‚rie|ballade|guerre|l‚gende|saga|quˆte|trilogie|pentalogie) (?:de la |de l'|des |du |d'|de )?)/i, $chaine);
   if (($a3 ne '') && (substr($a3,0,3) ne 'et ') && (substr($a3,0,1) lt '0') && (substr($a3,0,1) gt '9'))
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
