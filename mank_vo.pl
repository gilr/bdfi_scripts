#===========================================================================
#
#  1.0    30/10/2007 : Passage à l'extension php
#                      Utilisation de la librairie de fonction web_xxx
#
#---------------------------------------------------------------------------
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
$coll_start = 2;                                $coll_size = 7;
$num_start = 10;                                $num_size = 5;
$typnum_start = 15;
$date_start = 17;                               $date_size = 4;
$mois_start = 22;                               $mois_size = 2;
$mark_start = 31;                               $mark_size = 4;
$isbn_start = 36;                               $isbn_size = 13;

#--- intitule
$genre_start = 3;
$type_start = 11;                               $type_size = 5;
$auttyp_start = $type_start+$type_size+1;
$author_start = $auttyp_start+1;                $author_size = 28;
$title_start = $author_start+$author_size;

$collab_f_pos = $author_start+$author_size-1;
$collab_n_pos = 0;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site = $local_dir . "/site";

my $ref_en_cours = "NOUV_REF";  # NOUV_REF, NUM_MULT, COLLAB, FIN_SUPP
my $in = 0;
my $oldin = 0;
my $old_titre = "";
my $old_cmt = "";
my $canal = 0;
my $NOCYC = 0;

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$but = "VOTITRE";   # TRADUC, VO, VOTITRE, VODATE, FRANCO

sub usage
{
   print STDERR "usage : $0 [-s|-c|-t|-w|-h]\n";
   print STDERR "        Generation de la page xhtml/php manque_sommaire\n";
   print STDERR "Options :\n";
   print STDERR "        -o : (Par d‚faut) traduction : manque titre vo seul \n";
   print STDERR "        -e : Traduction : manque titre et/ou date vo \n";
   print STDERR "        -O : Traduction : manque titre vo au moins \n";
   print STDERR "        -d : Traduction : manque date vo seule \n";
   print STDERR "        -f : Francophone : manque date originale \n";
   print STDERR "        -h : Help\n";
   print STDERR "\n";
   exit;
}

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-h")
   {
      usage;
      exit;
   }
   elsif ($ARGV[$i] eq "-e")
   {
      $but="TRADUC";
   }
   elsif ($ARGV[$i] eq "-O")
   {
      $but="VO";
   }
   elsif ($ARGV[$i] eq "-o")
   {
      $but="VOTITRE";
   }
   elsif ($ARGV[$i] eq "-d")
   {
      $but="VODATE";
   }
   elsif ($ARGV[$i] eq "-f")
   {
      $but="FRANCO";
   }
   $i++;
}

#---------------------------------------------------------------------------
# Lecture d'autres fichiers
# tests d'unicit‚
# choix en fonction du parametre d'entree "param"
# ...
#---------------------------------------------------------------------------

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

# Trucs a memoriser...
my @my_refs=();

# variables locales

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
         printf STDERR " <& xxx> non prcd de <xxx &> :\n";
         printf STDERR "$old\n";
         printf STDERR "$lig\n";
         exit;
      }
      elsif ($flag_collab_suite eq '/')
      {
         # erreur, arret
         printf STDERR "*** Error line $nblig ***\n";
         printf STDERR " </ xxx> non prcd de <xxx /> :\n";
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
         $mois=substr ($lig, $mois_start, $mois_size);
         $mois=~s/ +$//o;
         $mois=~s/^ +//o;
         $mois=~s/xx//o;
         $mois=&convmois($mois);
         $num=substr ($lig, $num_start, $num_size);
         $num=~s/ +$//o;
         $num=~s/^ +//o;
         $typnum=substr ($lig, $typnum_start, 1);
         $isbn="";
         $isbn_type=substr ($lig, $mark_start, $mark_size);
         $isbn=substr ($lig, $isbn_start, $isbn_size);
         if ((substr($isbn, 0, 1) eq '-') || ($isbn_type ne 'ISBN'))
         {
            $isbn_type="NREF";
            $isbn="-";
         }
         if ((substr($isbn, 0, 1) eq '.') || (substr($isbn, -1, 1) eq '.'))
         {
            $isbn="inconnu";
         }
      
         $reference = {
           COLL=>"$coll",
           ISBN_TYPE=>"$isbn_type",
           ISBN=>"$isbn",
           COMPLET=>"",
           DATE=>"$date",
           NB_REED=>0,
           REED=>["","","","","","","","","","","","","","",""],
           MOIS=>"$mois",
           NUM=>"$num",
           TYPNUM=>"$typnum",
           GENRE=>"", G1=>"", G2=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           CYCLE=>{CP=>"", IP=>0, CS=>"", IS=>0},
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
           %SOMMAIRE=>(),
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
#     printf STDERR "Tiens, une couverture !\n";
      next;
   }
   elsif ($prem eq ">")
   {
#     printf STDERR "Oh Oh, une note... !\n";
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
           ISBN_TYPE=>"",
           ISBN=>"",
           COMPLET=>"",
           DATE=>"",
           MOIS=>"",
           NUM=>"",
           TYPNUM=>"",
           GENRE=>"", G1=>"", G2=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           CYCLE=>{CP=>"", IP=>0, CS=>"", IS=>0},
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
           %SOMMAIRE=>(),
         };

         $reference->{COLL} = $in_ref->{COLL};
         $reference->{ISBN_TYPE} = $in_ref->{ISBN_TYPE};
         $reference->{ISBN} = $in_ref->{ISBN};
         $reference->{COMPLET} = $in_ref->{COMPLET};
         $reference->{DATE} = $in_ref->{DATE};
         $reference->{NB_REED} = $in_ref->{NB_REED};
         $reference->{REED} = $in_ref->{REED};
         $reference->{MOIS} = $in_ref->{MOIS};
         $reference->{NUM} = $in_ref->{NUM};
         $reference->{TYPNUM} = $in_ref->{TYPNUM};

         $reference->{IN_TITRE} = $in_ref->{TITRE};
         $reference->{IN_VODATE} = $in_ref->{VODATE};
         $reference->{IN_VOTITRE} = $in_ref->{VOTITRE};
         $reference->{IN_TYPE} = $in_ref->{TYPE};
      }
      # ligne contenu
      $auteur=substr ($lig, $author_start, $author_size-1);
      $auteur=~s/ +$//o;
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      #-----------------------------------------------------
      # si ligne support : creation d'une nouvelle reference
      #-----------------------------------------------------
      $genre=substr ($lig, $genre_start, 1);
      $g1=substr ($lig, $genre_start+1, 1);
      $g2=substr ($lig, $genre_start+2, 1);

      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);
      $complet=((index($type_c, 'x') == -1) ? 'OUI' : 'NON');

      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      $cycle="";
      $titre_seul="";
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

      $reference->{GENRE} = "$genre";
      $reference->{COMPLET} = "$complet";
      $reference->{G1} = "$g1";
      $reference->{G2} = "$g2";
      $reference->{TITRE} = "$titre";
      $reference->{TITRE_SEUL} = "$titre_seul";
      $reference->{TYPE} = "$type_c";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";
      $reference->{CYCLE}->{CP} = $cycle;
      $reference->{CYCLE}->{IP} = $indice_cycle;
      $reference->{CYCLE}->{CS} = "$scycle";
      $reference->{CYCLE}->{IS} = $indice_scycle;

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

      # Un titre vo, mais pas de date
      if (
          ((($but eq "VOTITRE") || ($but eq "TRADUC")) 
              && ($reference->{VOTITRE} eq "?") && ($reference->{VODATE} ne "?"))
       || (($but eq "VO")
              && ($reference->{VOTITRE} eq "?") )
       || ((($but eq "VODATE") || ($but eq "TRADUC"))
              && ($reference->{VOTITRE} ne "") && ($reference->{VOTITRE} ne "?") && ($reference->{VODATE} eq "?"))
       || (($but eq "TRADUC")
              && ($reference->{VOTITRE} eq "?") && ($reference->{VODATE} eq "?"))
       || (($but eq "FRANCO")
              && ($reference->{VOTITRE} eq "") && ($reference->{VODATE} eq "?"))
         )
      {
         push (@my_refs, $reference);
      }
   }
   $old=$lig;
}

# Trier
#--------------------
@tri_refs=sort tri @my_refs;

# Affichage resultats
#---------------------
$outf="${livraison_site}/manque_vo.php";
print STDERR "resultat dans $outf\n";
open (OUTP, ">$outf");
$canal=OUTP;

&web_begin ($canal, "../commun/", "Dates et/ou titres VO manquantes");
&web_head_meta ("author", "Richardot Gilles");
&web_head_meta ("description", "Page d'aide : sommaires manquants");
&web_head_css ("screen", "../styles/bdfi.css");
&web_head_js ("../scripts/outils.js");
&web_body ();
&web_menu (1, "site");
   &web_data ("<div id='menbib'>");
   &web_data ("Vous &ecirc;tes ici : <a href='../..'>BDFI</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Site\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='aide.php'>Aide</a>\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> Manque VO\n");
   &web_data ("</div>\n");
&web_data ("<h1>Donn&eacute;es VO &agrave; compl‚ter</h1>\n\n");

#-------------------------------------------------------------
# Affichage des resultats
#-------------------------------------------------------------
$oldaa="";
print STDERR " qte : $#tri_refs \n";
 if ($but eq "TRADUC") {
   print $canal &tohtml("Nombre d'enregistrements auxquels il manque date ou titre VO : <strong><em>$#tri_refs</em></strong><br />\n");
 }
 elsif ($but eq "VOTITRE") {
   print $canal &tohtml("Nombre d'enregistrements auxquels il manque titre VO : <strong><em>$#tri_refs</em></strong><br />\n");
 }
 elsif ($but eq "VODATE") {
   print $canal &tohtml("Nombre d'enregistrements auxquels il manque date VO : <strong><em>$#tri_refs</em></strong><br />\n");
 }
 elsif ($but eq "FRANCO") {
   print $canal &tohtml("Nombre d'enregistrements (franco) auxquels il manque date 1Šre parution : <strong><em>$#tri_refs</em></strong><br />\n");
 }

   print $canal &tohtml("M‚mo : [Rec Nvl] = Recueil de nouvelles [Rec-Omn] = Recueil ou Omnibus [Novelis] = Novelisation ");
   print $canal &tohtml("[Antho] = Anthologie [Nvlle] = Nouvelle [Novella] = Court roman<br /><br />\n");

if ($#my_refs + 1 > 0)
{
   # pre...

   foreach $item (@tri_refs) { &AFFICHE ($item); }

   # post...
}

&web_end();

# Upload site, dans data
$cwd = "/www/site";
&bdfi_upload($outf, $cwd);

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#---------------------------------------------------------------------------
sub tri
{
   if (uc($a->{AUTEUR}[0]) ne uc($b->{AUTEUR}[0]))
   {
      uc($a->{AUTEUR}[0]) cmp uc($b->{AUTEUR}[0]);
   }
   else
   {
      uc($a->{TITRE}) cmp uc($b->{TITRE});
   }
}

#---------------------------------------------------------------------------
# Subroutine de conversion des mois
#---------------------------------------------------------------------------
@listmois=("janvier", "fevrier", "mars", "avril",
           "mai", "juin", "juillet", "aout",
           "septembre", "octobre", "novembre", "decembre");

sub convmois
{
   my $mois=$_[0];
   if ($mois ne "")
   {
      return $listmois[$mois];
   }
}

sub AFFICHE
{
   local($aa)=$_[0];
   
   if (($aa->{AUTEUR}[0] ne $oldaa->{AUTEUR}[0]) ||
       ($aa->{TITRE} ne $oldaa->{TITRE}) ||
       ($aa->{VOTITRE} ne $oldaa->{VOTITRE}) ||
       ($aa->{VODATE} ne $oldaa->{VODATE}) ||
       ($aa->{TYPE} ne $oldaa->{TYPE}))
   {
      if ($aa->{AUTEUR}[0] ne $oldaa->{AUTEUR}[0])
      {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR}[0]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         print $canal &tohtml("\n<br /><a class=\"auteur\" href=\"../auteurs/$initiale_lien/$lien_auteur.php\">");
         print $canal &tohtml("$aa->{AUTEUR}[0]");
         print $canal "</a> ";
      }
      else
      {
         print $canal &tohtml("<br /><span style=\"visibility:hidden;\">$aa->{AUTEUR}[0]&nbsp;</span>");
      }

   $type_c=$aa->{TYPE};
   $type=substr ($type_c, 0, 1);
   $stype=substr ($type_c, 1, 2);
   $type_c=~s/ +$//;
   $stype=~s/ +$//;

   if    (($type eq 'U') && ($stype ne "")) { $afftype="Fix-Up" }
   elsif (($type eq 'N') && ($stype ne "")) { $afftype="Rec Nvl"; }
   elsif (($type eq 'N') && ($stype eq "")) { $afftype="Nvlle"; }
   elsif (($type eq 'C') && ($stype ne "")) { $afftype="Rec Nvl"; }
   elsif (($type eq 'R') && ($stype ne "")) { $afftype="Rec-Omn"; }
   elsif (($type eq 'R') && ($stype eq "")) { $afftype="Roman"; }
   elsif (($type eq 'F') && ($stype eq "")) { $afftype="Novelis"; }
   elsif (($type eq 'S') && ($stype eq "")) { $afftype="Noveli TV"; }
   elsif (($type eq 'r') && ($stype ne "")) { $afftype="Rec-Omn"; }
   elsif (($type eq 'r') && ($stype eq "")) { $afftype="Novella"; }
   elsif (($type eq 'E') && ($stype eq "")) { $afftype="Essai"; }
   elsif (($type eq 'G') && ($stype eq "")) { $afftype="Guide"; }
   elsif (($type eq 'O') && ($stype eq "")) { $afftype="Scenar"; }
   elsif (($type eq 'J') && ($stype eq "")) { $afftype="Jeu"; }
   elsif (($type eq 'A') && ($stype ne "")) { $afftype="Antho"}
   elsif (($type eq 'P') && ($stype ne "")) { $afftype="Rec Poem"; }
   elsif (($type eq 'P') && ($stype eq "")) { $afftype="Poeme"; }
   elsif (($type eq 'T') && ($stype ne "")) { $afftype="Rec Theat"; }
   elsif (($type eq 'T') && ($stype eq "")) { $afftype="Piece"; }
   elsif (($type eq 'M') && ($stype ne "")) { $afftype="Revue"; }
   elsif (($type eq 'p') && ($stype eq "")) { $afftype="Preface"; }
   elsif (($type eq 'o') && ($stype eq "")) { $afftype="Postface"; }
   elsif (($type eq 'a') && ($stype eq "")) { $afftype="Article"; }
   elsif (($type eq 'h') && ($stype eq "")) { $afftype="Chron"; }
   elsif (($type eq 'b') && ($stype eq "")) { $afftype="Biograf"; }
   elsif (($type eq 'B') && ($stype eq "")) { $afftype="Biblio"; }
   elsif (($type eq 'I') && ($stype eq "")) { $afftype="Interview"; }
   elsif (($type eq 'X') && ($stype eq "")) { $afftype="Extrait"; }
   elsif (($type eq 'a') && ($stype eq "")) { $afftype="Article"; }
   elsif ($type eq '.') { $afftype="?????"; }
   elsif ($stype ne "") { $afftype="Euh..."; }
   else  { $afftype="???"; }

      print $canal &tohtml("[$afftype] ");
      print $canal &tohtml("<span class=\"fr\">$aa->{TITRE}</span> (");
      print $canal &tohtml("<span class=\"vo\">$aa->{VODATE}, ");
      print $canal &tohtml("$aa->{VOTITRE}</span>) ");
   }
   $coll=$aa->{COLL};
   $coll=~s/ +$//;
   if ($aa->{NUM} eq "?")
   {
      print $canal &tohtml("<span class='nota'>[$aa->{DATE}-$coll]</span>");
   }
   else
   {
      print $canal &tohtml("<span class='nota'>[$aa->{DATE}-$coll-$aa->{NUM}]</span>");
   }
   $oldaa=$aa;
}


