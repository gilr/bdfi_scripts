# ------------------------------------------------------------
# 
#   25/12/23 V  2 : Gestion des s‚ries "telle qu'imprim‚es sur le livre"
#   29/12/23 V  3 : Gestion de collection + sous-collection
#   30/12/23 V  4 : Gestion (c) FR, et init de ce copyright avec date publi si ouvrage non fr (pas bon, mais mieux que date VO)
#   31/12/23 V  5 : Gestion traducteurs complŠte
#   14/01/24 V  6 : Gestion feuilletons
#   16/01/24 V  7 : Simulation de plusieurs images - A revoir si besoin (plusieurs images de suite au format "}"
#   16/01/24 V  8 : Retrait des "SERIALS" de la liste des ouvrages + indication morceau feuilleton
#   31/01/24 V  9 : Pr‚paration pour ‚viter les doublons -> solution 1 ci-dessous. La solution 2 sera n‚cessaire pour les ajouts aprŠs premier seeding
#   03/02/24 V 10 : Gestion de l'ordonnancement des s‚rie
#   04/02/24 V 11 : traducteurs : pour l'instant format "NOM Pr‚nom" pour ˆtre en ligne avec recherche variants -> fichier variant … mettre … jour si changement
#                   + r‚vision des types (de contenu principal) d'ouvrage
#   ../02/24 V 12 : nettoyage v‚rifi‚ ou non, dimensions & co
#
#   ../02/24 V 13 : TBD les traducteurs et illustrateurs : quel format envoyer pour mise en base ?
#
# ------------------------------------------------------------
#
#    Solution 1 : arriver … exclure les doublons de titre, et retrouver le nø ID rempla‡ant
#        => pas d'impact PHP
#        => arriver … retrouver lors d'un traitement titre, si le titre existe d‚j… dans le json g‚n‚r‚, et si les auteurs sont les mˆmes !
#        ... difficile... … moins de cr‚er un fichier de travail r‚utilisable comprenant la ligne -> done
#
#    Solution 2 : pas de modification perl, mais impact PHP : les exclure lors du seeder, et il faut pouvoir retrouver le rempla‡ant … ce moment-l…
#        titles -> titles.json  -> il y a des doublons
#        	                    /!\ Mais attention, avec auteurs identiques, sachant que les auteurs sont dans le json suivant !
#                                  ... 2.1 les exclure lors du seeder
#                                  ... 2.2 les exclure lors du seeder, et cr‚er un fichier des doublons (id existant, nouvel id remplac‚)
#        auttit -> aut_tit.json -> si doublon, il suffit d'exclure dans le seeder les id de titre non trouv‚s en base
#        cyctit -> cyc_tit.json -> si doublon, pas grave, suffit d'exclure dans le seeder les id de titre non trouv‚s en base
#        pubtit -> pub_tit.json -> Ici le plus difficile
#                                   ... 2.1 rechercher si exactement identique existe (implique de v‚rifier aussi les auteurs)
#                                   ... 2.2 utiliser le fichier cr‚‚ lors de l'import des titres pour remplacer l'id courant de titre par celui existant en base
# ------------------------------------------------------------
#
# [OK] Mettre en commentaire si traduction r‚vis‚e
# [OK] Inverser le nom / pr‚nom des traducteurs
# [OK] G‚rer la chaŒne complŠte des traducteurs (' + ', ' et ', ' & ')
#
# [OK] Temporaire (pour aller plus vite) : un seul fichier col (copi‚ dans ouvrages.imp)
# [OK] Tester avec plusieurs fichier COL
# [OK] Test avec un fichier interm‚diaire de plusieurs COL
# [..] Revenir au fichier ouvrages complet
#
# --- R‚cup‚ration des publications
# [OK] Zapper les lignes '&' si ligne "incluse" (ne garder que les "-")
# [OK] Ajouter lien ‚diteur
# [OK] Ajouter lien collection si existe
# [OK] Spliter les titres et cycles -> dans un second champs (… cr‚er si not existant)
# [OK] Revoir la r‚cup cover, illustrators et cover_front
# [OK] R‚cup‚rer le num‚ro dans la collection si existe
# [OK] Titres et cycles => prendre le plus petit (?)
# [OK] Attacher les auteurs
# [OK] Ajout des infos "verified" et "verified_by"
# [OK] Ajout des autres paginations (dernier num‚ro imprim‚, pagination totale)
#
# --- R‚cup‚ration des titres
# [OK] R‚cup‚ration simple titre, cr‚ation du fichier de seed json
# [OK] Pr‚voir de stocker le titre "collection" (page=NULL) et les titres inclus (pages, ou alors o1 o2 o3 etc)
# [..] Pour les titres, il faudra aussi utiliser les "ALIAS RECUEIL" ...
# [OK] Attacher les auteurs
#
# --- R‚cup‚ration des liens titres - cycles
# [OK] Cr‚er le lien titre - cycle (une fois la table cr‚‚e)
# [..] Cr‚er les liens multiples titre - cycle (si plusieurs cycles)
# [..] ...
#
# --- Et les sommaires
# [OK] Pour les titres, il faudra aussi utiliser les "ALIAS RECUEIL" ...
#
#
# [..] Faire une comparaison / bibantho pour r‚cup des infos
#

push  (@INC, "c:/util/");
require "bdfi.pm";
# require "auteurs.pm";
# require "affiche.pm";
# require "home.pm";
# require "html.pm";


# Soit ajouter les commentaires dans ouvrages.res, soit cr‚er un ouvrages.imp
#   qui contient les commentaires ">---" / ">--." ainsi que les "!---"

# ouvrir ouvrages.col (ou plut“t ouvrages.imp)
#
# Pour chaque ligne … partir d'un "^o", jusqu'… nouvel "o" (sera … revoir lors de l'import textes)
#

# Ouverture du fichier stockant les ID de collection
# /!\ Attention … revoir complŠtement si attach‚ aux ‚diteurs, et collection optionnelle
$idcoll="E:/sf/sigles.id";
open (f_sig, "<$idcoll");
@idcolls=<f_sig>;
close (f_sig);
# Ouverture du fichier stockant les ID d'auteurs
$idaut="E:/laragon/www/bdfi-v2/storage/app/auteurs.id";
open (f_aut, "<$idaut");
@idauts=<f_aut>;
close (f_aut);
# Ouverture du fichier stockant les ID de series
$idcyc="E:/sf/cycles.id";
open (f_cyc, "<$idcyc");
@idcycs=<f_cyc>;
close (f_cyc);


# Ouverture des canaux JSON de sortie en cr‚ation-‚criture
$pubs="E:/laragon/www/bdfi-v2/storage/app/publications.json";
open (PUBS, ">$pubs");
$file_pubs=PUBS;
print $file_pubs "[\n";

$reprints="E:/laragon/www/bdfi-v2/storage/app/reprints.json";
open (REPRINTS, ">$reprints");
$file_reprints=REPRINTS;
print $file_reprints "[\n";

$colpub="E:/laragon/www/bdfi-v2/storage/app/col_pub.json";
open (COLPUB, ">$colpub");
$file_colpub=COLPUB;
print $file_colpub "[\n";

$autpub="E:/laragon/www/bdfi-v2/storage/app/aut_pub.json";
open (AUTPUB, ">$autpub");
$file_autpub=AUTPUB;
print $file_autpub "[\n";

$titles="E:/laragon/www/bdfi-v2/storage/app/titles.json";
open (TITLES, ">$titles");
$file_titles=TITLES;
print $file_titles "[\n";

$auttit="E:/laragon/www/bdfi-v2/storage/app/aut_tit.json";
open (AUTTIT, ">$auttit");
$file_auttit=AUTTIT;
print $file_auttit "[\n";

$pubtit="E:/laragon/www/bdfi-v2/storage/app/pub_tit.json";
open (PUBTIT, ">$pubtit");
$file_pubtit=PUBTIT;
print $file_pubtit "[\n";

$cyctit="E:/laragon/www/bdfi-v2/storage/app/cyc_tit.json";
open (CYCTIT, ">$cyctit");
$file_cyctit=CYCTIT;
print $file_cyctit "[\n";

# Ouverture des ouvrages en lecture
# DEBUG
$ouvrages_file="E:/sf/ouvrages.imp";
# COMPLET
#--- $ouvrages_file="E:/sf/ouvrages.res";
open (f_ouv, "<$ouvrages_file");
@ouvrages=<f_ouv>;
close (f_ouv);

#--- index des tables & autres variables
$id_tit = 0;
$id_pub = 0;
$id_cp = 0;
$id_ap = 0;
$id_at = 0;
$id_pt = 0;
$order_cp = 1;
$order_scp = 1;
$old_collection = 0;

$support = "";

$description = "";
$notes = "";
$format = "";
$dim = "";
$pages = 0;
$prix = "";
$cible = "inconnu";
$age = "";
$relie = 0;
$jaquette = 0;
$rabat = 0;
$printer = 0;
$dl = 0;
$ai = 0;

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------
#--- support
$coll_start=2;                                $coll_size=7;
$num_start=10;                                $num_size=5;
$typnum_start=15;
$date_start=17;                               $date_size=4;
$mois_start=22;                               $mois_size=2;
$mark_start=31;                               $mark_size=4;
$isbn_start=36;                               $isbn_size=17;

#--- intitul‚
$genre_start=3;
$type_start=11;                               $type_size=5;
$auttyp_start=$type_start+$type_size+1;
$author_start=$auttyp_start+1;                $author_size=28;
$title_start=$author_start+$author_size;
$page_start=6;                                $page_size=5;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

#--- couverture
$scan_start= 1;                               $scan_size=17;
$illu_start= 18;                              $illu_size=28;
$dess_start= $title_start;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $ref_en_cours="NOUV_REF";  # NOUV_REF, NUM_MULT, COLLAB, FIN_SUPP
my $retirages_en_cours = 0;
my $id_retirage = 0;
my $in=0;
my $oldin=0;
my $old_titre="";
my $old_cmt="";
my $nblig = 0;

foreach $ligne (@ouvrages)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig = $ligne;
   $nblig++;
   chop ($lig);

   $prem=substr ($lig, 0, 1);
   if ($lig eq '')
   {
      # exclusion des lignes vides
      next;
   }
   if (($prem eq '_') || ($prem eq '?'))
   {
      # exclusion des sigles
      # exclusion des entr‚es douteuses
      next;
   }
   #   if ($prem eq '!')
   #   {
   #      # exclusion des commentaires
   #      next;
   #   }
   if ($prem eq '­')
   {
      # exclusion des entr‚es non parues
      next;
   }

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   # si ligne support ("^o") : R‚cup‚rer la ligne, et la spliter pour r‚cup‚rer :
   #   le sigle, et donc la collection / l'‚diteur (selon la solution prise)
   #   un ‚ventuel num‚ro dans la collection (traiter les 25i -> [25])
   #   L'ann‚e de "parution"
   #   L'ISBN si existe
   #   Mettre le tout dans un tableau des ouvrages/impressions
   #
   if (($ref_en_cours eq "NOUV_REF") && ($prem eq 'o'))
   {
      $support = "papier";
      $description = "";
      $notes = "";
      $format = "";
      $dim = "";
      $pages = 0;
      $prix = "";
      $cible = "inconnu";
      $age = "";
      $relie = 0;
      $jaquette = 0;
      $rabat = 0;
      $printer = 0;
      $dl = 0;
      $ai = 0;
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
#        $coll=~s/+$//o;
#        $coll=~s/^ +//o;
         $annee=substr ($lig, $date_start, $date_size);
         $annee=~s/ +$//o;
         $annee=~s/^ +//o;
         $mois=substr ($lig, $mois_start, $mois_size);
         $mois=~s/ +$//o;
         $mois=~s/^ +//o;
         $mois=~s/xx//o;
	 if ($mois eq "") { $mois = "00"; }
	 $date="$annee-$mois-00";
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

         $verif = 0;
         $verifpar = "";

	 @retirages=();
         $reference = {
           NIVEAU=>0,
           SERIAL_EPISODE=>0,
           SERIAL_COMPLET=>0,
           SERIAL_INFO=>0,
           SUPPORT=>"",
           DESCRIPTION=>"",
           NOTES=>"",
           FORMAT=>"",
           VERIF=>"0",
           VERIFPAR=>"0",
           DIM=>"",
           PAGES=>"",
           DPI=>"",
           DPU=>"",
           PTO=>"",
           PRIX=>"",
           CIBLE=>"inconnu",
           AGE=>"",
           RELIE=>"",
           JAQUETTE=>"",
           RABAT=>"",
           COLL=>"$coll",
           ISBN_TYPE=>"$isbn_type",
           ISBN=>"$isbn",
           COMPLET=>"",
           ANNEE=>"$annee",
           MOIS=>"$mois",
           DATE=>"$date",
           NB_REED=>0,
           REED=>["","","","","","","","","","","","","","",""],
           NUM=>"$num",
           TYPNUM=>"$typnum",
           HG=>"", G1=>"", G2=>"",
           PAGE=>"",
           TITRE=>"",
           TITRE_SEUL=>"",
           ALIAS_RECUEIL=>"",
           TYPE=>"",
           SOUSTYPE=>"",
           VODATE=>"",
           VOTITRE=>"",
           SSSSC=>"",
           INDICE_SSSSC=>0,
           IMP_CYCLE=>"",
           IMP_INDICE=>"",
           INDICE=>0,
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
           TRADS=>"",
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
   elsif ($prem eq '+')
   {
      # R‚‚ditions chez le mˆme ‚diteur
   }
   elsif ($prem eq 'x')
   {
      # Retirages : Stocker dans une table temporaire
      # -> stocker l'id de la publication
      #  + l'AI
      #  + la date de publication (inexistante aujourd'hui en base)
      #  Commentaires non g‚r‚s
      #   - information s'il y a - non g‚r‚
      #   - texte priv‚ - non g‚r‚
      #  Scans non g‚r‚s (identique ouvrage de r‚f‚rence)

      $annee=substr ($lig, $date_start, $date_size);
      $annee=~s/ +$//o;
      $annee=~s/^ +//o;
      $mois=substr ($lig, $mois_start, $mois_size);
      $mois=~s/ +$//o;
      $mois=~s/^ +//o;
      $mois=~s/xx//o;
      if ($mois eq "") { $mois = "00"; }
      $date="$annee-$mois-00";

      $retirages_en_cours=1;
      push(@retirages, "$id_pub\t$date");
      # print "DEBUG id_pub[$id_pub] date [$date]\n";
   }
   elsif ($prem eq '}')
   {
      if ($retirages_en_cours == 1)
      {
         # On ne gŠre pas les scans des retirages (identiques)
         next;
      }

      ($couv, $illustrateur, $dessinateurs) = &extract_couv ($ligne);
      #         $mois=~s/ +$//o;
      $couv=~s/\.jpg$//o;
      if ($couv eq "?") { $couv = "noimg"; }
      $reference->{COUV}[$reference->{NB_REED}] = "$couv";
      $reference->{ILLU}[$reference->{NB_REED}] = "$illustrateur";
      $reference->{DESS}[$reference->{NB_REED}] = "$dessinateurs";
      next;
   }
   elsif (($prem eq '!') && (substr($lig, 0, 13) eq "!--- SERIE : "))
   {
      printf "DEBUG : [" . substr($lig, 0, 13) . "]\n";
      # On conserve le nom de s‚rie tel qu'indiqu‚ sur l'ouvrage lui-mˆme
      # 
      $impserie = substr($lig, 13);
      ($impcycle, $impnum)=split (/ \- /,$impserie);
      $reference->{IMP_CYCLE} = $impcycle;
      $reference->{IMP_INDICE} = $impnum;
      next;
   }
   elsif (($prem eq '>') || ($prem eq '!'))
   {
      if ($retirages_en_cours == 1)
      {
         # On ne gŠre pas les commentaires des retirages (devrait ˆtre … priori identiques)
         next;
      }
      if (index ($lig, "SERIAL") ne -1)
      {
         $reference->{SERIAL_COMPLET} = 1;
	 $infoserial=$lig;
         $infoserial=~s/^!--- //;
         $infoserial=~s/^>--- //;
	 $infoserial=~s/SERIAL : //;
	 $infoserial=getnomcoll($reference->{COLL}) . " " . $infoserial;
         $reference->{SERIAL_INFO} = $infoserial;
      }
      #-----------------------------------------------------
      # Commentaire "Officiel"
      #-----------------------------------------------------
      $br=substr($lig, 3, 1);

      if ((index ($lig, " - ") ne -1) &&
          ((index (lc($lig), "pages") ne -1) || (index(lc($lig), " mm ") ne -1) || (index(lc($lig), " cm ") ne -1) || (index(lc($lig), "euros") ne -1) ||
           (index(lc($lig), "francs") ne -1) || (index(lc($lig), "centimes") ne -1) || (index(lc($lig), "jaquette") ne -1) || (index(lc($lig), "reli‚") ne -1) ||
           (index(lc($lig), "christian") ne -1) || (index(lc($lig), "gilles") ne -1) || (index(lc($lig), "gallica") ne -1)))
      {
         # Recherches infos format, pages, dims, prix
         # split des " - " -> tableau
         $lig=~s/^>-+\.* *//;
         $lig=~s/^!-+\.* *//;
         @datas = split (/ - /, $lig);

         foreach $data (@datas)
         {
            $data=~s/ +$//o;
            $data=~s/^ +//o;

	    if (uc($data) eq "CHRISTIAN")
            {
               $verif = 1;
               $verifpar = $verifpar . ($verifpar eq "" ? "" : "; ") . "Christian";
            }
	    elsif (uc($data) eq "GILLES")
            {
               $verif = 1;
               $verifpar = $verifpar . ($verifpar eq "" ? "" : "; ") . "Gilles";
            }
	    if (uc($data) eq "LAURENT")
            {
               $verif = 1;
               $verifpar = $verifpar . ($verifpar eq "" ? "" : "; ") . "Laurent";
            }
	    elsif (uc($data) eq "GALLICA")
            {
               $verif = 1;
               $verifpar = $verifpar . ($verifpar eq "" ? "" : "; ") . "Gallica";
            }
	    elsif (substr(uc($data), 0, 2) eq "DL")
            {
               $data=~s/^DL //o;
               $dl = $data;
            }
	    elsif (substr(uc($data), 0, 2) eq "AI")
            {
               $data=~s/^AI //o;
               $ai = $data;
            }
	    elsif (substr(uc($data), 0, 6) eq "IMPRIM")
            {
               $data=~s/^IMPRIM //o;
               $printer = $data;
            }
	    elsif (index(lc($data), "audio") ne -1)
            {
               $support = "audio";
            }
	    elsif (index(lc($data), "num‚rique") ne -1)
            {
               $support = "num‚rique";
            }
	    elsif (index(lc($data), "euros") ne -1)
            {
               # prix
	       $prix = $data;
            }
            elsif ((index(lc($data), "centimes") ne -1) || (index(lc($data), "francs") ne -1) || (index(lc($data), "frs") ne -1) || (index(lc($data), "fr.") ne -1) || (index(lc($data), "fr") ne -1))
            {
               # prix
	       $prix = $data;
            }
            elsif (index(lc($data), "pages") ne -1)
            {
               # pages
	       if ($verif eq 1) {
	          $dpu = $data;
	          $dpu=~s/ pages//;
	       }
	       else {
	          $pages = $data;
	          $pages=~s/ pages//;
	       }
            }
            elsif (index(uc($data), "DPI") ne -1)
            {
               # Dernier num‚ro de page visible
	       $dpi = $data;
	       $dpi=~s/DPI //;
            }
            elsif (index(uc($data), "PTO") ne -1)
            {
               # pagination totale
	       $pto = $data;
	       $pto=~s/PTO //;
            }
            elsif (index($data, "18+") ne -1)
            {
               # cible
	       $cible = "adulte";
	       $age = "18+";
            }
            elsif (index(uc($data), "YA") ne -1)
            {
               # cible
	       # Spliter si "YA 13+" pour r‚cup‚rer le "13+"
               ($cible, $age) = split (/ /, $data);
	       $cible = "YA";
            }
            elsif (index(lc($data), "jeunesse") ne -1)
            {
               # cible
	       #  TODO spliter si "Jeunesse 13+" pour r‚cup‚rer le "13+"
               ($cible, $age) = split (/ /, $data);
	       $cible = "jeunesse";
            }
            elsif (index(lc($data), "ado") ne -1)
            {
               # cible
	       # Spliter si "Ado 13+" pour r‚cup‚rer le "13+"
               ($cible, $age) = split (/ /, $data);
	       $cible = "YA";
            }
            elsif ((index(lc($data), " mm") ne -1) || (index(lc($data), " cm") ne -1) || (index(lc($data), "DIM ") ne -1) || (index(lc($data), " x ") ne -1))
            {
               # dim
               $data=~s/DIM //;

               $unit=1;
               if (index(lc($data), " mm") ne -1) { $unit=1; $data=~s/ mm//; }
               elsif (index(lc($data), " cm") ne -1) { $unit=10; $data=~s/ cm//; }
               elsif (index(lc($data), "mm") ne -1) { $unit=1; $data=~s/ mm//; }
               elsif (index(lc($data), "cm") ne -1) { $unit=10; $data=~s/ cm//; }

               if (index(lc($data), " x ") ne -1)
               {
                  ($largeur, $hauteur) = split (/ x /, $data);
		  $l = ($largeur + 0) * $unit;
		  $h = ($hauteur + 0) * $unit;
		  $dim = "$l x $h";

               }
               elsif (index(lc($data), "x") ne -1)
               {
                  # TODO : exclure les xA
                  $unit=1;
                  ($largeur, $hauteur) = split (/x/, $data);
		  $l = ($largeur + 0) * $unit;
		  $h = ($hauteur + 0) * $unit;
		  $dim = "$l x $h";
               }
               else
               {
		  $largeur = 0;
		  $hauteur = $data;
		  $h = ($hauteur + 0) * $unit;
		  $dim = "$h";
               }
            }
            elsif (index(lc($data), "x") ne -1)
            {
               # dim
               $data=~s/DIM //;
	       $unit = 1;
               ($largeur, $hauteur) = split (/x/, $data);
               $l = ($largeur + 0) * $unit;
               $h = ($hauteur + 0) * $unit;
	       $dim = "$l x $h";
            }
	    else
            {
               if (index(lc($data), "poche") ne -1)
               {
                  # format
		  $format = "poche";
               }
               if (index(uc($data), "MF") ne -1)
               {
                  # format
		  $format = "mf";
               }
               if (index(uc($data), "GF") ne -1)
               {
                  # format
		  $format = "gf";
               }
               if (index(lc($data), "broch") ne -1)
               {
                  # reli‚
		  $relie = 0;
               }
               if (index(lc($data), "reli") ne -1)
               {
                  # reli‚
		  $relie = 1;
               }
               if (index(lc($data), "jaquette") ne -1)
               {
                  # jaquette (has_dustjacket)
		  $jaquette = 1;
               }
               if (index(lc($data), "rabat") ne -1)
               {
                  # rabat (has_coverflaps)
		  $rabat = 1;
               }
            }
         }
      }
      elsif ($prem eq ">")
      {
         $lig=~s/^>-+\.* *//;
         if ($description eq "")
         {
            $description = "$lig";
         }
         elsif ($br eq ".")
         {
            $description = $description . " $lig";
         }
         else
         {
            $description = $description . "<br />$lig";
         }
      }
      else
      {
         $lig=~s/^!-+\.* *//;
         if ($notes eq "")
         {
            $notes = "$lig";
         }
         elsif ($br eq ".")
         {
            $notes = $notes . " $lig";
         }
         else
         {
            $notes = $notes . "<br />$lig";
         }
      }

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
      ||  (($ref_en_cours eq "NOUV_REF") && (($prem eq '=') || ($prem eq ':') || ($prem eq ')'))))
   {
      if ($prem eq '-')
      {
         $retirages_en_cours = 0;
         $reference->{DESCRIPTION} = $description;
	 $description = "";
         $reference->{NOTES} = $notes;
	 $notes = "";
         $reference->{FORMAT} = $format;
	 $format = "";
         $reference->{VERIF} = $verif;
	 $verif = "";
         $reference->{VERIFPAR} = $verifpar;
	 $verifpar = "";
         $reference->{DIM} = $dim;
	 $dim = "";
         $reference->{PAGES} = $pages;
	 $pages = 0;
         $reference->{DPI} = $dpi;
	 $dpi = 0;
         $reference->{DPU} = $dpu;
	 $dpu = 0;
         $reference->{PTO} = $pto;
	 $pto = 0;
         $reference->{PRIX} = $prix;
	 $prix = "";
         $reference->{CIBLE} = $cible;
	 $cible = "inconnu";
         $reference->{AGE} = $age;
	 $age = "";
         $reference->{RELIE} = $relie;
	 $relie = 0;
         $reference->{JAQUETTE} = $jaquette;
	 $jaquette = 0;
         $reference->{RABAT} = $rabat;
	 $rabat = 0;
         $reference->{DL} = $dl;
	 $dl = 0;
         $reference->{AI} = $ai;
	 $ai = 0;
         $reference->{PRINTER} = $printer;
	 $printer = 0;

         $reference->{SUPPORT} = $support;
         $support = "papier";
      }
      #-----------------------------------------------------
      # ligne "reference" (contenu principal ou inclus)
      #-----------------------------------------------------
      $in=0;
      if (($prem eq '=') || ($prem eq ':') || ($prem eq ')'))
      {
         # si texte inclus, nouvelle reference
	 #
	 # on ne zappe pas : permet de stocker dans les titres ‚galement
	 #
	 #next;

         $in=1;
         $reference = {
           NIVEAU=> ($prem eq '=' ? 2 : 1),
           SERIAL_EPISODE=> ($prem eq ')' ? 1 : 0),
           SUPPORT=>"",
           DESCRIPTION=>"",
           NOTES=>"",
           FORMAT=>"",
           DIM=>"",
           PAGES=>"",
           DPI=>"",
           DPU=>"",
           PTO=>"",
           PRIX=>"",
           CIBLE=>"inconnu",
           AGE=>"",
           RELIE=>"",
           JAQUETTE=>"",
           RABAT=>"",
           COLL=>"",
           ANNEE=>"",
           MOIS=>"",
           DATE=>"",
           NUM=>"",
           TYPNUM=>"",
           HG=>"", G1=>"", G2=>"",
           PAGE=>"",
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
           TRADS=>"",
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

         $reference->{SERIAL_COMPLET} = $in_ref->{SERIAL_COMPLET};
         $reference->{SERIAL_INFO} = $in_ref->{SERIAL_INFO};
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
      $hg=substr ($lig, $genre_start, 1);
      $g1=substr ($lig, $genre_start + 1, 1);
      $g2=substr ($lig, $genre_start + 2, 1);

      $type_c=substr ($lig, $type_start, $type_size);
      $type=substr ($type_c, 0, 1);
      $stype=substr ($type_c, 1, 1);

      $page=substr ($lig, $page_start, $page_size);
      $page=~s/ +$//o;
      $page=~s/^ +//o;
      $page=~s/[=_kcgpi]$//o;

      $reference->{TITRE} = "$titre";
      $reference->{PAGE} = "$page";
      $reference->{HG} = "$hg";
      $reference->{G1} = "$g1";
      $reference->{G2} = "$g2";
      $reference->{TYPE} = "$type";
      $reference->{SOUSTYPE} = "$stype";
      $reference->{VODATE} = "$vodate";
      $reference->{VOTITRE} = "$votitre";
      $reference->{TRADS} = "$trad";

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
      if ($flag_collab_suite eq '&')
      {
         next; #--- on zappe puisque on ne prends que les publications
      }
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

      #
      # Pr‚-traitements communs pub ou titre
      #
      # TODO : compl‚ter
      $titre = $reference->{TITRE_SEUL};
      $titre=~s/\"/\\"/g;
      if (length($titre) > 255) { $titre = substr($titre,0,255); }

      # En fait ce nom cycle est pour la publi uniquement (… priori id titres mais bon...)
      $pubcyc = "";
      $pubnum = 0;

      # Attention, on privig‚lie nom en commentaire si existe ( !--- SERIE : xxx - i )
      if ($reference->{IMP_CYCLE} ne "")
      {
         # On stocke au niveau pub le nom imprim‚ si existe et diff‚rent
         $pubcyc = $reference->{IMP_CYCLE};
         $pubnum = $reference->{IMP_INDICE};
      }
      elsif ($reference->{SSSSC} ne "")
      {
         # ... ou sinon le sous-sous-cycle s'il existe...
         $pubcyc = $reference->{SSSSC};
         $pubnum = $reference->{INDICE_SSSSC};
      }
      elsif ($reference->{CYCLE_S} ne "")
      {
         # ... sinon le sous-cycle s'il existe...
         $pubcyc = $reference->{CYCLE_S};
         $pubnum = $reference->{INDICE_S};
      }
      elsif ($reference->{CYCLE} ne "")
      {
         # ... sinon le cycle s'il existe...
         $pubcyc = $reference->{CYCLE};
         $pubnum = $reference->{INDICE};
      }


      #
      # Il s'agit d'un ouvrage => ajout comme publication, et comme titre
      #

      # TODO : faire mieux, mais pour l'instant ini sinon champ non initialis‚ qui se retrouve avec vide ou la valeur pr‚c‚dente !
      $pubcible = $reference->{CIBLE};

      if (($in == 0) && ($reference->{SERIAL_COMPLET} != 1))
      {
         # 
         # Ouvrage seulement si pas "SERIAL complet" !
         # 
         # TODO : Plein de trucs -> ajout au fichier json de la publi
         $id_pub++;
         $ix_contenu = 0;

         if ($id_pub > 1) {
            print $file_pubs ",\n";
         }
         print $file_pubs "\{\n";

         $cover = $reference->{ILLU}[$reference->{NB_REED}];
         $cover=~s/\"/\\"/g;
         $illustrators=$reference->{DESS}[$reference->{NB_REED}];
         $illustrators=~s/\"/\\"/g;


         $sigle = $reference->{COLL};
	 $collection = 0;
	 $coll_parent = 0;
         #-----------------------------------------------------------------------
         #--- Recherche ‚diteur et collection
         #--- Si $sigles appartient … la premiŠre colonne de IDCOLLS
         #-----------------------------------------------------------------------
	 # TBD ne faut-il pas une tabulation apres $sigle ??
	 #
         @edicols = grep(/^${sigle}	/, @idcolls);
         if (scalar(@edicols) > 1)
         {
            # si plus de deux entr‚es, pas grave pour les ‚diteurs
            # par contre pour les collections, il faudra trouver un id coll diff‚rent de 0
            # print "ERREUR, \"${sigle}\" a deux entr‚es ?! !\n";
            $edicol = $edicols[0];
            chop ($edicol);
            ($sigsig, $editeur, $collection, $coll_parent, $reste) = split (/\t/, $edicol);
         }
         elsif (scalar(@edicols) == 1)
         {
            $edicol = $edicols[0];
            chop ($edicol);
            ($sigsig, $editeur, $collection, $coll_parent, $reste) = split (/\t/, $edicol);
            # print "OK : [$sigle] trouv‚ ! : [$edicol] [$editeur] \n";
         }
         else
         {
            print "ERREUR : sigle [$sigle] non trouv‚ ? \n";
         }

	 if ($coll_parent != 0) {
            $subcoll = $collection;
	    $collection = $coll_parent;
         }
	 else {
            $subcoll = 0;
         }

         #-----------------------------------------------------------------------
         #--- Recherche des auteurs
         #-----------------------------------------------------------------------
         $ix_aut=0;
         while ($ix_aut < $reference->{NB_AUTEUR})
         {
            $credit = $reference->{AUTEUR}[$ix_aut];

            @auteurs = grep(/^${credit}	/, @idauts);
            if (scalar(@auteurs) > 1)
            {
               # si plus de deux entr‚es, pb
               print "ERREUR, \"${credit}\" a deux entr‚es ?! !\n";
            }
            elsif (scalar(@auteurs) == 1)
            {
               $aut = $auteurs[0];
               chop ($aut);
               ($nombdfi, $id) = split (/\t/, $aut);
               # print "OK : [$credit] trouv‚ ! : [$id] \n";
               $id_ap++;
               if ($id_ap > 1) {
                  print $file_autpub ",\n";
               }
               print $file_autpub "\{\n";
               print $file_autpub "\"id_aut\": \"" . $id . "\",\n";
               print $file_autpub "\"id_pub\": \"" . $id_pub . "\",\n";
               print $file_autpub "\"role\": \"author\"\n";
               print $file_autpub "\}";
            }
            else
            {
               print "ERREUR : auteur [$credit] non trouv‚ ? \n";
            }
            $ix_aut++;
         }
         #-----------------------------------------------------------------------
         #--- Recherche des anthologistes/‚diteur
         #-----------------------------------------------------------------------
         $ix_aut=0;
         while ($ix_aut < $reference->{NB_ANTHOLOG})
         {
            $credit = $reference->{ANTHOLOG}[$ix_aut];
            if ($credit ne "***")
            {
               @auteurs = grep(/^${credit}	/, @idauts);
               if (scalar(@auteurs) > 1)
               {
                  # si plus de deux entr‚es, pb
                  print "ERREUR, \"${credit}\" a deux entr‚es ?! !\n";
               }
               elsif (scalar(@auteurs) == 1)
               {
                  $aut = $auteurs[0];
                  chop ($aut);
                  ($nombdfi, $id) = split (/\t/, $aut);
                  # print "OK : [$credit] trouv‚ ! : [$id] \n";
                  $id_ap++;
                  if ($id_ap > 1) {
                     print $file_autpub ",\n";
                  }
                  print $file_autpub "\{\n";
                  print $file_autpub "\"id_aut\": \"" . $id . "\",\n";
                  print $file_autpub "\"id_pub\": \"" . $id_pub . "\",\n";
                  print $file_autpub "\"role\": \"editor\"\n";
                  print $file_autpub "\}";
               }
               else
               {
                  print "ERREUR : auteur [$credit] non trouv‚ ? \n";
               }
            }
            $ix_aut++;
         }

         $pubsupport=$reference->{SUPPORT};

         $pubdesc=$reference->{DESCRIPTION};
         $pubdesc=~s/\"/\\"/g;

         $pubnotes=$reference->{NOTES};
         $pubnotes=~s/\"/\\"/g;

         $pubformat=$reference->{FORMAT};
         $pubdim=$reference->{DIM};
         $pubpages=$reference->{PAGES};
         $pub_dpi=$reference->{DPI};
         $pub_dpu=$reference->{DPU};
         $pub_pto=$reference->{PTO};
         $pubprix=$reference->{PRIX};
         $pubcible=$reference->{CIBLE};
         $pubage=$reference->{AGE};
         $pubrelie=$reference->{RELIE};
         $pubjaquette=$reference->{JAQUETTE};
         $pubrabat=$reference->{RABAT};
         $pubprinter=$reference->{PRINTER};
         $pubdl=$reference->{DL};
         $pubai=$reference->{AI};

	 $isverif = $reference->{VERIF};
	 $verifpar = $reference->{VERIFPAR};
	 $epaisseur = "";
       
         print $file_pubs "\"name\": \"" . oem2utf($titre) . "\",\n";
         print $file_pubs "\"cycle\": \"" . oem2utf($pubcyc) . "\",\n";
         print $file_pubs "\"indice\": \"" . oem2utf($pubnum) . "\",\n";
         print $file_pubs "\"isbn\": \"" . oem2utf($reference->{ISBN}) . "\",\n";
         print $file_pubs "\"approximate_parution\": \"" . $reference->{DATE} . "\",\n";
         print $file_pubs "\"cover\": \"" . oem2utf($cover) . "\",\n";
         print $file_pubs "\"illustrators\": \"" . oem2utf($illustrators) . "\",\n";
         print $file_pubs "\"cover_front\": \"" . $reference->{COUV}[$reference->{NB_REED}] . "\",\n";
	 # TODO juste pour test de la fonction slide des pages publications
	 if (int(rand(2)) < 1)
         {
            print $file_pubs "\"cover_back\": \"" . $reference->{COUV}[$reference->{NB_REED}] . "\",\n";
         }
	 else
         {
            print $file_pubs "\"cover_back\": \"\",\n";
         }
	 if (int(rand(2)) < 1)
         {
            print $file_pubs "\"withband_front\": \"" . $reference->{COUV}[$reference->{NB_REED}] . "\",\n";
         }
	 else
         {
            print $file_pubs "\"withband_front\": \"\",\n";
         }
	 if (int(rand(2)) < 1)
         {
            print $file_pubs "\"dustjacket_front\": \"" . $reference->{COUV}[$reference->{NB_REED}] . "\",\n";
         }
	 else
         {
            print $file_pubs "\"dustjacket_front\": \"\",\n";
         }
         print $file_pubs "\"type_contenu\": \"" . pub_type($reference->{TYPE}, $reference->{SOUSTYPE}) . "\",\n";
         print $file_pubs "\"description\": \"" . oem2utf($pubdesc) . "\",\n";
         print $file_pubs "\"private\": \"" . oem2utf($pubnotes) . "\",\n";
         print $file_pubs "\"hg\": \"" . pub_hg($reference->{HG}) . "\",\n";
         print $file_pubs "\"genrestat\": \"" . genrestat($reference->{HG},$reference->{G1},$reference->{G2}) . "\",\n";
         print $file_pubs "\"support\": \"" . $pubsupport . "\",\n";
         print $file_pubs "\"format\": \"" . $pubformat . "\",\n";
         print $file_pubs "\"dim\": \"" . $pubdim . "\",\n";
         print $file_pubs "\"epaisseur\": \"" . $epaisseur . "\",\n";
         print $file_pubs "\"pages\": \"" . $pubpages . "\",\n";
         print $file_pubs "\"dpi\": \"" . $pub_dpi . "\",\n";
         print $file_pubs "\"dpu\": \"" . $pub_dpu . "\",\n";
         print $file_pubs "\"pto\": \"" . $pub_pto . "\",\n";
         print $file_pubs "\"prix\": \"" . $pubprix . "\",\n";
         print $file_pubs "\"cible\": \"" . oem2utf($pubcible) . "\",\n";
         print $file_pubs "\"age\": \"" . oem2utf($pubage) . "\",\n";
         print $file_pubs "\"relie\": \"" . $pubrelie . "\",\n";
         print $file_pubs "\"jaquette\": \"" . $pubjaquette . "\",\n";
         print $file_pubs "\"rabat\": \"" . $pubrabat . "\",\n";
         print $file_pubs "\"printer\": \"" . oem2utf($pubprinter) . "\",\n";
         print $file_pubs "\"is_verified\": \"" . $isverif . "\",\n";
         print $file_pubs "\"verified_by\": \"" . $verifpar . "\",\n";
         print $file_pubs "\"dl\": \"" . $pubdl . "\",\n";
         print $file_pubs "\"ai\": \"" . oem2utf($pubai) . "\",\n";
         print $file_pubs "\"id_ed\": \"" . $editeur . "\"\n";
   
         print $file_pubs "\}";

         foreach $retirage (@retirages)
         {
            ($reimp_id_pub, $reimp_date) = split (/\t/, $retirage);

	    # l'identifiant d'ouvrage est le pr‚c‚dent (r‚f‚rence pas encore termin‚) donc on l'incr‚mente
            $reimp_id_pub++;

            if ($id_retirage != 0)
            {
               print $file_reprints ",\n";
            }
            $id_retirage++;
            print $file_reprints "\{\n";
            print $file_reprints "\"id_pub\": \"" . $reimp_id_pub . "\",\n";
            print $file_reprints "\"ai\": \"" . oem2utf($reimp_date) . "\"\n";
            print $file_reprints "\}";
         }

         if ($collection != 0)
         {
            $num_pub = $reference->{NUM};
            if ($num_pub eq "?")
	    {
	       $num_pub = "";
	    }

            $id_cp++;
	    if (($collection == $old_collection) || ($subcoll == $old_collection))
	    {
               $order_cp++;
            }
	    else
	    {
               $order_cp = 1;
            }

            if ($id_cp > 1) {
               print $file_colpub ",\n";
            }
            print $file_colpub "\{\n";
            print $file_colpub "\"id_col\": \"" . $collection . "\",\n";
            print $file_colpub "\"id_pub\": \"" . $id_pub . "\",\n";
            print $file_colpub "\"order\": \"" . $order_cp . "\",\n";
            print $file_colpub "\"num\": \"" . $num_pub . "\"\n";
            print $file_colpub "\}";
	    $old_collection = $collection;
         }
         if ($subcoll != 0)
         {
            $num_pub = $reference->{NUM};
            if ($num_pub eq "?")
	    {
	       $num_pub = "";
	    }

            $id_cp++;
	    if ($subcoll == $old_subcoll)
	    {
               $order_scp++;
            }
	    else
	    {
               $order_scp = 1;
            }

#           if ($id_cp > 1) {
               print $file_colpub ",\n";
#           }
            print $file_colpub "\{\n";
            print $file_colpub "\"id_col\": \"" . $subcoll . "\",\n";
            print $file_colpub "\"id_pub\": \"" . $id_pub . "\",\n";
            print $file_colpub "\"order\": \"" . $order_scp . "\",\n";
            print $file_colpub "\"num\": \"" . $num_pub . "\"\n";
            print $file_colpub "\}";
	    $old_subcoll = $subcoll;
         }
         # Ins‚rer le titre "g‚n‚ral" avec order = NULL et page=NULL
         # TBD : voir si on entre tout, ou pas les recueils
	 # => dans le code commun ci-dessous
	 $niveau = 0;
         $page = '';

      }
      #
      # Il s'agit d'un titre inclus => ajout comme titre avec page = page ou ordre
      #
      else
      {
         $niveau = $reference->{NIVEAU};
         if ($reference->{HG} eq 'C')
         {
            $niveau = $niveau - 0.5;
         }

         $page = $reference->{PAGE};
         # => code commun ci-dessous
      }

      #
      # R‚f‚rencement d'un titre (de type publi ou contenu)
      #
      # ICI : recherche si d‚j… pouss‚ dans le fichier json
      if ($reference->{NB_AUTEUR} > 0) {
         $aaa = $reference->{AUTEUR}[0];
      }
      else
      {
         $aaa = "-";
      }
      if ($reference->{NB_ANTHOLOG} > 0) {
         $bbb = $reference->{ANTHOLOG}[0];
      }
      else
      {
         $bbb = "-";
      }
               
      $memo="START	$titre	$aaa	$bbb	$reference->{NB_AUTEUR}	$reference->{NB_ANTHOLOG}	$reference->{VODATE}	$reference->{VOTITRE}	$reference->{TRADS}	$reference->{TYPE}	$reference->{SOUSTYPE}	END";

      if (($oid = title_exists($memo, $id_tit)) != 0)
      {
         # On reprend l'ID existant pour l'associer … la publication - pas besoin alors de stocker titre, lien titre-auteur, et lien titre-cycle
	 print "DEBUG : reprise id [$oid] pour le texte [$titre] de [$aaa][$bbb]\n";
	 $id_tit_reel = $oid;
      }
      else
      {
         $id_tit++;
	 $id_tit_reel = $id_tit;
	 #  print "DEBUG : Ajout titre JSON [$id_tit_reel]\n";

         if ($id_tit > 1) {
            print $file_titles ",\n";
         }
         print $file_titles "\{\n";
         print $file_titles "\"name\": \"" . oem2utf($titre) . "\",\n";
         print $file_titles "\"hg\": \"" . texte_hg($reference->{HG}) . "\",\n";
         print $file_titles "\"genrestat\": \"" . genrestat($reference->{HG},$reference->{G1},$reference->{G2}) . "\",\n";
         print $file_titles "\"genre1\": \"" . texte_genre($reference->{G1}) . "\",\n";
         print $file_titles "\"genre2\": \"" . texte_genre($reference->{G2}) . "\",\n";
         print $file_titles "\"cible\": \"" . oem2utf($pubcible) . "\",\n";
         print $file_titles "\"age\": \"" . oem2utf($pubage) . "\",\n";
         print $file_titles "\"feuilleton\": \"" . $reference->{SERIAL_EPISODE} . "\",\n";
         print $file_titles "\"variant_type\": \"premier\",\n"; # TODO : premier par d‚faut mais il faudra g‚rer les "vrais auteurs" de pseudos
         print $file_titles "\"serial_complet\": \"" . $reference->{SERIAL_COMPLET} . "\",\n";
         print $file_titles "\"serial_data\": \"" . oem2utf($reference->{SERIAL_INFO}) . "\",\n";
         print $file_titles "\"copyright\": \"" . texte_cop($reference->{VODATE}) . "\",\n";
         print $file_titles "\"vo\": \"" . texte_vo($reference->{VOTITRE}) . "\",\n";
         if ($reference->{VOTITRE} ne "") {
            print $file_titles "\"copyright_fr\": \"" . $reference->{DATE} . "\",\n";
         }
         else {
            print $file_titles "\"copyright_fr\": \"" . texte_cop($reference->{VODATE}) . "-00-00\",\n";
         }
         print $file_titles "\"copyr\": \"" . texte_cop($reference->{VODATE}) . "-00-00\",\n";
         print $file_titles "\"trad\": \"" . liste_trads($reference->{TRADS}) . "\",\n";
         print $file_titles "\"description\": \"" . revision_trads($reference->{TRADS}) . "\",\n";
         print $file_titles "\"type\": \"" . texte_type($reference->{TYPE}, $reference->{SOUSTYPE}, $reference->{HG}) . "\"\n";

         print $file_titles "\}";

         #
         #-----------------------------------------------------------------------
         #--- Recherche des auteurs pour table de liaison titre - auteurs
         #-----------------------------------------------------------------------
         $ix_aut=0;
         while ($ix_aut < $reference->{NB_AUTEUR})
         {
            $credit = $reference->{AUTEUR}[$ix_aut];
   
            @auteurs = grep(/^${credit}	/, @idauts);
            if (scalar(@auteurs) > 1)
            {
               # si plus de deux entr‚es, pb
               print "ERREUR, \"${credit}\" a deux entr‚es ?! !\n";
            }
            elsif (scalar(@auteurs) == 1)
            {
               $aut = $auteurs[0];
               chop ($aut);
               ($nombdfi, $id) = split (/\t/, $aut);
               # print "OK : [$credit] trouv‚ ! : [$id] \n";
               $id_at++;
               if ($id_at > 1) {
                  print $file_auttit ",\n";
               }
               print $file_auttit "\{\n";
               print $file_auttit "\"id_aut\": \"" . $id . "\",\n";
               print $file_auttit "\"id_tit\": \"" . $id_tit_reel . "\"\n";
               print $file_auttit "\}";
            }
            else
            {
               print "ERREUR : auteur [$credit] non trouv‚ ? \n";
            }
            $ix_aut++;
         }
         # TBD : et les anthologistes ?
         $ix_aut=0;
         while ($ix_aut < $reference->{NB_ANTHOLOG})
         {
            $credit = $reference->{ANTHOLOG}[$ix_aut];
            if ($credit ne "***")
            {
               @auteurs = grep(/^${credit}	/, @idauts);
               if (scalar(@auteurs) > 1)
               {
                  # si plus de deux entr‚es, pb
                  print "ERREUR, \"${credit}\" a deux entr‚es ?! !\n";
               }
               elsif (scalar(@auteurs) == 1)
               {
                  $aut = $auteurs[0];
                  chop ($aut);
                  ($nombdfi, $id) = split (/\t/, $aut);
                  # print "OK : [$credit] trouv‚ ! : [$id] \n";
   
                  $id_at++;
                  if ($id_at > 1) {
                     print $file_auttit ",\n";
                  }
                  print $file_auttit "\{\n";
                  print $file_auttit "\"id_aut\": \"" . $id . "\",\n";
                  print $file_auttit "\"id_tit\": \"" . $id_tit_reel . "\"\n";
                  print $file_auttit "\}";
               }
               else
               {
                  print "ERREUR : auteur [$credit] non trouv‚ ? \n";
               }
            }
         $ix_aut++;
         }

         #-----------------------------------------------------------------------
         # R‚f‚rencement d'un titre (de type publi ou contenu)
         #-----------------------------------------------------------------------

         if ($reference->{SSSSC} ne "")
         {
            # 
            # On attache le sous-sous-cycle s'il existe...
            # 
            $nomcycle = $reference->{SSSSC};
            $numcycle = $reference->{INDICE_SSSSC};
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }
         elsif ($reference->{CYCLE_S} ne "")
         {
            # 
            # ... sinon le sous-cycle s'il existe...
            # 
            $nomcycle = $reference->{CYCLE_S};
            $numcycle = $reference->{INDICE_S};
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }
         elsif ($reference->{CYCLE} ne "")
         {
            # 
            # ... sinon le cycle s'il existe...
            # 
            $nomcycle = $reference->{CYCLE};
            $numcycle = $reference->{INDICE};
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }

         # 
         # On prends tous les autres sous-cycles s'ils existent
         # 
         # SOUS-CYCLE 2
         $nomcycle = $reference->{CYCLE_S2};
         $numcycle = $reference->{INDICE_S2};
         if ($nomcycle ne "")
         {
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }
         # SOUS-CYCLE 3
         $nomcycle = $reference->{CYCLE_S3};
         $numcycle = $reference->{INDICE_S3};
         if ($nomcycle ne "")
         {
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }

         # 
         # et tous les autres cycles s'ils existent
         # 
         # CYCLE 2
         $nomcycle = $reference->{CYCLE2};
         $numcycle = $reference->{INDICE2};
         if ($nomcycle ne "")
         {
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }
         # CYCLE 3
         $nomcycle = $reference->{CYCLE3};
         $numcycle = $reference->{INDICE3};
         if ($nomcycle ne "")
         {
            @cyctitl = grep(/^${nomcycle}	/, @idcycs);
            if (scalar(@cyctitl) > 1)
            {
               # si plus de deux entr‚es => pas normal
               print "ERREUR : cycle [${nomcycle}] a deux entr‚es ?! !\n";
               $cyccyc = $cyctitl[0];
               chop ($cycyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);
            }
            elsif (scalar(@cyctitl) != 1)
            {
               print "ERREUR : cycle [$nomcycle] non trouv‚ ? \n";
            }
            else
            {
               $id_ct++;
               if ($id_ct > 1) {
                  print $file_cyctit ",\n";
               }

               $cyccyc = $cyctitl[0];
               chop ($cyccyc);
               ($cycnam, $id_cyc) = split (/\t/, $cyccyc);

               print $file_cyctit "\{\n";
               print $file_cyctit "\"id_cyc\": \"" . $id_cyc . "\",\n";
               print $file_cyctit "\"id_tit\": \"" . $id_tit_reel . "\",\n";
               print $file_cyctit "\"num\": \"" . $numcycle . "\",\n";
               print $file_cyctit "\"order\": \"" . getordercycle($numcycle) . "\"\n";
               print $file_cyctit "\}";
            }
         }
         # Fin de stockage titre - si non d‚j… existant
      }

      #-----------------------------------------------------------------------
      #--- Mise … jour table de liaison publication - titre ( = sommaire)
      #-----------------------------------------------------------------------
      if ($reference->{SERIAL_COMPLET} != 1) {
         # 
         # Sauf si SERIAL
         # 
         $id_pt++;
         if ($id_pt > 1) {
            print $file_pubtit ",\n";
         }

         print $file_pubtit "\{\n";
         print $file_pubtit "\"id_pub\": \"" . $id_pub . "\",\n";
         print $file_pubtit "\"id_tit\": \"" . $id_tit_reel . "\",\n";

         print $file_pubtit "\"ordre\": \"" . $ix_contenu . "\",\n";
         print $file_pubtit "\"niveau\": \"" . $niveau . "\",\n";
         print $file_pubtit "\"debut\": \"" . $page . "\"\n";
         print $file_pubtit "\}";

         $ix_contenu++;
      }
   }

   $old=$lig;
}

print $file_pubs "\n]\n";
print $file_reprints "\n]\n";
print $file_colpub "\n]\n";
print $file_autpub "\n]\n";
print $file_titles "\n]\n";
print $file_auttit "\n]\n";
print $file_pubtit "\n]\n";
print $file_cyctit "\n]\n";

close (PUBS);
close (REPRINTS);
close (COLPUB);
close (AUTPUB);
close (PUBTIT);
close (CYCTIT);
exit;


#
# Puis la migration des oeuvres
#  si "^-" : est une publi ET un titre d'oeuvre (… priori toujours, cf. ISFDB)
#  si "^:" : est un titre d'oeuvre (ou de "Partie / Groupe de texte")
#  si "^=" : est un titre d'oeuvre (ou de "Partie / Groupe de texte")
#

#
#


sub oem2utf
{
   $chaine= $_[0];
   use Encode qw(decode);
   use Encode qw(encode);

   my $win = decode('cp437',$chaine);
   my $utf8 = encode('utf8',$win);

   return $utf8;
}

sub texte_type
{
   $type= $_[0];
   $stype= $_[1];
   $hg= $_[2];

      if (($type eq "p") && ($stype eq " "))
      {
         return('preface');
      }
      elsif (($type eq "o") && ($stype eq " "))
      {
         return('postface');
      }
      elsif (($type eq "P") && ($stype eq " "))
      {
         return('poem');
      }
      elsif (($type eq "l") && ($stype eq " "))
      {
         return('letter');
      }
      elsif (($type eq "T") && ($stype eq " "))
      {
         return('theatre');
      }
      elsif (($type eq "H") && ($stype eq " "))
      {
         return('radio');
      }
      elsif (($type eq "O") && ($stype eq " "))
      {
         return('scenario');
      }
      elsif (($type eq "a") && ($stype eq " "))
      {
         return('article');
      }
      elsif (($type eq "l") && ($stype eq " "))
      {
         return('letter');
      }
      elsif (($type eq "R") && ($stype eq " "))
      {
         return('novel');
      }
      elsif (($type eq "r") && ($stype eq " "))
      {
         return ('novella');
      }
      elsif (($type eq "N") && ($stype eq " "))
      {
         return ('shortstory');
      }
      elsif (($type eq "u") && ($stype eq " "))
      {
         return ('fix-up-element');
      }
      elsif (($type eq "n") && ($stype eq " "))
      {
         return('shortshort'); # Micronouvelle
      }
      elsif ($type eq "E")
      {
         return('essai');
      }
      elsif (($type eq "b") && ($stype eq " "))
      {
         return('bio');
      }

      elsif ($type eq "C")
      {
         if ($hg eq 'C') {
            return('section');
         }
	 else {
            return('chroniques');
         }
      }

      elsif (($type eq "U") && ($stype eq " "))
      {
         return('fix-up'); # TBD voir comment on gŠre. Plut“t roman, avec ou sans contenu ?
      }
      elsif (($type eq "U") && ($stype ne " "))
      {
         return('fix-up'); # TBD voir comment on gŠre. Plut“t roman, avec ou sans contenu ?
      }
      elsif (($type eq "G") && ($stype eq " "))
      {
         return('essai'); # TBD essai ou guide ?
      }
      elsif (($type eq "F") && ($stype eq " "))
      {
         return('novel'); # TBD novel (avec info "is_novelisaion") ou novelisation ?
      }
      elsif (($type eq "S") && ($stype eq " "))
      {
         return('novel'); # TBD novel (avec info "est novelisaion de s‚rie t‚l‚") ou novelisation ?
      }
      elsif (($type eq "V") && ($stype eq " "))
      {
         return('novel'); # TBD novel (avec info " est novelisaion de jeu video :-) ") ou novelisation ?
      }
      elsif (($type eq "A") && ($stype ne " "))
      {
         return('anthologie');
      }
      elsif ((($type eq "N") || ($type eq "n") || ($type eq "R") || ($type eq "r") || ($type eq "C") || ($type eq "Y"))
          && ($stype ne " "))
      {
         return('collection');
      }
      elsif ($type eq "M")
      {
         return('magazine');
      }
      elsif ($type eq "d")
      {
         return('comics');
      }
      elsif ($type eq "Z")
      {
         return('gamebook');
      }
      elsif ($type eq "?")
      {
         return('unknown');
      }


    elsif ($type eq "X")
    {
       return('novel'); # TBD voir comment on gŠre (ajout (extrait) ?)
    }
    elsif ($type eq "x")
    {
       return('shortstory'); # TBD voir comment on gŠre (ajout (extrait) ?)
    }
    elsif (($type eq "I") && ($stype eq " "))
    {
       return('article'); # TBD voir comment on gŠre : ajout "interview" en commentaire, ou type "article" ?
    }
    # {
    #    return('extract');
    # }
    # elsif ((($type eq "X") || ($type eq "x") || ($type eq "t")) && ($stype eq " "))
    # {
    #    return('extract');
    # }

    # elsif (($type eq "Y") && ($stype eq " "))
    # {
    #    $reference->{CMT_TYPE} = "[Collecte]";
    # }
    # elsif (($type eq "E") && ($stype eq "N"))
    # {
    #    $reference->{CMT_TYPE} = "[Essai et nouvelles]";
    # }
    # elsif (($type eq "P") && ($stype ne " "))
    # {
    #    $reference->{CMT_TYPE} = "[Recueil de poŠmes]";
    # }
    # elsif (($type eq "T") && ($stype ne " "))
    # {
    #    $reference->{CMT_TYPE} = "[Recueil de piŠces]";
    # }
    # elsif (($type eq "C") && ($stype ne " "))
    # {
    #    $reference->{CMT_TYPE} = "[Textes li‚s ou enchass‚s]";
    # }

}

sub texte_hg
{
   $info= $_[0];
   if (($info eq 'x') || ($info eq '!')) { return ('non'); }
   if ($info eq '?') { return ('inconnu'); }
   if ($info eq 'p') { return ('partiel'); }
   return ('oui');
}

sub texte_genre
{
   $info= $_[0];
   $g1= $_[1];
   $g2= $_[2];

   return 'sf';
}

sub texte_cop
{
   $info= $_[0];
   $result = $info;
   # TODO : il faut voir comment g‚rer les quelques dates d'‚criture [xxxx] - en description ?
   # TODO : il faut voir comment r‚cup‚rer et g‚rer les r‚visions
   if (substr($result,0,1) eq "[")
   {
      $result = substr($result,7);
   }
   if (substr($result,4,1) eq "-")
   {
      $result = substr($result,5);
   }
   return $result;
}

sub texte_vo
{
   $info= $_[0];
   $result = $info;
   $result=~s/\"/'/g;
   return (oem2utf($result));
}

sub revision_trads
{
   $info= $_[0];
#   print "Revision trad - DEBUT [$info]\n";
   $reste = "";
   ($trads, $reste) = split (/ \+ /, $info, 2);
   if ($reste eq "") {
      return "";
   }
#  print "Revision trad - reste [$reste]\n";

   $comment = "Traduction de " . normalize_traducteurs($trads) . oem2utf(" r‚vis‚e par ") .  normalize_traducteurs($reste) . ".";
#   print "Revision trad - FIN [$comment]\n";

   return ($comment);
}

sub normalize_traducteurs
{
   $info= $_[0];
   $info=~s/ \+ /, /g;
   $info=~s/ & /, /g;
   $info=~s/ et /, /g;

   my @trads = split (/, /, $info);
   my @new_trads;

   foreach $trad (@trads) {
       $new_trad = reverse_name($trad);    
       push @new_trads, $new_trad;
   }
   $result = join(', ', @new_trads);
   return (oem2utf($result));
}

sub reverse_name
{
   $info= $_[0];
   #  print "Reverse nom - DEBUT [$info]\n";
   $info=~s/ +$//o;
   $info=~s/^ +//o;

   @mots = split (/ /, $info);
   $count = @mots;
   if ($count == 1)
   {
      $result = ucfirst(lc($info));
   }
   else
   {
      #TODO
      # On r‚pŠte 4 fois (le max de "nom" actuel dans ma base) / ou pour chaque morceau de nom pour simplifier :
      # Si le premier morceau de nom fait partie du nom, le d‚caler en fin
      for ($i=0 ; $i<$count ; $i++) {
         if (is_name($morceau = shift(@mots)) == 0)
         {
            unshift(@mots, ucfirst(lc($morceau)));
         }
         else
         {
            push(@mots, ucfirst(lc($morceau)));
         }
      }
      $result = join (' ', @mots);
   }

   #   print "Reverse nom - FIN [$result]\n";
   return $result;
}

sub is_name
{
   $info= $_[0];
   #   print "Is name - DEBUT [$info]\n";

   # Si le nom fait deux lettres, toutes deux majuscules
   # ... ou si le nom fait plus de deux, avec la premiŠre et la troisiŠme majuscule
   if ((length($info) == 2) &&
       (substr($info, 0, 1) ge 'A') &&  (substr($info, 0, 1) le 'Z') &&
       (substr($info, 1, 1) ge 'A') &&  (substr($info, 1, 1) le 'Z'))
   {
      return 1;
   }
   elsif ((length($info) > 2) &&
       (substr($info, 0, 1) ge 'A') &&  (substr($info, 0, 1) le 'Z') &&
       (substr($info, 2, 1) ge 'A') &&  (substr($info, 2, 1) le 'Z'))
   {
      return 1;
   }

   return 0;
}

sub liste_trads
{
   $info= $_[0];

   # TBD TODO revoir en fonction du stockage et recherche des traducteurs
   #   return (normalize_traducteurs($info));

   return (oem2utf($info));
}

sub pub_hg
{
   $info= $_[0];
   if (($info eq 'x') || ($info eq '!')) { return ('non'); }
   if ($info eq 'p') { return ('partiel'); }
   return ('oui');
}

sub genrestat
{
   $info= $_[0];
   $g1= $_[1];
   $g2= $_[2];

   if (($info eq 'x') || ($info eq '!')) {
      return ('mainstream');
   }
   if ($g1 eq 'S') { return 'sf'; }
   if ($g1 eq 'Y') { return 'fantasy'; }
   if (($g1 eq 'F') || ($g1 eq 'K') || ($g1 eq 'M') || ($g1 eq 'N') || ($g1 eq 'O') || ($g1 eq 'V')) { return 'fantastique'; }
   if (($g1 eq 'I') || ($g1 eq 'U')) { return 'hybride'; }
   if (($g1 eq 'Z') || ($g1 eq 'G') || ($g1 eq 'T')) { return 'autre'; }

   if ($g2 eq 'S') { return 'sf'; }
   if ($g2 eq 'Y') { return 'fantasy'; }
   if (($g2 eq 'F') || ($g2 eq 'K') || ($g2 eq 'M') || ($g2 eq 'N') || ($g2 eq 'O') || ($g2 eq 'V')) { return 'fantastique'; }
   if (($g2 eq 'I') || ($g2 eq 'U')) { return 'hybride'; }
   if (($g2 eq 'Z') || ($g2 eq 'G') || ($g2 eq 'T')) { return 'autre'; }

   return 'inconnu';
}

sub pub_type
{
   $type= $_[0];
   $stype= $_[1];

   if ($stype eq " ") {
      # contenu simple
      if (($type eq "T") || ($type eq "R") || ($type eq "U") || ($type eq "F") || ($type eq "S") || ($type eq "V"))
      {
         return('roman');
      }
      elsif (($type eq "P") || ($type eq "r") || ($type eq "N") || ($type eq "O") || ($type eq "X"))
      {
         return('fiction');
      }
      elsif (($type eq "l") || ($type eq "a") || ($type eq "E") || ($type eq "b") || ($type eq "G") || ($type eq "Z"))
      {
         return('non-fiction');
      }
      elsif ($type eq "M")
      {
         return('periodique');
      }
   }
   else
   {
      # ensemble de textes
      if (($type eq "R") && ($stype ne "N"))
      {
         return('omnibus');
      }
      elsif (($type eq "P") || ($type eq "T") || ($type eq "R") || ($type eq "r") || ($type eq "N") || ($type eq "n") || ($type eq "C") || ($type eq "A") || ($type eq "Y"))
      {
         return('compilation');
      }
      elsif ($type eq "M")
      {
         return('periodique');
      }
      elsif ($type eq "U")
      {
         return('roman');
      }
      elsif (($type eq "E") || ($type eq "G"))
      {
         if ($stype eq "N")
         {
            return('compilation');
         }
	 else
         {
            return('non-fiction');
         }
      }
   }

}

sub title_exists
{
   $memo= $_[0];
   $curr_id= $_[1];

   $idtitle="E:/sf/titres.id";

   #   print "DEBUG: recherche [$memo]\n";

   open (f_tit, "<$idtitle");
   @idtitles=<f_tit>;
   close (f_tit);

   $pat = quotemeta($memo);
   @foundtitles = grep(/$pat/, @idtitles);
   if (scalar(@foundtitles) > 1)
   {
      # si plus de deux entr‚es... ‡a veut dire que ‡a marche pas
      printf STDERR "*** Error 2 fois dans le fichier des id tites ?! ***\n";
      printf STDERR " [$memo]\n";
      exit;
   }
   elsif (scalar(@foundtitles) == 1)
   {
      $stored = $foundtitles[0];
      ($oid, $reste) = split (/\t/, $stored);
      #      print "DEBUG: d‚j… trouv‚ [$oid] [$memo]=[$stored]\n";
      return $oid;
   }
   else
   {
      # Pas trouv‚ -> il faut l'ajouter, avec son nouvel ID
      $curr_id++;

      $to_file="$curr_id	$memo";
      open (WTITLE, ">>$idtitle");
      $file_titles_id=WTITLE;
      print $file_titles_id "$to_file\n";
      #      print "DEBUG: ajout [$to_file]\n";
      close (WTITLE);

      return 0;
   }
}

sub getnomcoll()
{
   $mysig= $_[0];

   @edicols = grep(/^${mysig}	/, @idcolls);
   if (scalar(@edicols) > 1)
   {
      # si plus de deux entr‚es, pas grave pour les ‚diteurs
      # par contre pour les collections, il faudra trouver un id coll diff‚rent de 0
      # print "ERREUR, \"${sigle}\" a deux entr‚es ?! !\n";
      $edicol = $edicols[0];
      chop ($edicol);
      ($sigsig, $editeur, $collection, $coll_parent, $reste) = split (/\t/, $edicol);
      return $reste;
   }
   elsif (scalar(@edicols) == 1)
   {
      $edicol = $edicols[0];
      chop ($edicol);
      ($sigsig, $editeur, $collection, $coll_parent, $reste) = split (/\t/, $edicol);
      # print "OK : [$sigle] trouv‚ ! : [$edicol] [$editeur] \n";
      return $reste;
   }
   else
   {
      print "ERREUR : sigle [$mysig] non trouv‚ ? \n";
      return $mysig;
   }
}

sub getordercycle ()
{
   $ncyc= $_[0];

   if (($ppp = index(($ncyc), "/")) eq -1)
   {
      return $ncyc;
   }
   else
   {
      $lastplus = substr($ncyc, $ppp+1);
      $lastplus = $lastplus + 0.01;
      return $lastplus;
   }
}
