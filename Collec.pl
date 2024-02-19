#===========================================================================
#
# Script de generation des pages collections
#
#  ==> Essai de regroupement des traitements "-" et ":" et "="
#    OK !
# A SUPPRIMER ???    
#---------------------------------------------------------------------------
# Historique :
#  v0.1  - 12/01/2001 creation
#  v0.2  - 30/03/2001
#  v0.3  - 13/01/2002 Ajout des balises de lien sur collection
#        - 21/06/2002 Utilisation de bdfi.pm
#  v0.4  - 01/09/2003 Nouveau format de base de donnees
#  v0.5  - 02/09/2003 Generation de fichier par sigle
#  v1.0  - 09/10/2003 Version propre, regroupement des traitements =/:/-
#                     Surlignage flashy pour les donnees inconnues ou non sure 
#                     nø interne BDFI si pas de ISBN
#  v1.5  - xx/03/2006 Mise a jour pour CSS-XHTML et design definitif
#  v1.6  - xx/11/2006 Reintegration de la generation par sigle
#                     Ajout d'un style officiel/debug
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl collec.pl <fichier_col_sans_extension> :
#            generation fichier htm et txt de meme nom, 
#            livres sur le site local
#
#---------------------------------------------------------------------------
#
# A FAIRE
#
# Ajouter couverture, comme bibantho
#
# Verifier tous les sigles de help (surtout premier char) et traiter...
#
# Prevoir les liens vers les auteurs si existe (pas urgent)
#
# Lorsque plusieurs _XXX se suivent, prendre le bon (=> plusieurs fichiers
#  identiques, mais facilite les index)
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
$bib_start=25;                                $bib_size=5;
$mark_start=31;                               $mark_size=4;
$isbn_start=36;                               $isbn_size=13;

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
#my $livraison_site=$local_dir . "/_collec";
my $livraison_site=$local_dir . "/collections";
my $imgrec="http://www.bdfi.info/recueils/";
my $imgrec2="http://www.bdfi.info/couvs/";

my $ref_en_cours=0;
my $in=0;
my $oldin=0;
my $old_titre="";
my $oldcoll='';

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
my $type_tri=0;
my $no_coll=0;

my $type_work="";
my $sortie="SITE";
my $type_style="DEBUG";
my $first_sigle=0;
my $contenu_affiche="NON";
my $last_multi="";
my $crypte="NON";
my $sommaire="NON";
my $couv_annee="OUI";

sub usage
{
   print STDERR "usage : $0 [-k] [-o|-d] [-f] <fichier_col>\n";
   print STDERR "        $0 [-k] [-o|-d] [-s] <sigle_collection>\n";
   exit;
}

if ($ARGV[0] eq "")
{
   usage;
   exit;
}
$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-f")
   {
      $type_work="FICHIER";
   }
   elsif ($ARGV[$i] eq "-s")
   {
      $type_work="SIGLE";
   }
   elsif ($ARGV[$i] eq "-o")
   {
      $type_style ="OFFICIEL";
   }
   elsif ($ARGV[$i] eq "-d")
   {
      $type_style ="DEBUG";
   }
   elsif ($ARGV[$i] eq "-k")
   {
      $crypte="OUI";
   }
   elsif ($ARGV[$i] eq "-c")
   {
      $sortie="CONSOLE";
   }
   elsif ($ARGV[$i] eq "-t")
   {
      $sortie="FICHIER_DOS";
   }
   elsif ($ARGV[$i] eq "-w")
   {
      $sortie="FICHIER_WIN";
   }
   else
   {
      $param=$ARGV[$i];
   }
   $i++;
}

if ($type_work eq "FICHIER")
{
   #---------------------------------------------------------------------------
   # Lecture du fichier de collections
   #---------------------------------------------------------------------------
   $file=$param;
   $file=~s/.col//;
   $file=~s/.COL//;
   $lien=lc($file);
   $file_col=$file;
   $file_col=~s/$/.col/;
   open (f_col, "<$file_col");
   @collec=<f_col>;
   close (f_col);
}
elsif ($type_work eq "SIGLE")
{
   #---------------------------------------------------------------------------
   # Recherche du sigle et de ses associes
   #---------------------------------------------------------------------------
   $sigle=$param;

   # 1. verifier si le sigle existe
   #---------------------------------------------------------------------------
   # Lecture du fichier sigles
   #---------------------------------------------------------------------------
   $file="sigles.res";
   open (f_sig, "<$file");
   @sigles=<f_sig>;
   close (f_sig);
   foreach $lig (@sigles)
   {
      $refsig=$lig;
      chop($refsig);
      $sig=substr ($refsig, 2, 7);
      $sig=~s/ +$//;
      $reste=substr ($refsig, 10);
      ($edc, $periode)=split (/þ/,$reste);
      $edc=~s/ +$//o;
      if ($sigle eq $sig)
      {
         $coll=$edc;
      }
   }
   if ($coll eq "")
   {
      print "Erreur sigle [$sigle] inconnu\n";
      exit;
   }

   # 2. retrouver le bon fichier COL
   #--------------------------------------------
   $chaine = "^_ $sigle";
   $file="listcol.res";
   open (f_listcol, "<$file");
   @listcol=<f_listcol>;
   close (f_listcol);
   my $nb=0;
   foreach $icol (@listcol)
   {
      $col=$icol;
      chop ($col);

      $file="$col";
      open (f_col, "<$file");
      @col=<f_col>;
      close (f_col);
      @res = grep(/$chaine /, @col);
      $nb=$#res+1;
      if ($nb == 0) { next; }
      elsif ($nb == 1) { print "DBG: OK file [$file]\n"; last; }
      else { print "Erreur : plusieurs sigle [$sigle] ($chaine ) dans [$col]\n"; exit; }
   }
   if ($nb != 1)
   {
      print "Erreur : sigle [$sigle] ($chaine) non trouve dans les fichiers col\n";
      exit;
   }

   # 3. chercher la liste de sigles associes
   #-----------------------------------------
   # 4. restreindre le fichier col aux lignes "utiles"
   #---------------------------------------------------
   $en_cours="DEBUT"; # "SIGLES" "SIGLES_CONT" "OK" "FIN"
   foreach $ligne (@col)
   {
      $lig=$ligne;
      chop ($lig);
      $len=length($lig);
      $prem =substr ($lig, 0, 1); 
      $marqueur=substr ($lig, 0, 4); 

      #DBG print "--- $en_cours\n"; 
      if ($marqueur eq '!DEB')
      {
         $sig=substr ($lig, 5, 7);
         $sig=~s/ +$//;

         if ($en_cours eq "DEBUT")
         {
            $en_cours="SIGLES";
            push (@ls, $ligne);

            if ($sig eq $sigle)
            {
               $en_cours="SIGLES_CONT";
            }
         }
         elsif ($en_cours eq "SIGLES")
         {
            push (@ls, $ligne);
            if ($sig eq $sigle)
            {
               $en_cours="SIGLES_CONT";
               push (@collec, $hr);
               push (@collec, @ls);
               $sigle=substr($ls[0], 2, 7);
               $sigle=~s/ +$//;
            }
         }
         elsif ($en_cours eq "SIGLES_CONT")
         {
            push (@collec, $ligne);
         }
         elsif ($en_cours eq "OK")
         {
            $en_cours="FIN";
            last;
         }
      }
      elsif ($marqueur eq '!FIN')
      {
         $sig=substr ($lig, 5, 7);
         $sig=~s/ +$//;

         if ($en_cours eq "OK")
         {
            $en_cours="FIN";
         }
      }
      elsif ($en_cours eq "SIGLES_CONT")
      {
         $en_cours="OK";
         push (@collec, $ligne);
      }
      elsif ($en_cours eq "OK")
      {
         push (@collec, $ligne);
      }
      else
      {
         if (($prem eq '!') && (substr($lig, 0, 7) eq "!------")) { $hr=$ligne; }
         $en_cours="DEBUT";
         @ls=();
      }
   }

   # 5. creer le nom du fichier pour la collection (premier sigle de la liste)
   #---------------------------------------------------------------------------
   if ($crypte eq "OUI")
   {
      $sigle=~s/ +$//;
      $lien=lc(reverse(substr($sigle,1)). ord(substr($sigle,0,1)));
      $lien=~tr/_aeiouy/0123456/;
   }
   else
   {
      $lien=lc($sigle);
   }

   # 6. traitement identique ensuite
   #print "DBG / START\n";
   #foreach $ligne (@collec)
   #{
   #   print $ligne;
   #}
   #print "DBG / END\n";
}
else
{
   # Erreur
   print "Erreur : type_work non defini [$type_work]\n";
   usage;
   exit;
}


#---------------------------------------------------
# Ouverture fichiers de sortie
#---------------------------------------------------
$outh="$livraison_site/$lien.htm";
open (OUTH, ">$outh");
$canalH=OUTH;

#$outt="$livraison_site/${lien}_txt.htm";
#open (OUTT, ">$outt");
#$canalT=OUTT;
print "Sorties sur $outh\n";
#print "Sorties sur $outt\n";

&web_begin($canalH, "Fichier collection");
&web_head_meta ("author", "Richardot Gilles");
&web_head_meta ("description", "Fichier collection");
&web_head_meta ("keywords", "collection, edition, editeur, roman, nouvelles, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
if ($type_style eq "DEBUG")
{
   &web_head_css ("screen", "../private.css");
}
else
{
   &web_head_css ("screen", "../bdfi.css");
}
&web_head_js ("../scripts/header.js");
&web_head_js ("../scripts/outils.js");
&web_body ("../");
&web_menu (0, "", "");
# Inserer les index d'en-tete
$lien=$file;
$lien=lc($lien);
$lien=~s/.col//;
if ($type_style eq "DEBUG")
{
   print $canalH "<font size=1>Index : <a href=\"ix1.htm\">fichiers</a> - ";
   print $canalH &tohtml("<a href=\"ix2.htm\">collections par fichier</a> - ");
   print $canalH &tohtml("editeurs &amp; collections [");
   foreach $lettre ('A' ... 'Z', '09')
   {
      print $canalH &tohtml(" <a href=\"ix3_".$lettre.".htm\"> $lettre</a>");
   }
   print $canalH " ] - <a href=\"ix4_${lien}.htm\">${lien}.col</a></font>";
}

#print $canalT "<html><body>\n";
#print $canalT "<pre>\n";

$dt = localtime;
print $canalH &tohtml("<br /><font size=-2>\n");
print $canalH &tohtml("&lt;DerniŠre modification le : $dt&gt;");
print $canalH &tohtml("</font>\n");

# type ligne courant = debut
#
# Pour chaque ligne du fichier
#
$contenu_en_cours = 0;

$inclus="";
$prefixe="";
$suffixe="";
foreach $ligne (@collec)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   $lig=~s/ +$//;
   chop ($lig);
   $len=length($lig);
   $prem=substr ($lig, 0, 1);

   # Fin d'ouvrage (fin de format table)
   if (($contenu_en_cours == 1) && (($len == 0) || ($prem eq 'o')))
   {
      print $canalH "</table>\n";
      $contenu_en_cours = 0;
   }
   if ($len == 0) { print $canalH "<br />"; next; }

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

#   print $canalT &tohtml("$lig\n");

   # memo du type de ligne

   $debut=substr ($lig, 0, 8);

   if (($prem eq '?') || ($prem eq '¨') || ($prem eq '­') || ($prem eq '*'))
   {
      #-----------------------------------------------------
      # Infos incomplètes, a paraitre ou ou jamais paru
      #-----------------------------------------------------
      if ($prem eq '?')
      {
         $prefixe="<span class='tbc'>? </span>";
         $suffixe=" <span class='tbc'>[A compl‚ter ou confirmer]</span>";
      }
      elsif ($prem eq '¨')
      {
         $prefixe="!!! ";
         $suffixe=" [A paraitre, <span class='tbc'>ou parution … confirmer</span>]";
 
      }
      elsif ($prem eq '­')
      {
         $prefixe="!!! ";
         $suffixe=" [Pr‚vu mais jamais paru]";
      }
      elsif ($prem eq '*')
      {
         $prefixe="<span class='tbc'>? </span>";
         $suffixe=" <span class='tbc'>[Genre a confirmer]</span>";
      }
      # Recuperer le bon format par decalage
      #--------------------------------------
      if ((substr($lig, 2, 1) ne ' ') || ((substr($lig, 1, 1) eq '&') && (substr ($lig, $auttyp_start, 1) ne ' ')))
      {
         # format decalage des deux premiers caracteres seulement
         substr($lig, 0, 1) = substr($lig, 1, 1);
         substr($lig, 1, 1) = substr($lig, 2, 1);
         substr($lig, 2, 1) = ' ';
         $prem=substr ($lig, 0, 1);
      }
      else
      {
         # format decalage ligne complete
         $lig=substr($lig, 1);
         $len=length($lig);
         $prem=substr ($lig, 0, 1);
      }
      # Fin d'ouvrage (fin de format table)
      if (($contenu_en_cours == 1) && (($len == 0) || ($prem eq 'o')))
      {
         print $canalH "</table>\n";
         $contenu_en_cours = 0;
      }
   }

   if ($debut eq "!-------")
   {
      #-----------------------------------------------------
      # Commentaire "ligne"
      #-----------------------------------------------------
      print $canalH "<hr />\n";
   }
#  elsif ($prem eq '}')
#  {
#     next;
#  }
   elsif ($prem eq '!')
   {
      #-----------------------------------------------------
      # Commentaire divers
      #-----------------------------------------------------
      $prefixe="";
      $suffixe="";
      $lig=~s/^!-+ *//;
      $lig=~s#TBC#<span class='tbc'><b>A confirmer</b></span>#;
      $lig=~s#TBD#<span class='tbc'><b>A definir</b></span>#;
      # si commentaire vide (!, - space), ou ligne vide : rien
      if ($lig ne "")
      {
         $lig=~s/þ/___ /g;
         if ($contenu_en_cours == 0)
         {
            print $canalH &tohtml("<span class='ligcmt'>$lig</span><br />\n");
         }
         else
         {
            print $canalH "<tr><td>&nbsp;</td><td colspan='3' valign='top'>\n";
            print $canalH &tohtml("<span class='ligcmt'>$lig</span>");
            print $canalH "</td></tr>\n";
         }
      }
   }
   elsif ($prem eq '_')
   {
      #-----------------------------------------------------
      # Si d‚finition de sigle : afficher le nom
      #-----------------------------------------------------
      $prefixe="";
      $suffixe="";
      $sig=substr ($lig, 2, 7);
      $sig=~s/ +$//o;
      $reste_lig=substr ($lig, 10);
      ($edc, $periode)=split (/þ/,$reste_lig);
      $edc=~s/ +$//o;
      print $canalH &tohtml("<a name=\"$sig\">");
      print $canalH &tohtml(" &nbsp; &nbsp;  <span class='colbook'><b>$sig</b></span> &nbsp; $edc");
      print $canalH &tohtml("</a>");
      if ($periode ne "")
      {
         print $canalH &tohtml(" ($periode)");
      }
      print $canalH "<br />\n";
   }
   elsif ($prem eq 'o')
   {
      #-----------------------------------------------------
      # Ligne reference support
      #-----------------------------------------------------
      $inclus="";
      $in=0;
      $coll=substr ($lig, $coll_start, $coll_size);
      $num=substr ($lig, $num_start, $num_size);
      $num=~s/ +$//o;
      $num=~s/^ +//o;
      $typnum=substr ($lig, $typnum_start, 1);
      if ($num ne '?')
      {
         if ($typnum eq 'q')
         {
            $num = " (n&deg; $num)";
         }
         elsif ($typnum eq 'i')
         {
            $num = " (n&deg; bdfi $num)";
         }
         else
         {
            $num = " n&deg; $num";
         }
      }
      else
      {
         $num = "";
      }
      $date=substr ($lig, $date_start, $date_size);
      $mois=substr ($lig, $mois_start, $mois_size);
      $date=~s/ +$//o;
      $date=~s/^ +//o;
      $jai=substr ($lig, $bib_start, $bib_size);
      $isbn="";
      if (substr ($lig, $mark_start, $mark_size) eq 'BDFI')
      {
         $isbn="BDFI " . substr ($lig, $isbn_start, $isbn_size);
      }
      elsif (substr ($lig, $mark_start, $mark_size) eq 'ISBN')
      {
         $isbn="ISBN " . substr ($lig, $isbn_start, $isbn_size);
      }
      
      if ($flag_num_a_suivre ne '/')
      {
         &SUPPORT ($coll, $num, $mois, $date, $isbn, $jai);
      }
   }
   elsif ($prem eq '/')
   {
      #-----------------------------------------------------
      # Numero multiple
      #-----------------------------------------------------
      $new_num=substr ($lig, $num_start, $num_size);
      $new_num=~s/ +$//o;
      $new_num=~s/^ +//o;
      $num .= "-" . "$new_num";

      if ($flag_num_a_suivre ne '/')
      {
         &SUPPORT ($coll, $num, $mois, $date, $isbn, $jai);
      }
   }
   elsif ($prem eq '}')
   {
# A FAIRE : cliquable pour visu en grand ?
      $couv=substr ($lig, 1, 16);
      $couv=~s/ +$//o;
      $couv=~s/^ +//o;
      $couv=~s/\.jpg$//o;
      $couv=$couv . ".jpg";
      print $canalH "<br /><div style='margin-left: 35px; padding-left:10px; border-left: solid 10px orange; height:204px;'>";
      print $canalH "<img style='height:200px; padding:1px; border:1px solid black;' src=\"${imgrec}v_$couv\"></img>";
      print $canalH "<img style='padding:1px; border:1px solid black;' src=\"${imgrec2}v_$couv\"></img>";
      print $canalH "</div><br />\n";
      next;
   }
   elsif (($prem eq '+') || ($prem eq 'x'))
   {
      #-----------------------------------------------------
      # Reedition
      #-----------------------------------------------------
      $date=substr ($lig, $date_start, $date_size);
      $mois=substr ($lig, $mois_start, $mois_size);
      $date=~s/ +$//o;
      $date=~s/^ +//o;
      $jai=substr ($lig, $bib_start, $bib_size);
      # SRU : voir si numero different possible
      #       a priori oui (non indique puis indique par exemple)
      $isbn="";
      if (substr ($lig, $mark_start, $mark_size) eq 'BDFI')
      {
         $isbn="BDFI " . substr ($lig, $isbn_start, $isbn_size);
      }
      elsif (substr ($lig, $mark_start, $mark_size) eq 'ISBN')
      {
         $isbn="ISBN " . substr ($lig, $isbn_start, $isbn_size);
      }
      &SUPPORT ("&nbsp;Reed.&nbsp;&nbsp;", " ", $mois, $date, $isbn, $jai);
   }
   elsif (($prem eq '-') || ($prem ne ':') || ($prem ne '=') || ($prem ne ')') || ($prem ne '&'))
   {
      #-----------------------------------------------------
      # Contenu ou sous-contenu, collaboration ...
      #-----------------------------------------------------
      $auttyp=substr ($lig, $auttyp_start, 1);

      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      $auteur=~s/ /&nbsp;/;
      $type_aut="";
      if (($auttyp eq '*') && ($auteur ne '***'))
      {
         $type_aut=" (Anthol.)";
         $coord="et";
      }
      if ($auttyp eq 't')
      {
         $coord="Trad.";
      }
      else
      {
         $coord="et";
      }

      $genre=substr ($lig, $genre_start, 1);
      $g1=substr ($lig, $genre_start+1, 1);
      $g2=substr ($lig, $genre_start+2, 1);
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 2);
      $type_c=~s/ +$//;
      $stype=~s/ +$//;

      $cycle="";
      $titre_seul="";
      ($cycle, $indice_cycle)=split (/ \- /,$cycle);
      # suppression des doubles [[ et ]]
      #----------------------------------
      $titre =~s/\[\[/\[/go;
      $titre =~s/\]\]/\]/go;
      # separation titre / serie
      #--------------------------
      ($titre_seul, $scycle, $cycle)=split (/\[/,$titre);
      $titre_seul=~s/ +$//o;
      if ($scycle ne "")
      {
         $scycle=~s/\]//o;
         if ($cycle ne "")
         {
            $cycle=~s/\]//o;
         }
         else
         {
            $cycle=$scycle;
            $scycle="";
         }
      }
      ($cycle, $indice_cycle)=split (/ \- /,$cycle);
      ($scycle, $indice_scycle)=split (/ \- /,$scycle);
      if ($indice_cycle eq '') { $indice_cycle = $NOCYC; }
      if ($indice_scycle eq '') { $indice_scycle = $NOCYC; }


      $len=length($titre)+length($vodate)+length($votitre)+5;
      if ($len > 90)
      {
#        print STDOUT "longueur totale : $len\n";
      }
      
      $stype=~s#x#<span class='tbc'><b>&nbsp;x </b></span>#;
      if    (($type eq 'U') && ($stype ne "")) { $afftype="FixUp". "$stype"; $last_multi="Fix-Up"; }
      elsif (($type eq 'N') && ($stype ne "")) { $afftype="Recueil ". "$stype"; $last_multi="Recueil de nouvelles"; }
      elsif (($type eq 'N') && ($stype eq "")) { $afftype="Nouvelle"; }
      elsif (($type eq 'C') && ($stype ne "")) { $afftype="Chroniques ". "$stype"; $last_multi="Chroniques"; }
      elsif (($type eq 'R') && ($stype ne "")) { $afftype=$type_c; $last_multi="Ouvrage, recueil ou omnibus"; }
      elsif (($type eq 'R') && ($stype eq "")) { $afftype="Roman"; }
      elsif (($type eq 'X') && ($stype eq "")) { $afftype="Extrait"; }
      elsif (($type eq 'F') && ($stype eq "")) { $afftype="Novelisation"; }
      elsif (($type eq 'r') && ($stype ne "")) { $afftype=$type_c; $last_multi="Recueil de novella"; }
      elsif (($type eq 'r') && ($stype eq "")) { $afftype="Novella"; }
      elsif (($type eq 'E') && ($stype eq "")) { $afftype="Essai"; }
      elsif (($type eq 'J') && ($stype eq "")) { $afftype="Jeu"; }
      elsif (($type eq 'A') && ($stype ne "")) { $afftype="Anthologie ". "$stype"; $last_multi="Anthologie"; }
      elsif (($type eq 'P') && ($stype ne "")) { $afftype=$type_c; $last_multi="Recueil de poˆmes"; }
      elsif (($type eq 'P') && ($stype eq "")) { $afftype="Poeme"; }
      elsif (($type eq 'T') && ($stype ne "")) { $afftype=$type_c; $last_multi="Recueil de piŠces de th‚atre"; }
      elsif (($type eq 'T') && ($stype eq "")) { $afftype="Piece"; }
      elsif (($type eq 'M') && ($stype ne "")) { $afftype="Revue ". $stype; $last_multi="Revue"; }
      elsif (($type eq 'p') && ($stype eq "")) { $afftype="Pr‚face"; }
      elsif (($type eq 'o') && ($stype eq "")) { $afftype="Postface"; }
      elsif (($type eq 'a') && ($stype eq "")) { $afftype="Article"; }
      elsif (($type eq 'h') && ($stype eq "")) { $afftype="Chronique"; }
      elsif (($type eq 'b') && ($stype eq "")) { $afftype="Biographie"; }
      elsif (($type eq 'B') && ($stype eq "")) { $afftype="Bibliographie"; }
      elsif (($type eq 'I') && ($stype eq "")) { $afftype="Interview"; }
      elsif (($type eq '.') || ($type eq ".")) { $afftype="?"; }
      elsif ($stype eq "") { $afftype=$type_c; }
      elsif ($stype ne "") { $afftype=$type_c; $last_multi="Euh..."; }

      if ($prem eq '&')
      {
         print $canalH "<tr><td>&nbsp;</td><td align='center'>\n";
         print $canalH &tohtml("$coord\n");
         print $canalH "</td><td valign='top'>\n";
         if (($auteur eq "?") || ($auteur eq "?"))
         {
            print $canalH &tohtml("<span class='auteur'><span class='tbc'><b>&nbsp;Auteur(s) ?&nbsp;</b></span></span>\n");
         }
         else
         {
            print $canalH &tohtml("<span class='auteur'>&nbsp;$auteur</span>");
         }
         print $canalH &tohtml("$type_aut&nbsp;&nbsp;&nbsp;");
         print $canalH "</td></tr>\n";
      }
      elsif (($SOMMAIRE eq "OUI") || ($prem ne ':'))
      {
         if ($prem eq '-')
         {
            if ($contenu_en_cours == 0)
            {
               $contenu_en_cours = 1;
               print $canalH "<table class='collec'>\n";
            }
            # Si - : intitule ouvrage
         }

         $prefixe=$prefixe . "&nbsp;";
         $suffixe=$suffixe . "";

         if ($genre eq "?")
         {
            $prefixe="?";
            $suffixe=" [Genre a confirmer]";
         }
         elsif ($genre eq "x")
         {
            $suffixe=" [Hors genres]";
         }
         elsif ($genre eq "p")
         {
            $suffixe=" [Partiellement hors genres]";
         }

         if    ($g1 eq 'A') { $suffixe = $suffixe . " [Aventure]"; }
         if    ($g1 eq 'B') { $suffixe = $suffixe . " [Thriller]"; }
         elsif ($g1 eq 'C') { $suffixe = $suffixe . " [Chevalerie]"; }
         elsif ($g1 eq 'D') { $suffixe = $suffixe . " [Guerre]"; }
         elsif ($g1 eq 'E') { $suffixe = $suffixe . " [Espionnage]"; }
         elsif ($g1 eq 'F') { $suffixe = $suffixe . " [Fantastique]"; }
         elsif ($g1 eq 'G') { $suffixe = $suffixe . " [Gore]"; }
         elsif ($g1 eq 'H') { $suffixe = $suffixe . " [Historique]"; }
         elsif ($g1 eq 'I') { $suffixe = $suffixe . " [SF-F-F]"; }
         elsif ($g1 eq 'J') { $suffixe = $suffixe . " [Humour]"; }
         elsif ($g1 eq 'K') { $suffixe = $suffixe . " [Insolite-Etrange]"; }
         elsif ($g1 eq 'L') { $suffixe = $suffixe . " [Mainstream]"; }
         elsif ($g1 eq 'M') { $suffixe = $suffixe . " [Merveilleux, Conte de f‚e]"; }
         elsif ($g1 eq 'N') { $suffixe = $suffixe . " [Conte et l‚gendes]"; }
         elsif ($g1 eq 'O') { $suffixe = $suffixe . " [Mythologie, l‚gendes]"; }
         elsif ($g1 eq 'P') { $suffixe = $suffixe . " [Policier]"; }
         elsif ($g1 eq 'Q') { $suffixe = $suffixe . " [Erotique]"; }
         elsif ($g1 eq 'R') { $suffixe = $suffixe . " [Romance]"; }
         elsif ($g1 eq 'S') { $suffixe = $suffixe . " [SF]"; }
         elsif ($g1 eq 'T') { $suffixe = $suffixe . " [Terreur]"; }
         elsif ($g1 eq 'U') { $suffixe = $suffixe . " [Fusion]"; }
         elsif ($g1 eq 'V') { $suffixe = $suffixe . " [R‚alisme magique]"; }
         elsif ($g1 eq 'W') { $suffixe = $suffixe . " [Western]"; }
         elsif ($g1 eq 'X') { $suffixe = $suffixe . " [Porno]"; }
         elsif ($g1 eq 'Y') { $suffixe = $suffixe . " [fantasy]"; }
         elsif ($g1 eq 'Z') { $suffixe = $suffixe . " [Pr‚historic Fiction]"; }
         elsif ($g1 eq '-') { $suffixe = $suffixe . " [Texte]"; }
         elsif (($g1 eq '?')
             || ($g1 eq '.')
             || ($g1 eq ' ')) {
            $suffixe = $suffixe . " <span class='tbc'>[Genre(s) ?]</span>";
         }
         else               { $suffixe = $suffixe . " <font color=YELLOW>[genre (" . $g1 . ") inconnnu !]</font>"; }

         if (($g2 ne " ") && ($g2 ne "."))
         {
            if ($g2 eq 'A')    { $suffixe = $suffixe . " [Aventure]"; }
# B
            elsif ($g2 eq 'C') { $suffixe = $suffixe . " [Chevalerie]"; }
# D
            elsif ($g2 eq 'E') { $suffixe = $suffixe . " [Erotique]"; }
            elsif ($g2 eq 'F') { $suffixe = $suffixe . " [Fantastique]"; }
# G
            elsif ($g2 eq 'H') { $suffixe = $suffixe . " [Historique]"; }
            elsif ($g2 eq 'I') { $suffixe = $suffixe . " [SF-F-F]"; }
# J
            elsif ($g2 eq 'K') { $suffixe = $suffixe . " [Insolite-Etrange]"; }
            elsif ($g2 eq 'L') { $suffixe = $suffixe . " [Mainstream]"; }
            elsif ($g2 eq 'M') { $suffixe = $suffixe . " [Merveilleux, Conte de f‚e]"; }
# N
# O
            elsif ($g2 eq 'P') { $suffixe = $suffixe . " [Policier]"; }
# Q
            elsif ($g2 eq 'R') { $suffixe = $suffixe . " [Humour]"; }
            elsif ($g2 eq 'S') { $suffixe = $suffixe . " [SF]"; }
            elsif ($g2 eq 'T') { $suffixe = $suffixe . " [Terreur]"; }
            elsif ($g2 eq 'U') { $suffixe = $suffixe . " [Fusion]"; }
# V
            elsif ($g2 eq 'W') { $suffixe = $suffixe . " [Western]"; }
# X
            elsif ($g2 eq 'Y') { $suffixe = $suffixe . " [fantasy]"; }
# Z
            else               { $suffixe = $suffixe . " [genre (" . $g2 . ") inconnnu !]"; }
         }

         if (($prem ne '-') && ($contenu_affiche eq "NON") && ($last_multi ne ""))
         {
            if ($sommaire eq "OUI") {
               print $canalH "<tr><td>&nbsp;</td><td colspan=3 valign='top'>\n";
               if ($inclus eq "")
               {
                  print $canalH &tohtml("  &nbsp; &nbsp; <font color=#303030>$last_multi contenant :</font>\n");
               }
               else
               {
                  print $canalH &tohtml("  &nbsp; &nbsp; <font color=#303030>$last_multi inclus contenant :</font>\n");
               }
            }
            else
            {
               print $canalH "<tr><td colspan=3 valign='top'>\n";
               print $canalH &tohtml ("<i>lien sommaire</i>\n");
            }
            print $canalH "</td></tr>\n";
            $contenu_affiche="OUI";
            $last_multi="";

            if ($inclus eq "") { $inclus="o&nbsp;"; }
            elsif ($inclus eq "o&nbsp;") { $inclus="&nbsp;&nbsp;oo&nbsp;"; }
            else { print "ERROR  : [$inclus] ($lig) \n"; }
         }
         if (((($prem ne '-') && ($contenu_affiche eq "NON") && ($last_multi eq "")) || ($prem eq '=')) && ($sommaire eq "OUI"))
         {
            if ($inclus eq "&nbsp;&nbsp;oo&nbsp;") { $inclus="o&nbsp;"; }
            elsif ($inclus ne "o&nbsp;")
            {
               # erreur peut-etre, sauf si nouvelle avec roman, ou article avec texte ...
               print "WARNING : inclus [$inclus] prem [$prem] last_multi [$last_multi]\n";
               print "          contenu_affiche [$contenu_affiche] ($lig)\n";
               print $canalH "<tr><td>&nbsp;</td><td colspan=3 valign='top'>\n";
               print $canalH &tohtml("  &nbsp; &nbsp; <font color=#303030>Ouvrage contenant aussi:</font>\n");
               print $canalH "</td></tr>\n";
               $contenu_affiche="OUI";
              $last_multi="";
            }
         }
         if ($prem eq '-')
         {
            $contenu_affiche="NON";
         }
         print $canalH "<tr><td valign='top'>\n";
         if ($prefixe ne "") {
            print $canalH &tohtml("<b>$prefixe</b>");
         }
         if ($prem eq '-')
         {
            print $canalH "</td><td valign='top' class='typebook'>\n";
         }
         else
         {
            print $canalH "</td><td valign='top' class='typein'>\n";
            if ($puce ne "") {
               print $canalH &tohtml("<span class='puce'>$inclus</span>");
            }
         }
# if (($sommaire eq "OUI") || ($prem ne ':')) {
         if ($afftype eq '?')
         {
            print $canalH &tohtml("<span class='coltype'>&nbsp;<span class='tbc'><b>&nbsp;Type ?&nbsp;</b></span>&nbsp;</span>");
         }
         else
         {
            print $canalH &tohtml("<span class='coltype'>[$afftype] </span>");
         }
         print $canalH "</td><td valign='top'>\n";
         if (($auteur eq "?") || ($auteur eq "?"))
         {
            print $canalH &tohtml("<span class='auteur'><span class='tbc'><b>&nbsp;Auteur(s) ?&nbsp;</b></span></span>\n");
         }
         else
         {
            print $canalH &tohtml("<span class='auteur'>&nbsp;$auteur</span>");
         }
         print $canalH &tohtml("$type_aut&nbsp;&nbsp;&nbsp;");
         print $canalH "</td><td valign='top'>\n";
         if (($titre_seul eq "?") || ($titre_seul eq "?"))
         {
            print $canalH &tohtml("<span class='fr'> <span class='tbc'><b>&nbsp;Titre ?&nbsp;</b></span> \n");
         }
         else
         {
            print $canalH &tohtml("<span class='fr'> $titre_seul \n");
         }

         if ($cycle ne "")
         {
            # nom du lien sur le cycle
            $lien_serie=&url_serie($cycle);
            print $canalH &tohtml("[<A class=\"cycle\" href=\"../series/$lien_serie.htm\">");
            if ($titre_seul ne $cycle) {
               print $canalH &tohtml("$cycle");
            }
            else {
               print $canalH &tohtml("*");
            }
            print $canalH &tohtml("</A>");
            if ($indice_cycle ne "")
            {
               print $canalH &tohtml(" - $indice_cycle");
            }
            print $canalH &tohtml("]\n");
         }
         if ($scycle ne "")
         {
            # Pas de lien pour l'instant
            # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
            print $canalH &tohtml("[$scycle");
            if ($indice_scycle ne "")
            {
               print $canalH &tohtml(" - $indice_scycle");
            }
            print $canalH &tohtml("]\n");
         }
         print $canalH &tohtml("</span>\n");
         if ($len > 90)
         {
            print $canalH &tohtml("<br />");
         }
         if ($vodate eq '?')
         {
            print $canalH &tohtml(" <span class='vo'>(<span class='tbc'><b>&nbsp;$vodate&nbsp;</b></span>");
         }
         else
         {
            print $canalH &tohtml(" <span class='vo'>($vodate");
         }
         if ($votitre eq '?')
         {
            print $canalH &tohtml(", <span class='tbc'><b>&nbsp;$votitre&nbsp;</b></span>)</span>");
         }
         elsif ($votitre ne "")
         {
            print $canalH &tohtml(", $votitre)</span>");
         }
         else
         {
            print $canalH &tohtml(")</span>");
         }
         if ($trad eq 'Trad. ?')
         {
            print $canalH &tohtml(" <span class='tbc'><b>$trad</b></span> ");
         }
         elsif ($trad ne "")
         {
            print $canalH &tohtml(" $trad ");
         }
         if ($suffixe ne "") {
             print $canalH &tohtml("$suffixe");
         }
         print $canalH "</td></tr>\n";
         if ($prem eq "=")
         {
            $contenu_affiche="NON";
         }
         $prefixe="";
         $suffixe="";
      }

      $prefixe="";
      $suffixe="";
#     print $canalH &tohtml("<br />\n");
   }
   else
   {
      print $canalH &tohtml("inconnu _[$prem]_ : $lig\n");
   }
}

# Fin d'ouvrage (fin de format table)
if ($contenu_en_cours == 1)
{
   print $canalH "</table>\n";
   $contenu_en_cours = 0;
}

print $canalH "<hr />\n";
&web_end ("../");

#print $canalT "</pre>\n";
#print $canalT "</body></html>\n";

close (OUTH);
close (OUTT);

#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference de support
#---------------------------------------------------------------------------
sub SUPPORT {
   local($sigle)=$_[0];
   local($num)=$_[1];
   local($mois)=$_[2];
   local($date)=$_[3];
   local($isbn)=$_[4];
   local($jai)=$_[5];

   $sigle=~s/ +$//o;
   if ($prefixe ne "")
   {
      print $canalH &tohtml("<b>$prefixe</b>");
   }
   if ($type_style eq "DEBUG")
   {
      print $canalH &tohtml("<span class='colbook'><b>&nbsp;$sigle$num </b></span>\n");
   }
   else
   {
      print $canalH &tohtml("<span class='colbook'><b>&nbsp;$num </b></span>\n");
   }

   print $canalH &tohtml("<font color=black><b>&nbsp;");
   if (($mois eq 'xx') || ($mois eq '?'))
   {
      print $canalH &tohtml("&nbsp; <span class='tbc'>$mois</span>.");
   }
   else
   {
      print $canalH &tohtml("&nbsp; $mois.");
   }
   if (($date eq 'xxxx') || ($date eq '?') || ($date eq '????') || (substr($date, -1, 1) eq '?') || (substr($date, -1, 1) eq '.'))
   {
      print $canalH &tohtml("<span class='tbc'>$date</span>");
   }
   else
   {
      print $canalH &tohtml("$date");
   }
   print $canalH &tohtml("</b></font>\n");
   if (substr($isbn, 0, 4) eq 'BDFI')
   {
      print $canalH &tohtml("&nbsp; <font color=black>N&deg; $isbn</font>\n");
   }
   elsif ((substr($isbn, 0, 4) eq 'ISBN') &&
       ((substr($isbn, 5, 1) ne '.') && (substr($isbn, -1, 1) ne '.')))
   {
      print $canalH &tohtml("&nbsp; <font color=black>N&deg; $isbn</font>\n");
   }
   elsif ($isbn ne "")
   {
      print $canalH &tohtml("&nbsp; <font color=black>N&deg; <span class='tbc'><b>$isbn</b></span></font>\n");
   }
   if (($jai ne ".....") && ($jai ne "") && ($type_style eq "DEBUG"))
   {
      print $canalH &tohtml("<font color=black> (biblio: <b>");
      if ((substr($jai,0,1) eq 'R') || (substr($jai,0,1) eq 'G'))
      {
         print $canalH &tohtml("GR");
      }
      if ((substr($jai,1,1) eq 'C') || (substr($jai,1,1) eq 'M'))
      {
         print $canalH &tohtml("M");
      }
      if (substr($jai,2,1) eq 'H')
      {
         print $canalH &tohtml("H");
      }
      if (substr($jai,3,1) eq 'L')
      {
         print $canalH &tohtml("L");
      }
      if (substr($jai,4,1) eq 'P')
      {
         print $canalH &tohtml("P");
      }
      print $canalH &tohtml("</b>)</font>\n");
   }

   if ($suffixe ne "") {
      print $canalH &tohtml("$suffixe<br />\n");
   }
   $prefixe='';
   $suffixe='';
}


# --- fin ---


