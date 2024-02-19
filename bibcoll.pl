$DBG=2;
$texte_debug = $DBG == 1 ? "Mode normal" : "Infos manquantes";

#===========================================================================
#
# Script de generation des pages collections
#
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
#  v1.6  - 10/11/2006 Reintegration de la generation par sigle
#                     Ajout d'un style officiel/debug
#  v1.7a - 17/11/2006 Suppression type fichier, cryptage, annee si inutiles + corrections
#                     Ajout image en popup deplacable
#  v1.7  - 27/11/2006 Ajout lien auteur, traitement bloc d'entete version 1, 
#                     Groupement par N couvs
#  v1.8  - 05/12/2006 Gestion collec.res, mélange sigle, nb couvs si rééd.
#  v1.9  - 12/12/2006 Harmonisation notation collection, img logo et collection 
#                     Cas des sigles "multiples", regroupement traitement o et +
#                     Refonte affichage (en fin de ref complete), correc collab 
#  v2.0  - 12/12/2006 Aff edit/coll+cible; gestion TIT_COLL pour titre page
#                     Bloc header Afficher/cacher les infos - Page conforme
#  v2.1  - 14/12/2006 Affichage ligne supp type - isbn - trad - genre; bouton afficher/cacher
#                     Groupes d'images dans un div. - Bouton cacher/afficher pour les images
#  v2.2  - 14/12/2006 Scripts dans fichier js, gestion mode "aide" (surimpression des infos incomplètes)
#                     OK - Passer tous les scripts dans un fichier js outils
#                     OK - gestion propre du mode debug (bouton normal / debug ?)
#                    x option g‚n‚ration : debug / non : bouton [debug | normal]
#                    x si oui : debug par defaut, sinon normal
#                    x dans tous les cas : mise en vert si debug - normal ou non affiche si normal
#                     OK - Amelioration scripts, fonctions aff_xxx(mode) + function switch_xxx() appelant aff_
#  v2.3  - 27/08/2007 css pop dans fihier css, ajout image vnoimg
#                     ajout <span id> pour les infos titres, permet suppression
#                     et ajout bouton <vignettes seules>
#  v2.4  - 18/10/2007 : Passage a l'extension PHP
#                       Suppression autres sorties locales (DOS, WINDOWS, HTML) 
#  v2.5  - 15/11/2007 : Ajout des liens vers recueils et anthologies
#  v2.6  - 11/06/2008 : Essai ajout piclens
#  v2.7  - 14/10/2009 : Nouveau moteur affichage des couvertures
#  v2.7  - 17/02/2009 : Nouveaux scripts js (jquery)
#  v3.0  - 12/10/2010 : upload automatique par defaut
#  v3.1  - 17/04/2011 : modification sigle en titre dans le "vous ˆtes ici"
#  v3.2  - xx/04/2011 : renommage du fichier "sigle" en "nom_collec"
#  v4.0  - 22/11/2019 : Gestion des liens pour les FixUp - Gestion des ISBN r‚troactifs - Ajout des illustrateurs de couv.
#  v4.1  - 21/04/2020 : Correction num‚ro multiple; ajour lien recueils th‚ƒtre; 
#  v4.2  - xx/04/2020 : ajout de lignes pour r‚‚ditions; affichage n/a si pas d'illustration de couverture
#
# Faire (facile) : formate_date pour afficher avec ou sans "tbc"
#
#    chercher A FAIRE
#     
#            Comment g‚rer les collections de mm nom ? nom_collec_id ?
#       
#        A faire : voir plus bas
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl collec.pl <sigle> :
#            generation fichier xhtml/php sur site
#
#---------------------------------------------------------------------------
#
# PB
#  --- Version 1.7
#  OK - Lien sur s‚rie erron‚
#  OK - Image en popup sur click
#  OK - degraissage (fichier, crypte, type sortie...)
#  OK - suppression ann‚e si groupement par ann‚e
#  OK - Image en popup qu'on peut faire mumuse avec (treeees urgent)
#  OK - "!--." si pas de saut de ligne sur commentaire
#  OK - pr‚voir de pouvoir grouper par "N" livres plutot que par ann‚e
#  OK - Traitement bloc d'entete
#  OK - Ajouter lien auteurs
#
#  --- Version 1.8
#  OK - Gestion des "melanges" de collections, avec reed ou non
#  OK - Rechercher sigle dans collec.res d'abord
#  OK - Extraire du fichier collec.res et afficher le(s) lien(s) forum
#  OK - Nettoyage des tests du contenu puisque filtre fait précédemment (contenu_xxx, last_multi...)
#  OK - Pas de lien si anthologiste inconnu (***)
#  OK - Ne pas s'arrêter au nombre de couvs si réédition
#  OK - Prevoir le cas sigles mélangés (entêtes différents : filtre - modèle ENT GRP header ENT)
#  OK - Harmoniser la notation collection, step 1
#        DEB, GRP et FIN deviennent DEB_HEAD, GRP_OUVR et FIN_COLL
#  OK - Harmoniser la notation collection, step 2 : ajout FIN_HEAD et DEB_HEAD
#
#  --- Version 1.9
#  OK - Harmoniser la notation collection, step 3 : Prevoir image logo, image(s) éventuelle(s) d'illustration collection
#  OK - Ajouter traitement IMG_LOGO (non popup-able) et IMG_COLL (popup-able)
#  OK - Ne laisser dans collec.res que l'Id du topic
#  OK - ===> impact dans ix_coll.pl aussi
#  NON - Possibilité dans collec.res de plusieurs Id de topic (937;930) ==> un seul lien (sinon source de pbs)
#  OK - Début et fin d'entête, ne plus prendre !--- mais DEB et FIN de _HEAD
#  OK - Différencier le mode mono-sigle du multi-sigle (* dans collec.res)
#  OK - Traiter les cas des pages "sigles multiples"
#       X OK  : Prevoir une marque et un sigle speciaux dans collec.res (*1234567 par exemple)
#       X NON : Entête : lien sur pages unitaires ?
#       X Traitement entete : idem page simple,avec sigle special "multiple"
#       X Controle existence DEB_HEAD
#       X Le premier DEB_COLL de la liste signe le début de la collection
#       X Le dernier FIN_COLL de la liste signe la fin de la collection
#       X Traitement contenu : collecte a partir de la liste de sigles admis
#  OK - regroupement traitements o et +
#  OK - Tagger la fin d'un ouvrage (nouveau 'o' ou '!' ou ???) [debut="o"]
#  OK - refont des affichages : a la fin complète d'un ouvrage
#  OK - pb collaboration : les autres auteurs apparaissent apres toutes infos !
#
#  --- Version 2.0
#  OK - Nettoyer prefixe / suffixe
#  OK - Extraire du fichier collec.res et afficher la cible (jeunesse, adulte)
#  OK - Affichage également (hors futur bloc) : editeur: <xxx> collection: <xxx> sous-collection: <xxx> cible: <xxx>
#  OK - Ajout TIT_COLL dans le header pour affichage du titre choisi (que collection, que editeur, autre...)
#  OK - Pb des titres des sigles "multiples" => via TIT_COLL
#  OK - Mettre le header dans un bloc expandable (y compris images coll et logo)
#  OK - Page conforme (validation xhtml / css)
#
#  --- Version 2.1
#  OK - prevoir lignes supplementaire, non affichee par defaut
#  OK - prevoir bouton pour enlever les lignes suppl
#  OK - afficher type sur une seconde ligne
#  OK - afficher ISBN sur une seconde ligne
#  OK - afficher traducteur sur une seconde ligne
#  OK - afficher genre sur une seconde ligne
#  OK - prévoir bouton pour cacher les images
#  OK - afficher/cacher les images (chaque groupe d'images dans un div)
#  OK - Fix : Bug pas d'annee affichee au debut
#  OK - Fix : Bug double 'br' avant derniere ligne sur bib_mar
#  OK - Fix : Bug affichage "- ()" au debut
#  OK - Fix : Bug sur les prefixes
#  OK - Fix : Bug les groupes couv commencent parfois a 2 (si annees)
#  OK - Fix : Bug si reedition en mode annee, un groupe "annee de reed" s'intercale
#
#  --- Version 2.2
#  OK - Passer tous les scripts dans un fichier js outils
#  OK - gestion propre du mode debug (bouton normal / debug ?)
#        x option g‚n‚ration : debug / non : bouton [debug | normal]
#        x si oui : debug par defaut, sinon normal
#        x dans tous les cas : mise en vert si debug - normal ou non affiche si normal
#  OK - Amelioration scripts, fonctions aff_xxx(mode) + function switch_xxx() appelant aff_
#
#  --- Version 2.3
#  22 - Passer les styles dans les fichiers css ? (a voir)
#  22 - Pas de lien si auteurs non référencé, en général hors genre ou préface (pas dans auteurs.res)
#       ===> ne pas mettre dans auteurs.res les auteurs de préface, postface, etc
#  22 - Faire possibilité d'un sous-index des pages (exemple marabout : par collection, par éditeur, par genre)
#  22 - Gérer les index d'index
#  22 - ajout des notes pour certains ouvrages
#  22 - distinguer notes affichables des non affichables
#  22 - Traiter mieux les cas des pages "sigles multiples"
#       - mettre l'étoile également dans fichier .col ? (pour distinguer des sigles mono)
#       - afficher la collection exacte, ou un sigle évocateur, ou une lettre ?
#              ex marab : [G] [B] [S] [F] [N] (mais rien dans un premier temps)
#              ou       : [Geant] 
#  OK - Pb collaboration : non prise en compte, NB_AUT jamais incr‚ment‚ !
#
#  --- Version 2.4 et plus
#  24 - : rendre les pages obtenues conformes
#  24 - : passage a l'extension php
#  25 - : liens anthos et recueils
#  26 - : 
#  27 - : 
#  28 - : Nouveau moteur js (utilisation jquery)
#
#  41 - : Correction : les num‚ros multiple ne marchent pas (cf Neo)
#
#  xx - Revoir la fa‡on d'afficher les "boutons"
#  xx - Pr‚voir un type ann‚e / pas ann‚e, mix‚ avec le nombre d'images par groupe
#  xx - Faire le lien sur une page auteur si le traducteur … une page
#  xx - Voir comment traiter les r‚‚ditions (localement, en fin, ou via une variable de config
#  xx - Etudier un possible export JSON, trait‚ localement par la page ?
#  xx - Groupe d'ann‚e marche pas si reed. classee en "o" (par exemple pour contenu modifie)
#       remplacer par '+' ? (tous .pl potentiellement impactés)
#       marche pas bien non plus si années intercalees => passer en mode groupe
#  xx - : am‚liorer les boutons dispo (bloc boutons droite, bloc titre gauche) avec flottant et marge
#  xx - : boutons remplacer par checkin ? (Affichage 'couv', 'titres', 'info')
#  xx - :  Et remplacer "Plus d'infos" par un [+]
#
#  xx - Commentaires : Ajout du caractŠre # pour commentaires purement locaux (entete fichier, remarques...)
# ---   - # pour commentaires a ne jamais exporter : niveau fichier, infos editeur, divers...
# ---   - ! entetes (exportables) et commentaires divers non exportables
# ---   - > commentaires exportables pour ouvrage, oeuvre ou texte
#
#---------------------------------------------------------------------------
#  Harmonisation de la notation collection :
#    !DEB_HEAD <sigle>      (sigle .col ou sigle multiple collec.res)
#    _ <sigle>  nom
#    !GRP_OUVR <nb>         (optionnel)
#    !TIT_COLL <titre>      (titre collection)
#    !IMG_LOGO <image>      (image(s) logo, optionnel)
#    !IMG_COLL <image>      (image(s) coll. complete ou autre vue, optionnel)
#    ! (entete)
#    !FIN_HEAD <sigle>      (signe la fin de l'entete)
#    !DEB_COLL <sigle>      (sigle simple uniquement)
#     (ouvrages)      (... du sigle ou d'un autre ...)
#    !FIN_COLL <sigle>
#
#
#===========================================================================
push  (@INC, "c:/util/");
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
my $livraison_site=$local_dir . "/collections/pages";
#---OLD my $imgrec="http://www.bdfi.info/recueils/";
#my $imgrec2="http://www.bdfi.info/vignettes/";
# Pour tests locaux sans images
#my $imgrec2="images/";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
my $type_tri=0;
my $no_coll=0;
my $old_date=0;
my $titre_coll="";
my $id_ouv=0;
my $upload=1;

my $taille_vignette ="MEDIUM";
my $type_style="DEBUG";
my $first_sigle=0;
my $max_couv_groupe=0;

sub usage
{
   print STDERR "usage : $0 [-o|-d|-u] <sigle_collection>\n";
   print STDERR "\n";
   print STDERR "        -u : pas d'upload du fichier\n";
   print STDERR "\n";
   exit;
}

if ($ARGV[0] eq "")
{
   usage;
   exit;
}
my $i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-o")
   {
      $type_style ="OFFICIEL";
   }
   elsif ($ARGV[$i] eq "-d")
   {
      $type_style ="DEBUG";
   }
   elsif ($ARGV[$i] eq "-m")
   {
      $taille_vignette ="MEDIUM";
   }
   elsif ($ARGV[$i] eq "-u")
   {
      $upload = 0;
   }
   else
   {
      $param=$ARGV[$i];
   }
   $i++;
}

#---------------------------------------------------------------------------
# Recherche du sigle et de ses associes
#---------------------------------------------------------------------------
$sigle=$param;
my $mode_sigle="MONO"; # MONO ou MULTI

#---------------------------------------------------------------------------
# 0. rechercher existence et type de sigle dans collec.res
#    Lecture du fichier collections
#---------------------------------------------------------------------------
my $file_col="collec.res";
open (f_col, "<$file_col");
my @col=<f_col>;
close (f_col);

$chaine = "^\*?$sigle	"; # rechercher sigle tel quel ou precede de *
@res = grep(/$chaine/, @col);
$nb=$#res+1;
 
if ($nb == 0) { print "Erreur : sigle [$sigle][$chaine] non trouve dans [collec.res]\n"; exit; }
elsif ($nb != 1) { print "Erreur : plusieurs sigle [$sigle][$chaine] dans [collec.res]\n"; exit; }

print "DBG: OK sigle [$res[0]]\n";
chop($res[0]);
($fsig, $typg, $nom, $souscoll, $editeur, $topic, $multi)=split (/\t/, $res[0]);

$editeur=~s/ \[(.*)\]//;
if ($editeur eq "*") { $editeur="multiples"; }
$nom=~s/ \[(.*)\]//;
$souscoll=~s/ \[(.*)\]//;
if ($souscoll eq "-") { $souscoll=""; }

my $type = substr($typg,0,1);
if ($type eq "C") { $type = "Collection"; }
elsif ($type eq "K") { $type = "Sous-collection"; }
elsif ($type eq "S") { $type = "S‚rie"; }
elsif ($type eq "R") { $type = "Revue"; }
elsif ($type eq "A") { $type = "Auto-‚dition"; }
elsif ($type eq "F") { $type = "Fanzine"; }
elsif ($type eq "E") { $type = "Edition"; }

my $adeq = substr($typg,1,1);
if ($adeq eq "2") { $adeq = ""; }
elsif ($adeq eq "1") { $adeq = " partiellement hors genres, contenant des ouvrages "; }
elsif ($adeq eq "0") { $adeq = " majoritairement hors genres, contenant quelques ouvrages "; }

my $genre1 = substr($typg,2,1);
if ($genre1 eq ".") { $genre1 = ""; }
elsif ($genre1 eq "I") { $genre1 = ""; }
elsif ($genre1 eq "S") { $genre1 = " de science-fiction"; }
elsif ($genre1 eq "Y") { $genre1 = " de fantasy"; }
elsif ($genre1 eq "F") { $genre1 = " de fantastique"; }
elsif ($genre1 eq "T") { $genre1 = " de terreur"; }
elsif ($genre1 eq "G") { $genre1 = " de gore"; }
elsif ($genre1 eq "P") { $genre1 = " de policier"; }
elsif ($genre1 eq "A") { $genre1 = " d'aventures"; }
elsif ($genre1 eq "K") { $genre1 = " d'‚trange"; }
elsif ($genre1 eq "Z") { $genre1 = " de fiction pr‚historique"; }

my $genre2 = substr($typg,3,1);
if ($genre2 eq ".") { $genre2 = ""; }
elsif ($genre2 eq "S") { $genre2 = " et science-fiction"; }
elsif ($genre2 eq "Y") { $genre2 = " et fantasy"; }
elsif ($genre2 eq "F") { $genre2 = " et fantastique"; }
elsif ($genre2 eq "T") { $genre2 = " et terreur"; }
elsif ($genre2 eq "G") { $genre2 = " et gore"; }
elsif ($genre2 eq "P") { $genre2 = " et policier"; }
elsif ($genre2 eq "A") { $genre2 = " et aventures"; }
elsif ($genre2 eq "K") { $genre2 = " et d'‚trange"; }
elsif ($genre2 eq "Z") { $genre2 = " et de fiction pr‚historique"; }

# Infos cible
my $cible = substr($typg,4,1);
if ($cible eq ".") { $cible = ""; }
elsif ($cible eq "a") { $cible = " - Lectorat : adolescent/adulte"; }
elsif ($cible eq "P") { $cible = " - Lectorat : partiellement adulte"; }
elsif ($cible eq "A") { $cible = " - Lectorat : adulte"; }
elsif ($cible eq "J") { $cible = " - Lectorat : jeunesse"; }

my $edicoll= "Editeur : $editeur - Collection : $nom $souscoll";
my $comment= $type . $adeq . $genre1 . $genre2 . $cible . ".";
# chop($topic);
$forum="https://forums.bdfi.net/viewtopic.php?id=$topic";

if (substr ($fsig, 0, 1) eq "*") {
   $fsig=substr($fsig, 1);
   $mode_sigle="MULTI"; 
   @liste_sigles=split(/;/, $multi);
   $nb_sigles=$#liste_sigles + 1;
   print "Mode $mode_sigle - [$fsig] - nb sigles: [$nb_sigles] --> [@liste_sigles]\n";
}
else
{
   print "Mode $mode_sigle - [$fsig]\n";
}


#---------------------------------------------------------------------------
# 1. verifier si le sigle existe (uniquement si mono-sigle)
#    Lecture du fichier sigles
#---------------------------------------------------------------------------
if ($mode_sigle eq "MONO") {
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
}

#---------------------------------------------------------------------------
# 2. retrouver le bon fichier COL
#---------------------------------------------------------------------------
if ($mode_sigle eq "MONO") {
   $chaine = "^_ $sigle ";
}
else {
   $chaine = "^!DEB_HEAD $sigle";
   $chaine=~s/ +$//o;
   $chaine = $chaine . "\$";
}

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
   @res = grep(/$chaine/, @col);
   $nb=$#res+1;
   if ($nb == 0) { next; }
   elsif ($nb == 1) {
      print "DBG: OK file [$file]\n";
      last;
   }
   else { print "Erreur : plusieurs sigle [$sigle] ($chaine ) dans [$col]\n@res\n"; exit; }
}
if ($nb != 1)
{
   print "Erreur : sigle [$sigle] ($chaine) non trouve dans les fichiers col\n";
   exit;
}

#---------------------------------------------------------------------------
# 4. restreindre le fichier col aux lignes "utiles"
#---------------------------------------------------------------------------
$en_cours="DEBUT";  # "OK" "FIN"

my $prendre="OUI";
my $prendre_ouv = "NON"; 
my $compteurs_sig=0;

foreach $ligne (@col)
{
   $lig=$ligne;
   chop ($lig);
   $len=length($lig);
   $marqueur=substr ($lig, 0, 9); 
   $sig=substr ($lig, 10, 7);
   $prem =substr ($lig, 0, 1); 
   $sig=~s/ +$//;
   $coll=substr ($lig, $coll_start, $coll_size);
   $coll=~s/ +$//;

   # DBG print "--- $en_cours\n"; 

   # FAIRE --- prevoir un mode multi-sigle (pour page "tout marabout" par exemple)
   # FAIRE >>> a prevoir aussi dans le collec.res

   # Mode "mono-sigle" 
   if ($marqueur eq '!DEB_HEAD')
   {
      if ($sig eq $sigle) { $en_cours="OK"; push (@collec, $ligne); }
   }
   elsif ($marqueur eq '!FIN_HEAD')
   {
       if ($sig eq $sigle) { $en_cours="FIN"; push (@collec, $ligne); } # Devient obligatoire
   }
   elsif ($marqueur eq '!DEB_COLL')
   {
      if (($mode_sigle eq "MONO") && ($sig eq $sigle)) { $en_cours="OK"; } # Encore optionnel
      # Si mode multi et appartient à la liste (dès le premier)
      if (($mode_sigle eq "MULTI") && ($en_cours ne "OK")) {
          @sig_exist = grep(/^${sig}$/, @liste_sigles);
          if ($#sig_exist == 0) { $en_cours="OK"; }
          # FAIRE : test si > 2 erreur !
      }
   }
   elsif ($marqueur eq '!FIN_COLL')
   {
      if (($mode_sigle eq "MONO") && ($sig eq $sigle)) { $en_cours="FIN"; }
      # Compter le nombre, et si max => fin
      if (($mode_sigle eq "MULTI") && ($en_cours eq "OK")) {
          @sig_exist = grep(/^${sig}$/, @liste_sigles);
          if ($#sig_exist == 0) { $compteur_sig += 1; }
          # FAIRE : test si > 2 erreur !
          if ($compteur_sig == $nb_sigles) { $en_cours="FIN"; }
      }
   }
   elsif ($marqueur eq '!GRP_OUVR')
   {
      # Nombre d'elements pour alternance titres / couvertures
      if ($en_cours eq "OK") { $max_couv_groupe = $sig; }
   }
   elsif ($marqueur eq '!TIT_COLL')
   {
      # Titre a afficher
      if ($en_cours eq "OK") { $titre_coll = substr ($lig, 10); }
   }
   elsif ($en_cours eq "OK")
   {
      # Reduire aux lignes "utiles" (hors contenu)
      if ($prem eq 'o') {
         if ($mode_sigle eq "MONO") {
            if ($coll eq $sigle) { $prendre = "OUI"; $prendre_ouv = "OUI"; }
            else  { $prendre_ouv = "NON"; $prendre = "NON"; }
         }
         else
         {
            @sig_exist = grep(/^${coll}$/, @liste_sigles);
            if ($#sig_exist == 0) { $prendre = "OUI"; $prendre_ouv = "OUI"; }
            else  { $prendre_ouv = "NON"; $prendre = "NON"; }
         }
      }
      elsif (($prem eq '+') || ($prem eq 'x')) {
         if ($mode_sigle eq "MONO") {
            if ($coll eq $sigle) { $prendre_ouv = "OUI"; $prendre = "OUI"; }
            else  { $prendre = "NON"; }
         }
         else
         {
            @sig_exist = grep(/^${coll}$/, @liste_sigles);
            if ($#sig_exist == 0) { $prendre = "OUI"; $prendre_ouv = "OUI"; }
            else  { $prendre = "NON"; }
         }
      }
      elsif (($prem eq '-') && ($prendre_ouv eq "OUI")) {
         $prendre = "OUI";
         $prendre_ouv = "NON";
      }
      elsif ($prem eq ':') { $prendre = "NON"; }
      elsif ($prem eq '=') { $prendre = "NON"; }
      elsif ($prem eq ')') { $prendre = "NON"; }
      elsif ($prem eq '?') { $prendre = "NON"; }
      elsif ($prem eq '­') { $prendre = "OUI"; }
      elsif ($prem eq '¨') { $prendre = "OUI"; }
      elsif ($prem eq '*') { $prendre = "OUI"; }

      if ($prendre eq "OUI") {
         push (@collec, $ligne);
# print "$ligne";
      }
   }
}

#---------------------------------------------------------------------------
# 5. creer le nom du fichier pour la collection (premier sigle de la liste)
#---------------------------------------------------------------------------
$lien=lc($sigle);

#---------------------------------------------------------------------------
# Ouverture fichiers de sortie
#---------------------------------------------------------------------------
$outh="$livraison_site/$lien.php";
#PICLENS $outrss="$livraison_site/$lien.rss";
open (OUTH, ">$outh");
#PICLENS open (OUTRSS, ">$outrss");
$canalH=OUTH;
#PICLENS $rss=OUTRSS;

#PICLENS print "Sorties sur $outh et $outrss\n";
print "Sorties sur $outh\n";

&web_begin($canalH, "../../commun/", "Fichier collection");
&web_data ("<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />\n");
&web_head_meta ("author", "Richardot Gilles, Moulin Christian, Equipe BDFI");
&web_head_meta ("description", "Fichier collection");
&web_head_meta ("keywords", "collection, edition, editeur, roman, nouvelles, imaginaire, SF, sienceiction, fantastique, fantasy, horreur");
#PICLENS print $rss "<?xml version='1.0' encoding='utf-8' standalone='yes'?>\n";
#PICLENS print $rss "<rss version='2.0'\n";
#PICLENS print $rss "xmlns:media='http://search.yahoo.com/mrss'\n";
#PICLENS print $rss "xmlns:atom='http://www.w3.org/2005/Atom'>\n";
#PICLENS print $rss "<channel>\n";

# A FAIRE : supprimer ça ???
&web_data ("<link rel='alternate' type='application/x-cooliris-quick' href='https://www.bdfi.net/collections/pages/cooliris-quick.xml' />\n");
&web_data ("<style type='text/css'>\n");
&web_data ("img { background: #ddd; }\n");
&web_data ("</style>\n");

&web_head_css ("screen", "../../styles/bdfi.css");

&web_head_js ("../../scripts/jquery-1.4.1.min.js");
&web_head_js ("../../scripts/jquery-ui-1.7.2.custom.min.js");
&web_head_js ("../../scripts/popup_v3.js");
&web_head_js ("../../scripts/outils_v2.js");
&web_data("<?php include('../../commun/image.inc.php') ?>");

&web_body_v2 (" onload='init_debug();'");
&web_menu (0, "");
# Inserer les index d'en-tete
#$lien=$file;
#$lien=lc($lien);
#$lien=~s/.col//;

# type ligne courant = debut
#
# Pour chaque ligne du fichier
#

$prefixe="";
$suffixe="";
$notes="";
$bloc_entete="AVANT";
$sigle_vu="NON";
@couvs=();
foreach $ligne (@collec)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   $lig=~s/ +$//;
   chop ($lig);
   $len=length($lig);
   $prem=substr ($lig, 0, 1);

   # Fin d'ouvrage
   if ($len == 0) { next; }

   $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
   $flag_num_a_suivre=substr ($lig, $typnum_start, 1);
   $flag_collab_a_suivre="";

   # memo du type de ligne
   $debut=substr ($lig, 0, 9);
   if (($prem eq '?') || ($prem eq '¨') || ($prem eq '­') || ($prem eq '*'))
   {
      #-----------------------------------------------------
      # Infos incompletes, a paraitre ou jamais paru
      #-----------------------------------------------------
      $prefixe="";
      if (substr($lig,1,1) eq 'o') {
         if ($prem eq '?') {
            $prefixe="Donn‚es … <span class='tbc'>compl‚ter ou confirmer</span> :";
         }
         elsif ($prem eq '¨') {
            $prefixe="Ouvrage … paraitre, <span class='tbc'>ou parution … confirmer</span> :";
         }
         elsif ($prem eq '­') {
            $prefixe="Ouvrage annonc‚ mais jamais paru :";
         }
         elsif ($prem eq '*') {
            $prefixe="Ouvrage dont l'appartenance aux genres est <span class='tbc'> … confirmer</span> :";
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
         &web_data (" <a class='expandable' alt='photo collection' href='<?php echo \$bdfi_url_couvs; ?>$initiale_couv/$couv'>\n");
         &web_data ("<img title='Cliquer pour agrandir' alt='photo collection' src='<?php echo \$bdfi_url_couvs_vignettes; ?>$initiale_couv/v_$couv' />\n");
         &web_data ("</a>\n");
      }
      else {
         &web_data ("<img style='margin:3px 2px; padding:0; border: 1px solid #888;' alt='logo collection' src='<?php echo \$bdfi_url_couvs; ?>$initiale_couv/$couv' />");
      }
   }
   elsif ($prem eq '_')
   {
      #-----------------------------------------------------
      # Si d‚finition de sigle : afficher le nom en titre
      # Uniquement si TIT_COLL n'existe pas
      # FAIRE : marche pas, car apres le DBG_HEAD => supprimer a terme
      #-----------------------------------------------------
      if ($titre_coll eq "") {
         $sig=substr ($lig, 2, 7);
         $sig=~s/ +$//o;
         $reste_lig=substr ($lig, 10);
         ($edc, $periode)=split (/þ/,$reste_lig);
         $edc=~s/ +$//o;
         $titre_coll=$edc;
         &web_data ("<h1><a name='$lien'>$titre_coll</a></h1>\n");
      }
      $sigle_vu = "OUI";  
   }
   elsif ($debut eq "!DEB_HEAD")
   {
      #-----------------------------------------------------
      # Signe de d‚but entete
      #-----------------------------------------------------
      if ($bloc_entete eq "AVANT") {

	 $bloc_entete = "PENDANT";
	 &affiche_menu_bib($titre_coll);

         &web_data ("<div id='bib_header'>\n");
         if ($titre_coll ne "") {
            &web_data (" <h1><a name='$lien'>$titre_coll</a></h1>");
         }
         &web_data ("$edicoll");
         &web_data (" &nbsp; &nbsp; &nbsp; &rarr; <a href='$forum'>Forum d‚di‚</a>, pour discussion et commentaires.");
         &web_data ("<br />\n");
         &web_data ("$comment");
         &web_data ("<br />\n <button id='head0' title=\"Compl&eacute;ment d'information sur la collection\" class='bib_button' onclick='switch_head();'>Afficher plus d'informations</button> &nbsp; &nbsp; ");
         &web_data (" &nbsp; &nbsp; &nbsp; ");
         &web_data (" &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;");
         &web_data (" <button id='dbg_0' title='Surlignage des informations incompl&egrave;tes' class='bib_button' onclick='switch_debug();'>" . $texte_debug . "</button>");
         &web_data ("\n <div id='head' style='display:none; margin: 5px 10px;'>\n");
      }
      else {
          print "Erreur ! plusieurs deb_head rencontres ?\n";
      }
   }
   elsif ($debut eq "!FIN_HEAD")
   {
      #-----------------------------------------------------
      # Signe de fin d'entete
      #-----------------------------------------------------
      if ($bloc_entete eq "PENDANT") {
         $bloc_entete = "APRES";
         &web_data ("  <div style='clear: both'></div>\n </div>\n");
         &web_data ("</div>\n<br />\n<div>\n");
         &web_data (" <button class='bib_button' onclick=\"onoff(this, 'covers');\">Cacher les couvertures</button>\n");
         &web_data (" <button class='bib_button' title='Afficher les vignettes seules' onclick=\"onoff(this, 'coldata');\">Cacher les infos ouvrages</button>\n");
         &web_data (" <button class='bib_button' title='Affiche les type, ISBN, traducteur et genre de chaque ouvrage' onclick=\"onoff(this, 'precision');\">Afficher les pr&eacute;cisions ouvrages</button>\n");
         &web_data (" <br />\n");
	 # Debut de bloc data - seulement si gestion sans annee
         if ($max_couv_groupe != 0) {
            &web_data (" <div class='coldata'>\n");
         }
      }
      else {
          print "Erreur ! plusieurs fin_head rencontres ?\n";
      }
   }
   elsif ($debut eq "!--------")
   {
      #-----------------------------------------------------
      # Commentaire "ligne"
      #-----------------------------------------------------
      if (($sigle_vu eq "OUI") && ($bloc_entete eq "PENDANT")) {
#          print $canalH "<br />\n";
      }
   }
   elsif ($prem eq '>')
   {
      #-----------------------------------------------------
      # Commentaire "Officiel"
      #-----------------------------------------------------
      $br=substr($lig, 3, 1);
      $lig=~s/^>-+\.* *//;
      # si commentaire vide (!, - space), ou ligne vide : rien
      if ($br ne "-")
      {
         $notes = $notes . " $lig\n";
      }
      else
      {
         $notes = $notes . "<br />\n$lig\n";
      }
   }
   elsif ($prem eq '!')
   {
      #-----------------------------------------------------
      # Commentaire divers
      #-----------------------------------------------------
# FAIRE :
# Mode debug seulement (des span invisibles) si hors bloc de presentation
     if ($bloc_entete eq "PENDANT") {
        $br=substr($lig, 3, 1);
        $lig=~s/^!-+\.* *//;
        $lig=~s#TBC#<span class='tbc'>A confirmer</span>#;
        $lig=~s#TBD#<span class='tbc'>A d&eacute;finir</span>#;
        # si commentaire vide (!, - space), ou ligne vide : rien
        if ($br ne "-")
        {
           $lig=~s/þ/___ /g;
           &web_data ("$lig\n");
        }
        else
        {
           &web_data ("<br />");
           &web_data ("$lig\n");
        }
     }
   }
   elsif (($prem eq 'o') || ($prem eq '+') || ($prem eq 'x'))
   {
      #-----------------------------------------------------
      # >>> Ligne reference support
      # Collection : "+" peut être un premier ouvrage, si 
      #  les reeditions sont en collections (légèrement) différentes
      #-----------------------------------------------------

      #-----------------------------------------------------
      # Fin éventuel de header
      #-----------------------------------------------------
      if ($bloc_entete eq "PENDANT") { # FAIRE : Pourra etre supprimé apres respect des FIN_HEAD
         $bloc_entete = "APRES";
         &web_data (" </div>\n");
         &web_data (" <br />\n");
	 # Debut de bloc data - seulement si gestion sans annee
         if ($max_couv_groupe != 0) {
            &web_data (" <div class='coldata'>\n");
         }
      }

      #-----------------------------------------------------
      # Affichage de l'ouvrage précédent (si existe !!)
      #-----------------------------------------------------
      if ((($prem eq 'o') && ($old_date != 0)) || ((($prem eq '+') || ($prem eq 'x')) && ($reference->{NB_ED} ne "") && ($reference->{NB_ED} == 0))) {
         &AFFICHE_OUV ($reference, $notes);
         $notes = "";
      }

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
         elsif (substr ($isbn, -1, 1) eq ".") {
            $isbn="<span class='tbc'>ISBN non renseign‚</span>";
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
         elsif (substr ($isbn, -1, 1) eq ".") {
            $isbn="<span class='tbc'>ISBN non renseign‚</span>";
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

      if (($prem eq 'o') || ((($prem eq '+') || ($prem eq 'x')) && ($reference->{NB_ED} == 0)))
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
            $reference->{REED}[$reference->{NB_REED}] = "$date";
            $reference->{NB_REED} = $reference->{NB_REED} + 1;
         }
         # FAIRE : else erreur
      }
      
      # Afficher toutes les couvertures
      #  - si date diff‚rente de la pr‚c‚dente
      # ou (exclusif)
      #  - si limite groupe (groupe != 0 et nb=groupe)
      $nbim=@couvs;
#       print "[DBG] grp [$max_couv_groupe] nbim [$nbim] date [$reference->{DATE}] old [$old_date]\n";
      if ((($max_couv_groupe == 0) && ($reference->{DATE} ne $old_date)) ||
          (($max_couv_groupe != 0) && ($nbim >= $max_couv_groupe) && ($reed == 0))) {
         if ($nbim != 0) {
	    # Fin de bloc data, et d‚but bloc couverture
            &web_data (" </div>\n");
            &web_data (" <div class='covers'>\n");
         }
         while ($couv = shift(@couvs))
         {
            &web_data ($couv);
         }
         if ($nbim != 0) {
            &web_data (" </div>\n <div style='clear:both'></div>\n");
         }
         if ($max_couv_groupe == 0) {
            &web_data (" <br />\n");
            &web_data (" <b>$reference->{DATE}</b>\n <br /><br />\n");
         }
         if (($max_couv_groupe == 0) || ($nbim != 0)) {
            &web_data (" <div class='coldata'>\n");
         }
      }
      $old_date=$reference->{DATE};
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
      $reference->{NUM} = $num;
   }
   elsif ($prem eq '}')
   {
      ($couv, $illustrateur, $dessinateurs) = &extract_couv ($ligne);

      #-----------------------------------------------------
      # Image couverture
      #-----------------------------------------------------
      $initiale_couv=substr ($couv, 0, 1);
      $initiale_couv=lc($initiale_couv);
      $reference->{COUV}[$reference->{NB_REED}] = "$couv";
      if (($initiale_couv ge '0') && ($initiale_couv le '9')) {
         $initiale_couv='09';
      }
      if ($taille_vignette eq "PETIT") {
         push (@couvs, "  <a class='expandable' href='<?php echo \$bdfi_url_couvs; ?>$initiale_couv/$couv'><img alt='couverture' title='Cliquer pour ouvrir' src='<?php echo \$bdfi_url_couvs_vignettes; ?>$initiale_couv/v_$couv' /></a>\n");
      }
      else { # "MEDIUM"
         push (@couvs, "  <a class='expandable' href='<?php echo \$bdfi_url_couvs; ?>$initiale_couv/$couv'><img alt='couverture' title='Cliquer pour ouvrir' src='<?php echo \$bdfi_url_couvs_medium; ?>$initiale_couv/m_$couv' /></a>\n");
      }
#PICLENS       print $rss "<item>\n";
#PICLENS       print $rss "<title></title>\n";
#PICLENS       print $rss "<link></link>\n";
#PICLENS       print $rss "<media:thumbnail url='<?php echo \$bdfi_url_couvs_vignettes; ?>v_$couv'>\n";
#PICLENS       print $rss "<media:content url='<?php echo \$bdfi_url_couvs; ?>$couv'>\n";
#PICLENS       print $rss "</item>\n";

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
      
         $stype=~s#x#<span class='tbc'> x </span>#;
         if    (($type eq 'U') && ($stype eq "")) { $afftype="FixUp"; }
         elsif (($type eq 'U') && ($stype ne "")) { $afftype="FixUp recueil"; }
         elsif (($type eq 'N') && ($stype ne "")) { $afftype="Recueil"; }
         elsif (($type eq 'N') && ($stype eq "")) { $afftype="Nouvelle"; }
         elsif (($type eq 'C') && ($stype ne "")) { $afftype="Recueil de textes li‚s ou enchass‚s"; }
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
               $prefixe="Ouvrage dont l'appartenance aux genres est <span class='tbc'> … confirmer</span> :";
               $reference->{PREFIXE} = "$prefixe";
               $suffixe=" [Appartenance aux genre a determiner]";
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
         if    ($g1 eq 'B') { $suffixe = $suffixe . " thriller"; }
         elsif ($g1 eq 'C') { $suffixe = $suffixe . " chevalerie"; }
# D
         elsif ($g1 eq 'E') { $suffixe = $suffixe . " espionnage"; }
         elsif ($g1 eq 'F') { $suffixe = $suffixe . " fantastique"; }
         elsif ($g1 eq 'G') { $suffixe = $suffixe . " gore"; }
         elsif ($g1 eq 'H') { $suffixe = $suffixe . " historique"; }
         elsif ($g1 eq 'I') { $suffixe = $suffixe . " SF-F-F"; }
# J
# K
         elsif ($g1 eq 'K') { $suffixe = $suffixe . " insolite, ‚trange"; }
         elsif ($g1 eq 'L') { $suffixe = $suffixe . " mainstream"; }
         elsif ($g1 eq 'M') { $suffixe = $suffixe . " merveilleux, conte de f‚e"; }
# N
# O
         elsif ($g1 eq 'P') { $suffixe = $suffixe . " policier"; }
         elsif ($g1 eq 'Q') { $suffixe = $suffixe . " ‚rotique"; }
         elsif ($g1 eq 'R') { $suffixe = $suffixe . " humour]"; }
         elsif ($g1 eq 'S') { $suffixe = $suffixe . " SF"; }
         elsif ($g1 eq 'T') { $suffixe = $suffixe . " terreur"; }
         elsif ($g1 eq 'U') { $suffixe = $suffixe . " fusion"; }
# V
         elsif ($g1 eq 'W') { $suffixe = $suffixe . " western"; }
         elsif ($g1 eq 'X') { $suffixe = $suffixe . " porno"; }
         elsif ($g1 eq 'Y') { $suffixe = $suffixe . " fantasy"; }
         elsif ($g1 eq 'Z') { $suffixe = $suffixe . " Pr‚historic Fiction"; }
         elsif ($g1 eq '-') { $suffixe = $suffixe . " texte"; }
         elsif (($g1 eq '?')
             || ($g1 eq '.')
             || ($g1 eq ' ')) {
            $suffixe = $suffixe . " <span class='tbc'>[Genre(s) ?]</span>";
         }
         else               { $suffixe = $suffixe . " <font color=YELLOW>[genre (" . $g1 . ") inconnnu !]</font>"; }

         if (($g2 ne " ") && ($g2 ne "."))
         {
            if ($g2 eq 'A')    { $suffixe = $suffixe . ", aventure"; }
# B
            elsif ($g2 eq 'C') { $suffixe = $suffixe . ", chevalerie"; }
# D
            elsif ($g2 eq 'E') { $suffixe = $suffixe . ", espionnage"; }
            elsif ($g2 eq 'F') { $suffixe = $suffixe . ", fantastique"; }
            elsif ($g2 eq 'G') { $suffixe = $suffixe . ", gore"; }
            elsif ($g2 eq 'H') { $suffixe = $suffixe . ", historique"; }
            elsif ($g2 eq 'I') { $suffixe = $suffixe . ", SF-F-F"; }
# J
            elsif ($g2 eq 'K') { $suffixe = $suffixe . ", insolite, ‚trange"; }
            elsif ($g2 eq 'L') { $suffixe = $suffixe . ", mainstream"; }
            elsif ($g2 eq 'M') { $suffixe = $suffixe . ", merveilleux, conte de f‚e"; }
# N
# O
            elsif ($g2 eq 'P') { $suffixe = $suffixe . ", policier"; }
            elsif ($g2 eq 'Q') { $suffixe = $suffixe . ", ‚rotique"; }
            elsif ($g2 eq 'R') { $suffixe = $suffixe . ", humour"; }
            elsif ($g2 eq 'S') { $suffixe = $suffixe . ", SF"; }
            elsif ($g2 eq 'T') { $suffixe = $suffixe . ", terreur"; }
            elsif ($g2 eq 'U') { $suffixe = $suffixe . ", fusion"; }
# V
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
               printf STDERR " plus de 10 anthologistes ?!\n";
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
      &web_data ("inconnu _[$prem]_ : $lig\n");
      print "inconnu _[$prem]_ : $lig\n";
   }
}

# Fin d'ouvrage (fin de format table)
&AFFICHE_OUV ($reference, $notes);
$notes = "";
&web_data (" </div>\n");

if ($nbim=@couvs ne 0) {
   &web_data (" <div class='covers'>\n");
   while ($couv = shift(@couvs))
   {
      &web_data ($couv);
   }
   &web_data (" </div>\n <div style='clear:both'></div>\n");
}
&web_data ("</div>\n");

&web_end ();
#PICLENS print $rss "</channel>\n";
#PICLENS print $rss "</rss>\n";

close (OUTH);

if ($upload == 1)
{
#$outh="$livraison_site/$lien.php";
#   $file = "${livraison_site}/$initiale/$outfile.php";
   $cwd = "/www/collections/pages";
   print "Upload sur $cwd";
   &bdfi_upload($outh, $cwd);
}

#---------------------------------------------------------------------------
# Affichage d'un ouvrage
#---------------------------------------------------------------------------
sub AFFICHE_OUV {
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
       &web_data ("  <b>$prefixe</b>\n");
   }

   #-----------------------------------------------------
   # Support : numero, annee, reeditions
   #-----------------------------------------------------
   local($num)=$ref->{NUM};
   local($date)=$ref->{DATE};
   $id_ouv += 1;
   &web_data ("  <div>\n");
   if ($num ne "") {
     &web_data ("   <span class='colbook'>$num</span> - ");
   }
   else
   {
     &web_data ("   - ");
   }

   if ($max_couv_groupe != 0) {
      if (($date eq 'xxxx') || ($date eq '?') || ($date eq '????') || (substr($date, -1, 1) eq '?') || (substr($date, -1, 1) eq '.'))
      {
         &web_data ("<span class='tbc'>$date</span>");
      }
      else
      {
         &web_data ("$date");
      }
   }
   if ($ref->{NB_REED} != 0)
   {
      &web_data (" (<span class='reed'>r&eacute;&eacute;d.</span> ");
      $date=$ref->{REED}[0];
      if (($date eq 'xxxx') || ($date eq '?') || ($date eq '????') || (substr($date, -1, 1) eq '?') || (substr($date, -1, 1) eq '.'))
      {
         &web_data ("<span class='tbc'>$date</span>");
      }
      else
      {
         &web_data ("$date");
      }

      $nb_reed = 1;
      while ($nb_reed < $ref->{NB_REED})
      {
         $date=$ref->{REED}[$nb_reed];
         if (($date eq 'xxxx') || ($date eq '?') || ($date eq '????') || (substr($date, -1, 1) eq '?') || (substr($date, -1, 1) eq '.'))
         {
            &web_data (", <span class='tbc'>$date</span>");
         }
         else
         {
           &web_data (", $date");
         }
         $nb_reed++;
      }
      &web_data ( ")");
   }

   #-----------------------------------------------------
   # Auteurs et anthologistes
   #-----------------------------------------------------
   &web_data ("\n");
   local($nb_aut) = 0;
   while ($nb_aut < $ref->{NB_AUTEUR})
   {
      if (($auteur eq "?") || ($auteur eq "?"))
      {
         &web_data ("   <span class='auteur'><span class='tbc'> Auteur(s) ? </span></span>\n");
      }
      # nom du lien, et initiale
      $lien_auteur=&url_auteur($ref->{AUTEUR}[$nb_aut]);
      $initiale_lien=substr ($lien_auteur, 0, 1);
      $initiale_lien=lc($initiale_lien);
   
      #mot intermediaire : ", " /  " et "
      if ($nb_aut != 0) {
         if ($nb_aut+1 == $ref->{NB_AUTEUR}) { &web_data (" et "); }
         else { &web_data (", "); }
      }
      &web_data ("   <a class='auteur' href='../../auteurs/$initiale_lien/$lien_auteur.php'>");
      &web_data ("$ref->{AUTEUR}[$nb_aut]");
      &web_data ("</a>\n");

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
            if ($nb_aut != 0) { &web_data (", anthologistes "); }
            else { &web_data ("   Anthologistes "); }
         }
         elsif ($nb_anth == 0) {
            if ($nb_aut != 0) { &web_data (", anthologiste "); }
            else { &web_data ("   Anthologiste "); }
         }
         elsif ($nb_anth+1 == $ref->{NB_ANTHOLOG}) { &web_data (" et "); }
         else  { &web_data (", "); }

         &web_data ("<a class='auteur' href='../../auteurs/$initiale_lien/$lien_auteur.php'>");
         &web_data ("$ref->{ANTHOLOG}[$nb_anth]");
         &web_data ("</a>\n");
      }
      else
      {
         &web_data ("Anthologie ");
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
 
   if (($titre_seul eq "?") || ($titre_seul eq "?"))
   {
      &web_data ("   <span class='fr'> <span class='tbc'> Titre ? </span>");
   }
   else
   {
         $antho = (($ref->{AFFTYPE} eq "Recueil"
		 || $ref->{AFFTYPE} eq "Anthologie"
		 || $ref->{AFFTYPE} eq "Omnibus"
		 || $ref->{AFFTYPE} eq "Recueil de textes li‚s ou enchass‚s"
		 || $ref->{AFFTYPE} eq "PiŠces de th‚ƒtre"
		 || $ref->{AFFTYPE} eq "FixUp recueil") ? 1 : 0);
         
         # Si anthologie, chercher idrec
         if ($antho == 1) {
            $idrec=idrec($titre_seul, $cycle, $scycle);
            $url_antho=url_antho($idrec);
            $url_antho="${url_antho}.php";
            &web_data ("   <span class='fr'><a class='antho' href='../../recueils/pages/$url_antho'>$titre_seul</a>");
         }
         else {
            &web_data ("   <span class='fr'>$titre_seul");
         }
#      &web_data ("<span class='fr'> $titre_seul \n");
   }
   if ($cycle ne "")
   {
      # nom du lien sur le cycle
      $lien_serie=&url_serie($cycle);
      &web_data (" [<a class=\"cycle\" href=\"../../series/pages/$lien_serie.php\">");
      if ($titre_seul ne $cycle) {
         &web_data ("$cycle");
      }
      else {
         &web_data ("*");
      }
      &web_data ("</a>");
      if ($indice_cycle ne "")
      {
         p&web_data (" - $indice_cycle");
      }
      &web_data ("]");
   }
   if ($scycle ne "")
   {
      # Pas de lien pour l'instant
      # --> sinon url de type cycle#scycle, devrait etre mis dans bdfi.pm)
      &web_data (" [$scycle");
      if ($indice_scycle ne "")
      {
         &web_data (" - $indice_scycle");
      }
      &web_data ("]");
   }
   &web_data ("</span>\n");
   if ($vodate eq '?')
   {
      &web_data ("   <span class='vo'>(<span class='tbc'> $vodate </span>");
   }
   else
   {
      &web_data ("   <span class='vo'>($vodate");
   }
   if ($votitre eq '?')
   {
      &web_data (", <span class='tbc'> $votitre </span>)</span>\n");
   }
   elsif ($votitre ne "")
   {
      &web_data (", $votitre)</span>\n");
   }
   else
   {
      &web_data (")</span>\n");
   }
   if ($ref->{SUFFIXE} eq " [Hors genres]") {
      &web_data (" - Hors genres\n");
   }

   #-----------------------------------------------------
   # Infos supplementaires : trad, isbn, type, genre
   #-----------------------------------------------------
   # type : afftype : A FAIRE (integr. dans structure reference)
   #-----------------------------------------------------

   # Indication type d'ouvrage
   local($afftype)=$ref->{AFFTYPE};
   &web_data ("   <p class='precision' style='border-left: 3px solid #888; margin: 5px 10px;'><i>");
   if ($afftype eq '?')
   {
      &web_data ("<span class='tbc'> Type ? </span>");
   }
   else
   {
      &web_data ("$afftype");
   }

   # Indication ISBN
   local($isbn)=$ref->{ISBN};
   &web_data (" - $isbn");

   # Indication traducteur
   if ($trad eq '?')
   {
       &web_data (" - <span class='tbc'>Traducteur ?</span> ");
   }
   elsif ($trad ne "")
   {
       &web_data (" - Traduction : $trad ");
   }

   # Indication couverture premiŠre ‚dition
   # TO DO A FAIRE ICI : … corriger, on afficherait la derniŠre ‚dition
   local($couv)=$ref->{ILLU}[$reference->{NB_REED}];
   if ($couv eq '?')
   {
       &web_data (" - <span class='tbc'>Couverture : $couv</span> ");
   }
   else
   {
      &web_data (" - Couverture : $couv");
   }


   # Indication genre
   local($suffixe)=$ref->{SUFFIXE};
   &web_data (" - Genre : $suffixe");

   # TO DO A FAIRE ICI : … corriger, on afficherait la derniŠre ‚dition
   # ici, avant les notes, cr‚er une ligne par r‚‚dition et afficher : R‚‚dition <ann‚e> - ISBN <XXX> / <Pas d'ISBN> - Couverture <XXX>

   # Afficher notes
   if ($notes ne '') {
      &web_data ("\n");
      &web_data ("$notes");
   }

   &web_data ("</i></p>\n");
   &web_data ("  </div>\n");

}

sub affiche_menu_bib {
   local($titre)=$_[0];
   &web_data ("<div id='menbib'>");
   &web_data (" [ <a href='javascript:history.back();' onmouseover='window.status=\"Back\";return true;'>Retour</a> ] ");
   &web_data ("Vous &ecirc;tes ici : <a href='../..'>BDFI</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../../images/sep.png' alt='--&gt;'/> <a href='..'>Collections</a>\n");
   &web_data ("<img src='../../images/sep.png'  alt='--&gt;'/> $titre\n");
   &web_data ("<br />");
   &web_data ("Collections de l'imaginaire (SF, fantasy, merveilleux, fantastique, horreur, &eacute;trange) ");
   &web_data (" - <a href='javascript:mail_collec();'>Ecrire &agrave; BDFI</a> pour compl&eacute;ments &amp; corrections.");
   &web_data ("</div>\n");

   &web_data ("<br />");
   &web_data ("<br />\n");
}


# --- fin ---

