#===========================================================================
#
# Script de generation d'une biblio auteurs
#
#---------------------------------------------------------------------------
# Historique :
#
# Version du moteur :
#  0.0   - 30/04/2000 : Creation 
#  0.1   - 10/05/2000 : Ajout critere de tri -d/-o (date VO/titre VO)
#  0.2   - 12/05/2000 : ?
#  0.9   - 14/12/2000 : Gestion des entr‚e (nom auteur) avec accent
#  1.0   - 26/12/2000 : Ajout fond, date de g‚n‚ration, modifs options
#                      : DerniŠre version avant le d‚but de la fusion
#  1.1   - 15/01/2001 : Ajout <title>
#  1.2   - 15/03/2001 : Ajout des tags meta et des liens collaborateurs
#                     : Ajout des liens accueil, biblio, page-initiale
#                     : Tri num‚rique pour les nos de cycle (option -v)
#                     : Ajout du paragraphe "anthologistes de..."
#  1.2.b - 29/03/2001 : Ajout du cartouche de liens
#  1.3   - 05/08/2001 : Ajout des titres de recueils
#                     : Cas des sorties console/texte des collaborations (a terminer)
#                     : Ajout novelisations restantes (S,V, verifier autres ?)
#                     : Gestion enfin complete des collaborations
#                     : Gestion du format texte windows
#  1.4   - 13/11/2001 : Nouveau look          
#  1.5   - 09/01/2002 : Option pour infos, et liens autres noms
#  1.6   - 03/06/2002 : Ajout utilisation de bdfi.css
#  1.6.b - 21/06/2002 : Amelioration : utilisation du module <bdfi.pm>
#  1.6.c - 15/07/2002 : Correction bugs : romans hors genre, anthologiste en premier
#  1.6.d - 16/07/2002 : Usage : par defaut, -s (site) et -v (tri date VO)
#  1.6.e - 18/07/2002 : Modification cartouche d'en-tˆte
#  1.6.f - 26/07/2002 : Date et titre VO en NAVY au lieu de GREEN, fond NAVY au lieu de BLUE
#  1.7   - 22/08/2002 : Ajout des extraits de romans (cmt [Extrait])
#                     : Ajout du commentaire [Partiel] pour recueils
#                        (sigle + A GENERALISER : A FAIRE)
#                     : Ajout du commentaire [Court roman] pour les Novella
#  1.8   - ../06/2002 : Ajout des bios (par defaut, option -B pour supprimer)
#  1.8.b - 15/02/2003 : Amelioration : "derniŠre mise … jour" --> "derniŠre modification le"
#  1.8.c - 16/05/2003 : Amelioration : ajout "avertissement" + mail --> BDFI
#  1.9   - 30/05/2003 : gestion num‚ros doubles, triples ou plus ("/")
#  2.0   - 13/08/2003 : Utilisation du fichier URL (auteurs.pm)
#  2.1   - 29/08/2003 : prise en compte du nouveau format de la base
#  2.2   - 01/09/2003 : Liens sur pages cycles/series
#  2.2.b - 03/10/2003 : Simplification lien avertissement et mail
#  2.2.c - 22/01/2004 : Pas de s‚rie si [ en d‚but de titre
#  2.3   - 04/08/2004 : Prise en compte des reeditions
#                     : Utilisation du module affiche.pm pour edition page
#                     : Optimisation de la taille de la page generee
#                     : Nettoyage du code genere (CSE HTML Validator Lite)
#  2.4   - 21/01/2005 : CSS - XHTLM
#  2.5   - 11/08/2005 : Mise a jour du design definitif (xhtml)
#  2.6   - 18/10/2007 : utilisation de la librairie web_xxx
#                       Passage a l'extension PHP
#                       Suppression autres sorties locales (DOS, WINDOWS, HTML) 
#  2.7   - 15/11/2007 : Affichage des liens sur anthologies et recueils                     
#  2.7   - 15/12/2007 : Remplacement NICOT St‚phane par NICOT S.
#  2.8   - 23/03/2009 : Format auteurs.txt (d‚coupage NOM Pr‚nom et ajout URL)
#  2.9   - 23/09/2009 : Nouvelle arbo (pgm dans c:\util)
#  3.0   - 03/08/2010 : Upload automatique par defaut
#  3.1   - 08/10/2010 : Ajout des liens sur anthos de poesie
#  3.2   - 11/11/2010 : Ajout gestion sous-cycles et cycles suppl‚mentaires
#          14/06/2011 : piŠce de th‚ƒtre (au lieu de th‚atre)
#  3.3   - 14/10/2011 : Ajout d'un troisiŠme niveau de cycle
#  3.3   - 14/10/2011 : Ajout d'un troisiŠme niveau de cycle
#  3.4   - 13/10/2012 : Bio g‚n‚r‚e dans fichier externe
#  3.5   - 05/02/2013 : Prise en compte des extraits de nouvelle et des chansons
#  3.6   - 25/05/2015 : Prise en compte des hors genres "non r‚f‚renc‚s" (visible en recueils)
#  3.7   - 27/04/2016 : Adaptations extraits (t au lieu de Y) et prise en compte des collectes
#  3.8   - 02/07/2016 : Suppression g‚n‚ration des bios
#  3.9   - 17/10/2018 : Prise en compte des genres inconnus non r‚f‚renc‚s (mais visibles en recueils)
#  4.0   - 10/04/2019 : Prise en compte des livres-jeux (LDVELH)
#  4.1   - 30/06/2019 : Trier les types aprŠs titres fran‡ais (romans et extrait) + contr“le titre VO pour chaque entr‚e (puce)
#  4.2   - 11/09/2019 : Afficher le lien sur la page pour les Fix-Up (aux textes reconnaissables : Ux)
#  4.3   - 08/04/2020 : Correction : les essais avec "*" doivent ˆtre affich‚s dans le bloc "essais" et non "Anthologies"
#  4.4   - 18/04/2020 : Les extraits sont maintenant tous affich‚s dans le bloc "nouvelles"
#  4.5   - 22/12/2020 : Prise en compte des alias de recueil en ligne ((Nom de page))
#  4.6   - 04/12/2021 : Ajout des "genre … d‚terminer" sur les pages auteurs
#  4.7   - 10/04/2022 : Gestion jusqu'… 15 auteurs (pour le 13 chez ‚ditions 1115)
#
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
# A FAIRE :
#
#  0/ Utiliser la librairie de generation page
#
#  1/ am‚liorier les "liens vers autre nom ou pseudonyme"
#
#  3/ ajouter les articles et autres textes "autour" de la SF
#       (titres = Essais, articles, guides, ...)
#    --> uniquement par le script de recherche dynamique
#
#  3/ Essayer de gerer les prix, soit (ou les deux) :
#        - liste des prix en tete, dans la bio
#        - lien sur prix pour chaque oeuvre prim‚e
#
#  3/ Prevoir de pouvoir ajouter les traducteurs (option supplementaire)
#
#  4/ Ajout des vrais auteurs des pseudos multiples
#    --> voir comment...
#
#  4/ Option biblios avec oeuvres sous pseudo inclues
#    --> augmenter la priorit‚ !!
#    --> Pb des collaborations (couples)
#
#  5/ Options pour ajout postface, preface, et autres textes "limites"
#    --> uniquement par le script de recherche dynamique
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
my $livraison_site=$local_dir . "/auteurs";

my $ref_en_cours="NOUV_REF";  # NOUV_REF, NUM_MULT, COLLAB, FIN_SUPP
my $in=0;
my $oldin=0;
my $old_titre="";
my $old_cmt="";
$canal=0;
$canalb=0;


#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$type_tri=1;
$no_coll=0;
$avec_bio=1;
$avec_prix=0;
$avec_cycles=0;
$sortie="SITE";
$upload=1;

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 [-s|-c][-v|-d|-o|-f][-r][-B][+P] <nom_auteur>\n";
   print STDERR "        -s : (par d‚faut) livraison fichier xhtml/php sur arbo site \n";
   print STDERR "        -c : sortie console \n";
   print STDERR "\n";
   print STDERR "        -u : pas d'upload du fichier\n";
   print STDERR "\n";
   print STDERR "        -v : tri sur date VO\n";
   print STDERR "        -d : tri sur date\n";
   print STDERR "        -o : tri sur titre VO\n";
   print STDERR "        -f : tri sur titre fran‡ais\n";
   print STDERR "\n";
   print STDERR "        -r : rapide (sans collection)\n";
   print STDERR "        -B : biblio sans bio\n";
#  print STDERR "        +P : biblio avec prix\n";

   exit;
}
my $i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-s")
   {
      $sortie="SITE";
   }
   elsif ($ARGV[$i] eq "-c")
   {
      $sortie="CONSOLE";
   }
   elsif ($ARGV[$i] eq "-v")
   {
      $type_tri=1;
   }
   elsif ($ARGV[$i] eq "-o")
   {
      $type_tri=2;
   }
   elsif ($ARGV[$i] eq "-d")
   {
      $type_tri=3;
   }
   elsif ($ARGV[$i] eq "-f")
   {
      $type_tri=0;
   }
   elsif ($ARGV[$i] eq "-u")
   {
      $upload = 0;
   }
   elsif ($ARGV[$i] eq "-r")
   {
      $no_coll=1;
   }
   elsif ($ARGV[$i] eq "-B")
   {
      $avec_bio=0;
   }
   elsif ($ARGV[$i] eq "+P")
   {
      print STDERR " (+P) Non impl‚ment‚...\n";
      exit;
   }
   else
   {
      $choix=&win2dos($ARGV[$i]);
   }
   $i++;
}

#---------------------------------------------------------------------------
# Lecture du fichier auteurs
#---------------------------------------------------------------------------
$file="auteurs.res";
open (f_aut, "<$file");
@aut=<f_aut>;
close (f_aut);

#---------------------------------------------------------------------------
# L'auteur est-il unique
#---------------------------------------------------------------------------
# print STDOUT $choix;
# foreach $auteurs (@aut) { print STDOUT "$auteurs"; }

@res=grep (/$choix/, @aut);

$nb=$#res+1;
if ($nb != 1)
{
   for (@res) { print STDERR "$_"; }
   print STDERR " ##### ATTENTION ##### ========> Auteur [$choix] non trouv‚ : choisir un, et un seul auteur\n";
   exit;
}

$choix=$res[0];
chop($choix);
#-- print STDOUT $choix;
   
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

#@ext=grep(/$choix/, @ouv);
#$nb=$#ext+1;

@romans=();
@recueils=();
@nouvelles=();
@poemes=();
@pieces=();
@hors_genre=();
@genre_inconnu=();
@essais=();
@anthologies=();
@articles=();
$nblig=0;

foreach $ligne (@ouv)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   $nblig++;
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
         printf STDERR " nouvelle ref et abscence 'o' :\n";
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
#        print STDERR "Nouvelle reference \n";
         $coll=substr ($lig, $coll_start, $coll_size);
#        $coll=~s/ +$//o;
#        $coll=~s/^ +//o;
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
           SOUSTYPE=>"",
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
           ANTHOLOG=>["","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
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
           DATE=>"",
           NUM=>"",
           TYPNUM=>"",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
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
           ANTHOLOG=>["","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
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
         $reference->{IN_SOUSTYPE} = $in_ref->{SOUSTYPE};
      }
      # ligne contenu
      ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

      # Substitution NICOT St‚phane
      if ($auteur eq "NICOT St‚phane") { $auteur = "NICOT S." }
      $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

      #-----------------------------------------------------
      # si ligne support : creation d'une nouvelle reference
      #-----------------------------------------------------
      $genre=substr ($lig, $genre_start, 1);
      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);

      $reference->{TITRE} = "$titre";
      $reference->{GENRE} = "$genre";
      $reference->{TYPE} = "$type";
      $reference->{SOUSTYPE} = "$stype";
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
#        print STDERR "antho : $auteur\n";
      }
      else
      {
         $reference->{NB_AUTEUR} = 1;
         $reference->{AUTEUR}[0] = "$auteur";
#        print STDERR "auteur : $auteur\n";
      }
   }
   elsif ($ref_en_cours eq "COLLAB")
   {
      #---------------------------------------------------
      # Collaboration d'auteurs : mise a jour reference
      #---------------------------------------------------
      $auteur=substr ($lig, $author_start, $author_size-1);
      $auteur=~s/ +$//o;
      # Substitution NICOT St‚phane
      if ($auteur eq "NICOT St‚phane") { $auteur = "NICOT S." }
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
#        print STDERR "Mise a jour reference \n";
         # test si anthologiste (marque '*' devant)
         $lenaut=length($auteur);
         if (substr ($lig, $auttyp_start, 1) eq '*')
         {
#            $auteur = substr($auteur,0,$lenaut-1);
            if ($reference->{NB_ANTHOLOG} < 5)
            {
               $reference->{ANTHOLOG}[$reference->{NB_ANTHOLOG}] = "$auteur";
               $reference->{NB_ANTHOLOG} = $reference->{NB_ANTHOLOG} + 1;
#              print STDERR "antho : $auteur\n";
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 5 anthologistes ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
         else
         {
#           print STDERR "auteur : $auteur\n";
            if ($reference->{NB_AUTEUR} < 15)
            {
               $reference->{AUTEUR}[$reference->{NB_AUTEUR}] = "$auteur";
               $reference->{NB_AUTEUR} = $reference->{NB_AUTEUR} + 1;
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 15 auteurs ?!\n";
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

      # Si l'auteur cherch‚ fait partie de la liste :
      # ajout au tableau idoine (romans, recueils, nouvelles, anthos...)

      # swap de l'auteur trouv‚ en premiŠre position (collab. ensuite)
      $nb_aut=0;
      while ($nb_aut < $reference->{NB_AUTEUR})
      {
         $nb_aut++;
         if ($reference->{AUTEUR}[$nb_aut] eq $choix)
         {
            $reference->{AUTEUR}[$nb_aut]=$swap=$reference->{AUTEUR}[0];
            $reference->{AUTEUR}[0]=$choix;
            $nb_aut = $reference->{NB_AUTEUR};
         }
      }
      $nb_aut=0;
      while ($nb_aut < $reference->{NB_ANTHOLOG})
      {
         $nb_aut++;
         if ($reference->{ANTHOLOG}[$nb_aut] eq $choix)
         {
            $reference->{ANTHOLOG}[$nb_aut]=$swap=$reference->{ANTHOLOG}[0];
            $reference->{ANTHOLOG}[0]=$choix;
            $nb_aut = $reference->{NB_ANTHOLOG};
        }
      }

      if ($reference->{AUTEUR}[0] eq $choix)
      {
         $reference->{CONTRIB}="a";

         if ((($reference->{GENRE} eq "x") || ($reference->{GENRE} eq "?"))
             && ($type ne "."))
         {
            # on ne compte "hors genre" / "genre incoonu" que les romans, nouvelles, recueils, biographies, essais
            if (($type eq "R") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Roman]";
            }
            if (($type eq "X") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Extrait]";
            }
            if (($type eq "x") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Extrait]";
            }
            if ((($type eq "N") || ($type eq "Y")) && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Nouvelle]";
            }
            if (($type eq "a") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Article]";
            }
            if (($type eq "r") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Court roman]";
            }
            elsif ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") ||
                    ($type eq "A") || ($type eq "C") || ($type eq "Y"))
                && ($stype ne " "))
            {
               $reference->{CMT_TYPE} = "[Recueil]";
            }
            elsif (($type eq "P") && ($stype ne " "))
            {
               $reference->{CMT_TYPE} = "[Po‚sies]";
            }
            elsif (($type eq "T") && ($stype ne " "))
            {
               $reference->{CMT_TYPE} = "[PiŠces de th‚ƒtre]";
            }
            elsif (($type eq "b") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Biographie]";
            }
            elsif ($type eq "E")
            {
               $reference->{CMT_TYPE} = "[Essai]";
            }
            if ($reference->{GENRE} eq "x")
            {
               push (@hors_genre, $reference);
            }
            if ($reference->{GENRE} eq "?")
            {
               push (@genre_inconnu, $reference);
            }
         }
         elsif (($reference->{GENRE} ne "!") && ($reference->{GENRE} ne "?") && ($reference->{GENRE} ne "C"))
         {
            # 25/10/18: Exclusion des chapitres / parties
            # 17/10/18: Exclusion genres inconnus/douteux en plus des hors genres
            if ((($type eq "N") || ($type eq "Y") || ($type eq "n") || ($type eq "r")) && ($stype eq " "))
            {
               # Nouvelle, Short Short ou novella seule - Collecte incluse
               if ($type eq "r")
               {
                  $reference->{CMT_TYPE} = "[Court roman]";
               }
               elsif ($type eq "Y")
               {
                  $reference->{CMT_TYPE} = "[Collecte]";
               }
               elsif ($type eq "n")
               {
                  $reference->{CMT_TYPE} = "[Micronouvelle]";
               }
               push (@nouvelles, $reference);
            }
            elsif (($type eq "X") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Extrait]";
               push (@nouvelles, $reference);
            }
            elsif (($type eq "x") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Extrait]";
               push (@nouvelles, $reference);
            }
            elsif ((($type eq "R") && ($stype eq " "))
                || (($type eq "Z") && ($stype eq " "))
                || ($type eq "U"))
            {
               # Roman ou Fix-Up
               if ($type eq "U")
               {
                  $reference->{CMT_TYPE} = "[Fix-Up]";
               }
               elsif ($type eq "Z")
               {
                  $reference->{CMT_TYPE} = "[Livre-jeu]";
               }
               push (@romans, $reference);
            }
            elsif ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") ||
                    ($type eq "A") || ($type eq "C") || ($type eq "Y") ||
                    ($type eq "P") || ($type eq "T"))
                && ($stype ne " "))
            {
               # Recueils, Anthologies, Collectes, Chroniques...
               if ($reference->{GENRE} eq "p")
               {
                  $reference->{CMT_TYPE} = "[Partiellement hors genres]";
               }
               elsif ($type eq "C")
               {
                  $reference->{CMT_TYPE} = "[Textes li‚s ou enchass‚s]";
               }
               elsif ($type eq "P")
               {
                  $reference->{CMT_TYPE} = "[Po‚sies]";
               }
               elsif ($type eq "T")
               {
                  $reference->{CMT_TYPE} = "[PiŠces de th‚ƒtre]";
               }
               push (@recueils, $reference);
            }
            elsif (($type eq "t") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Extrait]";
               push (@pieces, $reference);
            }
            elsif (($type eq "H") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[PiŠce radiophonique]";
               push (@nouvelles, $reference);
            }
            elsif (($type eq "P") && ($stype eq " "))
            {
               push (@poemes, $reference);
            }
            elsif (($type eq "c") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Chanson]";
               push (@poemes, $reference);
            }
            elsif (($type eq "F") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Novelisation]";
               push (@romans, $reference);
            }
            elsif (($type eq "f") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Courte novelisation]";
               push (@nouvelles, $reference);
            }
            elsif (($type eq "S") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Novelis. s‚rie TV]";
               push (@romans, $reference);
            }
            elsif (($type eq "V") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Novelis. jeu vid‚o]";
               push (@romans, $reference);
            }
            elsif (($type eq "T") && ($stype eq " "))
            {
               push (@pieces, $reference);
            }
            elsif (($type eq "E") && ($stype ne " "))
            {
               $reference->{CMT_TYPE} = "[Collectif]";
               push (@essais, $reference);
            }
            elsif (($type eq "E") || ($type eq "G"))
            {
               push (@essais, $reference);
            }
            elsif (($type eq "b") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Biographie]";
               push (@essais, $reference);
            }
         }
      }
      else
      {
         $reference->{CONTRIB}="b";
#        if (($reference->{ANTHOLOG}[0] eq $choix) && ($type eq "A"))
         if ($reference->{ANTHOLOG}[0] eq $choix)
         {
            if ($reference->{GENRE} eq "x")
            {
               $reference->{CMT_TYPE} = "[Anthologiste de]";
               push (@hors_genre, $reference);
            }
            elsif ($reference->{GENRE} eq "?")
            {
               $reference->{CMT_TYPE} = "[Anthologiste de]";
               push (@genre_inconnu, $reference);
            }
            elsif (($type eq "E") || ($type eq "G"))
            {
               $reference->{CMT_TYPE} = "[Direction d'ouvrage]";
               push (@essais, $reference);
            }
            elsif (($type eq "b") && ($stype eq " "))
            {
               $reference->{CMT_TYPE} = "[Biographie]";
               push (@essais, $reference);
            }
            else
            {
               if ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") ||
                    ($type eq "A") || ($type eq "C") || ($type eq "Y") ||
                    ($type eq "P") || ($type eq "T"))
                && ($stype ne " "))
               {
                  # Recueils, Anthologies, Chroniques...
                  if ($reference->{GENRE} eq "p")
                  {
                     $reference->{CMT_TYPE} = "[Partiellement hors genres]";
                  }
               }
               push (@anthologies, $reference);
            }
         }
      }
   }
   $old=$lig;
}


# Trier les tableaux
#--------------------

@romans0=sort tri @romans;
@recueils0=sort tri @recueils;
@nouvelles0=sort tri @nouvelles;
@poemes0=sort tri @poemes;
@pieces0=sort tri @pieces;
@hors_genre0=sort tri @hors_genre;
@genre_inconnu0=sort tri @genre_inconnu;
@antho0=sort tri @anthologies;
@essais0=sort tri @essais;

# Affichage resultats
#---------------------

if ($sortie ne "CONSOLE")
{
   # nom du lien, et initiale
   $outfile=&url_auteur($choix);
   $initiale=substr ($outfile, 0, 1);
   $initiale=lc($initiale);
   $maj=uc($initiale);
   
   if ($sortie eq "SITE")
   {
      $outf="${livraison_site}/$initiale/$outfile.php";
   }
   else
   {
      # ERREUR de format de sortie des resultats
   }

   print STDERR "resultat dans $outf\n";
   open (OUTP, ">$outf");
   $canal=OUTP;
}
else
{
   $canal=STDOUT;
   $canalb=STDOUT;
}


if ($sortie eq "SITE")
{
   &web_begin ($canal, "../../commun/", "$choix : une page non officielle");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Bibliographie : $choix");
   &web_head_meta ("keywords", "biblio, bibliographie, roman, nouvelle, auteur, imaginaire, SF, science-fiction, fantasy, merveilleux, fantastique, horreur $choix");
   &web_head_css ("screen", "../../styles/bdfi.css");
   &web_head_js ("../../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../../scripts/outils_v2.js");
   &web_body ();
   &web_menu (0, "");

   &web_data ("<div id='menbib'>");
   &web_data (" [ <a href='javascript:history.back();' onmouseover='window.status=\"Back\";return true;'>Retour</a> ] ");
   &web_data ("Vous &ecirc;tes ici : <a href='../..'>BDFI</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='..'>Auteurs</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Index\n");
   $maj = uc ($initiale);
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='../index.php?i=$initiale'>Initiale $maj</a>\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> $choix\n");
   &web_data ("<br />");
   &web_data ("Bibliographies de l'imaginaire (SF, fantasy, merveilleux, fantastique, horreur, &eacute;trange) ");
   &web_data (" - <a href=\"javascript:mail();\">Ecrire &agrave; BDFI</a> pour compl&eacute;ments &amp; corrections.");
   &web_data ("</div>\n");

   &web_data ("<h1><a name='$outfile'>$choix</a></h1>\n");

   if ($avec_bio == 1)
   {
      # Ins‚rer la fonction de r‚cup‚ration et affichage bio
      print $canal "<?php include('../../commun/lib_bdfi.php'); ?>\n";
      print $canal "<?php include('../../commun/outils_sgbd.inc.php'); ?>\n";
      $choixnoacc = &noacc($choix);
      $inputdb = $choixnoacc;
      # Remplacer les " par des \"
      $inputdb=~s/"/\\"/g;
#     print STDERR "[DBG] (( $choixnoacc )) \n";
      # g‚n‚rer la chaine d'appel (pb avec les "... 3 niveaux !)
      $calldb = "<?php affiche_bio(\"" . $inputdb . "\"); ?>\n";
      print $canal $calldb;
      # Utilise $choixnoacc 
      # print $canal "<?php include('../../commun/include_bio.inc.php'); ?>\n";
   }

   # print $canal &tohtml("<hr />\n");
#   print $canal &tohtml("<!-- Refs: ");
#   print $canal "Romans="
#,$#romans0+1,&tohtml(", Recueils=")
#,$#recueils0+1,&tohtml(", Nouvelles=")
#,$#nouvelles0+1,&tohtml(", Poemes=")
#,$#poemes0+1,&tohtml(", Pieces=")
#,$#pieces0+1,&tohtml(", Anthologiste=")
#,$#antho0+1,&tohtml(", Essais=")
#,$#essais0+1,&tohtml(", Hors genres=")
#,$#hors_genre0+1," -->\n";
}
else
{
   print $canal " ---------- $choix ---------- \n";
}

   if ($avec_prix == 1)
   {
      # &aff_prix($choix, $sortie);
   }
   if ($avec_cycles == 1)
   {
      # 
      # dans la suite...
      # 
   }

if ($#romans0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Romans</h2>\n<ul>");
   }
   else
   {
      print $canal " --- Romans :\n";
   }
   $li_en_cours="NON";
   foreach $item (@romans0) {
      if (($item->{TYPE} eq "U") && ($item->{SOUSTYPE} ne " ")) {
         &AFFICHE ($item, 1);
      }
      else {
         &AFFICHE ($item, 0);
      }
   }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}

if ($#recueils0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Recueils, anthologies, collectes, omnibus...</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- Recueils, anthologies, collectes, omnibus... :\n";
   }
   $li_en_cours="NON";
   foreach $item (@recueils0) { &AFFICHE ($item, 1); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}

if ($#nouvelles0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Nouvelles et courts romans</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- Nouvelles :\n";
   }
   $li_en_cours="NON";
   foreach $item (@nouvelles0) { &AFFICHE ($item, 0); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}

if ($#poemes0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>PoŠmes, chansons...</h2>\n<ul>");
   }
   else
   {
      print $canal &totext ("\n --- PoŠmes, chansons :\n");
   }
   $li_en_cours="NON";
   foreach $item (@poemes0) { &AFFICHE ($item, 0); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}

if ($#pieces0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>PiŠces de th‚ƒtre</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- PiŠces de th‚ƒtre :\n";
   }
   $li_en_cours="NON";
   foreach $item (@pieces0) { &AFFICHE ($item, 0); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}

if ($#antho0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Anthologiste de :</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- Anthologiste de :\n";
   }
   $li_en_cours="NON";
   foreach $item (@antho0) { &AFFICHE ($item, 1); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}

if ($#essais0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Essais, ‚tudes, guides</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- Essais :\n";
   }
   $li_en_cours="NON";
   foreach $item (@essais0) { &AFFICHE ($item, 0); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}


if ($#hors_genre0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Hors genres</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- Hors genres :\n";
   }
   $li_en_cours="NON";
   foreach $item (@hors_genre0) { &AFFICHE ($item, 0); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}
if ($#genre_inconnu0 + 1 > 0)
{
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("<h2>Genre … confirmer (SF, fantastique... ou hors-genres)</h2>\n<ul>");
   }
   else
   {
      print $canal "\n --- Genre … d‚terminer :\n";
   }
   $li_en_cours="NON";
   foreach $item (@genre_inconnu0) { &AFFICHE ($item, 0); }
   if ($sortie eq "SITE")
   {
      print $canal &tohtml("</li></ul>\n");
   }
   $old_titre="";
   $old_cmt="";
}


if ($sortie eq "SITE")
{
   &web_end();
}

if ($sortie ne "CONSOLE")
{
   close (OUTP);
}

if ($upload == 1)
{
   $file = "${livraison_site}/$initiale/$outfile.php";
   $cwd = "/www/auteurs/$initiale";
   &bdfi_upload($file, $cwd);
}

#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference
#---------------------------------------------------------------------------
sub AFFICHE {
   local($aa)=$_[0];
   $antho=$_[1];

   $titre=$aa->{TITRE};
   $titre_seul=$aa->{TITRE_SEUL};
   $alias_recueil=$aa->{ALIAS_RECUEIL};
   $cycle=$aa->{CYCLE};
   $indice=$aa->{INDICE};
   $sous_sous_cycle=$aa->{SSSSC};
   $indice_sous_sous_cycle=$aa->{INDICE_SSSSC};
   $sous_cycle=$aa->{CYCLE_S};
   $indice_sous_cycle=$aa->{INDICE_S};
   $sous_cycle2=$aa->{CYCLE_S2};
   $indice_sous_cycle2=$aa->{INDICE_S2};
   $sous_cycle3=$aa->{CYCLE_S3};
   $indice_sous_cycle3=$aa->{INDICE_S3};
   $cycle2=$aa->{CYCLE2};
   $indice2=$aa->{INDICE2};
   $cycle3=$aa->{CYCLE3};
   $indice3=$aa->{INDICE3};

   # Suppression des cycles dans des doubles crochets [[xxx]]
   # SRU ne sert plus a rien, il faut les retrouver par comparaison des titre et cycle
   # $titre=~s/\[\[.*\]\]//o;

   if (($type_tri == 3) || (uc($titre) ne uc($old_titre))
       || ($aa->{CMT_TYPE} ne $old_cmt) || ($aa->{VODATE} ne $old_vodate)
        #--- 30/06 ajout de "et si le titre VO est diff‚rent du pr‚c‚dent => affichage distinct
       || ($aa->{VOTITRE} ne $old_votitre))
   {
      if ($sortie eq "SITE")
      {
         if ($li_en_cours eq "OUI")
         {
            print $canal "</li>";
            print $canal "\n";
         }
         $li_en_cours="OUI";
         
         # Si anthologie, chercher idrec
# GR 08/10/10 ajouts anthos po‚sies
#        if (($antho == 1) && ($aa->{TYPE} ne 'P')) {
         if ($antho == 1) {
            if ($alias_recueil ne "")
            {
               $idrec=idrec($alias_recueil, "", "");
            }
            else
            {
               $idrec=idrec($titre_seul, $cycle, $sous_cycle);
            }
            $url_antho=url_antho($idrec);
            $url_antho="${url_antho}.php";
            print $canal &tohtml("<li><span class='fr'><a class='antho' href='../../recueils/pages/$url_antho'>$titre_seul</a>");
         }
         else {
            print $canal &tohtml("<li><span class='fr'>$titre_seul");
         }
         if ($sous_sous_cycle ne "")
         {
#           print STDERR "[DBG] sous-sous-cycle extrait : $sous_sous_cycle ($indice_sous_sous_cycle)\n";
            # Pas de lien pour l'instant
            # --> sinon ?
            print $canal &tohtml(" [$sous_sous_cycle");
            if ($indice_sous_sous_cycle ne "")
            {
               print $canal &tohtml(" - $indice_sous_sous_cycle");
            }
            print $canal &tohtml("]");
         }
         if ($sous_cycle ne "")
         {
#           print STDERR "[DBG] sous-cycle 1 extrait : $sous_cycle ($indice_sous_cycle)\n";
            # Pas de lien pour l'instant
            # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
            print $canal &tohtml(" [$sous_cycle");
            if ($indice_sous_cycle ne "")
            {
               print $canal &tohtml(" - $indice_sous_cycle");
            }
            print $canal &tohtml("]");
         }
         if ($sous_cycle2 ne "")
         {
#           print STDERR "[DBG] sous-cycle 2 extrait : $sous_cycle2 ($indice_sous_cycle2)\n";
            # Pas de lien pour l'instant
            # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
            print $canal &tohtml(" [$sous_cycle2");
            if ($indice_sous_cycle2 ne "")
            {
               print $canal &tohtml(" - $indice_sous_cycle2");
            }
            print $canal &tohtml("]");
         }
         if ($sous_cycle3 ne "")
         {
#           print STDERR "[DBG] sous-cycle 3 extrait : $sous_cycle3 ($indice_sous_cycle3)\n";
            # Pas de lien pour l'instant
            # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
            print $canal &tohtml(" [$sous_cycle3");
            if ($indice_sous_cycle3 ne "")
            {
               print $canal &tohtml(" - $indice_sous_cycle3");
            }
            print $canal &tohtml("]");
         }
         if ($cycle ne "")
         {
#           print STDERR "[DBG] cycle 1 extrait : $cycle ($indice)\n";
            # nom du lien sur le cycle
            $lien_serie=&url_serie($cycle);
            print $canal &tohtml(" [<a class='cycle' href='../../series/pages/$lien_serie.php'>");
            if (($titre_seul eq $cycle) && ($indice eq "")) {
               print $canal &tohtml("*");
            }
            else {
               print $canal &tohtml("$cycle");
            }
            print $canal &tohtml("</a>");
            if ($indice ne "")
            {
               print $canal &tohtml(" - $indice");
            }
            print $canal &tohtml("]");
         }
         if ($cycle2 ne "")
         {
#           print STDERR "[DBG] cycle 2 extrait : $cycle2 ($indice2)\n";
            # nom du lien sur le cycle2
            $lien_serie=&url_serie($cycle2);
            print $canal &tohtml(" [<a class='cycle' href='../../series/pages/$lien_serie.php'>");
            if (($titre_seul eq $cycle2) && ($indice2 eq "")) {
               print $canal &tohtml("*");
            }
            else {
               print $canal &tohtml("$cycle2");
            }
            print $canal &tohtml("</a>");
            if ($indice2 ne "")
            {
               print $canal &tohtml(" - $indice2");
            }
            print $canal &tohtml("]");
         }
         if ($cycle3 ne "")
         {
#           print STDERR "[DBG] cycle 3 extrait : $cycle3 ($indice3)\n";
            # nom du lien sur le cycle3
            $lien_serie=&url_serie($cycle3);
            print $canal &tohtml(" [<a class='cycle' href='../../series/pages/$lien_serie.php'>");
            if (($titre_seul eq $cycle3) && ($indice3 eq "")) {
               print $canal &tohtml("*");
            }
            else {
               print $canal &tohtml("$cycle3");
            }
            print $canal &tohtml("</a>");
            if ($indice3 ne "")
            {
               print $canal &tohtml(" - $indice3");
            }
            print $canal &tohtml("]");
         }
         print $canal &tohtml("</span>");
      }
      else
      {
         print $canal &totxt ("$titre");
      }
      $old_titre=$titre;
      $old_cmt=$aa->{CMT_TYPE};
      $old_vodate=$aa->{VODATE};
      $old_votitre=$aa->{VOTITRE};

#     if (($aa->{VODATE} ne "") && ($aa->{VODATE} != 0))
      if ($aa->{VODATE} ne "")
      {
         if ($sortie eq "SITE")
         {
            print $canal &tohtml(" <span class=\"vo\">($aa->{VODATE}");
#           if (($aa->{VOTITRE} ne "") && ($aa->{VOTITRE} != 0))
            if ($aa->{VOTITRE} ne "")
            {
               print $canal &tohtml(", $aa->{VOTITRE}");
            }
            print $canal &tohtml(")</span>");
         }
         else
         {
            print $canal " ($aa->{VODATE}";
            if ($aa->{VOTITRE} ne "")
            {
               print $canal &totxt (", $aa->{VOTITRE}");
            }
            print $canal ")";
         }
      }

# tohtml seulement si site
# si il s'agit d'un auteur, liste auteur puis antho
#
#  A (anthologiste E)
#  A (avec B, C et D, anthologiste E, F, G et H)
#
#  E (textes de A)
#  E (avec F, G et H, textes de A, B, C et D)
#
#
      if ($aa->{NB_AUTEUR} + $aa->{NB_ANTHOLOG} > 1)
      {
         print $canal " (";
      }
      if ($aa->{CONTRIB} eq "a")
      {
       $nb_aut = 1;
       while ($nb_aut < $aa->{NB_AUTEUR})
       {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         #mot intermediaire : "avec " / ", " /  " et "
         if ($nb_aut == 1) { print $canal "avec "; }
         elsif ($nb_aut+1 == $aa->{NB_AUTEUR}) { print $canal " et "; }
         else  { print $canal ", "; }


         if ($sortie eq "SITE")
         {
            if ($lien_auteur ne "nicot_s") {
               print $canal &tohtml("<a class=\"auteur\" href=\"../$initiale_lien/$lien_auteur.php\">");
               print $canal &tohtml("$aa->{AUTEUR}[$nb_aut]");
               print $canal &tohtml("</a>");
            } else {
               print $canal &tohtml("<span class='auteur'>$aa->{AUTEUR}[$nb_aut]</span>");
            }
         }
         else
         {
            print $canal "$aa->{AUTEUR}[$nb_aut]";
         }

         $nb_aut++;
       }
       $nb_aut = 0;
       if (($aa->{NB_AUTEUR} > 1) && ($aa->{NB_ANTHOLOG} > 0))
       {
          print $canal ", ";
       }
       while ($nb_aut < $aa->{NB_ANTHOLOG})
       {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{ANTHOLOG}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         #mot intermediaire : "avec " / ", " /  " et "
         if (($nb_aut == 0) && ($aa->{NB_ANTHOLOG} > 1)) { print $canal "anthologistes "; }
         elsif ($nb_aut == 0) { print $canal "anthologiste "; }
         elsif ($nb_aut+1 == $aa->{NB_ANTHOLOG}) { print $canal " et "; }
         else  { print $canal ", "; }


         if ($sortie eq "SITE")
         {
            if ($lien_auteur ne "nicot_s") {
               print $canal &tohtml("<a class=\"auteur\" href=\"../$initiale_lien/$lien_auteur.php\">");
               print $canal &tohtml("$aa->{ANTHOLOG}[$nb_aut]");
               print $canal "</a>";
            } else {
               print $canal &tohtml("<span class='auteur'>$aa->{ANTHOLOG}[$nb_aut]</span>");
            }
         }
         else
         {
            print $canal "$aa->{ANTHOLOG}[$nb_aut]";
         }

         $nb_aut++;
       }
      }
      else
      {
       $nb_aut = 1;
       while ($nb_aut < $aa->{NB_ANTHOLOG})
       {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{ANTHOLOG}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         #mot intermediaire : "avec " / ", " /  " et "
         if ($nb_aut == 1) { print $canal "avec "; }
         elsif ($nb_aut+1 == $aa->{NB_ANTHOLOG}) { print $canal " et "; }
         else  { print $canal ", "; }


         if ($sortie eq "SITE")
         {
            if ($lien_auteur ne "nicot_s") {
               print $canal &tohtml("<a class=\"auteur\" href=\"../$initiale_lien/$lien_auteur.php\">");
               print $canal &tohtml("$aa->{ANTHOLOG}[$nb_aut]");
               print $canal &tohtml("</a>");
            } else {
               print $canal &tohtml("<span class='auteur'>$aa->{ANTHOLOG}[$nb_aut]</span>");
            }
         }
         else
         {
            print $canal "$aa->{ANTHOLOG}[$nb_aut]";
         }

         $nb_aut++;
       }
       $nb_aut = 0;
       while ($nb_aut < $aa->{NB_AUTEUR})
       {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR}[$nb_aut]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         if ($aa->{NB_ANTHOLOG} > 1) { print $canal ", ";}
         #mot intermediaire : "avec " / ", " /  " et "
         if ($nb_aut == 0) {
            if ($aa->{TYPE} eq "Y")
            {
               print $canal "collectes de ";
            }
            else
            {
               print $canal "textes de ";
            }
         }
         elsif ($nb_aut+1 == $aa->{NB_AUTEUR}) { print $canal " et "; }
         else  { print $canal ", "; }


         if ($sortie eq "SITE")
         {
            if ($lien_auteur ne "nicot_s") {
               print $canal &tohtml("<a class=\"auteur\" href=\"../$initiale_lien/$lien_auteur.php\">");
               print $canal &tohtml("$aa->{AUTEUR}[$nb_aut]");
               print $canal &tohtml("</a>");
            } else {
               print $canal &tohtml("<span class='auteur'>$aa->{AUTEUR}[$nb_aut]</span>");
            }
         }
         else
         {
            print $canal "$aa->{AUTEUR}[$nb_aut]";
         }

         $nb_aut++;
       }
      }
      if ($aa->{NB_AUTEUR} + $aa->{NB_ANTHOLOG} > 1)
      {
         print $canal ")";
      }

#     if (($aa->{CMT_TYPE} ne "") && ($aa->{CMT_TYPE} != 0))
      if ($aa->{CMT_TYPE} ne "")
      {
         if ($sortie eq "SITE")
         {
            print $canal &tohtml(" <span class=\"cmt\">$aa->{CMT_TYPE}</span>");
         }
         else
         {
            print $canal " aa->{CMT_TYPE}";
         }
      }      print $canal "\n";
   }

   if ($no_coll == 0)
   {
      print $canal "<br />";
      &aff_support($canal, $aa, 1, \@sigles);
      print $canal "\n";
      $li_en_cours="OUI";
   }
}

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#---------------------------------------------------------------------------
sub tri
{
   if ($type_tri==0)
   {
      # ----------------------------------------------
      # type de tri = 0 (defaut) titre fran‡ais
      #   deuxieme critere = date edition francaise
      # ----------------------------------------------
      if (uc($a->{TITRE}) ne uc($b->{TITRE}))
      {
         uc($a->{TITRE}) cmp uc($b->{TITRE});
      }
      else
      {
         uc($a->{DATE}) cmp uc($b->{DATE});
      }
   }
   elsif ($type_tri==1)
   {
      # ----------------------------------------------
      # type de tri = 1 (-v) premiŠre date du texte
      #   deuxieme critere/1 = titre cycle
      #   deuxieme critere/2 = indice dans le cycle
      #                  (Attention, tri num‚rique !)
      #   troisieme critere = titre VO
      # TBC  : si pas de titre VO, date de parution d'abord ?
      #   quatrieme critere = titre fran‡ais
      # FAIRE D'ABORD : par type (dans le mˆme tableau, il peut y avoir romans et extraits par exemple)
      #   cinquieme critere = date de parution
      # ----------------------------------------------
          # ne et cmp obligatoire si on veut diff‚rencier 1948 et 1948-1956
          # cf VAN VOGT
      $date_a=uc($a->{VODATE});
      $date_a=~s/\[//;
      $date_b=uc($b->{VODATE});
      $date_b=~s/\[//;
      if ($date_a ne $date_b)
      {
         $date_a cmp $date_b;
      }
      else
      {
         if (uc($a->{CYCLE}) ne uc($b->{CYCLE}))
         {
            uc($a->{CYCLE}) cmp uc($b->{CYCLE});
         }
         else
         {
            if ($a->{INDICE} != $b->{INDICE})
            {
               $a->{INDICE} <=> $b->{INDICE};
            }
            elsif ($a->{INDICE_S} != $b->{INDICE_S})
            {
               $a->{INDICE_S} <=> $b->{INDICE_S};
            }
            else
            {
               if (uc($a->{VOTITRE}) ne uc($b->{VOTITRE}))
               {
                  uc($a->{VOTITRE}) cmp uc($b->{VOTITRE});
               }
               else
               {
                  if (uc($a->{TITRE}) ne uc($b->{TITRE}))
                  {
                     uc($a->{TITRE}) cmp uc($b->{TITRE});
                  }
                  else
                  {
                     #--- 30/06 : ajout tri type entre titre et date (‚vite un extraits entre des ‚ditions d'un roman)
                     if ($a->{TYPE} ne $b->{TYPE})
                     {
                         $a->{TYPE} cmp $a->{TYPE};
                     }
                     else
                     {
                        uc($a->{DATE}) cmp uc($b->{DATE});
                     }
                  }
               }
            }
         }
      }
   }
   elsif ($type_tri==2)
   {
      # type de tri = 2 (-o) Titre original
      #  deuxieme critere = titre vf
      # ----------------------------------------------
      if (uc($a->{VOTITRE}) ne uc($b->{VOTITRE}))
      {
         uc($a->{VOTITRE}) cmp uc($b->{VOTITRE});
      }
      else
      {
         uc($a->{TITRE}) cmp uc($b->{TITRE});
      }
   }
   elsif ($type_tri==3)
   {
      #  A FAIRE  Marche pas terrible : a revoir ?

      # type de tri = 3 (-d) Date de l'‚dition fran‡aise
      #   deuxieme critere  = cycle
      #   troisieme critere = titre fran‡ais
      # ----------------------------------------------
      if (uc($a->{DATE}) ne uc($b->{DATE}))
      {
         uc($a->{DATE}) cmp uc($b->{DATE});
      }
      else
      {
         if (uc($a->{CYCLE}) ne uc($b->{CYCLE}))
         {
            uc($a->{CYCLE}) cmp uc($b->{CYCLE});
         }
         else
         {
            uc($a->{TITRE}) cmp uc($b->{TITRE});
         }
      }
   }
   else
   {
      uc($a->{TITRE}) cmp uc($b->{TITRE});
   }
}

# --- fin ---


