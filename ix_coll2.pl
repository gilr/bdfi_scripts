#===========================================================================
#
# Script de generation des index des pages collections
#
# A renommer en ix_coll.pl (officiel)
#
#---------------------------------------------------------------------------
# Historique :
#  v0.1  - 08/07/2007 creation
#   0.5  - 18/10/2007 : Passage à l'extension php
#   1.0  - 30/09/2010 : upload automatique par defaut
#
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl ix_coll.pl
#           pour collection à partir de collec.res
#---------------------------------------------------------------------------
#
# A FAIRE
#
# Index par :
#  <Ed. editeur>, <Coll. collection> --> dans Editeur, collection et dans Collection (editeur)
#
# Virer les 208, 209 et 210 (in machin, nø 207)
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
my $upload=1;

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
   print STDERR "        -u : pas d'upload du fichier\n";
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

   # Suppression de la marque indiquant une page avec sigles regroupés
   if (substr ($sigle, 0, 1) eq "*") {
      $sigle=substr($sigle, 1);
#      $mode_sigle="MULTI"; 
#      @liste_sigles=split(/;/, $multi);
      #print "[$fsig] @liste_sigles\n";
   }


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
   if ($genre1 eq ".") { $genre1 = ""; }
   elsif ($genre1 eq "I") { $genre1 = ""; }
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

   if (($souscoll eq "") || ($souscoll eq "-"))
   {
      $record="$nom ($editeur)	<em>$nom</em> ($editeur)	$lien	$sigle	$comment";
      push (@collec, $record);
      $record="$intitule, coll. $nom	$intitule, coll. <em>$nom</em>	$lien	$sigle	$comment";
      push (@collec, $record);
   }
   else
   {
      $record="$nom $souscoll ($editeur)	<em>$nom $souscoll</em> ($editeur)	$lien	$sigle	$comment";
      push (@collec, $record);
      $record="$souscoll - Coll. $nom ($editeur)	<em>$souscoll</em> - Coll. <em>$nom</em> ($editeur)	$lien	$sigle	$comment";
      push (@collec, $record);
      $record="$intitule, $nom $souscoll	$intitule, <em>$nom $souscoll</em>	$lien	$sigle	$comment";
      push (@collec, $record);
   }
}

@tri = sort @collec;

 #---------------------------------------------------------------------------
 # Header Fichiers index alphabetique
 #---------------------------------------------------------------------------
 @canal_alpha=();
 $i=1;
 foreach $let ('a'...'z', '09')
 {
    if (($tous eq "1") || ($let eq $lowchoix))
    {
       $out="$livraison_site/$let.php";
       $canal_alpha{$let}="CANAL_" . $let;
       open ($canal_alpha{$let}, ">$out");
    }
 }

 foreach $let ('a' ... 'z', '09')
 {
    if (($tous eq "1") || ($let eq $lowchoix))
    {
       $canal=$canal_alpha{$let};

       &web_begin($canal, "../commun/", "Index alphabetique editeurs et collections - lettre $let");
       &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
       &web_head_meta ("description", "Index alphabetique editeurs et collections - lettre $let");
       &web_head_meta ("keywords", "collection, edition, editeur, roman, nouvelles, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
       &web_head_css ("screen", "../styles/bdfi.css");
       &web_head_js ("../scripts/jquery-1.4.1.min.js");
       &web_head_js ("../scripts/outils_v2.js");
       &web_body ();
       &web_menu (1, "collections");

       $maj=uc($let);
   &web_data ("<div id='menbib'>Vous &ecirc;tes ici : <a href='..'>BDFI</a>\n");
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='.'>Collections</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Index\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Initiale $maj</div>\n");
       &web_alphab (0, 1);
       &web_data ("<h1>$maj</h1>\n\n");
       &web_data ("<table summary='Collections avec initiale $maj'>\n");
    }
 }

@liste_tri=sort tri @collec;

#---------------------------------------------------------------------------
# index par fichier sigle
#---------------------------------------------------------------------------
foreach $toto (@liste_tri)
{
   my ($inutile, $intitule, $topic, $sigle, $comment) = split(/\t/, $toto);
   $forum="http://forums.bdfi.net/viewtopic.php?id=$topic";

   #--- nom du fichier pour la collection
   $sigle=~s/ +$//;
   $sigle=~s/&/_/;
   $sigle=lc($sigle);

   $initiale=lc(substr($inutile, 0, 1));
   $canal="CANAL_" . $initiale;
   if (($initiale < 'a') || ($initiale > 'z'))
   {
      $canal="CANAL_09";
   }
   &web_canal ($canal);
   if (($tous eq "1") || ($initiale eq $lowchoix))
   {
      &web_data ("<tr><td>");
      &web_data ("<a href='pages/${sigle}.php'>$intitule</a> - $comment - ");
      &web_data ("<a href='$forum'>forum</a>");
      &web_data ("</td></tr>\n");
   }
}

#---------------------------------------------------------------------------
# Fin fichiers index alphabetique
#---------------------------------------------------------------------------
foreach $let ('a'...'z', '09')
{
   if (($tous eq "1") || ($let eq $lowchoix))
   {
      $canal=$canal_alpha{$let};
      &web_canal ($canal);
      &web_data ("</table>");
      &web_data ("<hr />\n");
      &web_end();
      close ($canal);
      if ($upload == 1)
      {
         $file = "$livraison_site/$let.php";
	 print $file;
         $cwd = "/www/collections";
         &bdfi_upload($file, $cwd);
      }
   }
}

sub tri
{
   my @liste=split (/[ ']/, $a);
   my $mot=$liste[0];

   $ia=$a;
   if (($mot eq "Le") ||
       ($mot eq "La") ||
       ($mot eq "Les") ||
       ($mot eq "L") ||
       ($mot eq "Du") ||
       ($mot eq "Des") ||
       ($mot eq "Un") ||
       ($mot eq "Une"))
   {
      $ia=~s/^$mot//;
      $ia=~s/^ //;
      $ia=~s/^'//;
   }
   $ia=~s/^"//;
   my @liste=split (/[ ']/, $b);
   my $mot=$liste[0];

   $ib=$b;
   if (($mot eq "Le") ||
       ($mot eq "La") ||
       ($mot eq "Les") ||
       ($mot eq "L") ||
       ($mot eq "Du") ||
       ($mot eq "Des") ||
       ($mot eq "Un") ||
       ($mot eq "Une"))
   {
      $ib=~s/^$mot//;
      $ib=~s/^ //;
      $ib=~s/^'//;
   }
   $ib=~s/^"//;

   lc($ia) cmp lc($ib);
}

# --- fin ---

