#
# Script de generation d'une biblio de cycle et s‚rie
#
#---------------------------------------------------------------------------
# Historique :
#
#   0.1  - 03/11/2002 : Creation d'aprŠs biblio.pl
#   0.2  - 26/04/2003 : liste des sous-cycles, et tri par sous-cycle
#   0.3  - 01/05/2003 : tri un peu plus potable, plus titres "alternatifs"
#   0.4  - 29/08/2003 : Prise en compte du nouveau format de la base
#   0.5  - 03/08/2004 : Prise en compte des reeditions
#                       Utilisation du module affiche.pm pour sorties pages
#                       Nettoyage du code HTML genere (CSE HTML Validator Lite)
#                       Legere optimisation de la taille de la page generee
#   0.6  - 21/01/2005 : CSS - XHTML
#   0.7  - 10/06/2005 : Gestion des titres vo dans series.vo
#   0.8  - 09/08/2005 : Mise … jour du design definitif (xhtml)
#   1.0  - 18/10/2007 : utilisation de la librairie web_xxx
#                       Passage a l'extension PHP
#                       Suppression sorties locales CONSOLE, DOS, WINDOWS, HTML
#   1.1  - 15/11/2007 : Affichage des liens sur anthologies et recueils 
#   1.2  - 03/08/2010 : upload automatique par defaut
#   1.3  - 11/11/2010 : Ajout gestion sous-cycles et cycles suppl‚mentaires
#   1.4  - 14/11/2011 : Ajout d'un troisiŠme niveau de cycle
#   1.5  - 16/11/2013 : Am‚lioration entˆte, titre variantes et VO
#                       Ajout des variantes et vo dans les sous-s‚ries
#                       Cr‚ation de subroutines
#   1.6  - 23/05/2014 : Gestion VO et Alt des titres de sous-cycles
#                        (titres sous-cycles identiques de cycles diff‚rents)
#   1.7  - 29/07/2015 : Comparaison auteur avant date VO (pour Star Wars)
#                       Correction tri des sous-cycles
#   1.8  - 04/11/2017 : Homog‚n‚isation avec autres outils bibxyz
#   1.9  - 05/12/2017 : Les textes enchass‚s comme les anthos...
#   2.0  - 10/04/2019 : Gestion des livres-jeux
#   2.1  - 30/06/2019 : Trier les types aprŠs titres fran‡ais (romans et extrait)
#   2.2  - 05/05/2020 : Sortir les sous-cycles de la liste complŠte (qui devient "s‚rie principale")
#                        + correction du tri principal (num‚ro avant sans num‚ro)
#   2.x  - 06/07/2022 : prise en compte des alias de recueil en ligne ((Nom de page))
#   2.y  - 10/04/2022 : Gestion jusqu'… 15 auteurs (pour le 13 chez ‚ditions 1115)
#   2.3  - 06/07/2022 : Corrections nb AUTEURS + tentative de rattrapage des pb de tris...
#   2.4  - 06/07/2022 : Correction finale du pb de tri + ajout du commentaire "court roman"
#   2.5  - 06/07/2022 : Nettoyages commentaires et debug
#
# A voir si mieux … la fa‡on de ISFDB ... 
#
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
# A FAIRE :
#
# - tri 1/2/3 aprŠs 1, 2, 3 ^pour sous-cycles
#
# - lorsque il y a un indice diff‚rent de "1, 2, 3..." ou "I, II, III ..."
#   l'indiquer avant le titre (exemple : " - CinquiŠme jour")
#
# - Ne pas indiquer le num‚ro si d‚j… indiqu‚ ? (r‚‚dition tittre diff‚rent)
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
my $livraison_site=$local_dir . "/series/pages";

my $ref_en_cours="NOUV_REF";
my $in=0;
my $oldin=0;
my $old_titre="";
my $old_cmt="";
my $canal=0;
my $NOCYC=0;
my $upload=1;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$type_tri=0;
$no_coll=0;

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 [-i|-v] <nom_auteur>\n";
   print STDERR "        -i : tri sur indice cycle\n";
   print STDERR "        -v : tri sur date VO\n";
   print STDERR "        -u : pas d'upload du fichier\n";
   print STDERR "\n";
   exit;
}
$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-i")
   {
      $type_tri=0;
   }
   elsif ($ARGV[$i] eq "-v")
   {
      $type_tri=1;
   }
   elsif ($ARGV[$i] eq "-u")
   {
      $upload = 0;
   }
   else
   {
      $choix=&win2dos($ARGV[$i]);
   }
   $i++;
}

#---------------------------------------------------------------------------
# Lecture du fichier series/cycles
#---------------------------------------------------------------------------
my $file="series.res";
open (f_cyc, "<$file");
my @cyc=<f_cyc>;
close (f_cyc);

my $file_cyc_alt="series.alt";
open (f_cyc_alt, "<$file_cyc_alt");
my @cyc_alt=<f_cyc_alt>;
close (f_cyc_alt);

my $file_cyc_vo="series.vo";
open (f_cyc_vo, "<$file_cyc_vo");
my @cyc_vo=<f_cyc_vo>;
close (f_cyc_vo);

#---------------------------------------------------------------------------
# La serie est-elle unique ?
#---------------------------------------------------------------------------
@res=grep (/$choix\$/, @cyc);
$nb=$#res+1;
if ($nb == 0)
{
   @res=grep {/$choix/i} @cyc;
   $nb=$#res+1;
}
if ($nb == 0)
{
   $choix=substr($choix, 0, -1);
   @res=grep {/$choix/i} @cyc;
   $nb=$#res+1;
}
if ($nb == 0)
{
   $choix=substr($choix, 1);
   @res=grep {/$choix/i} @cyc;
   $nb=$#res+1;
}

if ($nb == 0)
{
   print STDOUT "$choix : --> unknown...\n";
   exit;
}
elsif ($nb > 1)
{
   for (@res) { print STDOUT "$_"; }
   print STDOUT "$choix : --> more precision...\n";
   exit;
}

$choix=$res[0];
chop($choix);

#---------------------------------------------------------------------------
# S'il s'agit d'un sous-cycle, retenir le cycle
#---------------------------------------------------------------------------
$memo = "CYCLE : \"$choix\"";
$poscrochet = index ($choix, "\[");
if ($poscrochet >= 0)
{
   $choix = substr($choix, $poscrochet+1);
   $choix=~s/\]$//o;
   $memo .= " --> \"$choix\"";
}
print STDOUT "$memo : OK\n";

#---------------------------------------------------------------------------
# Recherche des titres alternatifs et vo ‚ventuels
#---------------------------------------------------------------------------
(@titre_alt) = &liste_titres_alt($choix);
(@titre_vo) = &liste_titres_vo($choix);

#---------------------------------------------------------------------------
# Lecture du fichier sigles
#---------------------------------------------------------------------------
$file="sigles.res";
open (f_sig, "<$file");
@sigles=<f_sig>;
close (f_sig);

#---------------------------------------------------------------------------
# Lecture du fichier ouvrages
#---------------------------------------------------------------------------
$file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);


@textes_du_cycle=();
@liste_sous_cycles=();

foreach $ligne (@ouv)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   chop ($lig);

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $prem=substr ($lig, 0, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   if (($ref_en_cours eq "NOUV_REF") && ($prem eq 'o'))
   {
      #----------------------------------------------
      # Nouvelle reference support
      #----------------------------------------------
      if ($flag_collab_suite eq '&')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <& xxx> non pr‚c‚d‚ de <xxx &> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($flag_collab_suite eq '/')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " </ xxx> non pr‚c‚d‚ de <xxx /> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($prem ne 'o')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " nouvelle ref et absence 'o' :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      else
      {
         #-----------------------------------------------------
         # si ligne support : creation d'une nouvelle reference
         #-----------------------------------------------------
         $in=0;
         $coll=substr ($lig, $coll_start, $coll_size);
         $date=substr ($lig, $date_start, $date_size);
         $date=~s/ +$//o;
         $date=~s/^ +//o;
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $typnum=substr ($lig, $typnum_start, 1);

         $reference = {
           COLL=>"$coll",
           DATE=>"$date",
           NB_REED=>0,
           REED=>["","","","","","","","","","","","","","",""],
           NUM=>"$num",
           TYPNUM=>"$typnum",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           SSSSC=>"",
           INDICE_SSSSC=>0,
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CYCLE_S2=>"",
           INDICE_S2=>0,
           CYCLE_S3=>"",
           INDICE_S3=>0,
           CYCLE2=>"",
           INDICE2=>0,
           CYCLE3=>"",
           INDICE3=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           CMT_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
         };
      }
   }
   elsif (($prem eq '+') || ($prem eq 'x'))
   {
      $date=substr ($lig, $date_start, $date_size);
      $date=~s/ +$//o;
      $date=~s/^ +//o;

      if ($reference->{NB_REED} < 15)
      {
         $reference->{REED}[$reference->{NB_REED}] = "$date";
         $reference->{NB_REED} = $reference->{NB_REED} + 1;
      }
      else
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " plus de 15 reeditions ?!\n";
         printf STDERR "$lig\n";
         exit;
      }
   }
   elsif ($prem eq '}')
   {
      next;
   }
   elsif ($prem eq ">")
   {
      next;
   }
   elsif ($ref_en_cours eq "NUM_MULT")
   {
      #----------------------------------------------
      # Numero multiple : mise a jour reference
      #----------------------------------------------
      if ($flag_collab_suite eq '/')
      {
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $reference->{NUM} .= "-" . "$num";
      }
      else
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <xxx /> non suivi de </ xxx> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
   }
   elsif ((($ref_en_cours eq "FIN_SUPP") && ($prem eq '-'))
      ||  (($ref_en_cours eq "NOUV_REF") && (($prem eq '=') || ($prem eq ':'))))
   {
      #-----------------------------------------------------
      # ligne "reference" (contenu principal ou inclus)
      #-----------------------------------------------------
      $in=0;
      if (($prem eq '=') || ($prem eq ':'))
      {
         # si texte inclus, nouvelle reference
         $in=1;
         $reference = {
           COLL=>"",
           DATE=>"",
           NUM=>"",
           TYPNUM=>"",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           SSSSC=>"",
           INDICE_SSSSC=>0,
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CYCLE_S2=>"",
           INDICE_S2=>0,
           CYCLE_S3=>"",
           INDICE_S3=>0,
           CYCLE2=>"",
           INDICE2=>0,
           CYCLE3=>"",
           INDICE3=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           CMT_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
         };

         $reference->{COLL} = $in_ref->{COLL};
         $reference->{DATE} = $in_ref->{DATE};
         $reference->{NB_REED} = $in_ref->{NB_REED};
         $reference->{REED} = $in_ref->{REED};
         $reference->{NUM} = $in_ref->{NUM};
         $reference->{TYPNUM} = $in_ref->{TYPNUM};

         $reference->{IN_TITRE} = $in_ref->{TITRE};
         $reference->{IN_VODATE} = $in_ref->{VODATE};
         $reference->{IN_VOTITRE} = $in_ref->{VOTITRE};
         $reference->{IN_TYPE} = $in_ref->{TYPE};
      }
      # ligne contenu
      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      #-----------------------------------------------------
      # si ligne support : creation d'une nouvelle reference
      #-----------------------------------------------------
      $hg=substr ($lig, $genre_start, 1);
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);

      $reference->{GENRE} = "$hg";
      $reference->{TITRE} = "$titre";
      $reference->{TYPE} = "$type";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";

      ($reference->{TITRE_SEUL}, $reference->{ALIAS_RECUEIL},
       $reference->{SSSSC}, $reference->{INDICE_SSSSC},
       $reference->{CYCLE_S}, $reference->{INDICE_S},
       $reference->{CYCLE_S2}, $reference->{INDICE_S2},
       $reference->{CYCLE_S3}, $reference->{INDICE_S3},
       $reference->{CYCLE}, $reference->{INDICE},
       $reference->{CYCLE2}, $reference->{INDICE2},
       $reference->{CYCLE3},
       $reference->{INDICE3}) = decomp_titre ($titre, $nblig, $lig);

      # Recherche des anthologistes (marque '*' devant)
      if (substr ($lig, $auttyp_start, 1) eq '*')
      {
         $reference->{NB_ANTHOLOG} = 1;
         $reference->{ANTHOLOG}[0] = "$auteur";
      }
      else
      {
         $reference->{NB_AUTEUR} = 1;
         $reference->{AUTEUR}[0] = "$auteur";
      }
   }
   elsif ($ref_en_cours eq "COLLAB")
   {
      #---------------------------------------------------
      # Collaboration d'auteurs : mise a jour reference
      #---------------------------------------------------
      $auteur=substr ($lig, $author_start, $author_size-1);
      $auteur=~s/ +$//o;
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      if ($flag_collab_suite ne '&')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " <xxx &> non suivi de <& xxx> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      else
      {
         # test si anthologiste (marque '*' devant)
         $lenaut=length($auteur);
         if (substr ($lig, $auttyp_start, 1) eq '*')
         {
            if ($reference->{NB_ANTHOLOG} < 10)
            {
               $reference->{ANTHOLOG}[$reference->{NB_ANTHOLOG}] = "$auteur";
               $reference->{NB_ANTHOLOG} = $reference->{NB_ANTHOLOG} + 1;
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " Plus de 10 anthologistes ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
         else
         {
            if ($reference->{NB_AUTEUR} < 15)
            {
               $reference->{AUTEUR}[$reference->{NB_AUTEUR}] = "$auteur";
               $reference->{NB_AUTEUR} = $reference->{NB_AUTEUR} + 1;
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " Plus de 15 auteurs ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
      }
   }
   else
   {
      #----------------------------------
      # erreur, arret
      #----------------------------------
      printf STDERR "*** Error line $nblig ***\n";
      printf STDERR " (ref_en_cours, prem) non coherent ($ref_en_cours, '$prem')...\n";
      printf STDERR "$lig\n";
      exit;
   }

   if ($flag_collab_a_suivre eq '&')
   {
      # A suivre...
      $ref_en_cours = "COLLAB";
   }
   elsif ($flag_num_a_suivre eq '/')
   {
      # A suivre...
      $ref_en_cours = "NUM_MULT";
   }
   elsif (($prem eq 'o') || ($prem eq '+') || ($prem eq 'x') || ($prem eq '/') && ($flag_num_a_suivre ne '/'))
   {
      # Fin de support principal (hors indications reeditions)
      #  reference principale (ou indication reeditions) a suivre...
      $ref_en_cours = "FIN_SUPP";
   }
   else
   {
      #-----------------------------------------------------
      # La reference est complete
      #-----------------------------------------------------
      $ref_en_cours = "NOUV_REF";

      # Si reference courante de type ouvrage : memo reference comme "in-ref"
      if ($in == 0)
      {
         $in_ref=$reference;
      }

      # Si la serie/cycle cherch‚e appartient aux cycles
      # ajout au tableau idoine (cycle, sscycle)

      if ((($reference->{CYCLE} eq $choix) ||
           ($reference->{CYCLE2} eq $choix) ||
           ($reference->{CYCLE3} eq $choix)) &&
          ($type ne "a") && ($type ne "d"))
      {
         if (($type eq "N") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Nouvelle]";
         }
         if (($type eq "r") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Court roman]";
         }
         elsif ((($type eq "X") || ($type eq "x")) && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Extrait]";
         }
         elsif ((($type eq "N") || ($type eq "R") || ($type eq "r") || ($type eq "A") || ($type eq "P") || ($type eq "T")) && ($stype ne " "))
         {
            $reference->{CMT_TYPE} = "[Recueil]";
         }
         elsif ($type eq "C")
         {
            $reference->{CMT_TYPE} = "[Textes li‚s ou enchass‚s]";
         }
         elsif ($type eq "U")
         {
            $reference->{CMT_TYPE} = "[Fix-Up]";
         }
         elsif ($type eq "F")
         {
            $reference->{CMT_TYPE} = "[Novelisation]";
         }
         elsif ($type eq "f")
         {
            $reference->{CMT_TYPE} = "[Courte novelisation]";
         }
         elsif (($type eq "E") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Essai]";
         }
         elsif (($type eq "G") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Guide]";
         }
         elsif (($type eq "Z") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Livre-jeu]";
         }
         # 05/12/2017 - En compl‚ment, info [Hors genres]
         if ($hg eq "x")
         {
            $reference->{CMT_TYPE} = $reference->{CMT_TYPE} . "[Hors genres]";
         }
         push (@textes_du_cycle, $reference);

         # Et si CYCLE_S, ajouter les sous_cycles dans la liste a trier
         if ($reference->{CYCLE} eq $choix)
         {
            if ($reference->{CYCLE_S} ne '') {
            push (@liste_sous_cycles, $reference->{CYCLE_S});
            }
            if ($reference->{CYCLE_S2} ne '') {
               push (@liste_sous_cycles, $reference->{CYCLE_S2});
            }
            if ($reference->{CYCLE_S3} ne '') {
               push (@liste_sous_cycles, $reference->{CYCLE_S3});
            }
            if ($reference->{SSSSC} ne '') {
               push (@liste_sous_cycles, $reference->{SSSSC});
            }
         }
      }
   }
   $old=$lig;
}

# Trier le tableaux g‚n‚ral
#---------------------------
@tri_textes_du_cycle = sort tri_liste @textes_du_cycle;

# Faire la liste tri‚e des sous-cycles :
#---------------------------------------
@liste_sous_cycles_triee = &unique(@liste_sous_cycles);

# Affichage resultats
#---------------------

   # nom du lien, et initiale
   $outfile=&url_serie($choix);
   $initiale=substr ($outfile, 0, 1);
   $initiale=lc($initiale);
   $maj=uc($initiale);
   if (($maj ge '0') && ($maj le '9'))
   {
      $maj="0-9";
      $initiale="09";
   }

   $outf="${livraison_site}/$outfile.php";

   print STDERR "--> Resultat dans $outf\n";
   open (OUTP, ">$outf");
   $canal=OUTP;

   &web_begin ($canal, "../../commun/", "$choix");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Bibliographie : $choix");
   &web_head_meta ("keywords", "biblio, bibliographie, roman, nouvelle, auteur, imaginaire, SF, science-fiction, fantasy, merveilleux, fantastique, horreur, $choix");
   &web_head_css ("screen", "../../styles/bdfi.css");
   &web_head_js ("../../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../../scripts/outils_v2.js");
   &web_body ();
   &web_menu (0, "");
   
   &web_data ("<div id='menbib'>");
   &web_data (" [ <a href='javascript:history.back();' onmouseover='window.status=\"Back\";return true;'>Retour</a> ] ");
   &web_data ("Vous &ecirc;tes ici : <a href='../..'>BDFI</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='..'>S&eacute;ries</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Index\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='../$initiale.php'>Initiale $maj</a>\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> $choix\n");
   &web_data ("<br />");
   &web_data ("Cycles, s&eacute;ries et feuilletons de l'imaginaire (SF, fantasy, merveilleux, fantastique, horreur, &eacute;trange) ");
   &web_data (" - <a href='javascript:mail_cycles();'>Ecrire &agrave; BDFI</a> pour compl&eacute;ments &amp; corrections.");
   &web_data ("</div>\n");

   &web_data ("<h1><a name='$outfile'>$choix</a></h1>\n");
   &affiche_titres (1);

if ($#liste_sous_cycles_triee + 1 > 0)
{
   if ($#liste_sous_cycles_triee == 0) {
      &web_data ("\n<dl class='serie'><dt>Contient la s‚rie ou le cycle suivant&nbsp;:</dt>\n");
   }
   if ($#liste_sous_cycles_triee > 0) {
      &web_data ("\n<dl class='serie'><dt>Contient les s‚ries ou cycles suivants&nbsp;:</dt>\n");
   }

   foreach $sc (@liste_sous_cycles_triee)
   {
      $name = &url_name_sous_serie ($sc);
      &web_data ("<dd><a href='#$name'>$sc</a>");

      #--------------------------------------------------
      # Recherche des titres alternatifs et vo ‚ventuels
      #--------------------------------------------------
      (@titre_alt) = &liste_titres_alt($sc, $choix);
      (@titre_vo) = &liste_titres_vo($sc, $choix);

      &affiche_titres (2);
      
      &web_data ("</dd>\n");
   }
   &web_data ("</dl>\n");
}

if ($#tri_textes_du_cycle + 1 > 0)
{
      if ($#liste_sous_cycles_triee + 1 > 0)
      {
	 # S'il existe des sous-cycles
	 # PB : est affich‚ mˆme s'il n'y a pas d'ouvrages dans le cycle principal !
	 #    la liste qui suit sera vide... il faudrait les compter...
         &web_data ("<h2>${choix} - S‚rie principale</h2>\n");
      }
      &web_data ("<dl class='serie'>\n");

   foreach $item (@tri_textes_du_cycle) {
      if ((($item->{CYCLE_S} eq '') &&
          ($item->{CYCLE_S2} eq '') &&
          ($item->{CYCLE_S2} eq '')) ||
          ($item->{INDICE} ne ''))
      {
	 # On n'affiche que si aucun sous-cycle... ET pas d'indice du cycle principal
         &affiche_liste ($item, 0, $choix);
      }
   }
   &web_data ("</dl>\n");

   $old_titre="";
   $old_cmt="";
}

if ($#liste_sous_cycles_triee + 1 > 0)
{
   if ($#tri_textes_du_cycle  + 1 > 0)
   {
      $old_sc="";
      foreach $sc (@liste_sous_cycles_triee)
      {
         $name = &url_name_sous_serie ($sc);
         &web_data ("<h2><a name='$name'>$sc</a></h2>\n");
         #--------------------------------------------------
         # Recherche des titres alternatifs et vo ‚ventuels
         #--------------------------------------------------
         (@titre_alt) = &liste_titres_alt($sc, $choix);
         (@titre_vo) = &liste_titres_vo($sc, $choix);
         &affiche_titres (1);
         &web_data ("<dl class='serie'>\n");
         $old_sc=$sc;

         $tri2_critere = $sc;
	 # Dans l'instruction suivante, trier @tri_textes_du_cycle ne marche pas... Pourquoi ? (devrait ˆtre identique ?!)
         @tri_textes_du_sous_cycle = sort tri_liste_2 @textes_du_cycle;

         foreach $item (@tri_textes_du_sous_cycle )
         {
            if (($item->{CYCLE_S} eq $sc) ||
                ($item->{CYCLE_S2} eq $sc) ||
                ($item->{CYCLE_S3} eq $sc) ||
                ($item->{SSSSC} eq $sc))
            {
               &affiche_liste ($item, 1, $sc);
            }
         }
         &web_data ("</dl>\n");

         $old_titre="";
         $old_cmt="";
      }
   }
}


&web_end();

close (OUTP);

if ($upload == 1)
{
   $cwd = "/www/series/pages";
   &bdfi_upload($outf, $cwd);
}

#---------------------------------------------------------------------------
# Fonction de recherche de titres alternatifs
#---------------------------------------------------------------------------
sub liste_titres_alt {
  local($serie)=$_[0];
  local($seriemere)=$_[1];
  local(@titre_alt)=();

  foreach $ligne (@cyc_alt)
  {
     $titre_cycle=$ligne;
     chop ($titre_cycle);
     ($titre_cycle, $titre_cycle_ref) = split (/\t/, $titre_cycle);
     # print "--- $titre_cycle_ref --- $serie ---\n";
     if (lc($titre_cycle_ref) eq lc($serie))
     {
        push (@titre_alt, $titre_cycle);
     }

     # Specifique pour des sous-titres identiques
     $serieplus = $serie . " [" . $seriemere . "]";
     #  print "--- $titre_cycle --- $serieplus ---\n";
     if (lc($titre_cycle_ref) eq lc($serieplus))
     {
        push (@titre_alt, $titre_cycle);
     }
  }
  return (@titre_alt);
}

#---------------------------------------------------------------------------
# Fonction de recherche de titres VO
#---------------------------------------------------------------------------
sub liste_titres_vo {
  local($serie)=$_[0];
  local($seriemere)=$_[1];
  local(@titre_vo)=();

  foreach $ligne (@cyc_vo)
  {
     $titre_cycle=$ligne;
     chop ($titre_cycle);
     ($titre_cycle, $titre_cycle_vo) = split (/\t/, $titre_cycle);
     #  print "--- $titre_cycle --- $serie ---\n";
     if (lc($titre_cycle) eq lc($serie))
     {
        push (@titre_vo, $titre_cycle_vo);
     }

     # Specifique pour des sous-titres identiques
     $serieplus = $serie . " [" . $seriemere . "]";
     #  print "--- $titre_cycle --- $serieplus ---\n";
     if (lc($titre_cycle) eq lc($serieplus))
     {
        push (@titre_vo, $titre_cycle_vo);
     }
  }
  return (@titre_vo);
}

#---------------------------------------------------------------------------
# Fonction d'affichage des autres formes de titre
#---------------------------------------------------------------------------
sub affiche_titres {
   local($type_aff)=$_[0];
   if ($type_aff == 1) {
      if ($#titre_alt == 0) { &web_data ("<em>Autre forme du titre :</em> "); }
      if ($#titre_alt > 0) { &web_data ("<em>Autres formes du titre :</em> "); }
   }
   else {
      if ($#titre_alt >= 0) { &web_data (" ("); }
   }
   $separ = '';
   foreach $t_alt (@titre_alt)
   {
      &web_data ("$separ$t_alt");
      $separ = ' - ';
   }

   if ($type_aff == 1) {
      if ($#titre_alt >= 0) { &web_data (".<br />"); }
      if ($#titre_vo == 0) { &web_data ("<em>Titre VO :</em> "); }
      if ($#titre_vo > 0) { &web_data ("<em>Titres VO :</em> "); }
   }
   else {
      if ($#titre_alt >= 0) { &web_data (") "); }
      if ($#titre_vo >= 0) { &web_data (" ("); }
   }
   $separ = '';
   foreach $t_vo (@titre_vo)
   {
      &web_data ("$separ$t_vo");
      $separ = ' - ';
   }
   if ($type_aff == 1) {
      if ($#titre_vo >= 0) { &web_data ("."); }
   }
   else {
      if ($#titre_vo >= 0) { &web_data (")"); }
   }
}

#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference
#---------------------------------------------------------------------------
sub affiche_liste {
   # A FAIRE
   # --> afficher les autres sous-cycles (sans lien)
   # --> afficher les cycles (avec lien)
   local($aa)=$_[0];
   local($type)=$_[1];
   local($value_cycle)=$_[2];

   $antho = 0;
   if (($aa->{CMT_TYPE} eq "[Recueil]") || ($aa->{CMT_TYPE} eq "[Textes li‚s ou enchass‚s]")) { $antho = 1; }
   $titre_seul=$aa->{TITRE_SEUL};
   $alias_recueil=$aa->{ALIAS_RECUEIL};
   $cycle=$aa->{CYCLE};
   $scycle=$aa->{CYCLE_S};
   $ssssc=$aa->{SSSSC};

   if ($type == 0) {
      if ($aa->{CYCLE} eq $value_cycle) {
         $ind = $aa->{INDICE};
      }
      elsif ($aa->{CYCLE2} eq $value_cycle) {
         $ind = $aa->{INDICE2};
      }
      elsif ($aa->{CYCLE3} eq $value_cycle) {
         $ind = $aa->{INDICE3};
      }
   }
   else {
      if ($aa->{CYCLE_S} eq $value_cycle) {
         $ind = $aa->{INDICE_S};
      }
      elsif ($aa->{CYCLE_S2} eq $value_cycle) {
         $ind = $aa->{INDICE_S2};
      }
      elsif ($aa->{CYCLE_S3} eq $value_cycle) {
         $ind = $aa->{INDICE_S3};
      }
      elsif ($aa->{SSSSC} eq $value_cycle) {
         $ind = $aa->{INDICE_SSSSC};
      }
   }

   if ((uc($aa->{TITRE}) ne uc($old_titre))
       || ($aa->{CMT_TYPE} ne $old_cmt)
       || ($aa->{VODATE} ne $old_vodate)
       || ($aa->{AUTEUR}[0] ne $old_aut))
   {
         print $canal "<dt>";
         if ($ind != $NOCYC) {
            &web_data ("<b>$ind.</b> ");
         }
         else
         {
            &web_data ("<b>*</b>&nbsp;&nbsp; ");
         }
         # Si anthologie, chercher idrec
         if ($antho == 1) {
            if ($alias_recueil ne "")
            {
               $idrec=idrec($alias_recueil, "", "");
            }
            else
            {
               $idrec=idrec($titre_seul, $cycle, $scycle);
            }
            $url_antho=url_antho($idrec);
            $url_antho="${url_antho}.php";
            &web_data ("<span class='fr'><a class='antho' href='../../recueils/pages/$url_antho'>$titre_seul</a></span> ");
         }
         else {
            &web_data ("<span class='fr'>$titre_seul</span> ");
         }

      $old_titre=$aa->{TITRE};
      $old_cmt=$aa->{CMT_TYPE};
      $old_vodate=$aa->{VODATE};
      $old_aut=$aa->{AUTEUR}[0];

      if ($aa->{VODATE} ne "")
      {
            &web_data ("<span class='vo'>($aa->{VODATE}");
            if ($aa->{VOTITRE} ne "")
            {
               &web_data (", $aa->{VOTITRE}");
            }
            &web_data (")</span>");
      }

      print $canal " ";

      $nb_aut = 0;
      while ($nb_aut < $aa->{NB_AUTEUR})
      {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         # mot intermediaire : "avec " / ", " /  " et "
         if ($nb_aut == 0) { print $canal "de "; }
         elsif ($nb_aut+1 == $aa->{NB_AUTEUR}) { print $canal " et "; }
         else  { print $canal ", "; }

            &web_data ("<a class='auteur' href='../../auteurs/$initiale_lien/$lien_auteur.php'>");
            &web_data ("$aa->{AUTEUR}[$nb_aut]");
            &web_data ("</a>");

         $nb_aut++;
       }

       if (($aa->{NB_AUTEUR} > 0) && ($aa->{NB_ANTHOLOG} > 0))
       { 
          print $canal ", "; 
       }
  
       $nb_aut = 0;
       while ($nb_aut < $aa->{NB_ANTHOLOG})
       {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{ANTHOLOG}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         # mot intermediaire : "avec " / ", " /  " et "
         if (($nb_aut == 0) && ($aa->{NB_ANTHOLOG} > 1)) { print $canal " anthologistes "; }
         elsif ($nb_aut == 0) { print $canal " anthologiste "; }
         elsif ($nb_aut+1 == $aa->{NB_ANTHOLOG}) { print $canal " et "; }
         else  { print $canal ", "; }

         if ($aa->{ANTHOLOG}[$nb_aut] ne "***") {
            &web_data ("<a class='auteur' href='../../auteurs/$initiale_lien/$lien_auteur.php'>");
            &web_data ("$aa->{ANTHOLOG}[$nb_aut]");
            &web_data ("</a>");
         }
         else {
            &web_data ("inconnu");
         }

         $nb_aut++;
      }

      if ($aa->{CMT_TYPE} ne "")
      {
         &web_data (" <span class='cmt'>$aa->{CMT_TYPE}</span>");
      }
      print $canal "</dt>\n";
   }

   if ($no_coll == 0)
   {
      print $canal "<dd>";
      &aff_support($canal, $aa, 1, \@sigles);
      print $canal "</dd>\n";
   }
}

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#---------------------------------------------------------------------------
sub tri_liste
{
   # ----------------------------------------------
   # l'ordre par d‚faut est :
   #  critere 1 = indice dans le cycle (Attention, tri num‚rique !)
   #          2 = date VO
   #          3 = indice avant "non indice"
   #          4 = titre F
   #          5 = auteur (ajout‚ pour romans de mˆme titre par diff‚rents auteurs : Star Wars)
   #          6 = date de parution
   # ----------------------------------------------

   $aci=$NOCYC;
   if ($a->{CYCLE} eq $choix) { $aci = $a->{INDICE}; }
   elsif ($a->{CYCLE2} eq $choix) { $aci = $a->{INDICE2}; }
   elsif ($a->{CYCLE3} eq $choix) { $aci = $a->{INDICE3}; }

   $bci=$NOCYC;
   if ($b->{CYCLE} eq $choix) { $bci = $b->{INDICE}; }
   elsif ($b->{CYCLE2} eq $choix) { $bci = $b->{INDICE2}; }
   elsif ($b->{CYCLE3} eq $choix) { $bci = $b->{INDICE3}; }

      # Une liste d'indice (3/4/5) est aprŠs tout les indices (3, 4, et 5)
      @inda=split('/', $aci);
      @indb=split('/', $bci);
      $ind_a = @inda[$#inda];
      $ind_b = @indb[$#indb];
      if ($#inda > 0) { $ind_a = $ind_a + 0.5; }
      if ($#indb > 0) { $ind_b = $ind_b + 0.5; }

      if (($ind_a != $NOCYC) && ($ind_b != $NOCYC) && ($ind_a != $ind_b))
      {
         # On compare les num‚ros, en prenant les comptes des 0.5 des num‚ros multiples
         return $ind_a <=> $ind_b;
      }
      elsif (($aci != $NOCYC) && ($bci == $NOCYC))
      {
         #--- indice avant "pas d'indice"
         #--- => a avec num‚ro plus petit que b
         return -1;
      }
      elsif (($aci == $NOCYC) && ($bci != $NOCYC))
      {
         #--- indice avant "pas d'indice"
         #--- => a sans num‚ro plus grand que b
         return 1;
      }
      elsif (uc($a->{VODATE}) ne uc($b->{VODATE}))
      {
         #--- ensuite, si les deux n'ont pas d'indices, comparaison des dates VO
         return uc($a->{VODATE}) cmp uc($b->{VODATE});
      }
      else
      {
         # A partir d'ici, il faudrait dans l'id‚al comparer :
         #  - titre puis date si texte ‚tranger
         #  - date puis titre si texte fran‡ais

         if ($a->{TYPE} ne $b->{TYPE})
         {
            $a->{TYPE} cmp $b->{TYPE};
         }
         elsif (uc($a->{TITRE}) ne uc($b->{TITRE}))
         {
            return uc($a->{TITRE}) cmp uc($b->{TITRE});
         }
         else
         {
            if (uc($a->{AUTEUR}[0]) ne uc($b->{AUTEUR}[0]))
            {
               return uc($a->{AUTEUR}[0]) cmp uc($b->{AUTEUR}[0]);
            }
            else
            {
               return uc($a->{DATE}) cmp uc($b->{DATE});
            }
         }
      }
}

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#---------------------------------------------------------------------------
sub tri_liste_2
{
   # ----------------------------------------------
   # l'ordre est : 
   #   premier critere = indice dans le cycle
   #                  (Attention, tri num‚rique !)
   #   deuxieme critere = date VO
   #   troisieme critere = titre F
   #   quatrieme critere = auteur (ajout‚ pour romans de mˆme titre par diff‚rents auteurs : Star Wars)
   #   cinquieme critere = date de parution
   # ----------------------------------------------
   $acsi=$NOCYC;
   if ($a->{CYCLE_S} eq $tri2_critere) { $acsi = $a->{INDICE_S}; }
   elsif ($a->{CYCLE_S2} eq $tri2_critere) { $acsi = $a->{INDICE_S2}; }
   elsif ($a->{CYCLE_S3} eq $tri2_critere) { $acsi = $a->{INDICE_S3}; }

   $bcsi=$NOCYC;
   if ($b->{CYCLE_S} eq $tri2_critere) { $bcsi = $b->{INDICE_S}; }
   elsif ($b->{CYCLE_S2} eq $tri2_critere) { $bcsi = $b->{INDICE_S2}; }
   elsif ($b->{CYCLE_S3} eq $tri2_critere) { $bcsi = $b->{INDICE_S3}; }

   # Une liste d'indice (3/4/5) est aprŠs tout les indices (3, 4, et 5)
   @inda=split('/', $acsi);
   @indb=split('/', $bcsi);
   $ind_a = @inda[$#inda];
   $ind_b = @indb[$#indb];
   if ($#inda > 0) { $ind_a = $ind_a + 0.5; }
   if ($#indb > 0) { $ind_b = $ind_b + 0.5; }
   if (($ind_a != $NOCYC) && ($ind_b != $NOCYC) && ($ind_a != $ind_b))
   {
      return $ind_a <=> $ind_b;
   }
   else
   {
      if (uc($a->{VODATE}) ne uc($b->{VODATE}))
      {
         return uc($a->{VODATE}) cmp uc($b->{VODATE});
      }
      else
      {
         if (uc($a->{TITRE}) ne uc($b->{TITRE}))
         {
            return uc($a->{TITRE}) cmp uc($b->{TITRE});
         }
         else
         {
            if (uc($a->{AUTEUR}[0]) ne uc($b->{AUTEUR}[0]))
            {
               return uc($a->{AUTEUR}[0]) cmp uc($b->{AUTEUR}[0]);
            }
            else
            {
               return uc($a->{DATE}) cmp uc($b->{DATE});
            }
         }
      }
   }
}

#---------------------------------------------------------------------------
# Subroutine de recherche de tous les sous-cycles
#---------------------------------------------------------------------------
sub unique()
{
   $old="";
   @uniq=();
   my @tri = sort @_;
   foreach $ref (@tri)
   {
      $scyc=$ref;
      if ($old ne $scyc)
      {
         push (@uniq, $scyc);
      }
      $old=$scyc;
   }
   return @uniq;
}

# --- fin ---
