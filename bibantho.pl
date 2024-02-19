#===========================================================================
#
# Script de generation d'une page de sommaires de recueil et antho
#
#---------------------------------------------------------------------------
# Historique :
#
#   0.1  - 15/04/2004 : Creation d'aprŠs bibserie.pl
#   0.2  - 27/07/2004 : Affichage des sommaire et du genre
#   1.0  - 05/08/2004 : Tri correct, ajout ISBN
#   1.1  - 10/02/2005 : CSS et XHTML
#   1.2  - 14/12/2005 : Resolution des recueils inclus dans omnibus
#   1.3  - 15/12/2005 : Ajout des Fix-Up & Chroniques
#   1.4  - 06/09/2006 : Ajout ‚diteurs et liens sur liste, tri complexe
#   1.5  - 18/10/2007 : Passage a l'extension PHP
#                       Suppression autres sorties locales (DOS, WINDOWS, HTML) 
#                       Nouveaux répertoires d'images + gestion agrandissement                     
#   1.6  - 14/12/2007 : Remplacement "en dur" de NICOT St‚phane par NICOT .S
#   1.7  - 15/04/2009 : Nouveau moteur d'affichage des agrandissements d'images
#   1.8  - 12/02/2010 : Utilisation JQuery pour menu & images
#                       Amelioration bloc couvs: boutons actif diff‚rent
#   1.9  - 03/08/2010 : upload automatique par defaut
#   1.9b - 09/07/2013 : passage … 15 r‚‚ditions possibles
#   2.0  - 25/05/2015 : Prise en compte dans les recueils des hors genres "non r‚f‚renc‚s"
#   2.1  - 27/04/2016 : Prise en compte des extraits (x et t) et des collectes (Y, Yx)
#   2.2  - 15/05/2016 : Adaptation suite … la nouvelle structure image (initiales)
#   2.3  - 04/11/2017 : Homog‚n‚isation des outils bibxyz
#   2.4  - 13/02/2018 : Ajout des "recueils" de guides et encyclop
#   2.5  - 17/10/2018 : Prise en compte des genres "douteux" dans les recueils
#   2.6  - 08/12/2018 : Gestion des sections/parties
#   2.7  - 30/06/2019 : Tri : titre VO ajout‚ entre date VO et date parution
#   2.9  - 08/04/2020 : Gestion des "recueils" d'essais + ajout [Micronouvelle]
#   3.0  - 09/05/2020 : Affichage des notes / commentaires recueils
#   3.1  - 12/05/2020 : extraction couv d‚port‚ dans bdfi.pm
#   3.2  - 22/12/2020 : prise en compte des alias de recueil en ligne ((Nom de page))
#
#
#   x.y  - ../../2020 : Affichage des ISBN des r‚‚ditions - FAIRE
#    exemple :
#      J'ai Lu, Science-fiction nø 2388, 1988 (r‚‚d. 1998, 2002, 2008, 2016, 2017)
#      ISBN : 2-277-22388-3 
#    deviendrait :
#      J'ai Lu, Science-fiction nø 2388, <b>1988</b> (ISBN 2-277-22388-3)
#      R‚‚ditions : <b>1998</b> (ISBN 2-277-22388-3), 2002 (ISBN 2-277-22388-3), 2008 (ISBN 2-277-22388-3), 2016 (ISBN 2-277-22388-3), 2017 (ISBN 2-277-22388-3)
#                     
#---------------------------------------------------------------------------
# Utilisation :
#
#---------------------------------------------------------------------------
#
# A FAIRE :
#
# - anthologistes en "***" -> affichage "inconnu" sans lien
# - afficher [type] dans les sommaires si pas nouvelle
# - Pb des recueils dans omnibus
#    * Propal : Intégrer dans le sommaire omnibus, et ajouter recueil inclus dans sa page,
#      mais avec lien (voir ce qui est fait actuellement)
# - Afficher le nombre de textes de fiction. Format :
#    Fictions : 15 textes (2 romans, 12 nouvelles, 1 poème) dont 4 hors genres
#    Fictions : 15 nouvelles dont 4 hors genres
#
# Algo global :
#  - rechercher tout les ouvrages de type antho/recueils tels que meme idrec
#  - Memoriser tout de suite le contenu ?
#  - afficher avec un des formats suivants :
#
#   ¤ Au look "revues sf" ericb :
#   > - Venus par Maurice Baring
#   > (Venus - "Orpheus in Mayfair", 1909) - Traduction: Norbert Gaulard
#   
#   ¤ Au look Sfmarseille :
#   > Patient (le) (1943) HULL Edna Mayne (Nouvelle) The patient 
#   
#   ¤ Look propal bdfi (look pages series) :
#   > Le bateau blanc (1919, The white ship) de HULL Edna Mayne [Nouvelle] Trad. BREQUE Jean-Daniel
#
#   ou (option)
#   > [Nouvelle] HULL Edna Mayne : Le bateau blanc (1919, The white ship) Trad. BREQUE Jean-Daniel
#
#   ou (le top, option donnant le format affichage :
#
#      ericb : -f "(T - O, V) - Traduction: F"
#      sfm   : -f "T (V) A (G) O"
#      bdfi1 : -f "T (V, O) de A [G] Trad. F"
#      bdfi2 : -f "[G] A : T (V, O) Trad. F"
# Par exemple:
#   Format du format : "%T [%C] (%V, %O) de %A Trad. %F"
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "auteurs.pm";
require "affiche.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage - Globales (aussi ds .pm)
#---------------------------------------------------------------------------
#--- support
$coll_start=2;                                $coll_size=7;
$num_start=10;                                $num_size=5;
$typnum_start=15;
$date_start=17;                               $date_size=4;
$mois_start=22;                               $mois_size=2;
$mark_start=31;                               $mark_size=4;
$isbn_start=36;                               $isbn_size=17;

#--- intitule
$genre_start=3;
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

#--- couverture
$scan_start= 1;                               $scan_size=17;
$illu_start= 18;                              $illu_size=28;
$dess_start= $title_start;
#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/recueils/pages";

my $ref_en_cours="NOUV_REF";  # "NOUV_REF", "NUM_MULT", "FIN_SUPPORT", "COLLAB"
my $into=0;
my $NOCYC=0;
my $notes="";
my $nblig=0;

my @anthos=();
my $id_antho_ref0;

my @ref0_sommaire=();
my $ref0_id_sommaire=0;
my $ref0_ok_to_mem="NON";

my @ref1_sommaire=();
my $ref1_id_sommaire=0;
my $ref1_ok_to_mem="NON";

my $canal=0;
my $upload=1;


#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$sortie="SITE";
$param="TITRE";

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 [-s|-c] <titre_recueil>\n";
   print STDERR "        -s : (par d‚faut) livraison fichier xhtml/php sur arbo site \n";
   print STDERR "        -c : sortie console \n";
   print STDERR "        -u : pas d'upload du fichier\n";
   print STDERR "\n";
   exit;
}
$i=0;

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
   elsif ($ARGV[$i] eq "-u")
   {
      $param="URL";
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
# Lecture du fichier anthos
#---------------------------------------------------------------------------
my $file="anthos.res";
open (f_ant, "<$file");
my @ant=<f_ant>;
close (f_ant);

foreach $ligne (@ant)
{
   $lig=$ligne;
   ($titre_antho, $id_antho, $page_antho)=split (/	/,$lig);
   push (@page, $id_antho);
   push (@url, $page_antho);
}

@tri = sort @page;
$old="";
@uniq=();
foreach $page_antho (@tri)
{
   if ($old ne $page_antho)
   {
      push (@uniq, $page_antho);
   }
   $old=$page_antho;
}

#---------------------------------------------------------------------------
# Le recueil est-il unique ?
#---------------------------------------------------------------------------
if ($param eq "TITRE")
{
   @res=grep (/$choix/i, @uniq);
   $nb=$#res+1;
   print STDOUT "-- $param -- [$choix] -- $nb correspondances\n";
}
else
{
   @res=grep (/$choix/i, @url);
   $nb=$#res+1;
   print STDOUT "-- $param -- [$choix] -- $nb correspondances\n";
}

if (($nb >= 1) && ($param eq "URL"))
{
   # OK
}
elsif ($nb == 1)
{
#print STDERR "1 : [$choix]\n";
   $choix=$res[0];
#print STDERR "2 : [$choix]\n";
   @res=grep (/	$choix	/, @ant);
   $choix=$res[0];
#print STDERR "3 : [$choix]\n";
}
else
{
   @res=grep (/	.*$choix.*	/, @ant);
   $nb=$#res+1;
   print STDOUT "-- (supp '()') -- [$choix] -- $nb correspondances\n";
      for (@res) { print STDOUT "$_"; }
   if ($nb != 1)
   {
      $choix=~s/\(/./go;
      $choix=~s/\)/./go;
      @res=grep {/$choix/x} @ant;
      $nb=$#res+1;
      print STDOUT "-- (idrec) -- [$choix] -- $nb correspondances\n";
   }
   if ($nb != 1)
   {
      @res=();
      @res=grep {/$choix/i} @ant;
      $nb=$#res+1;
      print STDOUT "-- (titres) -- [$choix] -- $nb correspondances\n";
   }
   if ($nb != 1)
   {
      @res=();
      @res=grep {/^$choix\t/i} @ant;
      $nb=$#res+1;
      print STDOUT "-- (titres) -- [^$choix\t] -- $nb correspondances\n";
   }
   if ($nb != 1)
   {
      $choix=substr($choix, 0, -1);
      @res=();
      @res=grep {/$choix/i} @ant;
      $nb=$#res+1;
      print STDOUT "-- (car fin) -- [$choix] -- $nb correspondances\n";
   }
   if ($nb != 1)
   {
      $choix=substr($choix, 1);
      @res=();
      @res=grep {/$choix/i} @ant;
      $nb=$#res+1;
      print STDOUT "-- (car debut) -- [$choix] -- $nb correspondances\n";
   }
   if ($nb == 0)
   {
      print STDOUT "$choix : --> unknown...\n";
      exit;
   }
}

if ($param eq "URL")
{
   $url_choix = $choix;
}
else
{
   if ($nb > 1)
   {
      for (@res) { print STDOUT "$_"; }
      print STDOUT "$choix : --> more precision...\n";
      exit;
   }
   $choix=$res[0];
   chop($choix);
#print STDERR "choix = $choix\n";
   ($inutile, $choix)=split(/	/, $choix);
#print STDERR "reste = $inutile\n";

   print STDERR "choix = $choix\n";

   $url_choix=url_antho($choix);
}
if ($choix eq "") {
   print STDOUT "$choix : --> pb, choix final vide...\n";
   exit;
}

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

foreach $ligne (@ouv)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   chop ($lig);
   $nblig++;

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $prem=substr ($lig, 0, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   if (($ref_en_cours eq "NOUV_REF") && ($prem eq 'o'))
   {
      #----------------------------------------------
      # Nouvelle reference, de type support (niv 0)
      #----------------------------------------------

      if ($ref0_ok_to_mem eq "OUI")
      {
         #----------------------------------------------
         #--- Un precedent sommaire etait en cours :
         #--- Recopie sommaire et arret memorisation
         #----------------------------------------------

#print STDERR "Recopie sommaire ref0 dans anthos, " . $id_anthos_ref0 . "\n";
         ($anthos[$id_anthos_ref0])->{SOMMAIRE} = \@{$ref0_sommaire[$ref0_id_sommaire]};
         $ref0_ok_to_mem = "NON";
      }
      if ($ref1_ok_to_mem eq "OUI")
      {
         #----------------------------------------------
         #--- Un precedent sommaire etait en cours :
         #--- Recopie sommaire et arret memorisation
         #----------------------------------------------
#print STDERR "Recopie sommaire ref1 dans anthos, -1 \n";
         ($anthos[-1])->{SOMMAIRE} = \@{$ref1_sommaire[$ref1_id_sommaire]};
         $ref1_ok_to_mem = "NON";
      }
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
         #---------------------------------------------------------------
         # Creation de la nouvelle reference de niveau 0 (type support)
         #---------------------------------------------------------------
         $into=0;
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
            $isbn_type="INCONNU";
         }
      
         $reference = {
           COLL=>"$coll",
           ISBN_TYPE=>"$isbn_type",
           ISBN=>"$isbn",
           COMPLET=>"",
           DATE=>"$date",
           MOIS=>"$mois",
           NB_REED=>0,
           REED=>["","","","","","","","","","","","","","",""],
           COUV=>["","","","","","","","","","","","","","",""],
           ILLU=>["","","","","","","","","","","","","","",""],
           DESS=>["","","","","","","","","","","","","","",""],
           NUM=>"$num",
           TYPNUM=>"$typnum",
           NOTES=>"",
           HG=>"", G1=>"", G2=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
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
           AFF_TYPE=>"",
           IN=>0,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
           IN_VODATE=>"",
           IN_VOTITRE=>"",
           %SOMMAIRE=>(),
         };
      }
   }
   elsif ($prem eq '}')
   {
      ($couv, $illustrateur, $dessinateurs) = &extract_couv ($ligne);
      $reference->{COUV}[$reference->{NB_REED}] = "$couv";
      $reference->{ILLU}[$reference->{NB_REED}] = "$illustrateur";
      $reference->{DESS}[$reference->{NB_REED}] = "$dessinateurs";
      next;
   }
   elsif (($prem eq '+') || ($prem eq 'x'))
   {
      #-----------------------------------------------------
      # Reedition : complement de la reference niveau 0
      #-----------------------------------------------------
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
   elsif ($prem eq ">")
   {
      #-----------------------------------------------------
      # Commentaire "Officiel"
      #-----------------------------------------------------
      $br=substr($lig, 3, 1);
      $lig=~s/^>-+\.* *//;
      # si commentaire vide (!, - space), ou ligne vide : rien
      if ($br ne "-")
      {
         $reference->{NOTES} = $reference->{NOTES} . " $lig\n";
      }
      else
      {
         $reference->{NOTES} = $reference->{NOTES} . "<br />\n$lig\n";
      }
      next;
   }
   elsif ($ref_en_cours eq "NUM_MULT")
   {
      #----------------------------------------------------------
      # Numero multiple : mise a jour reference niveau 0
      #----------------------------------------------------------
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
   elsif ((($ref_en_cours eq "FIN_SUPPORT") && ($prem eq '-'))
      ||  (($ref_en_cours eq "NOUV_REF") && (($prem eq '=') || ($prem eq ':'))))
   {
      #-----------------------------------------------------
      # ligne "reference" (contenu principal ou inclus)
      #-----------------------------------------------------
      $into=0;
      if ($prem eq ':')
      {
#print STDERR "Nouvelle reference [into=1] \n";
         $into=1;
         $in_ref=$ref0_;
         # Si
         if ($ref1_ok_to_mem eq "OUI")
         {
            #----------------------------------------------
            #--- Un precedent sommaire de niv 1 etait en cours :
            #--- Recopie sommaire et arret memorisation
            #----------------------------------------------
#print STDERR "Recopie sommaire ref1 dans anthos, -1 \n";
            ($anthos[-1])->{SOMMAIRE} = \@{$ref1_sommaire[$ref1_id_sommaire]};
            $ref1_ok_to_mem = "NON";
         }
      }
      elsif ($prem eq '=')
      {
#print STDERR "Nouvelle reference [into=2] \n";
         $into=2;
         $in_ref=$ref1_;
         # A FAIRE une seule fois !!!
         # A FAIRE : le $in_ref doit ˆtre inclus dans le sommaire de ref0
#print STDERR "Ajout du in-ref dans ref0_sommaire (PB: TROP SOUVENT)\n";
#         push (@{$ref0_sommaire[$ref0_id_sommaire]}, $in_ref);
      }
      if (($prem eq '=') || ($prem eq ':'))
      {
         #-----------------------------------------------------------
         # si texte inclus, nouvelle reference
         #-----------------------------------------------------------
         $reference = {
           COLL=>"",
           ISBN_TYPE=>"",
           ISBN=>"",
           COMPLET=>"",
           DATE=>"",
           MOIS=>"",
           NUM=>"",
           TYPNUM=>"",
           HG=>"", G1=>"", G2=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           CYCLE=>{CP=>"", IP=>0, CS=>"", IS=>0},
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","","","","","","",""],
           CMT_TYPE=>"",
           AFF_TYPE=>"",
           IN=>1,
           IN_TITRE=>"",
           IN_TYPE=>"",
           IN_SOUSTYPE=>"",
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
         $reference->{COUV} = $in_ref->{COUV};
         $reference->{ILLU} = $in_ref->{ILLU};
         $reference->{DESS} = $in_ref->{DESS};

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
      $hg=substr ($lig, $genre_start, 1);
      $g1=substr ($lig, $genre_start + 1, 1);
      $g2=substr ($lig, $genre_start + 2, 1);

      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);
      $complet=substr ($lig, $type_start-1, 1);

      ($titre_seul, $alias_recueil,
       $ssssc, $issssc,
       $scycle, $indice_scycle, $sc2, $isc2, $sc3, $isc3,
       $cycle, $indice_cycle, $c2, $ic2, $c3, $ic3) = decomp_titre ($titre, $nblig, $lig);

      $reference->{COMPLET} = "$complet";
      $reference->{HG} = "$hg";
      $reference->{G1} = "$g1";
      $reference->{G2} = "$g2";
      $reference->{TITRE} = "$titre";
      $reference->{TITRE_SEUL} = "$titre_seul";
      $reference->{ALIAS_RECUEIL} = "$alias_recueil";
      $reference->{TYPE} = "$type";
      $reference->{SOUSTYPE} = "$stype";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";
      $reference->{CYCLE}->{CP} = $cycle;
      $reference->{CYCLE}->{IP} = $indice_cycle;
      $reference->{CYCLE}->{CS} = "$scycle";
      $reference->{CYCLE}->{IS} = $indice_scycle;

      if (($type eq "p") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Pr‚face]";
      }
      elsif (($type eq "o") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Postface]";
      }
      elsif (($type eq "P") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[PoŠme]";
      }
      elsif (($type eq "T") && ($stype eq " "))
      {
         # GR 25/06/11 essai ajout T=piŠce de th‚ƒtre
         $reference->{CMT_TYPE} = "[PiŠce de th‚ƒtre]";
      }
      elsif (($type eq "H") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[PiŠce radiophonique]";
      }
      elsif (($type eq "a") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Article]";
      }
      elsif (($type eq "I") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Interview]";
      }
      elsif (($type eq "l") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Lettre]";
      }
      elsif ((($type eq "X") || ($type eq "x") || ($type eq "t")) && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Extrait]";
      }
      elsif (($type eq "R") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Roman]";
      }
      elsif (($type eq "n") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Micronouvelle]";
      }
      elsif (($type eq "Y") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Collecte]";
      }
      elsif (($type eq "E") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Essai]";
      }
      elsif (($type eq "G") && ($stype eq " "))
      {
         $reference->{CMT_TYPE} = "[Guide]";
      }
      elsif ((($type eq "N") || ($type eq "n") || ($type eq "u") || ($type eq "R") || ($type eq "r")) && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Recueil]";
      }
      elsif (($type eq "E") && ($stype eq "N"))
      {
         $reference->{CMT_TYPE} = "[Essai et nouvelles]";
      }
      elsif (($type eq "P") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Recueil de poŠmes]";
      }
      elsif (($type eq "T") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Recueil de piŠces]";
      }
      elsif (($type eq "U") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Fix-Up]";
      }
      elsif (($type eq "C") && ($stype ne " "))
      {
         $reference->{CMT_TYPE} = "[Textes li‚s ou enchass‚s]";
      }

      if ($type eq "d")
      {
         # 07/23/2022 - En compl‚ment, info [Hors genres] pour les BD
         $reference->{CMT_TYPE} = $reference->{CMT_TYPE} . "[Bande dessin‚e]";
         $reference->{AFF_TYPE} = "NO";
      }
      elsif (($hg eq "x") || ($hg eq "!"))
      {
         # 25/05/2015 - En compl‚ment, info [Hors genres]
         $reference->{CMT_TYPE} = $reference->{CMT_TYPE} . "[Hors genres]";
         $reference->{AFF_TYPE} = "NO";
      }
      elsif ($hg eq "?")
      {
         # 17/10/2018 - En compl‚ment, info [Genre … d‚terminer]
         $reference->{CMT_TYPE} = $reference->{CMT_TYPE} . "[Genre … d‚terminer]";
         $reference->{AFF_TYPE} = "TBD";
      }

      # Recherche des anthologistes (marque '*' devant)
      if (substr ($lig, $auttyp_start, 1) eq '*')
      {
         $reference->{NB_ANTHOLOG} = 1;
         $reference->{ANTHOLOG}[0] = "$auteur";
#print STDERR "antho : $auteur\n";
      }
      else
      {
         $reference->{NB_AUTEUR} = 1;
         $reference->{AUTEUR}[0] = "$auteur";
#print STDERR "auteur : $auteur\n";
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
#print STDERR "Mise a jour reference \n";
         # test si anthologiste (marque '*' devant)
#        $lenaut=length($auteur);
         if (substr ($lig, $auttyp_start, 1) eq '*')
         {
#           $auteur = substr($auteur,0,$lenaut-1);
            if ($reference->{NB_ANTHOLOG} < 10)
            {
               $reference->{ANTHOLOG}[$reference->{NB_ANTHOLOG}] = "$auteur";
               $reference->{NB_ANTHOLOG} = $reference->{NB_ANTHOLOG} + 1;
#print STDERR "antho : $auteur\n";
            }
            else
            {
               # erreur, arret
               printf STDERR "*** Error line $nblig ***\n";
               printf STDERR " plus de 10 anthologistes ?!\n";
               printf STDERR "$lig\n";
               exit;
            }
         }
         else
         {
#print STDERR "auteur : $auteur\n";
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
      # A suivre... (niveau 0 uniquement)
      $ref_en_cours = "NUM_MULT";
   }
   elsif (($prem eq 'o') || ($prem eq '+') || ($prem eq 'x') || ($prem eq '/') && ($flag_num_a_suivre ne '/'))
   {
      # Fin de support principal (hors indications reeditions)
      #  reference principale (ou indication reeditions) a suivre...
      $ref_en_cours = "FIN_SUPPORT";
   }
   else
   {
      #-----------------------------------------------------
      # La reference est complete
      #-----------------------------------------------------
      $ref_en_cours = "NOUV_REF";

      # Si reference courante de type ouvrage : memo reference comme "ref_support"
      if ($into == 0)
      {
#print STDERR "Memo reference in-ref 0 \n";
         $ref0_=$reference;
      }
      if ($into == 1)
      {
#print STDERR "Memo reference in-ref 1 \n";
         $ref1_=$reference;
      }

      # Memo sommaire si en cours
      if (($ref0_ok_to_mem eq "OUI") && ($into != 2))
      {
#print STDERR "Ajout ref dans ref0_sommaire ". $reference->{TITRE}."\n";
         push (@{$ref0_sommaire[$ref0_id_sommaire]}, $reference);
      }
      if ($ref1_ok_to_mem eq "OUI")
      {
#print STDERR "Ajout ref dans ref1_sommaire ". $reference->{TITRE}."\n";
         push (@{$ref1_sommaire[$ref1_id_sommaire]}, $reference);
      }

      $type=$reference->{TYPE};
      if (($type eq "A") ||
          (($type eq "N") && ($stype ne " ")) ||
          (($type eq "n") && ($stype ne " ")) ||
          (($type eq "U") && ($stype ne " ")) ||
          (($type eq "P") && ($stype ne " ")) ||
          (($type eq "T") && ($stype ne " ")) ||
          (($type eq "C") && ($stype ne " ")) ||
          (($type eq "Y") && ($stype ne " ")) ||
          (($type eq "R") && ($stype ne " ")) ||
          (($type eq "G") && ($stype ne " ")) ||
          (($type eq "E") && ($stype ne " ")) ||
          (($type eq "E") && ($stype eq "N")) ||
          (($type eq "r") && ($stype ne " ")))
      {

         if ($reference->{ALIAS_RECUEIL} ne "")
	 {
            $idrec=idrec($reference->{ALIAS_RECUEIL}, "", "");
	 }
	 else
	 {
#           $idrec=idrec($titre_seul, $c1, $sc1);
            $idrec=idrec($reference->{TITRE_SEUL}, $reference->{CYCLE}->{CP}, $reference->{SCYCLE}->{CS});
	 }

# print STDOUT "Antho : [$reference->{TITRE}] idrec [$idrec]\n";
# print STDERR "url_choix : [$url_choix] idrec [$idrec] \n";
      if (url_antho($idrec) eq $url_choix)
# TBD : autre type … retirer ?
      {
         if (($type eq "N") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Nouvelle]";
         }
         if (($type eq "n") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Micronouvelle]";
         }
         elsif (($type eq "Y") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Collecte]";
         }
         elsif (($type eq "X") && ($stype eq " "))
         {
            $reference->{CMT_TYPE} = "[Extrait]";
         }
         elsif ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r")) && ($stype ne " "))
         {
            $reference->{CMT_TYPE} = "[Recueil]";
         }
         elsif (($type eq "P") && ($stype ne " "))
         {
            $reference->{CMT_TYPE} = "[Recueil de poŠmes]";
         }
         elsif (($type eq "T") && ($stype ne " "))
         {
            $reference->{CMT_TYPE} = "[Recueil de piŠces]";
         }
         elsif (($type eq "U") && ($stype ne " "))
         {
            $reference->{CMT_TYPE} = "[Fix-Up]";
         }
         elsif (($type eq "C") && ($stype ne " "))
         {
            $reference->{CMT_TYPE} = "[Textes li‚s ou enchass‚s]";
         }
#        elsif (($type eq "A") && ($stype ne " "))
#        {
#           $reference->{CMT_TYPE} = "[Anthologie]";
#        }
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
         # Ajouter la reference de type recueil a la liste des anthos
         push (@anthos, $reference);
#print STDERR "PUSH anthos titre [$reference->{TITRE}] idrec [$idrec] \n";

         # Et a partir de la, il faudra memoriser le contenu...
         # Incrementer l'indice sommaire (car nouveau recueil)
         if ($into == 0)
         {
#print STDERR "OK nouveau sommaire into=0\n";
            $ref0_id_sommaire++;
            $ref0_ok_to_mem = "OUI";
            $id_anthos_ref0 = -1;
         }
         elsif ($into == 1)
         {
#print STDERR "OK nouveau sommaire into=1\n";
            $ref1_id_sommaire++;
            $ref1_ok_to_mem = "OUI";
            $id_anthos_ref0 -= 1;
         }
         else
         {
#print STDERR "BUG nouveau sommaire into=2\n";
         }
      }
      }
   }
   $old=$lig;
}

if ($ref0_ok_to_mem eq "OUI")
{
   #----------------------------------------------
   #--- Recopie sommaire du dernier ouvrage
   #----------------------------------------------
   ($anthos[$id_anthos_ref0])->{SOMMAIRE} = \@{$ref0_sommaire[$ref0_id_sommaire]};
#print STDERR "Recopie sommaire ref1 dans anthos, -1 \n";
}
if ($ref1_ok_to_mem eq "OUI")
{
   #----------------------------------------------
   #--- Recopie sommaire du dernier ouvrage
   #----------------------------------------------
#print STDERR "Recopie sommaire ref0 dans anthos, $id_anthos_ref0 \n";
   ($anthos[-1])->{SOMMAIRE} = \@{$ref1_sommaire[$ref1_id_sommaire]};
}


# Trier les tableaux
#--------------------
@anthos0=sort tri @anthos;

# Affichage resultats
#---------------------

if ($sortie ne "CONSOLE")
{
   # nom du lien, et initiale
   $outfile=$url_choix;
   $initiale=substr ($outfile, 0, 1);
   $initiale=lc($initiale);
   $maj=uc($initiale);
   if (($maj ge '0') && ($maj le '9'))
   {
      $maj="0-9";
      $initiale="09";
   }
   
   if ($sortie eq "SITE")
   {
      $outf="${livraison_site}/$outfile.php";
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
}

if ($sortie eq "SITE")
{
   &web_begin($canal, "../../commun/", "$choix");
   &web_data ("<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />\n");
   &web_head_meta ("author", "Richardot Gilles, Moulin Christian, Equipe BDFI");
   &web_head_meta ("description", "Sommaires recueils et anthologies : $choix");
   &web_head_meta ("keywords", "anthologie, recueil, omnibus, sommaire, bibliographie, imaginaire, SF, science-fiction, fantasy, merveilleux, fantastique, $choix");
   &web_head_css ("screen", "../../styles/bdfi.css");
   &web_head_js ("../../scripts/jquery-1.4.1.min.js");
   &web_head_js ("../../scripts/jquery-ui-1.7.2.custom.min.js");
   &web_head_js ("../../scripts/popup_v3.js");
   &web_head_js ("../../scripts/outils_v2.js");
   &web_data("<?php include('../../commun/image.inc.php') ?>");
   &web_body_v2 ();
   &web_menu (0, "");

   &web_data ("<div id='menbib'>");
   &web_data (" [ <a href='javascript:history.back();' onmouseover='window.status=\"Back\";return true;'>Retour</a> ] ");
   &web_data ("Vous &ecirc;tes ici : <a href='../..'>BDFI</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='..'>Recueils</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Index\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='../$initiale.php'>Initiale $maj</a>\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> $choix\n");
   &web_data ("<br />");
   &web_data ("Recueils, anthologies et omnibus de l'imaginaire (SF, fantasy, merveilleux, fantastique, horreur, &eacute;trange) ");
   &web_data (" - <a href='javascript:mail_anthos();'>Ecrire &agrave; BDFI</a> pour compl&eacute;ments &amp; corrections.");
   &web_data ("</div>\n");

   &web_data ("<h1><a name='$outfile'>$choix</a></h1>\n");
}
else
{
   print $canal " ---------- $choix ---------- \n";
}

#-------------------------------------------------------------
# Affichage de la liste des titres
#  Si superieur a 1 uniquement...
#-------------------------------------------------------------
if ($#anthos0 + 1 > 1)
{
   if ($#anthos0 == 0)
   {
      &web_data ("\nCette page r&eacute;pertorie l'ouvrage suivant :<br />\n");
   }
   else
   {
      &web_data ("\nCette page r&eacute;pertorie les recueils, anthologies, Fix-up ou omnibus suivants :<br />\n");
   }
   &web_data ("<ul>\n");
   $ix=1;
   foreach $sc (@anthos0)
   {
      &web_data ("<li><a class='cycle' href='#som$ix'><span class='fr'>$sc->{TITRE_SEUL}</span></a>");
#     print $canal &tohtml(" (publication $sc->{MOIS} $sc->{DATE})</li>\n");
# TBC function pour donner la chaine collection
      $coll_ok="Edition inconnue";
      foreach $toto (@sigles)
      {
         $refsig=$toto;
         chop($refsig);
         $sigle=substr ($refsig, 2, 7);
         $reste=substr ($refsig, 10);
         ($edc, $periode)=split (/þ/,$reste);
         $edc=~s/ +$//o;
         if ($sigle eq $sc->{COLL})
         {
            $coll_ok=$edc;
         }
      }
      &web_data (" - $sc->{DATE}, $coll_ok</li>\n");
      $ix = $ix + 1;
   }
   &web_data ("</ul>\n");
}

#-------------------------------------------------------------
# Affichage des sommaires
#-------------------------------------------------------------
if ($#anthos0 + 1 > 0)
{
   $ix=1;
   foreach $sc (@anthos0)
   {
      print $canal "\n<div class='rec'>\n";
# A FAIRE : boucle
      if ($sc->{COUV}[0] ne "")
      {
         &web_data ("<div class='rpcover'>\n");
         &web_data ("<table class='rpcover' summary='zone couvertures'>\n<tr>\n");
# FAIRE : Bouton "d‚file ?" ?
         if ($sc->{NB_REED} < 11) {
            &web_data (" <td rowspan='10'>\n");
	 }
	 else {
            &web_data (" <td rowspan='15'>\n");
	 }
         for ($ii=0;$ii<15;$ii++) {
          if ($sc->{COUV}[$ii] ne "")
          {
             $initiale = lc(substr($sc->{COUV}[$ii],0,1));
             if (($initiale ge '0') && ($initiale le '9')) {
                $initiale = "09";
             }
	     
             &web_data ("  <a class='cover expandable' href='<?php echo \$bdfi_url_couvs; ?>$initiale/$sc->{COUV}[$ii]'>\n");
             &web_data ("   <img src='<?php echo \$bdfi_url_couvs_medium; ?>$initiale/m_$sc->{COUV}[$ii]' alt='couverture' title=\"Couverture $sc->{TITRE_SEUL}\" />\n");
             &web_data ("  </a>\n");
           }
         }
         &web_data (" </td>\n");

         &web_data ("<td>");
         &web_data ("<input type='submit' value='$sc->{DATE}' />");
         &web_data ("</td></tr>\n");
 
         if ($sc->{NB_REED} < 11) {
            $iimax = 11;
	 }
	 else {
            $iimax = 16;
	 }
         for ($ii=1;$ii<$iimax;$ii++) {
            &web_data ("<tr><td>");
            if ($sc->{COUV}[$ii] ne "")
            {
               &web_data ("<input type='submit' value='$sc->{REED}[$ii-1]' />");
            }
	    else
            {
               &web_data ("&nbsp;");
            }
            &web_data ("</td></tr>\n");
         }
         &web_data ("</table>\n");
         &web_data ("</div>\n");
      }
      &web_data ("<a name=\"som$ix\">");
      &web_data ("</a>");
      &aff_titre($canal, $sc, 1);
#     &web_data ("<br />Publication : \n");
      &web_data ("<br />");
      &aff_support($canal, $sc, 1, \@sigles);

      #--- Affichage ISBN
      if ($sc->{ISBN_TYPE} eq 'NREF')
      {
         &web_data ("<br />Pas d'ISBN\n");
      }
      elsif ($sc->{ISBN_TYPE} eq 'INCONNU')
      {
         &web_data ("<!-- ISBN inconnu -->\n");
      }
      else
      {
         &web_data ("<br />ISBN : $sc->{ISBN}\n");
      }

      #--- Affichage genre
      &web_data ("<br />Genre : ");
      &web_data (genre($sc->{HG}, $sc->{G1}, $sc->{G2}));
      &web_data ("\n");

      #--- Affichage notes si existe
      if ($sc->{NOTES} ne '')
      {
         &web_data ("<div style='border-left: 1px solid grey; padding-left: 10px'>\n");
         &web_data ("<b>Notes : </b>");
         &web_data ($sc->{NOTES}); 
         &web_data ("</div>\n");
      }

      #--- Affichage indexation
      if (($sc->{COMPLET} ne '=') && ($sc->{COMPLET} ne '_') && ($sc->{COMPLET} ne 'k')) {
         &web_data ("<br /><i>Indexation :");
         if    ($sc->{COMPLET} eq 'i') { &web_data (" non r‚alis‚e"); }
         elsif ($sc->{COMPLET} eq 'p') { &web_data (" incomplŠte"); }
         else                          { &web_data (" non valid‚e"); }
         &web_data ("</i>\n");
      }
      if ($sc->{TYPE} eq "U") {
         &web_data ("<br />Sommaire du Fix-Up :\n");
      }
      else {
         &web_data ("<br />Sommaire :\n");
      }
      &web_data ("<ul>\n");
#print STDERR " $sc->{SOMMAIRE}  \n";
      if ($#{$sc->{SOMMAIRE}} + 1 == 0)
      {
         &web_data ("<li>(Contenu inconnu)</li>\n");
      }
      foreach $somm (@{$sc->{SOMMAIRE}})
      {
#print STDERR " $somm \n";
         &web_data ("<li>");
	 if ($somm->{HG} eq "C")
	 {
            &aff_section ($canal, $somm, 2); 
	 }
	 else
	 {
            &aff_titre ($canal, $somm, 2); 
	 }
         &web_data ("</li>\n");
      }
      &web_data ("</ul>\n</div>\n");
      $ix = $ix + 1;
   }
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
   $cwd = "/www/recueils/pages";
   &bdfi_upload($outf, $cwd);
}
#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#---------------------------------------------------------------------------
sub tri
{
   # ----------------------------------------------
   # l'ordre par d‚faut est : cycle puis date VO puis date Parution puis titre F
   # type de tri = 0 (defaut) cycle
   #  critere 1 = date de parution
   # ----------------------------------------------
   if (uc($a->{CYCLE}->{CP}) ne uc($b->{CYCLE}->{CP}))
   {
      uc($a->{CYCLE}->{CP}) cmp uc($b->{CYCLE}->{CP});
   }
   else
   {
      if ((uc($a->{CYCLE}->{IP}) ne "") && (uc($a->{CYCLE}->{IP}) ne 0) &&
         (uc($a->{CYCLE}->{IP}) ne uc($b->{CYCLE}->{IP})))
      {
         uc($a->{CYCLE}->{IP}) <=> uc($b->{CYCLE}->{IP});
      }
      else
      {
         if (uc($a->{VODATE}) ne uc($b->{VODATE}))
         {
            uc($a->{VODATE}) cmp uc($b->{VODATE});
         }
         else
         {
            if (uc($a->{VOTITRE}) ne uc($b->{VOTITRE}))
            {
               uc($a->{VOTITRE}) cmp uc($b->{VOTITRE});
            }
            else
            {
               if (uc($a->{DATE}) ne uc($b->{DATE}))
               {
                  uc($a->{DATE}) cmp uc($b->{DATE});
               }
               else
               {
                  # si ‚diteur identique, mettre d'abord num‚ro
                  if (uc($a->{COLL}) eq uc($b->{COLL   }))
                  {
                     uc($a->{NUM}) cmp uc($b->{NUM});
                  }
                  else
                  {
                     uc($a->{TITRE}) cmp uc($b->{TITRE});
                  }
               }
            }
         }
      }
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

