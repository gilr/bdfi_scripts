#===========================================================================
#
# Script de generation des index des pages collections
#
# A SUPPRIMER ???
#---------------------------------------------------------------------------
# Historique :
#  v0.1  - 03/04/2001 creation
#  v0.2  - 13/01/2002
#        - 21/06/2002 Utilisation de bdfi.pm
#  v0.3  - ../../2003 Nouveau format de base de donnees
#  v0.4  - 09/01/2004 Index par initiale editeur/collection
#  v1.0  - 10/03/2006 Mise a jour pour CSS-XHTML et design definitif
#                     Annulation des fichiers sigles
#                     Renommages et reorganisation des index
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl ix_coll.pl
#
# Genere 2 index generaux
#    ix1 : liste des noms de fichiers COL
#    ix2 : liste des noms de fichiers COL et sigles inclus
# Genere 26 index alphab‚tiques
#    ix3_<lettre> : liste des sigles, avec noms de fichiers COL avec sigles
# Genere 1 index par fichier collection
#    ix4_<collection> : liste des sigles pour ce fichier COL
#
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
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------
#--- support
$coll_start=2;                                $coll_size=7;
$num_start=10;                                $num_size=5;
$typnum_start=15;
$date_start=17;                               $date_size=4;
$mois_start=22;                               $mois_size=2;

#--- intitule
$genre_start=3;
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

 #---------------------------------------------------------------------------
 # Variables globales
 #---------------------------------------------------------------------------
 my $livraison_site=$local_dir . "/_collec";

 my $ref_en_cours=0;
 my $in=0;
 my $oldin=0;
 my $old_titre="";

 #---------------------------------------------------------------------------
 # Parametres
 #---------------------------------------------------------------------------
 if ($ARGV[0] ne "")
 {
   print STDERR "usage : $0\n";
   exit;
 }

 #---------------------------------------------------------------------------
 # Header Fichier index 1
 #---------------------------------------------------------------------------

 #---------------------------------------------------------------------------
 # Header Fichier index 2
 #---------------------------------------------------------------------------

 #---------------------------------------------------------------------------
 # Header Fichiers index alphabetique
 #---------------------------------------------------------------------------
 @canal_alpha=();
 foreach $let ('A'...'Z', '09')
 {
   $out="$livraison_site/ix3_$let.htm";
   $canal_alpha{$let}="CANAL_" . $let;
   open ($canal_alpha{$let}, ">$out");
print "DBG: tableau index lettre [$let] [$out] $canal_alpha{$let}\n";
 }

 foreach $let ('A' ... 'Z', '09')
 {
   $canal_ix3j=$canal_alpha{$let};
print "DBG: entete lettre [$let]\n";

   &web_begin($canal_ix3j, "Index alphabetique editeurs et collections - lettre $let");
   &web_head_meta ("author", "Richardot Gilles");
   &web_head_meta ("description", "Index alphabetique editeurs et collections - lettre $let");
   &web_head_meta ("keywords", "collection, edition, editeur, roman, nouvelles, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
   &web_head_css ("screen", "../private.css");
   &web_head_js ("../scripts/header.js");
   &web_head_js ("../scripts/outils.js");
   &web_body ("../");
   &web_menu (0, "", "");

   print $canal_ix3j &tohtml("<font size=1>Index : <a href=\"ix1.htm\">fichiers</a> - ");
   print $canal_ix3j &tohtml("<a href=\"ix2.htm\">collections par fichier</a> - ");
   print $canal_ix3j &tohtml("editeurs &amp; collections [");
   foreach $lettre ('A' ... 'Z', '09')
   {
      print $canal_ix3j &tohtml(" <a href=\"ix3_".$lettre.".htm\">$lettre</a>");
   }
   print $canal_ix3j &tohtml(" ]</font>\n");
   print $canal_ix3j &tohtml("<h1>Index alphabetique ‚diteurs et collections - lettre $let</h1>");
   print $canal_ix3j &tohtml("<table border=0>");
 }

 #---------------------------------------------------------------------------
 # Boucles sur les fichiers col --> index par fichier collection
 #---------------------------------------------------------------------------
 $file="./listcol.res";
 open (f_listcol, "<$file") or print "DBG: PB !!!";
 @listcol=<f_listcol>;
print "DBG : liste col [$file][@listcol]\n";
 close (f_listcol);
 $icol=0;
 foreach $fic_col (@listcol)
 {
   $icol++;
   $col=$fic_col;
   chop ($col);
print "DBG : traitement fichier [$col]\n";

   $file="$col";
   open (f_col, "<$file");
   @col=<f_col>;
   close (f_col);
   $lien=$col;
   $lien=lc($lien);
   $lien=~s/.col//;

   #---------------------------------------------------------------------------
   # Header de chaque fichier index de fichier collection
   #---------------------------------------------------------------------------
   $out4="$livraison_site/ix4_$lien.htm";
   open (OUT4, ">$out4");
   $canal_ix4j=OUT4;

   &web_begin($canal_ix4j, "Index des collections du fichier [$lien.col]");
   &web_head_meta ("author", "Richardot Gilles");
   &web_head_meta ("description", "Index des collections du fichier [$lien.col]");
   &web_head_meta ("keywords", "collection, edition, editeur, roman, nouvelles, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
   &web_head_css ("screen", "../private.css");
   &web_head_js ("../scripts/header.js");
   &web_head_js ("../scripts/outils.js");
   &web_body ("../");
   &web_menu (0, "", "");
   print $canal_ix4j &tohtml("<font size=1>Index : <a href=\"ix1.htm\">fichiers</a> - ");
   print $canal_ix4j &tohtml("<a href=\"ix2.htm\">collections par fichier</a> - ");
   print $canal_ix4j &tohtml("editeurs &amp; collections [");
   foreach $lettre ('A' ... 'Z', '09')
   {
      print $canal_ix4j &tohtml(" <a href=\"ix3_".$lettre.".htm\">$lettre</a>");
   }
   print $canal_ix4j &tohtml(" ]</font>\n");
   print $canal_ix4j &tohtml("<h1>Index des collections du fichier [$lien.col] - ordre du fichier</h1>");
   print $canal_ix4j "<br />&nbsp; &nbsp; (<a href=\"${lien}.htm\">fichier complet</a>)<br /><br />\n";

   foreach $ligne (@col)
   {
      # Recuperer les sigles de collections
      $lig=$ligne;
      chop ($lig);

      $sigle=substr ($lig, $coll_start, $coll_size);
      $reste=substr ($lig, 10);
      ($intitule, $periode)=split (/þ/,$reste);
      $intitule=~s/ +$//;
      $intitule=~s/&/&amp;/;
      $prem=substr ($lig, 0, 1);

      if ($prem eq "_")
      {
         #
         # Si d‚finition de sigle : afficher le nom
         #
         $lig=~s/^_ //;

         #--- nom du fichier pour la collection
         $sigle=~s/ +$//;
         $a_trier="${intitule}\t${lien}\t${sigle}";
         push (@liste, $a_trier);

#         $lien2=&crpt($sigle);
         $sigle=~s/&/&amp;/;

         print $canal_ix2 &tohtml("<a href=\"${lien}.htm#${sigle}\">$intitule</a> &nbsp; \n");
         print $canal_ix4j &tohtml(" <a href=\"${lien}.htm#${sigle}\">$intitule</a>  (sigle [$sigle])<br />\n");
      }
   }
   print $canal_ix2 "</div> \n";

   #---------------------------------------------------------------------------
   # Fin de chaque fichier index de fichier collection
   #---------------------------------------------------------------------------
   print $canal_ix4j "<hr />\n";
   &web_canal($canal_ix4j);
   &web_end();

   close (OUT4);
}

#---------------------------------------------------------------------------
# Fin fichier index 1
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Fin fichier index 2
#---------------------------------------------------------------------------

#-----------------------------------------------------------------
# Duplication de certaines entrees (collection d'abord)
#-----------------------------------------------------------------
@dupli=();
foreach $record (@liste)
{
   ($intitule, $lien, $sigle) = split(/\t/, $record);

   ($ed, @co) = split (/, /, $intitule);
   $col=join(', ', @co);
   $col=~s/ +$//;

      if (($intitule=~s/Editions de l'//) != undefined) { $intitule = $intitule . " (Editions de l')"; }
      elsif (($intitule=~s/Editions de la//) != undefined) { $intitule = $intitule . " (Editions de la)"; }
      elsif (($intitule=~s/Editions des//) != undefined) { $intitule = $intitule . " (Editions des)"; }
      elsif (($intitule=~s/Editions de//) != undefined) { $intitule = $intitule . " (Editions de)"; }
      elsif (($intitule=~s/Editions du//) != undefined) { $intitule = $intitule . " (Editions du)"; }
      elsif (($intitule=~s/Editions//) != undefined) { $intitule = $intitule . " (Editions)"; }
      elsif (($intitule=~s/Ed\. de l'//) != undefined) { $intitule = $intitule . " (Ed. de l')"; }
      elsif (($intitule=~s/Ed\. de la//) != undefined) { $intitule = $intitule . " (Ed. de la)"; }
      elsif (($intitule=~s/Ed\. des//) != undefined) { $intitule = $intitule . " (Ed. des)"; }
      elsif (($intitule=~s/Ed\. de//) != undefined) { $intitule = $intitule . " (Ed. de)"; }
      elsif (($intitule=~s/Ed\. du//) != undefined) { $intitule = $intitule . " (Ed. du)"; }
      elsif (($intitule=~s/Ed\.//) != undefined) { $intitule = $intitule . " (Ed.)"; }
      elsif (($intitule=~s#<b>in</b>##i) != undefined) { $intitule = $intitule . " (<b>in</b>)"; }
      $intitule=~s/ +$//;
      $intitule=~s/^ +//;

   $record="${intitule}\t${lien}\t${sigle}";
   push (@dupli, $record);

   if ($col ne "")
   {
      $new=$col . " ($ed)";
      $new=~s/Coll\. //;
      $record="${new}\t${lien}\t${sigle}";
      push (@dupli, $record);
#     print "re: $record\n";
   }
}

@liste_tri=sort tri @dupli;

#---------------------------------------------------------------------------
# index par fichier sigle
#---------------------------------------------------------------------------
foreach $toto (@liste_tri)
{
   ($intitule, $lien, $sigle) = split(/\t/, $toto);
   #--- nom du fichier pour la collection
   $sigle=~s/ +$//;
#   $lien2=&crpt($sigle);
   $sigle=~s/&/_/;

   $initiale=uc(substr($intitule, 0, 1));
   $canal_ix3j="CANAL_" . $initiale;
   if (($initiale < 'A') || ($initiale > 'Z'))
   {
      $canal_ix3j="CANAL_09";
   }
   print $canal_ix3j &tohtml("<tr><td>");
   print $canal_ix3j &tohtml("<a href=\"${lien}.htm#${sigle}\">$intitule</a> ");
   print $canal_ix3j &tohtml("(fichier $lien.col - <a href=\"ix4_${lien}.htm\">index</a>)");
   print $canal_ix3j &tohtml("</td></tr>");
}

#---------------------------------------------------------------------------
# Fin fichiers index alphabetique
#---------------------------------------------------------------------------
foreach $let ('A'...'Z', '09')
{
   $canal_ix3j=$canal_alpha{$let};
   print $canal_ix3j &tohtml("</table>");
   print $canal_ix3j "<hr />\n";
   &web_canal($canal_ix3j);
   &web_end();
}

# ??? close (OUT3);

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

   uc($ia) cmp uc($ib);
}

sub crpt
{
   $locsigle =$_[0];
   $loclink = lc(reverse(substr($locsigle,1)). ord(substr($locsigle,0,1)));
   $loclink=~tr/_aeiouy\&\./0123456ep/;
   return $loclink;   
}

# --- fin ---

