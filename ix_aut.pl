#===========================================================================
#
# Script de generation du fichier batch d'appel des biblios
#
#---------------------------------------------------------------------------
# Historique :
#  0.1  - 13/11/2000 : Creation 
#  0.2  - 14/12/2000 : Ajout d'un alphabet en bas de page
#  0.3  - 18/12/2000 : Amelioration fontes
#  0.4  - 26/12/2000 : Ajout font d'ecran + date de generation, livraison immediate
#  0.5  - 15/03/2000 : Sub url, titre, tag m‚tas
#  0.6  - 17/08/2001 : Modif nom : bib_X.bat, dans repertoire batchs
#  0.6a - 21/06/2002 : Utilisation du module bdfi.pm
#  0.7  - 23/06/2002 : Ajout des biblios dans les batchs de generation de pages
#  0.8  - 04/07/2002 : Option pour RAZ complet des biblios lettre dans le batchs
#  0.9  - 27/07/2002 : Ajout des menus sur les pages index
#  0.9a - 04/06/2003 : Menu par fonction javascript (un seul menu_xxx.js)
#  0.9b - 12/05/2004 : Deplacement des scripts javascript
#  1.0  - 04/08/2004 : Utilisation d'un script pour l'alphabet
#                      Nettoyage du code HTML genere (CSE HTML Validator Lite)
#                      Ajout lien index pays et page recherche
#  1.1  - 20/01/2005 : Mise à jour pour CSS - XHTML
#  1.2    11/08/2005 : Mise a jour du design definitif (xhtml)
#  1.2    11/08/2005 : Mise a jour du design definitif (xhtml)
#  1.3    17/10/2007 : Passage à l'extension php
#                      Utilisation de la librairie de fonction web_xxx
#  1.4  - 03/08/2010 : upload automatique par defaut
#  2.0  - 24/12/2020 : suppression g‚n‚ration pages initiale
#---------------------------------------------------------------------------
# Utilisation :
#    lettre -h : creation page php seule (X.php)
#    lettre -b : creation fichier batch (bib_X.bat)
#    lettre -u : pas d'upload automatique
#    lettre    : creation page php + fichier batch
#---------------------------------------------------------------------------
# FAIRE / BUG
#  rejet de certains noms ?
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 <lettre>\n";
   exit;
}

my $i=0;
while ($ARGV[$i] ne "")
{
   $choix=$ARGV[$i];
   $i++;
}

# Lecture du fichier auteurs
#---------------------------------------------------------------------------
$file="auteurs.res";
open (f_aut, "<$file");
@aut=<f_aut>;
close (f_aut);

#---------------------------------------------------------------------------
# Recherche de tout les auteurs commen‡ant par la lettre fournie
#---------------------------------------------------------------------------
$upchoix=uc($choix);
$lowchoix=lc($choix);

@res=grep (/^$upchoix/, @aut);

$nb=$#res+1;
if ($nb == 0)
{
   print STDERR " Aucun auteur pour cette lettre\n";
   exit;
}


$outB="batchs/bib_${lowchoix}.bat";
open (OUTB, ">$outB");
$canalB=OUTB;
print STDERR " Fichier $outB termin‚\n";

#--- Table des noms
$iaut=0;
foreach $auteur (@res)
{
   chop ($auteur);

   #
   # A FAIRE : inserer eventuellement un rejet de certains noms ?
   #
   $iaut++;

   $url=&url_auteur($auteur);
   $url=~s/$/.php/g;

   print $canalB "perl c:\\util\\biblio.pl -s -v \"\^$auteur\$\"\n";
}
&web_data ("</tr>\n");

close (OUTB);

exit;

# --- fin ---

