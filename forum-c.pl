$DBG=2;
$texte_debug = $DBG == 1 ? "Mode normal" : "Infos manquantes";

#===========================================================================
#
# Script de generation d'un post forum
#
#---------------------------------------------------------------------------
# Historique :
#  v0.1  - 02/05/2020 cr‚ation … partir de bibcoll
#  v0.2  - 20/02/2022 Remplacement du sommaire par un simple lien
#
#        Le besoin
#        - Simple, un fichier COL complet (quitte … en faire un temporaire)
#        - G‚n‚ration ‚cran + nom du fichier col avec extension .for
#        - Utilisation des balises bbCode
#        - Lien sur auteur, lien sur s‚rie, lien sur antho
#        - Prendre ‚galement les commentaires "non officiel" (… mettre dans une autre couleur)
#        - Afficher les ann‚es (les retrouver et afficher)
#
# WARNING : le fichier ne doit pas contenir de ligne vide ou de commentaire dans un "bloc" d'ouvrages (collection, ann‚e, sous-ensemble...)
#         toutes ligne "autre" (vide, commentaire, titre...) stoppe automatiquement le bloc d'affichage en cours et en red‚marre un nouveau
#
# Reste … faire :
#   [OK] traiter les lien PHP
#   [OK] g‚rer les sommaires via "notes...
#   [XX] g‚rer proprement les affichage de sommaires - le lien suffit
#   [XX] les afficher avant les couvs
#   [OK] afficher la plupart des trucs inconnus en couleur
#   [..] g‚rer proprement les modes ann‚e et/ou nombre max
#   [..] ne pas multiplier les affichages de lignes vides (1 seule suffit)
#   [..] Afficher les collections
#
#
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl forum-c <fichier col> :
#
#---------------------------------------------------------------------------
#
#
#---------------------------------------------------------------------------
#
#  TBD voir si on garde une partie de ce mat‚riel :
#
#    Utile par exemple :
#    !GRP_OUVR <nb>         (optionnel)
#    !TIT_COLL <titre>      (titre collection)
#    !IMG_LOGO <image>      (image(s) logo, optionnel)
#
#    !IMG_COLL <image>      (image(s) coll. complete ou autre vue, optionnel)
#
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";
$bdfi_url_couvs = "http://www.bdfi.info/couvs/";
$bdfi_url_couvs_vignettes = "http://www.bdfi.info/vignettes/";
$bdfi_url_couvs_medium = "http://www.bdfi.info/medium/";
$bdfi_url_auteurs = "http://www.bdfi.net/auteurs";
$bdfi_url_series = "http://www.bdfi.net/series/pages";
$bdfi_url_recueils = "http://www.bdfi.net/recueils/pages";

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
$isbn_start=36;                               $isbn_size=50;  # $isbn_size=17;

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
$reference_en_cours = "NON";
#   A chaque "o" => reference_en_cours="OUI"
#   A chaque ligne blanche => reference_en_cours="NON"
#   Si hors reference, on affiche directement tout commentaire
#   Sinon, on stocke

$contenu_en_cours = "NON"; # Pas utilis‚ pour l'instant

# pas utilis‚ ici mais dans bibantho : TBD voir si pas mieux
my $ref_en_cours="NOUV_REF";  # "NOUV_REF", "NUM_MULT", "FIN_SUPPORT", "COLLAB"

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------

my $type_tri=0;
my $no_coll=0;
my $old_date=0;
my $id_ouv=0;

my $taille_vignette ="MEDIUM";
my $max_couv_groupe=6;

sub usage
{
   print STDERR "usage : $0  <file .col>\n";
   print STDERR "\n";
   exit;
}

if ($ARGV[0] eq "")
{
   usage;
   exit;
}
$file_name = lc($ARGV[$0]);
$file_name =~ s/^ *//;
$file_name =~ s/ $//;
print "--- Fichier fourni [$file_name] \n";

$existf=1;
open (f_file, "<$file_name") or $existf=0;
if ($existf == 0)   # fichier inexistant
{
   print "fichier $file_name non trouv‚\n";
   exit;
}
@file=<f_file>;
close (f_file);

print "--- Le fichier existe, prˆt … d‚marrer... \n";

#---------------------------------------------------------------------------
# Ouverture fichiers de sortie
#---------------------------------------------------------------------------
$outh = $file_name;
$outh =~ s/\.txt//;
$outh =~ s/\.col//;
$outh =~ s/\....//;
$outh = $outh . ".for";
open (OUTH, ">$outh");
$CanalH=OUTH;

print "--- Sorties sur $outh\n";
print $CanalH "TIP Sublime Text : faire File -> Reopen with Encoding : DOS (CP 437)\n";


#
# Pour chaque ligne du fichier
#

$prefixe="";
$suffixe="";
$notes="";
@couvs=();
foreach $ligne (@file)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   $lig=~s/ +$//;
   chop ($lig);
   $len=length($lig);
   $prem=substr ($lig, 0, 1);

   # Fin d'ouvrage
 #   if ($len == 0) { next; }

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   # memo du type de ligne
   $debut=substr ($lig, 0, 9);

   if (($len == 0) || ($debut eq "!--------"))
   {
      #---------------------------
      # Ligne vide ou de s‚paration
      #  => on affiche la r‚f‚rence en cours, et/ou les notes, et les couvertures
      #---------------------------
      if ($reference_en_cours eq "OUI") {
         &affiche_reference ($reference, $notes);
         $notes = "";
      }
      elsif ($notes ne "")
      {
	 print $CanalH "$notes\n";
         $notes = "";
      }
      &affiche_couvertures (@couvs);
      @couvs=();
      $reference_en_cours = "NON";
      $contenu_en_cours = "NON";
      next;
   }
   elsif (substr($debut,0,5) eq "!=== ")
   {
      #---------------------------
      # Titre ou changement d'ann‚e => en gras. Mais d'abord...
      #  + on affiche la r‚f‚rence en cours, et/ou les notes, et les couvertures
      #---------------------------
      # Ligne vide
      if ($reference_en_cours eq "OUI") {
         &affiche_reference ($reference, $notes);
         $notes = "";
      }
      elsif ($notes ne "")
      {
         $notes = &affiche_notes ($notes);
      }
      &affiche_couvertures (@couvs);
      @couvs=();
      $reference_en_cours = "NON";
      $contenu_en_cours = "NON";

      print $CanalH "\n\n[b]" . substr($lig, 5) . "[/b]\n";
      next;
   }
   elsif (($prem eq '?') || ($prem eq '¨') || ($prem eq '­') || ($prem eq '*'))
   {
      #-----------------------------------------------------
      # Infos incompletes, a paraitre ou jamais paru
      #-----------------------------------------------------
      $prefixe="";
      if (substr($lig,1,1) eq 'o') {
         if ($prem eq '?') {
            $prefixe="[INS][b]Donn‚es … compl‚ter ou confirmer[/b][/INS] :";
         }
         elsif ($prem eq '¨') {
            $prefixe="[INS][b]Ouvrage … paraitre, ou parution … confirmer[/b][/INS] :";
         }
         elsif ($prem eq '­') {
            $prefixe="[INS][b]Ouvrage annonc‚ mais jamais paru[/b][/INS] :";
         }
         elsif ($prem eq '*') {
            $prefixe="[INS][b]Ouvrage dont l'appartenance aux genres est … confirmer[/b][/INS] :";
         }
      }
      # Recuperer le bon format par decalage
      #--------------------------------------
      if (((substr($lig, 2, 1) ne ' ') && (substr($lig, 1, 1) ne '>')) || ((substr($lig, 1, 1) eq '&') && (substr ($lig, $auttyp_start, 1) ne ' ')))
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
   }

   if (($debut eq "!IMG_LOGO") || ($debut eq "!IMG_COLL"))
   {
      # Affichage dans le descriptif des images de logo ou collection
      $couv=substr ($lig, 10);
      $couv=~s/ +$//o;
      $couv=~s/^ +//o;
      $couv=~s/\.jpg$//o;
      $couv=$couv . ".jpg";
      $initiale_couv=substr ($couv, 0, 1);
      $initiale_couv=lc($initiale_couv);
      if (($initiale_couv ge '0') && ($initiale_couv le '9')) {
         $initiale_couv='09';
      }
         
      if ($debut eq "!IMG_COLL") {
         print $CanalH "[url=${bdfi_url_couvs}${initiale_couv}/${couv}]";
         print $CanalH "[img]${bdfi_url_couvs_vignettes}${initiale_couv}/v_${couv}[/img][/url]\n";
      }
      else {
         print $CanalH "[img]${bdfi_url_couvs}${initiale_couv}/${couv}[/img]";
      }
   }
   elsif ($prem eq "_")
   {
      #-----------------------------------------------------
      # Si d‚finition de sigle : afficher le nom en titre
      #-----------------------------------------------------
      $sig=substr ($lig, 2, 7);
      $sig=~s/ +$//o;
      $reste_lig=substr ($lig, 10);
      ($edc, $periode)=split (/þ/,$reste_lig);
      $edc=~s/ +$//o;
      print $CanalH "[b]${edc}[/b] (sigle interne : ${sig})\n";
   }
   elsif ($prem eq ">")
   {
      #-----------------------------------------------------
      # Commentaire "Officiel"
      #-----------------------------------------------------
      $br=substr($lig, 3, 1);
      $lig=~s/^>-+\.* *//;
      $lig=~s#TBC#[INS][b]A confirmer[/b][/INS]#;
      $lig=~s#TBD#[INS][b]A d‚finir[/b][/INS]#;
      # si commentaire vide (!, - space), ou ligne vide : rien
      if ($br ne "-")
      {
         $notes = $notes . " $lig";
      }
      else
      {
         $notes = $notes . "\n    $lig";
      }
   }
   elsif ($prem eq "!")
   {
      #-----------------------------------------------------
      # Commentaire non "Officiel"
      #-----------------------------------------------------
      $br=substr($lig, 3, 1);
      $lig=~s/^!-+\.* *//;
      $lig=~s#TBC#[INS][b]A confirmer[/b][/INS]#;
      $lig=~s#TBD#[INS][b]A d‚finir[/b][/INS]#;
      # si commentaire vide (!, - space), ou ligne vide : rien
      if ($br ne "-")
      {
         $notes = $notes . " $lig";
      }
      else
      {
         $notes = $notes . "\n    (info) $lig";
      }
   }
   elsif (($prem eq "o") || ($prem eq "+"))
   {
      #-----------------------------------------------------
      # On affiche les ‚ventuelles commentaires pr‚c‚dents hors r‚f‚rences, s'il y en a...
      #-----------------------------------------------------
      if ($reference_en_cours eq "NON") {
         if ($notes ne "")
	 {
            $notes = &affiche_notes ($notes);
         }
      }

      #-----------------------------------------------------
      # >>> Ligne reference support
      # Collection : "+" peut être un premier ouvrage, si 
      #  les reeditions sont en collections (légèrement) différentes
      #-----------------------------------------------------

      #-----------------------------------------------------
      # Affichage de l'ouvrage précédent (si existe !!)
      #-----------------------------------------------------
      if ((($prem eq "o") && ($old_date != 0)) || (($prem eq "+") && ($reference->{NB_ED} ne "") && ($reference->{NB_ED} == 0))) {
         if ($reference_en_cours eq "OUI") {
            &affiche_reference ($reference, $notes);
            $notes = "";
         }
      }
      $reference_en_cours = "OUI";
      #-----------------------------------------------------
      # Nouvelle reference ou reedition
      #-----------------------------------------------------
      $coll=substr ($lig, $coll_start, $coll_size);
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
         $isbn = substr ($lig, $isbn_start, $isbn_size);
         $isbn=~s/^ +//o;
         $isbn=~s/ +$//o;
         if ($isbn eq "-") {
            $isbn="pas d'ISBN";
         }
         elsif ((substr ($isbn, -1, 1) eq ".") || ($isbn eq "?")) {
            $isbn="[INS][b]ISBN non renseign‚[/b][/INS]";
         }
         else {
            $isbn="ISBN " . substr ($lig, $isbn_start, $isbn_size);
         }
      }
      elsif (substr ($lig, $mark_start, $mark_size) eq 'ISBr')
      {
         $isbn = substr ($lig, $isbn_start, $isbn_size);
         $isbn=~s/^ +//o;
         $isbn=~s/ +$//o;
         if ($isbn eq "-") {
            $isbn="pas d'ISBN";
         }
         elsif ((substr ($isbn, -1, 1) eq ".") || ($isbn eq "?")) {
            $isbn="[INS][b]ISBN non renseign‚[/b][/INS]";
         }
         else {
            $isbn="((ISBN " . substr ($lig, $isbn_start, $isbn_size) . " r‚troactif))";
         }
      }

      $num=substr ($lig, $num_start, $num_size);
      $num=~s/ +$//o;
      $num=~s/^ +//o;
      $typnum=substr ($lig, $typnum_start, 1);
      if ($num ne '?')
      {
         if ($typnum eq 'q')
         {
            $num = "($num)";
         }
         elsif ($typnum eq 'i')
         {
            $num = "($num)";
         }
         else
         {
            $num = "$num";
         }
      }
      else
      {
         $num = "";
      }

      if (($prem eq "o") || (($prem eq "+") && ($reference->{NB_ED} == 0)))
      {
         $reference = {
           ISBN=>"$isbn",
           COLL=>"$coll",
           DATE=>"$date",
           MOIS=>"$mois",
           NB_ED=>1,
           NB_REED=>0,
           REED=>["","","","","","","","","",""],
           NUM=>"$num",
           TYPNUM=>"$typnum",
           GENRE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           TYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           CYCLE=>"",
           INDICE=>0,
           CYCLE_S=>"",
           INDICE_S=>0,
           CONTRIB=>"",
           NB_AUTEUR=>0,
           AUTEUR=>["","","","","","","","","","","","","","",""],
           NB_ANTHOLOG=>0,
           ANTHOLOG=>["","","","","","","","","",""],
           NB_TRAD=>0,
           TRAD=>["","","","",""],
           CMT_TYPE=>"",
           JAI=>"$jai",
           PREFIXE=>"$prefixe",
           SUFFIXE=>"",
           AFFTYPE=>"",
         };
         $prefixe="";
         $reed=0;
      }
      else
      {
         $reed=1;
         #-----------------------------------------------------
         # Reedition
         #-----------------------------------------------------
         if ($reference->{NB_REED} < 10)
         {
            $reference->{REED}[$reference->{NB_REED}] = "$mois.$date";
            $reference->{NB_REED} = $reference->{NB_REED} + 1;
         }
         # FAIRE : else erreur
      }
      
      # FAIRE : subroutine purge couvertures, appeller ici ou si titre
      # Afficher toutes les couvertures
      #  - si date diff‚rente de la pr‚c‚dente
      # ou (exclusif)
      #  - si limite groupe (groupe != 0 et nb=groupe)
      $nbim=@couvs;
      if ((($max_couv_groupe == 0) && ($reference->{DATE} ne $old_date)) ||
          (($max_couv_groupe != 0) && ($nbim >= $max_couv_groupe) && ($reed == 0))) {
         while ($couv = shift(@couvs))
         {
            print $CanalH ${couv};
         }
@couvs=();
         if ($nbim != 0) {
            print $CanalH " \n\n";
         }
#        Ce traitement comment‚ permet d'afficher la nouvelle ann‚e sans titre ann‚e existant dans le fichier (automatique)
#        if ($max_couv_groupe == 0) {
#           print $CanalH " \n\n";
#           print $CanalH " [b] $reference->{DATE} [/b]\n\n";
#        }
         if (($max_couv_groupe == 0) || ($nbim != 0)) {
            print $CanalH " \n";
         }
      }
      $old_date=$reference->{DATE};
   }
   elsif (($prem eq ":") || ($prem eq "="))
   {
       # le sommaire doit ˆtre ajout‚s dans les notes !
       # 20/02/2022 - retrait du sommaire, le lien suffit
       # $notes = $notes . "\n     -> (sommaire) $lig";
   }
   elsif ($prem eq "/")
   {
      #-----------------------------------------------------
      # Numero multiple
      #-----------------------------------------------------
      $new_num=substr ($lig, $num_start, $num_size);
      $new_num=~s/ +$//o;
      $new_num=~s/^ +//o;
      $num .= "-" . "$new_num";
      $reference->{NUM} = $num;
   }
   elsif ($prem eq '}')
   {
      #-----------------------------------------------------
      # Image couverture
      #-----------------------------------------------------
      ($couv, $illustrateur, $dessinateurs) = &extract_couv ($ligne);

      $initiale_couv=substr ($couv, 0, 1);
      $initiale_couv=lc($initiale_couv);
      $reference->{COUV}[$reference->{NB_REED}] = "$couv";
      if (($initiale_couv ge '0') && ($initiale_couv le '9')) {
         $initiale_couv='09';
      }
      if ($taille_vignette eq "PETIT") {
         push (@couvs, "  [url=${bdfi_url_couvs}${initiale_couv}/${couv}][img]${bdfi_url_couvs_vignettes}${initiale_couv}/v_${couv}[/img][/url]");
      }
      else { # "MEDIUM"
         push (@couvs, "  [url=${bdfi_url_couvs}${initiale_couv}/${couv}][img]${bdfi_url_couvs_medium}${initiale_couv}/m_${couv}[/img][/url]");
      }

      $reference->{ILLU}[$reference->{NB_REED}] = "$illustrateur";
      $reference->{DESS}[$reference->{NB_REED}] = "$dessinateurs";
      next;
   }
   elsif (($prem eq '-') || ($prem eq '&'))
   {
      $reference->{NB_ED} = 0;  #--- Reset indicateur reedition
      #-----------------------------------------------------
      # Contenu ou sous-contenu, collaboration ...
      #-----------------------------------------------------
      $auteur=substr ($lig, $author_start, $author_size);
      $auteur=~s/\&$//;
      $auteur=~s/ +$//;
      $auteur=~s/^ +//;

      if ($prem ne '&') {
         $genre=substr ($lig, $genre_start, 1);
         $g1=substr ($lig, $genre_start+1, 1);
         $g2=substr ($lig, $genre_start+2, 1);
         $type_c=substr ($lig, $type_start, $type_size);
         $type=substr ($type_c, 0, 1);
         $stype=substr ($type_c, 1, 2);
         $type_c=~s/ +$//;
         $stype=~s/ +$//;

         ($auteur, $titre, $vodate, $votitre, $trad) = decomp_reference ($lig);

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

         $reference->{GENRE} = "$genre";
         $reference->{TITRE} = "$titre";
         $reference->{TITRE_SEUL} = "$titre_seul";
         $reference->{TYPE} = "$type";
         $reference->{VODATE} = "$vodate";
         $reference->{VOTITRE} = "$votitre";
         $reference->{CYCLE} = "$cycle";
         $reference->{INDICE} = $indice_cycle;
         $reference->{CYCLE_S} = "$scycle";
         $reference->{INDICE_S} = $indice_scycle;

         # Recherche des anthologistes (marque '*' devant)
         if (substr ($lig, $auttyp_start, 1) eq '*')
         {
            $reference->{NB_AUTEUR} = 0;
            $reference->{NB_ANTHOLOG} = 1;
            $reference->{ANTHOLOG}[0] = "$auteur";
   #        print STDERR "antho : $auteur\n";
         }
         else
         {
            $reference->{NB_ANTHOLOG} = 0;
            $reference->{NB_AUTEUR} = 1;
            $reference->{AUTEUR}[0] = "$auteur";
   #        print STDERR "auteur : $auteur\n";
         }
      
         $stype=~s#x# [INS][b]x[/b][/INS] #;
         if    (($type eq 'U') && ($stype eq "")) { $afftype="FixUp"; }
         elsif (($type eq 'U') && ($stype ne "")) { $afftype="FixUp recueil"; }
         elsif (($type eq 'N') && ($stype ne "")) { $afftype="Recueil"; }
         elsif (($type eq 'N') && ($stype eq "")) { $afftype="Nouvelle"; }
         elsif (($type eq 'C') && ($stype ne "")) { $afftype="Chroniques"; }
         elsif (($type eq 'T') && ($stype eq "")) { $afftype="PiŠce de th‚ƒtre"; }
         elsif (($type eq 'T') && ($stype ne "")) { $afftype="PiŠces de th‚ƒtre"; }
         elsif (($type eq 'R') && ($stype eq "")) { $afftype="Roman"; }
         elsif (($type eq 'R') && ($stype eq "N")) { $afftype="Recueil"; }
         elsif (($type eq 'R') && ($stype eq "2")) { $afftype="Recueil"; }
         elsif (($type eq 'R') && ($stype ne "")) { $afftype="Omnibus"; }
         elsif (($type eq 'X') && ($stype eq "")) { $afftype="Extrait"; }
         elsif (($type eq 'F') && ($stype eq "")) { $afftype="Novelisation"; }
         elsif (($type eq 'V') && ($stype eq "")) { $afftype="Novelisation de jeu vid‚o"; }
         elsif (($type eq 'r') && ($stype eq "")) { $afftype="Novella"; }
         elsif (($type eq 'r') && ($stype eq "2")) { $afftype="Deux Novellas"; }
         elsif (($type eq 'r') && ($stype ne "")) { $afftype="Recueil"; }
         elsif (($type eq 'E') && ($stype eq "")) { $afftype="Essai"; }
         elsif (($type eq 'J') && ($stype eq "")) { $afftype="Jeu"; }
         elsif (($type eq 'A') && ($stype ne "")) { $afftype="Anthologie"; }
         elsif (($type eq 'P') && ($stype ne "")) { $afftype="Poemes"; }
         elsif (($type eq 'P') && ($stype eq "")) { $afftype="Poeme"; }
         elsif (($type eq 'T') && ($stype ne "")) { $afftype=$type_c; }
         elsif (($type eq 'T') && ($stype eq "")) { $afftype="Piece"; }
         elsif (($type eq 'M') && ($stype ne "")) { $afftype="Revue"; }
         elsif (($type eq 'p') && ($stype eq "")) { $afftype="Pr‚face"; }
         elsif (($type eq 'o') && ($stype eq "")) { $afftype="Postface"; }
         elsif (($type eq 'a') && ($stype eq "")) { $afftype="Article"; }
         elsif (($type eq 'h') && ($stype eq "")) { $afftype="Chronique"; }
         elsif (($type eq 'b') && ($stype eq "")) { $afftype="Biographie"; }
         elsif (($type eq 'B') && ($stype eq "")) { $afftype="Bibliographie"; }
         elsif (($type eq 'I') && ($stype eq "")) { $afftype="Interview"; }
         elsif (($type eq '.') || ($type eq ".")) { $afftype="?"; }
         elsif ($stype eq "") { $afftype=$type_c; }
         elsif ($stype ne "") { $afftype=$type_c; }
         $reference->{AFFTYPE} = "$afftype";

         if ($genre eq "?")
         {
            if (substr($lig,1,1) eq 'o') {
               $prefixe="Ouvrage dont l'appartenance aux genres est [INS][b]… confirmer[/b][/INS] :";
               $reference->{PREFIXE} = "$prefixe";
               $suffixe=" [Appartenance aux genre [INS][b]a d‚terminer[/b][/INS]]";
            }
         }
         elsif ($genre eq "x")
         {
            $suffixe=" [Hors genres]";
         }
         elsif ($genre eq "!")
         {
            $suffixe=" [Hors genres]";
         }
         elsif ($genre eq "p")
         {
            $suffixe=" [Partiellement hors genres]";
         }
         else { $suffixe=""; }

         if    ($g1 eq 'A') { $suffixe = $suffixe . " aventure"; }
         elsif ($g1 eq 'B') { $suffixe = $suffixe . " thriller"; }
         elsif ($g1 eq 'C') { $suffixe = $suffixe . " chevalerie"; }
         elsif ($g1 eq 'D') { $suffixe = $suffixe . " guerre"; }
         elsif ($g1 eq 'E') { $suffixe = $suffixe . " espionnage"; }
         elsif ($g1 eq 'F') { $suffixe = $suffixe . " fantastique"; }
         elsif ($g1 eq 'G') { $suffixe = $suffixe . " gore"; }
         elsif ($g1 eq 'H') { $suffixe = $suffixe . " historique"; }
         elsif ($g1 eq 'I') { $suffixe = $suffixe . " SF-F-F"; }
         elsif ($g1 eq 'J') { $suffixe = $suffixe . " humour"; }
         elsif ($g1 eq 'K') { $suffixe = $suffixe . " insolite, ‚trange"; }
         elsif ($g1 eq 'L') { $suffixe = $suffixe . " mainstream"; }
         elsif ($g1 eq 'M') { $suffixe = $suffixe . " merveilleux, conte de f‚e"; }
         elsif ($g1 eq 'N') { $suffixe = $suffixe . " contes et l‚gendes"; }
         elsif ($g1 eq 'O') { $suffixe = $suffixe . " Mythologie, l‚gendes"; }
         elsif ($g1 eq 'P') { $suffixe = $suffixe . " policier"; }
         elsif ($g1 eq 'Q') { $suffixe = $suffixe . " ‚rotique"; }
         elsif ($g1 eq 'R') { $suffixe = $suffixe . " romance"; }
         elsif ($g1 eq 'S') { $suffixe = $suffixe . " SF"; }
         elsif ($g1 eq 'T') { $suffixe = $suffixe . " terreur"; }
         elsif ($g1 eq 'U') { $suffixe = $suffixe . " fusion"; }
         elsif ($g1 eq 'V') { $suffixe = $suffixe . " r‚alisme magique"; }
         elsif ($g1 eq 'W') { $suffixe = $suffixe . " western"; }
         elsif ($g1 eq 'X') { $suffixe = $suffixe . " porno"; }
         elsif ($g1 eq 'Y') { $suffixe = $suffixe . " fantasy"; }
         elsif ($g1 eq 'Z') { $suffixe = $suffixe . " Pr‚historic Fiction"; }
         elsif ($g1 eq '-') { $suffixe = $suffixe . " texte"; }
         elsif (($g1 eq '?')
             || ($g1 eq '.')
             || ($g1 eq ' ')) {
            $suffixe = $suffixe . " [INS][b][Genre(s) ?][/b][/INS]";
         }
         else               { $suffixe = $suffixe . " [INS][b][genre (" . $g1 . ") inconnnu !][/b][/INS]"; }

         if (($g2 ne " ") && ($g2 ne "."))
         {
            if ($g2 eq 'A')    { $suffixe = $suffixe . ", aventure"; }
            elsif ($g2 eq 'B') { $suffixe = $suffixe . ", thriller"; }
            elsif ($g2 eq 'C') { $suffixe = $suffixe . ", chevalerie"; }
            elsif ($g2 eq 'D') { $suffixe = $suffixe . ", guerre"; }
            elsif ($g2 eq 'E') { $suffixe = $suffixe . ", espionnage"; }
            elsif ($g2 eq 'F') { $suffixe = $suffixe . ", fantastique"; }
            elsif ($g2 eq 'G') { $suffixe = $suffixe . ", gore"; }
            elsif ($g2 eq 'H') { $suffixe = $suffixe . ", historique"; }
            elsif ($g2 eq 'I') { $suffixe = $suffixe . ", SF-F-F"; }
            elsif ($g2 eq 'J') { $suffixe = $suffixe . ", humour"; }
            elsif ($g2 eq 'K') { $suffixe = $suffixe . ", insolite, ‚trange"; }
            elsif ($g2 eq 'L') { $suffixe = $suffixe . ", mainstream"; }
            elsif ($g2 eq 'M') { $suffixe = $suffixe . ", merveilleux, conte de f‚e"; }
            elsif ($g2 eq 'N') { $suffixe = $suffixe . ", contes et l‚gendes"; }
            elsif ($g2 eq 'O') { $suffixe = $suffixe . ", Mythologie, l‚gendes"; }
            elsif ($g2 eq 'P') { $suffixe = $suffixe . ", policier"; }
            elsif ($g2 eq 'Q') { $suffixe = $suffixe . ", ‚rotique"; }
            elsif ($g2 eq 'R') { $suffixe = $suffixe . ", romance"; }
            elsif ($g2 eq 'S') { $suffixe = $suffixe . ", SF"; }
            elsif ($g2 eq 'T') { $suffixe = $suffixe . ", terreur"; }
            elsif ($g2 eq 'U') { $suffixe = $suffixe . ", fusion"; }
            elsif ($g2 eq 'V') { $suffixe = $suffixe . ", r‚alisme magique"; }
            elsif ($g2 eq 'W') { $suffixe = $suffixe . ", western"; }
            elsif ($g2 eq 'X') { $suffixe = $suffixe . ", porno"; }
            elsif ($g2 eq 'Y') { $suffixe = $suffixe . ", fantasy"; }
            elsif ($g2 eq 'Z') { $suffixe = $suffixe . ", Pr‚historic Fiction"; }
            elsif ($g2 eq '-') { $suffixe = $suffixe . ", texte"; }
            else               { $suffixe = $suffixe . " [genre (" . $g2 . ") inconnnu !]"; }
         }
         $reference->{SUFFIXE} = "$suffixe";
      }
      else
      {
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
      print $CanalH "inconnu _[$prem]_ : $lig\n";
      print "inconnu _[$prem]_ : $lig\n";
   }
}

# Fin d'ouvrage (fin de format table)
if ($reference_en_cours eq "OUI") {
   &affiche_reference ($reference, $notes);
   $notes = "";
}
print $CanalH "\n";

if ($nbim=@couvs ne 0) {
   while ($couv = shift(@couvs))
   {
      print $CanalH ${couv};
   }
}


close (OUTH);

#---------------------------------------------------------------------------
# Affichage d'une reference
#---------------------------------------------------------------------------
sub affiche_reference {
   local($ref)=$_[0];
   local($notes)=$_[1];

      # Fin d'ouvrage pr‚c‚dent (si existe !!)
      # Toutes les impressions devraient être ici !
      #   x num‚ro
      #   x ann‚e
      #   x  + ann‚e r‚‚d
      #   X auteur
      #   X  + auteurs collab
      #   X titre fr, vo
      #   - notes

   #-----------------------------------------------------
   # Prefixe :
   #-----------------------------------------------------
   local($prefixe)=$ref->{PREFIXE};
   if (($prefixe ne "") && ($prefixe ne " ")) {
       print $CanalH "  [b]${prefixe}[/b]\n";
   }

   #-----------------------------------------------------
   # Support : numero, annee, reeditions
   #-----------------------------------------------------
   local($num)=$ref->{NUM};
   local($date)=$ref->{DATE};
   local($mois)=$ref->{MOIS};
   $id_ouv += 1;
   if ($num ne "") {
     print $CanalH " $num - ";
   }
   else
   {
     print $CanalH " ";
   }

#  if ($max_couv_groupe != 0) {
   print $CanalH &formate_moisdate ($mois, $date);

#  }
   if ($ref->{NB_REED} != 0)
   {
      print $CanalH " (r‚‚d. ";
      $moisdate=$ref->{REED}[0];
      $mois=substr($moisdate, 0, 2);
      $date=substr($moisdate, 3, 4);
      print $CanalH &formate_moisdate ($mois, $date);

      $nb_reed = 1;
      while ($nb_reed < $ref->{NB_REED})
      {
         $moisdate=$ref->{REED}[$nb_reed];
         $mois=substr($moisdate, 0, 2);
         $date=substr($moisdate, 3, 4);
         print $CanalH ", " . &formate_moisdate ($mois, $date);
         $nb_reed++;
      }
      print $CanalH  ")";
   }
   print $CanalH  " - ";

   #-----------------------------------------------------
   # Auteurs et anthologistes
   #-----------------------------------------------------
   local($nb_aut) = 0;
   while ($nb_aut < $ref->{NB_AUTEUR})
   {
      if (($auteur eq "?") || ($auteur eq "?"))
      {
         print $CanalH "[INS][b]Auteur(s) ?[/b][/INS] \n";
      }
      # nom du lien, et initiale
      $lien_auteur=&url_auteur($ref->{AUTEUR}[$nb_aut]);
      $initiale_lien=substr ($lien_auteur, 0, 1);
      $initiale_lien=lc($initiale_lien);
   
      # mot intermediaire : ", " /  " et "
      if ($nb_aut != 0) {
         if ($nb_aut+1 == $ref->{NB_AUTEUR}) { print $CanalH " et "; }
         else { print $CanalH ", "; }
      }
      print $CanalH "[url=${bdfi_url_auteurs}/${initiale_lien}/${lien_auteur}.php]";
      print $CanalH $ref->{AUTEUR}[$nb_aut];
      print $CanalH "[/url] ";

      $nb_aut++;
   }
   local($nb_anth) = 0;
   while ($nb_anth < $ref->{NB_ANTHOLOG})
   {
      if ($auteur ne '***') {
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($ref->{ANTHOLOG}[$nb_anth]);
         $initiale_lien=substr ($lien_auteur, 0, 1);
         $initiale_lien=lc($initiale_lien);
   
         #mot intermediaire : ", " /  " et "
         if (($nb_anth == 0) && ($ref->{NB_ANTHOLOG} > 1)) { 
            if ($nb_aut != 0) { print $CanalH ", anthologistes "; }
            else { print $CanalH " Anthologistes "; }
         }
         elsif ($nb_anth == 0) {
            if ($nb_aut != 0) { print $CanalH ", anthologiste "; }
            else { print $CanalH " Anthologiste "; }
         }
         elsif ($nb_anth+1 == $ref->{NB_ANTHOLOG}) { print $CanalH " et "; }
         else  { print $CanalH ", "; }

         print $CanalH " [url=${bdfi_url_auteurs}/${initiale_lien}/${lien_auteur}.php]";
         print $CanalH $ref->{ANTHOLOG}[$nb_anth];
         print $CanalH "[/url] ";
      }
      else
      {
         print $CanalH " Anthologie ";
      }
      $nb_anth++;
   }

   #-----------------------------------------------------
   # Titre, vo , cycles
   #-----------------------------------------------------
   local($titre)=$ref->{TITRE};
   local($titre_seul)=$ref->{TITRE_SEUL};
   local($cycle)=$ref->{CYCLE};
   local($indice)=$ref->{INDICE};
   local($scycle)=$ref->{CYCLE_S};
   local($indice_scycle)=$ref->{INDICE_S};
 
   print $CanalH  " - ";
   if (($titre_seul eq "?") || ($titre_seul eq "?"))
   {
      print $CanalH " [INS][b]Titre ?[/b][/INS] ";
   }
   else
   {
         $antho = (($ref->{AFFTYPE} eq "Recueil"
		 || $ref->{AFFTYPE} eq "Anthologie"
		 || $ref->{AFFTYPE} eq "Omnibus"
		 || $ref->{AFFTYPE} eq "Chroniques"
		 || $ref->{AFFTYPE} eq "PiŠces de th‚ƒtre"
		 || $ref->{AFFTYPE} eq "FixUp recueil") ? 1 : 0);
         
         # Si anthologie, chercher idrec
         if ($antho == 1) {
            $idrec=idrec($titre_seul, $cycle, $scycle);
            $url_antho=url_antho($idrec);
            $url_antho="${url_antho}.php";
            print $CanalH " [b][url=${bdfi_url_recueils}/${url_antho}]${titre_seul}[/url][/b]";
         }
         else {
            print $CanalH " [b]${titre_seul}[/b]";
         }
   }
   if ($cycle ne "")
   {
      # nom du lien sur le cycle
      $lien_serie=&url_serie($cycle);
      $lien_serie="${lien_serie}.php";
      print $CanalH " [[url=${bdfi_url_series}/${lien_serie}]";
      if ($titre_seul ne $cycle) {
         print $CanalH "$cycle";
      }
      else {
         print $CanalH "*";
      }
      print $CanalH "[/url]";
      if ($indice_cycle ne "")
      {
         print $CanalH " - $indice_cycle";
      }
      print $CanalH "]";
   }
   if ($scycle ne "")
   {
      # Pas de lien pour l'instant
      # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
      print $CanalH " [${scycle}";
      if ($indice_scycle ne "")
      {
         print $CanalH " - $indice_scycle";
      }
      print $CanalH "]";
   }
   print $CanalH " (" . &formate_annee($vodate);
   if ($votitre ne "")
   {
      print $CanalH ", " . &formate_titre($votitre);
   }
   else
   {
      print $CanalH ")\n";
   }
   if ($ref->{SUFFIXE} eq " [Hors genres]") {
      print $CanalH " - Hors genres\n";
   }

   #-----------------------------------------------------
   # Infos supplementaires : trad, isbn, type, genre
   #-----------------------------------------------------
   # type : afftype : A FAIRE (integr. dans structure reference)
   #-----------------------------------------------------

   # Indication type d'ouvrage
   local($afftype)=$ref->{AFFTYPE};
   print $CanalH "   [i]";
   if ($afftype eq '?')
   {
      print $CanalH " [INS][b]Type ?[/b][/INS] ";
   }
   else
   {
      print $CanalH "$afftype";
   }

   # Indication ISBN
   local($isbn)=$ref->{ISBN};
   print $CanalH " - $isbn";

   # Indication traducteur
   if ($trad eq 'Trad. ?')
   {
       print $CanalH " - [INS][b]${trad}[/b][/INS] ";
   }
   elsif ($trad ne "")
   {
       print $CanalH " - $trad ";
   }

   # Indication couverture premiŠre ‚dition
   # TO DO A FAIRE ICI : … corriger, on afficherait la derniŠre ‚dition
   local($couv)=$ref->{ILLU}[$reference->{NB_REED}];
   $couv=~s/^_//;
   if ($couv eq '?')
   {
      print $CanalH " - [INS][b]Couverture : ${couv}[/b][/INS]";
   }
   else
   {
      print $CanalH " - Couverture : ${couv}";
   }


   # Indication genre
   local($suffixe)=$ref->{SUFFIXE};
   print $CanalH " - Genre : $suffixe";

   # TO DO A FAIRE ICI : … corriger, on afficherait la derniŠre ‚dition
   # ici, avant les notes, cr‚er une ligne par r‚‚dition et afficher : R‚‚dition <ann‚e> - ISBN <XXX> / <Pas d'ISBN> - Couverture <XXX>

   # Afficher notes
   if ($notes ne '') {
#     print $CanalH "\n";
      print $CanalH "$notes";
   }

   print $CanalH "[/i]\n";
}

# --- fin ---

#---------------------------------------------------------------------------
# Subroutine affiche notes
#---------------------------------------------------------------------------
sub affiche_notes {
   local($notes)=$_[0];

   print $CanalH "$notes\n";
   return "";
}

#---------------------------------------------------------------------------
# Subroutine affiche couvertures
#---------------------------------------------------------------------------
sub affiche_couvertures {
   local(@couvs)=@_;

   if ($nbim=@couvs ne 0) {
      while ($couv = shift(@couvs))
      {
         print $CanalH ${couv};
      }
   }
}

sub formate_moisdate {
   local($mois)=$_[0];
   local($annee)=$_[1];

   $mm=$mois;
   $aa=$annee;
   if (($annee eq 'xxxx') || ($annee eq '?') || ($annee eq '????') || (substr($annee, -1, 1) eq '?') || (substr($annee, -1, 1) eq '.'))
   {
       $aa="[INS][b]${aa}[/b][/INS]";
   }
   if (($mois eq 'xx') || ($mois eq '??'))
   {
       $mm="[INS][b]${mm}[/b][/INS]";
   }
   return "[color=blue]${mm}/${aa}[/color]";
}
sub formate_annee {
   local($annee)=$_[0];
   if ($annee eq '?')
   {
      return "[INS][b]????[/b][/INS]";
   }
   else
   {
      return "[color=blue]${annee}[/color]";
   }
}
sub formate_titre {
   local($titre)=$_[0];
   if ($titre eq '?')
   {
      return "[INS][b]???[/b][/INS]";
   }
   else
   {
      return $titre;
   }
}
