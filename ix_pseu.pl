#===========================================================================
# Script 
#---------------------------------------------------------------------------
# Historique :
# date : 15/10/2003
#
#   0.1  - 15/10/2003 : Creation
#   0.2  - 17/08/2005 : CSS et XHTML 1.0 strict - Design d‚finitif
#   0.5  - 09/12/2014 : Refresh g‚n‚ral pour r‚utilisation temporaire
#
#---------------------------------------------------------------------------
# Utilisation :
#  creation des tables-index d'auteurs à signatures multiples
# 
#---------------------------------------------------------------------------
#
# A FAIRE
#
#  pour les liens (name #), remplacer les ' ' par des _
#
#
#    lien sur biblio dans les deux dernières colonnes :
#      NOM Auteur (biblio)
#        ^          ^
#        |          |
#        |          +-- lien biblio
#        |          
#        +--- lien interne pseudo
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "auteurs.pm";
require "affiche.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/pseudos";


#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$type='INITIALE';
$lettre="";
$i=0;

sub usage {
   print STDERR "usage : $0 -u|-t|-all|<initiale>\n";
   print STDERR "        Genere un fichier html des pseudos pour l'initiale fournie\n";
   print STDERR "        Options : \n";
   print STDERR "        -all : toutes les initiales\n";
   print STDERR "        -u : fichier(s) unique au format html (index.htm)\n";
   print STDERR "        -t : fichier texte (pseudo.res)\n";
}

if ($ARGV[0] eq "")
{
   &usage;
   exit;
}

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-u")
   {
      $type="UNIQUE";
   }
   elsif ($ARGV[$i] eq "-t")
   {
      $type="TEXTE";
   }
   elsif ($ARGV[$i] eq "-c")
   {
      $type='CONSOLE';
   }
   elsif ($ARGV[$i] eq "-all")
   {
      $type='ALL';
   }
   else
   {
      $lettre=lc($ARGV[$i]);
      if (($lettre lt 'a') || ($lettre gt 'z'))
      {
         &usage;
         exit;
      }
   }
   $i++;
}

print "--- OK type [$type] lettre [$lettre]\n";

my $can="CANAL";
if ($type eq "TEXTE")
{
   $out = "pseudo.res";
   open ($can, ">$out");
}
elsif ($type eq "CONSOLE")
{
   $can=STDOUT;
   $type="TEXTE";
}
elsif ($type eq "UNIQUE")
{
   $out = "$livraison_site/index.htm";
   open ($can, ">$out");
}
elsif ($type eq "INITIALE")
{
   $out = "$livraison_site/$lettre.htm";
   $can = $can . $lettre;
   open ($can, ">$out");
}
elsif ($type eq "ALL")
{
   @tabcanal=();
   $alphab[1]="a";
   $i=1;
   while ($i <= 26)
   {
      if ($i >= 2) { $alphab[$i] = $alphab[$i-1]; $alphab[$i]++; }
      $tabcanal[$i] = "CANAL" . $alphab[$i];
      $out="$livraison_site/$alphab[$i].htm";
      open ($tabcanal[$i], ">$out");
      print STDERR "--- alphab [$alphab[$i]] lien [$out] canal [$tabcanal[$i]]\n";
      $i++;
   } 
   print "--- Ouverture canaux de A a [$tabcanal[$i-1]]\n";
}
else 
{
   &usage;
   exit;
}

#---------------------------------------------------------------------------
# Ouverture du fichier auteurs.txt (export MS-DOS txt de excel)
#---------------------------------------------------------------------------
#$file="c:/auteurs.txt";
$file="auteurs.txt";
open (f_bio, "<$file");
@bio=<f_bio>;
close (f_bio);

# $ibio=0;
# $maxbio=$#bio;

if ($type eq "UNIQUE")
{
   &web_begin($can, "../commun/", "Pseudonymes et signatures multiples");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Index des auteurs a pseudonyme");
   &web_head_meta ("keywords", "pseudonymes, pseudo, signatures, collaborations, auteur, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
   &web_head_css ("screen", "../styles/bdfi.css");
   &web_head_js ("../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../scripts/outils_v2.js");
   &web_body ();
   &web_menu (0, "", "");

   print $can "<table class=\"index\" border=0>\n";
   print $can &tohtml("<tr bgcolor=ORANGE align=CENTER><td>NOM (lien sur biblio)</td><td>Pseudonyme de</td><td>Se r‚f‚rer …</td><td>Autres signatures</td></tr>\n");
}
elsif ($type eq "INITIALE")
{
   &entete($can);
}
elsif ($type eq "ALL")
{
   $i=1;
   print "--- ecriture des entete dans [$tabcanal[$i]] a";
   while ($i <= 26)
   {
      &entete($tabcanal[$i]);
      print STDERR " [$tabcanal[$i-1]]\n";
      $i++;
   }
}

my $nb=0;
foreach $lig (@bio)
{
   @lv=();
   @lp=();
#  ($key,       $nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,             $bio)=split (/\t/,$lig);
   my ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
   my $key=$key1 . " " . $key2;
   $key=~s/ +$//o;
   $auteur=$key;
   if (($type eq "INITIALE") || ($type eq "ALL"))
   {
      $initiale=lc(substr($key, 0, 1));
      next if (($type eq 'INITIALE') && ($initiale ne $lettre));
      $can="CANAL" . $initiale;
   }
   @liste_vrais=&find_vrais($auteur);
   @liste_pseudos=&find_pseudos($auteur);
   if (($pseu eq 'P') || ($#liste_vrais >= 0) || ($#liste_pseudos >= 0))
   {
      $nb += 1;
      if ($type ne "TEXTE")
      {
         ($ok, $url) = &exist_auteur ("../auteurs", $key);
         $aut_url=$key;
         if ($ok == 1) { $aut_url = "<a class=\"auteur\" href=\"$url\">$key</a>"; }
         if ($nb % 2 == 0) { print $can &tohtml("<tr bgcolor=#FFD080><td valign=TOP><a name=\"$key\">$aut_url<br>&nbsp;[<i>$nom</i>]</a></td>"); }
         else              { print $can &tohtml("<tr bgcolor=#D0D0D0><td valign=TOP><a name=\"$key\">$aut_url<br>&nbsp;[<i>$nom</i>]</a></td>"); }
      }
      if ($pseu eq 'P')
      {
            if ($type ne "TEXTE")
            {
               if (($vrai eq '?') || ($vrai eq '??')) { $vrai="<i>(inconnu)</i>"; }
               print $can &tohtml("<td valign=TOP>$vrai</td>");
            }
            else {
               if (($vrai eq '?') || ($vrai eq '??')) { $vrai="(inconnu)"; }
               print $can "$key	Vrai: $vrai	";
            }
      }
      else
      {
            if ($type ne 'TEXTE') { print $can "<td>&nbsp;</td>"; }
            else { print $can "$key	-	"; }
      }

      if ($#liste_vrais >= 0)
      {
            foreach $aaa (@liste_vrais)
            {
               ($mkey1,$mkey2,@reste)=split (/\t/,$aaa);
               my $mkey=$mkey1 . " " . $mkey2;
               $mkey=~s/ +$//o;
               if ($type eq "UNIQUE")
               {
                  $mkey="<a class=\"pseudo\" href=\"#$mkey\">$mkey</\a>";
               }
               elsif (($type eq "INITIALE") || ($type eq "ALL"))
               {
                  $initiale_lien=lc(substr($mkey, 0, 1));
                  $mkey="<a class=\"pseudo\" href=\"$initiale_lien.htm#$mkey\">$mkey</\a>";
               }
               push (@lv, $mkey);
            }
            if ($type ne "TEXTE") { $resu=join('<br> ', @lv); print $can &tohtml("<td valign=TOP>$resu</td>"); }
            else                  { $resu=join(' + ', @lv); print $can "Voir: $resu	"; }
      }
      else
      {
            if ($type ne "TEXTE") { print $can "<td>&nbsp;</td>"; }
            else                  { print $can "-	"; }
      }

      if ($#liste_pseudos >= 0)
      {
            foreach $aaa (@liste_pseudos)
            {
               ($mkey1,$mkey2,@reste)=split (/\t/,$aaa);
               my $mkey=$mkey1 . " " . $mkey2;
               $mkey=~s/ +$//o;
               if ($type eq 'UNIQUE')
               {
                  $mkey="<a class=\"pseudo\" href=\"#$mkey\">$mkey</\a>";
               }
               elsif (($type eq "INITIALE") || ($type eq "ALL"))
               {
                  $initiale_lien=lc(substr($mkey, 0, 1));
                  $mkey="<a class=\"pseudo\" href=\"$initiale_lien.htm#$mkey\">$mkey</\a>";
               }
               push (@lp, $mkey);
            }
            if ($type ne "TEXTE") { $resu=join('<br> ', @lp); print $can &tohtml("<td valign=TOP>$resu</td></tr>\n"); }
            else                  { $resu=join(', ', @lp); print $can "Autres: {$resu}\n"; }
      }
      else
      {
            if ($type ne "TEXTE") { print $can "<td>&nbsp;</td></tr>\n"; }
            else                  { print $can "-\n"; }
      }
   }
}

if ($type eq "UNIQUE")
{
   &web_end();
   close ($can);
}
elsif ($type eq "INITIALE")
{
   &tail ($can);
   close ($can);
}
elsif ($type eq "ALL")
{
   $i=1;
   print STDERR "--- ecriture des fins et fermeture de [$tabcanal[$i]] a";
   while ($i <= 26)
   {
      &tail ($tabcanal[$i]);
      close ($tabcanal[$i]);
      $i++;
   }
   print STDERR " [$tabcanal[$i-1]]\n";
}

exit;

#---------------------------------------------------------------------------
# 
#---------------------------------------------------------------------------
sub grep_with
{
   $chaine=$_[0];
   my @ok=();

   @res=grep (/$chaine/, @bio);
   foreach $lig (@res)
   {
#     my ($key,       $nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,             $bio)=split (/\t/,$lig);
      my ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key=$key1 . " " . $key2;
      $key=~s/ +$//o;
      if ($key =~ /$chaine/)
      {
#        print STDERR "=== [$key] $nom ($pseu : $vrai) cf. [$ref]\n";
         push (@ok, $key);
      }
   }
   return @ok;
}

#---------------------------------------------------------------------------
# Fonction retournant la reference exacte complete (et unique) d'une clef
#---------------------------------------------------------------------------
sub find_exact
{
   $chaine=$_[0];
   my $ok="";
   my @tmp=();

   # print STDERR "DBG find_exact ($chaine)\n";
   @res=();
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key=$key1 . " " . $key2;
      $key=~s/ +$//o;
      if ($key eq $chaine)
      {
         push (@res, $lig);
      }
   }
   if ($#res > 0)
   {
      print STDERR "2 refs id pour [^$chaine]\n";
      exit;
   }
   elsif ($#res != 0)
   {
      print STDERR "non trouve [^$chaine]\n";
      exit;
   }

   $ok=$res[0];
   $ok=~s/ +$//o;
   
   return $ok;
}

#---------------------------------------------------------------------------
# Fonction retournant la reference correspondant au nom fourni
#---------------------------------------------------------------------------
sub find_vrais
{
   $chaine=$_[0];
   my @ok=();
   my @ml=();
   my @ml2=();

   # print STDERR "DBG find_vrais ($chaine)\n";
   foreach $lig (@bio)
   {
      if (substr($lig, 0, 2) eq "--") {next; }
#     my ($key,       $nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,             $bio)=split (/\t/,$lig);
      my ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key=$key1 . " " . $key2;
      $key=~s/ +$//o;
      if ($key eq $chaine)
      {
         push (@ml, $lig);
      }
   }
   # la liste ne doit contenir qu'un seul enregistrement
   if ($#ml > 0)
   {
      print STDERR "Erreur, double entrée [$chaine]\n";
      exit;
   }
   elsif ($#ml == 0)
   {
#     ($key,       $nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,             $bio)=split (/\t/,$ml[0]);
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key=$key1 . " " . $key2;
      $key=~s/ +$//o;
      #     print STDERR " (DBG) [$key] $nom ($pseu: $vrai) cf. [$ref]\n";
      # si auteurs multiples, decomposer
      my @allref = split(/ \+ /, $ref);
      #     print STDERR " (DBG) $#allref\n";
      # Recherche pour tous les auteurs connus
      foreach $tagada (@allref)
      {
         if ($tagada ne '?')
         {
            @ok=&find_exact("$tagada");
            push (@ml2, @ok);
         }
      }
   }
   return @ml2;
}

#---------------------------------------------------------------------------
# Fonction retournant la liste des pseudos de l'auteur fourni
#---------------------------------------------------------------------------
sub find_pseudos
{
   $chaine=$_[0];
   my @ml=();

   # print STDERR "DBG find_pseudos ($chaine)\n";
   foreach $lig (@bio)
   {
#     my ($key,       $nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,             $bio)=split (/\t/,$lig);
      my ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key=$key1 . " " . $key2;
      $key=~s/ +$//o;
      # SRU : marche pas
      my @allref = split(/ \+ /, $ref);
      foreach $tagada (@allref)
      {
         if ($chaine eq $tagada)
         {
           push (@ml, $lig);
         }
      }
   }
   return @ml;
}


sub entete
{
   my $canalH = $_[0];
   $upchoix=uc(substr($canalH, 5, 1));

   &web_begin($canalH, "../commun/", "Pseudonymes et signatures multiples : $upchoix");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Index des auteurs a pseudonyme ($upchoix)");
   &web_head_meta ("keywords", "pseudonymes, pseudo, signatures, collaborations, auteur, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur");
   &web_head_css ("screen", "../styles/bdfi.css");
   &web_head_js ("../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../scripts/outils_v2.js");
   &web_head_js ("../scripts/menu_pseu.js");
#   &web_body ("../commun/");
   &web_body ();
   &web_menu (1, "aff_menu_pseudos", "");

   print $canalH &tohtml("<td valign=TOP>\n");
   print $canalH &tohtml("BDFI - Domaines de l'imaginaire (SF, fantastique, fantasy, horreur...)\n");
   print $canalH &tohtml("\n");
   print $canalH &tohtml("<div align=CENTER>\n");

   print $canalH "<div align=CENTER>\n";
   print $canalH &tohtml("<h1>Pseudonymes,\n");
   print $canalH &tohtml("signatures multiples, collaborations et couples</h1>\n");

   my $alpha='A';
   my $i=1;
   while ($i <= 26)
   {
      $min=lc($alpha);
      if ($alpha eq $upchoix)
      {
         print $canalH " $alpha";
      }
      else
      {
         print $canalH " <a href=\"$min.htm\">$alpha</a>";
      }
      $i++;
      $alpha++;
   }
   print $canalH "</div>\n";
   print $canalH "<br>\n";

   print $canalH "<table class=\"index\" border=0 width=\"95%\" align=CENTER>\n";
   print $canalH &tohtml("<tr bgcolor=ORANGE align=CENTER><td>NOM (lien sur biblio)</td><td>Pseudonyme de</td><td>Se r‚f‚rer …</td><td>Autres signatures</td></tr>\n");
}

sub tail
{
   my $canalH = $_[0];
   print $canalH "</table>\n\n";
   print $canalH "<div align=CENTER>\n";
   print $canalH "<br>\n";
   my $alpha='A';
   my $i=1;
   while ($i <= 26)
   {
      $min=lc($alpha);
      if ($alpha eq $upchoix)
      {
         print $canalH " $alpha";
      }
      else
      {
         print $canalH " <a href=\"$min.htm\">$alpha</a>";
      }
      $i++;
      $alpha++;
   }
   &web_end("../commun/");
}

