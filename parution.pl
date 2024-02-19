#===========================================================================
#
# Script de generation d'une page parution
#
#---------------------------------------------------------------------------
# Historique :
#  0.0  - 03/06/2002 : Creation 
#  0.1  - 14/06/2002 : Am‚liorations, gestion collaborations, nombre collections
#  0.2  - 21/06/2002 : Utilisation du module bdfi.pm
#  0.3  - 01/02/2003 : Ajout du genre
#  0.4  - 04/06/2003 : aff_menu
#  0.5  - ../09/2003 : Nouveau format des fichiers excel de Christian
#                    : !!! UNIQUEMENT DEPUIS SEPTEMBRE 2003
#  0.5b - 04/10/2003 : option -T pour infos compl‚mentaires
#  0.9  - 17/01/2005 : G‚n‚ration par ann‚e (an_00)
#                    : option -D : affichage mois parution
#                    : Utilisation CSS
#  1.0 - 08/12/2007 : Passage à l'extenstion PHP
#
#---------------------------------------------------------------------------
# Utilisation :
#    perl parution.pl <fichier_parution> : g‚n‚ration fichier html,
#                                          livr‚ sur le site local
#
#    perl parution.pl [-s|-c|-t|-w|-h] <fichier_prix>
#                        -s : (par d‚faut) livraison fichier HTML sur arbo site
#                        -C : groupe par collection
#                        -T : informations totales
#                        -d : tri date avant num‚ro
#                        -c : sortie console
#---------------------------------------------------------------------------
#
# A FAIRE :
#
#   collaborations de plus de 2 auteurs
#
#   Option fichier texte windows
#
#===========================================================================
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables de definition du fichier theme
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir;
my $ul_en_cours=0;

$title="";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$sortie="SITE";    # SITE, CONSOLE
$name_file="";
$groupe="EDIT";    # EDIT, COLL
$complete="NON";
$date="NON";
$tri="NUM";   # NUM, DATE

#---------------------------------------------------------------------------
# Help
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "usage : $0 [-h] [-s|-c|-t|-w|-h] <fichier_parution>\n";
   print STDERR "        -h : help \n";
   print STDERR "        -C : groupe par collection\n";
   print STDERR "        -D : afficher mois parution\n";
   print STDERR "        -T : afficher traducteur, date vo, titre vo, isbn...\n";
   print STDERR "        -d : Tri par date avant parution\n";
   print STDERR "        -s : (par d‚faut) livraison fichier PHP/HTML sur arbo site \n";
   print STDERR "        -c : sortie console \n";
   exit;
}

if (($ARGV[0] eq "") || ($ARGV[0] eq "-h"))
{
   usage;
}

$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-s")
   {
      $sortie="SITE";
   }
   elsif ($ARGV[$i] eq "-C")
   {
      $groupe="COLL";
   }
   elsif ($ARGV[$i] eq "-T")
   {
      $complete="OUI";
   }
   elsif ($ARGV[$i] eq "-D")
   {
      $date="OUI";
   }
   elsif ($ARGV[$i] eq "-d")
   {
      $tri="DATE";
   }
   elsif ($ARGV[$i] eq "-c")
   {
      $sortie="CONSOLE";
   }
   else
   {
      $name_file=$ARGV[$i];
   }
   $i++;
}

#---------------------------------------------------------------------------
# Lecture du fichier parution
#---------------------------------------------------------------------------
$name_file=~s/.txt//;
$parution_file = "parutions/" . $name_file . ".txt";
open (f_parution, "<$parution_file");
@parution=<f_parution>;
close (f_parution);

#---------------------------------------------------------------------------
# Determination du device de sortie
#---------------------------------------------------------------------------
if ($sortie eq "CONSOLE")
{
   $canal=STDOUT;
}
else
{
   # remplacer ‚galement les caractŠres accentu‚s
   $outfile=lc($parution_file);
   $outfile=~s/.txt//;

   $outf="${livraison_site}/${outfile}.php";

   open (OUTP, ">$outf");
   print STDERR "resultat dans $outf\n";
   $canal=OUTP;
}

@refs=();

#---------------------------------------------------------------------------
# Traitement du fichier
#---------------------------------------------------------------------------
$no=0;
foreach $ligne (@parution)
{
   $nom="";
   $prenom="";
   $titre="";
   $cycle="";
   $indice_cycle="";
   $votitre="";
   $genre="";
   $rnf="";
   $edit="";
   $coll="";
   $num="";
   $cop="";
   $mp="";
   $ap="";
   $reimp="";
   $traduct="";
   $isbn="";

   ($nom, $prenom, $titre, $cycle, $indice_cycle, $votitre, $genre, $rnf, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn) = split ("	", $ligne);
if ($mp == "9") { $mp = "09"; }
elsif ($mp == "8") { $mp = "08"; }
elsif ($mp == "7") { $mp = "07"; }
elsif ($mp == "6") { $mp = "06"; }
elsif ($mp == "5") { $mp = "05"; }
elsif ($mp == "4") { $mp = "04"; }
elsif ($mp == "3") { $mp = "03"; }
elsif ($mp == "2") { $mp = "02"; }
elsif ($mp == "1") { $mp = "01"; }
elsif (($mp != "10") && ($mp != "11") && ($mp != "12")) { $mp = "xx"; }
   $nom = &noacc($nom);
   $coll=~s/^_$//g;

   # Mettre dans tableau, en regroupant les collaborations

   if (($no >= 1) &&
       ($edit eq $refs[$no-1]->{EDIT}) &&
       ($coll eq $refs[$no-1]->{COLL}) &&
       ($indice_cycle eq $refs[$no-1]->{INDICE}) &&
       ($num eq $refs[$no-1]->{NUM}) &&
       ($titre eq $refs[$no-1]->{TITRE}))
   {
      # Ajouter l'auteur nø 2
      $nba = $refs[$no-1]->{NB_AUTEUR};
      $refs[$no-1]->{NOM}[$nba] = $nom;
      $refs[$no-1]->{PRENOM}[$nba] = $prenom;
      $refs[$no-1]->{NB_AUTEUR} ++;
   }
   else
   {
      $reference = {
         NB_AUTEUR=>1,
         NOM=>["$nom","","","",""],
         PRENOM=>["$prenom","","","",""],
         TITRE=>"$titre",
         TYPE=>"$rnf",
         COP=>"$cop",
         VOTITRE=>"$votitre",
         CYCLE=>"$cycle",
         INDICE=>$indice_cycle,
         EDIT=>"$edit",
         COLL=>"$coll",
         GENRE=>"$genre",
         NUM=>"$num",
         REIMP=>"$reimp",
         NB_COLL_BY_EDIT=>0,
         TRADUCT=>"$traduct",
         ISBN=>"$isbn",
         ANNEE=>"$ap",
         MOIS=>"$mp",
      };
      push (@refs, $reference);
      $no++;
   }
}

#-------------------------------------------------------------
# Trier par editeur, puis par collection, puis par num‚ro, puis par titre
#-------------------------------------------------------------
@liste=sort tri @refs;

#-------------------------------------------------------------
# boucle pour compter le nombre de collection par editeur
#-------------------------------------------------------------
$debut_edit=0;
$old_edit="";
$old_coll="";
$no=0;
foreach $ligne (@liste)
{
   if ($ligne->{EDIT} ne $old_edit)
   {
      # si premiŠre ligne ou nouvel ‚diteur :
      #   m‚mo ligne
      $debut_edit = $no;
      $old_edit = $ligne->{EDIT};
      $old_coll = $ligne->{COLL};
      #   incrementer le nombre de collections pour la ligne m‚moris‚e
      $liste[$debut_edit]->{NB_COLL_BY_EDIT} ++;
   }
   elsif ($ligne->{COLL} ne $old_coll)
   {
      # si mˆme ‚diteur, et collection diff‚rente de la pr‚c‚dente
      #   incrementer le nombre de collections pour la ligne m‚moris‚e
      $liste[$debut_edit]->{NB_COLL_BY_EDIT} ++;
      $old_coll = $ligne->{COLL};
   }
   # next ligne
   $no++;
}

#-------------------------------------------------------------
# g‚n‚ration du titre et du texte a partir du nom du fichier
#-------------------------------------------------------------
@str_month=("janvier", "f‚vrier", "mars", "avril", "mai", "juin",
            "juillet", "aout", "septembre", "octobre", "novembre", "d‚cembre" );

($year, $month) = split ("_", $name_file);
if ($month == 0)
{
   $title="Parutions $year";
   $reduc = "ann&eacute;e " . $year;
}
else
{
   ($sec,$min,$heure,$mjour,$mois,$annee,$sjour,$ajour,$isdst) = localtime(time);
   $mois++;
   $annee+=1900;
   $diff_mois = (12 * ($annee - $year)) + $mois - $month;
   print "diff: $diff_mois\n";
   if ($diff_mois > 0)
   {
      $title="Parutions " . $str_month[$month-1];
   }
   else
   {
      $title="Pr‚visions " . $str_month[$month-1];
   }
   print STDERR "[$month/$year]/[$mois/$annee] $title\n";
   $reduc = $str_month[$month-1] . " " . $year;
}
&header ($title, $reduc);
print $canal &tohtml("\n");

# g‚n‚rer le texte … partir du nom
if ($month == 0)
{
   $texte="Liste des parutions et r‚‚ditions de l'ann‚e $year :";
}
elsif ($diff_mois > 0)
{
   $texte="Liste des parutions et r‚‚ditions du mois de $str_month[$month-1] $year :";
# pas revues, peuvent comporter des erreurs
}
else
{
   $texte="Liste des parutions et r‚‚ditions pr‚vues pour le mois de $str_month[$month-1] $year :";
# sous r‚serve...
}
print $canal &tohtml("$texte\n");
print $canal &tohtml("<br />\n");
print $canal &tohtml("Cliquez sur un nom d'auteur pour atteindre sa bibliographie\n");
print $canal &tohtml(" (le lien est actif lorsqu'elle existe).\n");
if ($month != 0)
{
 print $canal &tohtml(" Les parutions r‚centes et les\n");
 print $canal &tohtml(" pr‚visions ne sont en g‚n‚ral pas encore int‚gr‚es dans les\n");
 print $canal &tohtml(" pages bibliographiques.\n");
}

#-------------------------------------------------------------
# G‚n‚ration de la page HTML
#-------------------------------------------------------------
$no=0;
$olded="XXX";
foreach $ligne (@liste)
{
   if (($no == 0) || (($no >= 1) && ($ligne->{EDIT} ne $liste[$no-1]->{EDIT})) || (($groupe eq 'COLL') && ($no >= 1) && ($ligne->{COLL} ne $liste[$no-1]->{COLL})))
   {
      # afficher nouveau ‚diteur
      #--------------------------
      $editeur=$ligne->{EDIT};
      $nbcoll=$ligne->{NB_COLL_BY_EDIT};
      $coll=$ligne->{COLL};
      if ($sortie eq "SITE")
      {
         print $canal &tohtml("\n");
         if (($coll ne "") && (($nbcoll == 1) || ($groupe eq 'COLL')))
         {
            if ($nbcoll == 1)
            {
               if ($ul_en_cours == 1) { $ul_en_cours = 0; print $canal "</ul>"; }
               print $canal &tohtml("<h2>$editeur : $coll</h2>\n<ul>\n");
               $ul_en_cours = 1;
            }
            elsif ($editeur ne $olded)
            {
               if ($ul_en_cours == 1) { $ul_en_cours = 0; print $canal "</ul>"; }
               print $canal &tohtml("<h2>$editeur</h2>\n");
               print $canal &tohtml("<h3>$coll</h3>\n<ul>\n");
               $ul_en_cours = 1;
            }
            else
            {
               if ($ul_en_cours == 1) { $ul_en_cours = 0; print $canal "</ul>"; }
               print $canal &tohtml("<h3>$coll</h3><ul>\n");
               $ul_en_cours = 1;
            }
         }
         else
         {
            if ($ul_en_cours == 1) { $ul_en_cours = 0; print $canal "</ul>"; }
            print $canal &tohtml("<h2>$editeur</h2>\n");
            if (($coll ne "") && ($groupe eq 'COLL'))
            {
               print $canal &tohtml("<h3>$coll</h3>\n");
            }
            print $canal &tohtml("<ul>\n");
            $ul_en_cours = 1;
         }
         $olded=$editeur;
      }
      else
      {
         print $canal "\n";
         print $canal "--- $editeur : $coll\r----------------------------------------------------\n";
         if (($nbcoll == 1) && ($coll ne ""))
         {
            print $canal "--- $editeur : $coll\n";
         }
         else
         {
            print $canal "--- $editeur\n";
         }
         print $canal "--- $editeur : $coll\r----------------------------------------------------\n";
      }
   }

   # Afficher titre
   # Traitement oeuvre parue/… paraŒtre
   # A FAIRE : g‚rer collaborations de plus de 2 auteurs
   $nom=uc($ligne->{NOM}[0]);
   $prenom=$ligne->{PRENOM}[0];
   $titre=$ligne->{TITRE};
   $cycle=$ligne->{CYCLE};
   $ind=$ligne->{INDICE};
   $coll=$ligne->{COLL};
   $num=$ligne->{NUM};
   $genre=$ligne->{GENRE};
   $reimp=$ligne->{REIMP};
   $traduct=$ligne->{TRADUCT};
   $isbn=$ligne->{ISBN};
   $cop=$ligne->{COP};
   $votitre=$ligne->{VOTITRE};
   $isbn=~s/\n//;
   $mp=$ligne->{MOIS};
   $ap=$ligne->{ANNEE};
   $type=$ligne->{TYPE};
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<li>");
      if (($complete eq 'OUI') || ($date eq 'OUI'))
      {
         print $canal &tohtml("$ap.$mp ");
      }
      $lien = "$nom $prenom";
      $auteur = "$prenom $nom";
      &aff_auteur($lien, $auteur);
      if ($ligne->{NB_AUTEUR} >= 2)
      {
         $nom=uc($ligne->{NOM}[1]);
         $prenom=$ligne->{PRENOM}[1];
         $lien = "$nom $prenom";
         $auteur = "$prenom $nom";
         print $canal &tohtml(" et ");
         &aff_auteur($lien, $auteur);
      }
      print $canal &tohtml(" : <span class=\"fr\">$titre</span>");
      if ($cycle ne "")
      {
         print $canal &tohtml("<span class='cycle'>");
         print $canal &tohtml(" [$cycle");
         if ($ind ne "")
         {
            print $canal &tohtml(" - $ind");
         }
         print $canal "]";
         print $canal &tohtml("</span>");
      }
      elsif ($ind ne "")
      {
         print $canal &tohtml("[$ind]");
      }
      if ($complete eq 'OUI')
      {
         if (($votitre ne '') && ($votitre ne '_'))
         {
            print $canal &tohtml(" <span class=\"vo\">($cop, $votitre)</span> ");
         }
         else
         {
            print $canal &tohtml(" <span class=\"vo\">($cop)</span> ");
         }
      }
      if (($coll ne "") && ($nbcoll > 1))
      {
         print $canal &tohtml(" (coll. $coll");
         if (($num ne "") && ($num ne "?") && ($num ne "_") && ($num ne "0"))
         {
            print $canal &tohtml(" n&deg; $num");
         }
         print $canal &tohtml(")");
      }
      else
      {
         if (($num ne "") && ($num ne "?") && ($num ne "_") && ($num ne "0"))
         {
            print $canal &tohtml(" (n&deg; $num)");
         }
      }
      if (($genre ne "") && ($genre ne "?"))
      {
         print $canal &tohtml(" ($genre)");
      }
      if (lc($type) ne "roman")
      {
         print $canal &tohtml(" <span class=\"cmt\">[$type]</span>");
      }
      if ($reimp eq 'R')
      {
         print $canal &tohtml(" <span class='note'>(r‚‚dition)</span>");
      }
      if ($complete eq 'OUI')
      {
         if (($traduct ne '') && ($traduct ne ' ') && ($traduct ne '_'))
         {
            print $canal &tohtml(" Trad. <span class=\"nom\">$traduct</span>");
         }
         if (($isbn ne '') && ($isbn ne ' '))
         {
            print $canal &tohtml(" ISBN $isbn");
         }
      }
      print $canal "</li>\n";
   }
   else
   {
      print $canal " $nom $prenom : $titre";
      if ($cycle ne "")
      {
         print $canal " [$cycle";
         if ($no ne "")
         {
            print $canal " - $no";
         }
         print $canal "]";
      }
      elsif ($no ne "")
      {
         print $canal "[$no]";
      }
      if ($coll ne "")
      {
         print $canal " (coll. $coll)";
      }
      print $canal "\n";
   }

   $no++;
}

if ($ul_en_cours == 1) { $ul_en_cours = 0; print $canal "</ul>"; }

if ($sortie eq "SITE")
{
   &web_end();
}
else
{
   close (OUTP);
}

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
# A FAIRE : modifier
# Actuel : par editeur, puis collection, puis num‚ro, puis titre
# Faire  : par editeur, puis collection, puis num‚ro, puis mois, puis titre
# Variant: par editeur, puis collection, puis mois, puis num‚ro, puis titre
#---------------------------------------------------------------------------
sub tri
{
   if (uc($a->{EDIT}) ne uc($b->{EDIT}))
   {
      uc($a->{EDIT}) cmp uc($b->{EDIT});
   }
   else
   {
      if (uc($a->{COLL}) ne uc($b->{COLL}))
      {
         uc($a->{COLL}) cmp uc($b->{COLL});
      }
      elsif ($tri eq "NUM")
      {
         if (uc($a->{NUM}) ne uc($b->{NUM}))
         {
            uc($a->{NUM}) <=> uc($b->{NUM});
         }
         else
         {
            if (uc($a->{MOIS}) ne uc($b->{MOIS}))
            {
               uc($a->{MOIS}) <=> uc($b->{MOIS});
            }
            else
            {
               if (uc($a->{TITRE}) ne uc($b->{TITRE}))
               {
                  uc($a->{TITRE}) cmp uc($b->{TITRE});
               }
            }
         }
      }
      elsif ($tri eq "DATE")
      {
         if (uc($a->{MOIS}) ne uc($b->{MOIS}))
         {
            uc($a->{MOIS}) <=> uc($b->{MOIS});
         }
         else
         {
            if (uc($a->{NUM}) ne uc($b->{NUM}))
            {
               uc($a->{NUM}) <=> uc($b->{NUM});
            }
            else
            {
               if (uc($a->{TITRE}) ne uc($b->{TITRE}))
               {
                  uc($a->{TITRE}) cmp uc($b->{TITRE});
               }
            }
         }
      }
   }
}

#---------------------------------------------------------------------------
# Fonction d'affichage de l'entete HTML
#---------------------------------------------------------------------------
sub header {
   $title=$_[0];
   $reduc=$_[1];
   if ($sortie eq "SITE")
   {
      &web_begin($canal, "../commun/", "Parutions : $title");
      &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
      &web_head_meta ("description", "Programme de publication : $title)");
      &web_head_meta ("keywords", "parutions, pr‚visions, programme, publication, programme de publication, imaginaire, SF, sience-fiction, fantastique, fantasy, horreur, $title");
      &web_head_css ("screen", "../styles/bdfi.css");
      &web_head_js ('../scripts/outils.js');
      &web_head_js ('../scripts/images.js');
      &web_body ();
      &web_menu (1, "parutions");

      &web_data ("<div id='menbib'>Vous &ecirc;tes ici : <a href='..'>BDFI</a>\n");
      &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> Base\n");
      &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='.'>Parutions</a>\n");
      &web_data ("<img src='../images/sep.png' alt='--&gt;'/> $reduc</div>\n");

      print $canal &tohtml("<h1>$title</h1>\n");
   }
}


