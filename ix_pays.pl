#===========================================================================
#
# Script de generation d'une page auteurs Pays,
#   Les pages auteurs doivent avoir ete creees avant
#
#  ainsi que d'‚ventuellement du fichier batch d'appel des biblios
#   (pour si mise … jour uniquement des auteurs d'un pays)
#
#---------------------------------------------------------------------------
# Historique :
#  0.1 - 16/07/2002 : creation a partir de lettre.pl
#  0.2 - 05/08/2002 : Ajout des menus sur les pages index
#  0.3 - 31/10/2002 : Correction titre + Gestion des noms compos‚s de pays
#  0.4 - 28/01/2003 : Ajout drapeau, modification titre
#  0.5 - 04/06/2003 : Menu par fonction javascript (un seul menu_xxx.js)
#  0.6 - 21/12/2003 : Petites corrections (blancs en fin de nom, help)
#  0.7 - 04/08/2003 : Nettoyage du code genere (CSE HTML Validator Lite)
#  0.8 - 28/01/2005 : Mise à jour pour CSS - XHTML
#  0.9 - 12/08/2005 : Mise a jour du design d‚finitif (xhtml)
#  1.0 - xx/10/2007 : Passage à l'extenstion PHP
#                     Utilisation de la source auteurs.txt (plus de xxx.aut)
#  1.1 - 24/.3/2009 : Nouveau format auteurs (ajout URL, nom et pr‚nom d‚corr‚l‚s)
#  1.2  - 03/03/2012 : upload automatique par defaut
#---------------------------------------------------------------------------
# Utilisation :
#    lettre +b : creation fichier batch (bib_X.bat)
#    lettre -u : pas d'upload automatique
#    lettre    : cr‚ation page html + fichier batch
#---------------------------------------------------------------------------
#
# A FAIRE : 
#
#  Prévoir Découpe "programmable" (en nombre) par pays 
#  -  d‚coupage France et USA en 4 (A-C / D-L / M-Z)
#  -  traiter les US (decoupage plus important ? Apres decompte du nombre)
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/auteurs";
my $batch=0;
my $raz=0;
my $upload=1;

# Tableau des decoupes eventuelles
@decoupe = ( 
   { PAYS=>"france", NB=>4 },
   { PAYS=>"etats_unis", NB=>4 },
);

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
if ($ARGV[0] eq "")
{
   print STDERR "Usage : $0 [+b] <pays>\n";
   print STDERR "        Creation page xhtml/php lien des auteurs 'pays'\n";
   print STDERR "Options\n";
   print STDERR "        +b : creation du batch en plus\n";
   print STDERR "        -u : pas d'upload du fichier\n";
   exit;
}
$i=0;
while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "+b")
   {
      $batch=1;
   }
   elsif ($ARGV[$i] eq "-u")
   {
      $upload = 0;
   }
   else
   {
      $pays=&win2dos($ARGV[$i]);
      $pays=~s/ +$//o;
      $pays=~s/^ +//o;
      $pays=~s/_/ /og;
      $cmp_pays=lc($pays);
      $cmp_pays=&noacc($cmp_pays);
      $choix=$cmp_pays;
      $choix=~s/-/_/og;
      $choix=~s/ /_/og;
      print STDERR "PAYS $pays - Fichier $choix\n";
   }
   $i++;
}

#---------------------------------------------------------------------------
# Ouverture du fichier auteurs.txt (export MS-DOS txt de excel)
#---------------------------------------------------------------------------
$file="auteurs.txt";
open (f_bio, "<$file");
@bio=<f_bio>;
close (f_bio);
   
@cf_renvois=();
$cf_renvoi=();
@aut=();

#---------------------------------------------------------------------------
# Recherche des auteurs du pays
#---------------------------------------------------------------------------
foreach $lig (@bio)
{
   ($key1,$key2,$nom,$sexe,$pseu,$vrai,$renvoi,$nation,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
   $key = "$key1 $key2";
   if (($renvoi eq '') || ($renvoi eq ' '))
   {
      # Pas de renvoi, info locale :
      $cmp_nation = &noacc(lc($nation));
      if ($cmp_nation eq $cmp_pays)
      {
         #------------------------------------------------------------
         # le pays est OK, memoriser l'auteur
         #------------------------------------------------------------
         push (@aut, $key);
      }
   }
   else
   {
      $cf_renvoi = $renvoi;
      @cf_renvois = split (/\+/, $renvoi);

      $cfr = $cf_renvois[0];

      $cfr=~s/^ +//;
      $cfr=~s/ +$//;
      #--------------------------------------------------------
      # Recherche de la reference du renvoi
      #--------------------------------------------------------
      foreach $lig (@bio)
      {
         ($keyb1,$keyb2,$nom,$sexe,$pseu,$vrai,$ref,$nation,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
         $keyb = "$keyb1 $keyb2";
         $cmp_nation = &noacc(lc($nation));
         if (($keyb eq $cfr) && ($cmp_nation eq $cmp_pays))
         {
            #------------------------------------------------------------
            # le pays est OK, memoriser l'auteur
            #------------------------------------------------------------
            push (@aut, $key);
         }
      }
   }
}

#---------------------------------------------------------------------------
# Controle du nombre d'auteurs
#---------------------------------------------------------------------------
$nb=$#aut+1;
if ($nb == 0)
{
   print STDERR " Aucun auteur trouve dans du pays $pays\n";
   exit;
}
print STDERR "Nombre de signatures du pays : $nb\n";

#---------------------------------------------------------------------------
# Faut-il decouper ?
#---------------------------------------------------------------------------
$pages=1;
foreach $record (@decoupe)
{
   if (lc($choix) eq lc($record->{PAYS}))
   {
      $pages = $record->{NB};
      print STDERR "Nombre de pages a generer : $pages\n";
   }
}
$next='A';
for ($page=1; $page<=$pages; $page++)
{
   if ($pages == 1) { $suffixe=""; $tranche=""; }
   else {
      $debut=$next; 
      if ($page == $pages) {
         $fin='Z';
      }
      else {
         $fin=substr($aut[$nb*$page/$pages],0,1);
         $fin=chr(ord($fin)-1);
         $next=chr(ord($fin)+1);
      }
      $suffixe=lc("_${debut}${fin}");
      $tranche=" - $debut &agrave; $fin";
      print STDERR "Suffixe $page : $suffixe\n";
   }

#---------------------------------------------------------------------------
# Generation de la (ou des) pages d'index
#---------------------------------------------------------------------------
if ($batch==1) {
   $outB="batchs/${choix}${suffixe}.bat";
   open (OUTB, ">$outB");
   print STDERR " Fichier $outB termin‚\n";
}


$outH="${livraison_site}/${choix}${suffixe}.php";
open (OUTH, ">$outH");
$canalH=OUTH;
$titre=$pays;
substr($titre,0,1)=uc(substr($titre,0,1));
$titre=~s/ (.)/ $1/;
$maj=uc($1);
$titre=~s/ (.)/ $maj/;
$titre=~s/Rep /Rep. /;

&web_begin($canalH, "../commun/", "Index des bibliographies de l'imaginaire (pays : ${titre}${tranche})");
&web_head_meta ("author", "Moulin Christian, Richardot Gilles");
&web_head_meta ("description", "Index des bibliographies d'auteurs (${titre}${tranche})");
&web_head_meta ("keywords", "biblio, biblios, bibliographie, bibliographies, romans, nouvelles, auteur, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur, $pays");
&web_head_css ("screen", "../styles/bdfi.css");
&web_head_js ("../scripts/outils.js");
&web_body ();
&web_menu (1, "auteurs");

   &web_data ("<div id='menbib'>Vous &ecirc;tes ici : <a href='..'>BDFI</a>\n");
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='.'>Auteurs</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Index\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='index_pays.php'>Pays</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> $pays</div>\n");

#&web_data ("Index des auteurs par nationalit‚s &nbsp;&nbsp; - ");
#&web_data ("&nbsp;&nbsp; <a href='recherche.php'>Recherche d'un nom</a>\n");

&web_data ("<h1>");
&web_data ("<img src='../images/drapeaux/${choix}.png' alt='(drapeau)' />");
&web_data (" ${titre}${tranche} ");
&web_data ("<img src='../images/drapeaux/${choix}.png' alt='(drapeau)' />");
&web_data ("</h1>\n");
&web_data ("<table class='index' summary='index des auteurs - ${titre}'>\n");

#---------------------------------------------------------------------------
# Ajouter les liens de tous les auteurs dont la page existe
#---------------------------------------------------------------------------
$iaut=0;
foreach $auteur (@aut)
{
   #chop ($auteur);

   #
   # inserer eventuellement un rejet de certains noms
   #
   $auteur=~s/ *$//;
   $url=&url_auteur($auteur);
   $url=~s/$/.php/g;
   $initiale=substr ($url, 0, 1);
   $initiale=lc($initiale);

   # Dans le cas de découpes, vérifier l'initiale :
   if (($pages == 1) || (($initiale ge lc($debut)) && ($initiale le lc($fin)))) {
   # print STDERR "[$page/$pages] - [$debut] [$initiale] [$fin]\n";
   # Ici, v‚rifier l'existence.
   $url_test=$livraison_site . "/${initiale}/${url}";
            
   $nf=1;
   open(AUTHOR, "<$url_test") or $nf=0;
   if ($nf == 1)   # si le lien existe
   {
      $iaut++;

      if ($batch == 1)
      {
         print $canalB "perl biblio.pl -s -v \"\^$auteur\$\"\n";
      }
      if ($iaut==1) {
         &web_data ("<tr>\n");
      }
      elsif ($iaut%3==1) {
         &web_data ("</tr><tr>\n");
      }
      &web_data ("<td><a href='$initiale/$url'>$auteur</a></td>\n");
   }
   else
   {
      print STDERR "($auteur) $url_test non trouv‚ ?\n";
   }
   }
}
&web_data ("</tr>\n");
&web_data ("</table>\n\n");
&web_end();
close (OUTH);
print STDERR " Fichier $outH termin‚\n";

if ($batch==1) {
   close (OUTB);
}
}

if ($upload == 1)
{
   $file = $outH;
   $cwd = "/www/auteurs";
   &bdfi_upload($file, $cwd);
}
exit;

# --- fin ---
