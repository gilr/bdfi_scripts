#===========================================================================
#
# Script de generation d'un fichier d'aide a l'int‚gration des parution
#
#
#---------------------------------------------------------------------------
# Historique :
#  0.1  - ../../.... : cr‚ation … partir de prog.pl
#  0.2  - 10/12/2023 : r‚cup‚ration du nom de scan de couverture
#  0.3  - 17/12/2023 : prise en compte de l'ordre de tri cm_tri + transfo 1-1 en 1.1
#  0.4  - 17/12/2023 : prise en compte des contenus (scan = "*")
#  0.5  - 23/12/2023 : ajout prise en compte des retirages
#  0.6  - 25/12/2023 : ligne pour le cycle, au cas ou diff‚rent du nom g‚n‚rique
#
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl importCM.pl <fichier_prix>
#
#    /!\ Pour un tri par num‚ro toutes collections confondues, ‚changer l'appel de tri_standard par tri_numero
#---------------------------------------------------------------------------
#
# A FAIRE :
#
#  [OK] R‚cup‚ration des images couvs
#  [OK] Supprimer les titres VO des cycles
#  [OK] Ordre de tri correct bas‚ sur les cm_tri
#  [OK] Transfo des num‚ros de s‚rie de n-m en n.m
#  [OK] exclure les romans inclus dans omnibus (et voir comment les g‚rer...) ou les inclure comme contenu
#  [..] Distinguer les r‚impressions des retirages
#  [..] gestion des titres de cycle diff‚rents
#
#   Comparer sans les accents !!!
#
#   collaborations de plus de 2 auteurs
#
#   Option fichier texte windows
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables de definition du fichier theme
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
$title="";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$name_file="";
$groupe="COLL";    # EDIT, COLL

#---------------------------------------------------------------------------
# Help
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "usage : $0 [-h] <fichier_parution>\n";
   exit;
}

if (($ARGV[0] eq "") || ($ARGV[0] eq "-h"))
{
   usage;
}

$i=0;

while ($ARGV[$i] ne "")
{
   $name_file=$ARGV[$i];
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

$file="sigles.cm2";
open (f_cmsig, "<$file");
@cmsig=<f_cmsig>;
close (f_cmsig);

#---------------------------------------------------------------------------
# Determination du device de sortie
#---------------------------------------------------------------------------
   $outf=$name_file . ".pgm";
   $outf=lc($outf);

   open (OUTP, ">$outf");
   print STDERR "resultat dans $outf\n";
   $canal=OUTP;

   #--- pour Debug
   #   $canal = STDOUT;

@refs=();

#---------------------------------------------------------------------------
# Traitement du fichier
#---------------------------------------------------------------------------
$no=0;
foreach $ligne (@parution)
{
   $cm_sexe="";
   $cm_nom="";
   $cm_prenom="";
   $cm_titre="";
   $cm_serie="";
   $cm_noserie="";
   $cm_titrevo="";
   $cm_genre="";  #-- SF, Fy, Fant, Hyb, et HG
   $cm_rno="";    #-- Roman, Recueil, Anthologie, Omnibus, Novella, Nouvelle, Novellisation, Essai, Coffret, Livre-Jeu, Art-book, Th‚atre et Revues
   $cm_a_j="";    #-- A=adulte, J=jeunesse < 13a, Y=YA > 13a
   $cm_format=""; #-- GF, MF, P - GFR, MFR, PR =si reli‚s - A=audio, N=num‚rique, C=Coffret
   $cm_dim="";    #-- = dur‚e si audio
   $cm_pages="";  #-- Si jai le bouquin : cest le nombre de pages int‚ressantes du texte, y compris postface et table des matiŠre, mais non compris liste des titres de la collection, donc pas forc‚ment la derniŠre page num‚rot‚e
   $cm_iba="";    #-- Auto = auto-‚ditions = A, Imaginaire=I et comme je suis trŠs coh‚rent, Blanche = G 
   $cm_edit="";
   $cm_coll="";
   $cm_nr="";
   $cm_tri="";    #-- peut ˆtre au format 2021-xx
   $cm_s="";      #-- S=Scan : X si poss‚d‚ par CM, "_" si identique ‚dition pr‚c‚dente
   $cm_o="";      #-- O = X si poss‚d‚ par CM, N si poss‚d‚ en num‚rique, _ si poss‚d‚ dans autre ‚dition, w si saisie r‚cente...
   $cm_copyr="";
   $cm_mp="";
   $cm_ap="";
   $cm_o_r="";    #-- I= in‚dit, O=premiŠre ‚dition dans collection, R=r‚impression dans la collection   => retirage si cm_S = "_" et O/R = "R"
   $cm_type="";   #-- "type" en cas de changement de maquette    "--" pour premier titre de la collection, "//" pour dernier
   $cm_dl="";
   $cm_ai="";     #-- "n.i." = non indiqu‚
   $cm_imprim="";
   $cm_prix="";
   $an_prix="";
   $cm_s_trad="";
   $cm_trad="";   #-- "A & B" si collab, "A + B" si r‚vision par B
   $cm_isbn="";
   $cm_comment="";
   $cm_s_ill="";
   $cm_ill="";   #-- "A & B" si collab, "A + B" si illustations int‚rieures (B)

   ($cm_sexe, $cm_prenom, $cm_nom, $cm_titre, $cm_serie, $cm_noserie, $cm_titrevo, $cm_genre, $cm_rno, $cm_a_j, $cm_format, $cm_dim, $cm_pages, $cm_iba, $cm_edit, $cm_coll, $cm_nr, $cm_tri, $cm_s, $cm_o, $cm_copyr, $cm_mp, $cm_ap, $cm_o_r, $cm_type, $cm_dl, $cm_ai, $cm_imprim, $cm_prix, $an_prix, $cm_s_trad, $cm_trad, $cm_isbn, $cm_comment, $cm_s_ill, $cm_ill) = split ("	", $ligne);


   if ($cm_mp == "9") { $cm_mp = "09"; }
   elsif ($cm_mp == "8") { $cm_mp = "08"; }
   elsif ($cm_mp == "7") { $cm_mp = "07"; }
   elsif ($cm_mp == "6") { $cm_mp = "06"; }
   elsif ($cm_mp == "5") { $cm_mp = "05"; }
   elsif ($cm_mp == "4") { $cm_mp = "04"; }
   elsif ($cm_mp == "3") { $cm_mp = "03"; }
   elsif ($cm_mp == "2") { $cm_mp = "02"; }
   elsif ($cm_mp == "1") { $cm_mp = "01"; }
   elsif (($cm_mp != "10") && ($cm_mp != "11") && ($cm_mp != "12")) { $cm_mp = "xx"; }

   $cm_nom = &noacc($cm_nom);
   $cm_nom = uc($cm_nom);

   #  Essai am‚liorer les regroupements : lc + pour vide / - / HC / Hors Collections
   $cm_coll = lc($cm_coll);
   if (($cm_coll eq "") || ($cm_coll eq "_") || ($cm_coll eq "hc") || ($cm_coll eq "hors collections")) { $cm_coll = "_"; }

   $edicol="$cm_edit	$cm_coll";
   $edicol=lc($edicol);
   $sigle="XXXX   ";
   foreach $toto (@cmsig)
   {
      $refsig=$toto;
      chop($refsig);
      $sig=substr ($refsig, 0, 7);
      $reste=substr ($refsig, 8);
      if ($reste eq $edicol)
      {
         $sigle=$sig;
         break;
      }
   }

   # Distinguer r‚impression de retirage (retirage si m_s=_ et O/R = R
   if ($cm_o_r eq "I") {
      $reimp = "inedit";
   }
   elsif ($cm_o_r eq "O") {
      $reimp = "premiere";
   }
   elsif ($cm_o_r eq "R") {
      if ($cm_s eq "_") {
         $reimp = "retirage";
      }
      else {
         $reimp = "reedition";
      }
   }
   else {
      print STDERR "champ cm O/R avec valeur inattendue : [$cm_o_r] \n";
      exit;
   }
 
   # TBD : comment g‚rer les doubles ISBN

   $reference = {
      NB_AUTEUR=>0,
      NOM=>["","","","",""],
      PRENOM=>["","","","",""],
      TITRE=>"$cm_titre",
      CYCLE=>"$cm_serie",
      INDICE=>$cm_noserie,
      TYPE=>"$cm_rno",
      AJ=>"$cm_a_j",
      FORMAT=>"$cm_format",
      DIM=>"$cm_dim",
      PAGES=>"$cm_pages",
      COMMENT=>"$cm_comment",
      COP=>"$cm_copyr",
      VOTITRE=>"$cm_titrevo",
      EDIT=>"$cm_edit",
      COLL=>"$cm_coll",
      SIGLE=>"$sigle",
      NUM=>"$cm_nr",
      ORDRE=>"$cm_tri",
      GENRE=>"$cm_genre",
      REIMP=>"$reimp",
      PARUTION=>"$cm_paru",
      NB_COLL_BY_EDIT=>0,
      ISBN=>"$cm_isbn",
      POSSEDE=>"$cm_o",
      DL=>"$cm_dl",
      AI=>"$cm_ai",
      IMPRIM=>"$cm_imprim",
      ISBN=>"$cm_isbn",
      ANNEE=>"$cm_ap",
      MOIS=>"$cm_mp",
      TRADUCT=>"$cm_trad",
   };

   # Si " & " dans nom ou pr‚nom => spliter les deux (ou plus) auteurs
   # TBD : voir comment seront g‚r‚s des collaborations avec un auteur sans pr‚nom (ex: OKSANA, AYERDHAL...)
   # ... Mais quand mˆme : si 1 nom et 2 pr‚noms => mˆme nom
   $index_sep_nom = index($cm_nom, " & ");
   $index_sep_prenom = index($cm_prenom, " & ");

   @noms = split(/ & /, $cm_nom);
   $nbn = scalar @noms;
   @prenoms = split(/ & /, $cm_prenom);
   $nbp = scalar @prenoms;
   if (($nbn ne $nbp) && ($nbp ne 0)) {
      if (($nbn eq 1) && ($nbp eq 2))
      {
         $reference->{NOM}[0] = $noms[0];
         $reference->{PRENOM}[0] = $prenoms[0];
         $reference->{NB_AUTEUR} ++;
         $reference->{NOM}[1] = $noms[0];
         $reference->{PRENOM}[1] = $prenoms[1];
         $reference->{NB_AUTEUR} ++;
      }
      else {
         print STDERR "Pb nombre noms & pr‚noms : [$cm_nom][$nbn] [$cm_prenom][$nbp] \n";
         exit;
      }
   }
   else
   {
      for (my $i = 0; $i < $nbn; $i++)
      {
         # Ajouter l'auteur nø i
         $reference->{NOM}[$i] = $noms[$i];
         $reference->{PRENOM}[$i] = $prenoms[$i];
         $reference->{NB_AUTEUR} ++;
      }
   }

   # spliter couv et illustrateur int‚rieur => illus_couv, illu_int
   $illu_couv = "";
   $illu_int = "";
   ($illu_couv, $illu_int) = split(/ & /, $cm_ill);
   if ($illu_couv eq "") { $illu_couv = "N"; }
   if ($illu_int eq "") { $illu_int = "N"; }
   $reference->{COUV} = $illu_couv;
   $reference->{ILLU} = $illu_int;

   # scan si existe
   if (($cm_s eq "X") || ($cm_s eq "_")) {
      $scan = "noimg";
   }
   elsif ($cm_s eq "*") {
      # TODO exlure les "*" qui ne devraient pas se trouver l…, dans gestion r‚f‚rence
      $scan = "*";
   }
   else {
      $scan = $cm_s;
   }
   $reference->{SCAN} = $scan;
 
   push (@refs, $reference);
   $no++;
}

#==================================#
#===                            ===#
#===   FIN DE LECTURE FICHIER   ===#
#===                            ===#
#==================================#



   # TODO : upgrader le format de sortie


#-------------------------------------------------------------
# Trier par editeur, puis par collection, puis par num‚ro, puis par titre
#-------------------------------------------------------------
@liste=sort tri_numero @refs;

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
}
else
{
($sec,$min,$heure,$mjour,$mois,$annee,$sjour,$ajour,$isdst) = localtime(time);
$mois++;
$annee+=1900;
$diff_mois = (12 * ($annee - $year)) + $mois - $month;
print STDERR "diff: $diff_mois\n";
if ($diff_mois > 0)
{
   $title="Parutions " . $str_month[$month-1];
}
else
{
   $title="Pr‚visions " . $str_month[$month-1];
}
print STDERR "[$month/$year]/[$mois/$annee] $title\n";
print $canal "[$month/$year]/[$mois/$annee] $title\n";
}

#-------------------------------------------------------------
# G‚n‚ration du fichier
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

         if (($nbcoll == 1) || ($groupe eq 'COLL'))
         {
            if ($nbcoll == 1)
            {
               print $canal "\n!--- EDIT/COLL : $editeur : $coll\n";
            }
            elsif ($editeur ne $olded)
            {
               print $canal "\n!--- EDIT : $editeur\n\n";
               print $canal "!--- COLL : $coll\n";
            }
            else
            {
               print $canal "\n!--- COLL : $coll\n";
            }
         }
         else
         {
            print $canal "\n!--- EDIT : $editeur\n\n";
            if ($groupe eq 'COLL')
            {
               print $canal "\n!--- COLL : $coll\n";
            }
         }
         $olded=$editeur;
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
   $sigle=$ligne->{SIGLE};
   $num=$ligne->{NUM};
   $genre=$ligne->{GENRE};
   $reimp=$ligne->{REIMP};
   $trad=$ligne->{TRADUCT};
   if (($trad ne '') && ($trad ne ' ') && ($trad ne '_'))
   {
      $trad = format_trad ($trad);
      $trad = " þTrad. $trad";
   }
   else
   {
      $trad = "";
   }
   $cop=$ligne->{COP};
   $vo=$ligne->{VOTITRE};
   $isbn=$ligne->{ISBN};
   $isbn=~s/\n//;
   $isbn=~s/ $//;
   if (($isbn eq '') || ($isbn eq ' '))
   {
      $isbn="?";
   }
   elsif ($isbn eq '_')
   {
      $isbn="-";
   }
   $vn=$ligne->{VN};
   $vn=~s/\n//;


   $scan=$ligne->{SCAN};
   $scan=~s/ $//g;
   $scan=~s/\n//;
   $scan=~s/ $//g;
   $couv=$ligne->{COUV};
   $couv=~s/ $//g;
   $couv=~s/\n//;
   $couv=~s/ $//g;
   if ($couv eq '_')
   {
      $couv="";
   }
   $illu=$ligne->{ILLU};
   $illu=~s/ $//g;
   $illu=~s/\n//;
   $illu=~s/ $//g;
   $antholog=$ligne->{ANTHOLOG};
   $antholog=~s/\n//;
   if ($antholog eq '_')
   {
      $antholog="";
   }
   $mp=$ligne->{MOIS};
   $ap=$ligne->{ANNEE};
   $type=$ligne->{TYPE};
   $aj=$ligne->{AJ};
   $aj=~s/ //g;
   $format=$ligne->{FORMAT};
   $format=~s/ //g;
   $dim=$ligne->{DIM};
   $dim=~s/ $//g;
   $dim=~s/^ //g;
   $pages=$ligne->{PAGES};
   $pages=~s/^ //g;
   $pages=~s/ $//g;
   $comment=$ligne->{COMMENT};
   $comment=~s/^ //g;
   $comment=~s/ $//g;
   $comment=~s/\n//;
   $dl=$ligne->{DL};
   $dl=~s/^ //g;
   $dl=~s/ $//g;
   $possede=$ligne->{POSSEDE};
   $possede=~s/^ //g;
   $possede=~s/ $//g;
   $ai=$ligne->{AI};
   $ai=~s/^ //g;
   $ai=~s/ $//g;
   $imprim=$ligne->{IMPRIM};
   $imprim=~s/^ //g;
   $imprim=~s/ $//g;

   #--- Affichage references livre

   if ($ligne->{SCAN} ne '*') {
      #--- DEBUT affichage des lignes ouvrages et textes
      #--- N'afficher ligne ouvrage, couverture, infos livres que si pas un contenu

   $markref = ($reimp eq 'retirage') ? "x" : (($reimp eq 'reedition') ? "+" : "o");
   $TBC = ($ligne->{PARUTION} eq '?') ? "¨" : "";

   if (($num eq "") || ($num eq "_") || ($num eq "0") || ($num eq "??"))
   {
      $num = "?";
   }
 # A FAIRE : si (27) remplacer par 27i
 # A FAIRE : virer des "_" en fin de ligne

   $vn_str = "";
   if (($vn ne "") && ($bn ne " ") && ($vn ne "_")) {
      $vn_str = " (VN $vn)";
   }
   $ref=sprintf("%s%s %-7s %5s  %s.%s ..... ISBN %s%s\n", $TBC, $markref, $sigle, $num, $ap, $mp, $isbn, $vn_str);

   print $canal $ref;

   #--- Affichage Illustrateur et anthologiste
   if (($couv ne "") && ($couv ne "_") && ($couv ne "?") && ($couv ne "??"))
   {
      # print $canal "!--- Couv : $couv\n";
      if (length ($couv) < 28) {
        $ref=sprintf("} %-14s _%-27s %s\n", $scan, $couv, $illu);
      }
      else {
        $ref=sprintf("} %-14s _%s    %s\n", $scan, $couv, $illu);
      }
   }
   else {
      $ref=sprintf("} %-14s _?                           %s\n", $scan, $illu);
   }
   print $canal $ref;

   if (($antholog ne "") && ($antholog ne "_") && ($antholog ne "?") && ($antholog ne "??"))
   {
      print $canal "!--- Anthologiste : $antholog\n";
   }

   print $canal "!--- ";
   if ($aj eq "J") {
      print $canal "Jeunesse - ";
   }
   elsif ($aj eq "Y") {
      print $canal "YA - ";
   }

   if ($format eq "N") {
      print $canal "Num‚rique ";
   }
   elsif ($format eq "P") {
      print $canal "Poche ";
   }
   elsif ($format eq "PR") {
      print $canal "Poche - Reli‚ ";
   }
   elsif ($format eq "GF") {
      print $canal "GF ";
   }
   elsif ($format eq "GFR") {
      print $canal "GF - Reli‚ ";
   }
   elsif ($format eq "MF") {
      print $canal "MF ";
   }
   elsif ($format eq "MFR") {
      print $canal "MF - Reli‚ ";
   }
   elsif ($format eq "A") {
      print $canal "Audio ";
   }
   elsif ($format eq "C") {
      print $canal "Coffret ";
   }
   else {
      print $canal "? ";
   }

   if ($possede eq "X") {
      print $canal "- CHRISTIAN ";
   }
   if (($dim ne "") && ($dim ne "_")) {
      if ($possede eq "X") {
         print $canal "- DIM $dim ";
      }
      else {
         print $canal "- $dim ";
      }
   }
   if (($pages ne "") && ($pages ne "_")) {
      print $canal "- $pages pages ";
   }
   if (($dl ne "") && ($dl ne "_")) {
      print $canal "- DL $dl ";
   }
   if (($ai ne "") && ($ai ne "_")) {
      print $canal "- AI $ai ";
   }
   if (($imprim ne "") && ($imprim ne "_")) {
      print $canal "- IMPRIM $imprim ";
   }

   print $canal "\n";

   #--- FIN affichage des lignes ouvrages et textes
   }

   if (($comment ne "") && ($comment ne "_")) {
      print $canal "!--- $comment \n";
   }

   #--- Affichage references texte
   # Enlever si besoin le titre anglais du cycle
   ($c_fr, $c_vo) = split (/ \/ /, $cycle);
   $cycle = $c_fr;

   if (($cycle ne "") && ($cycle ne "_"))
   {
      $titre = $titre . " [$cycle";
      if (($ind ne "") && ($ind ne "_"))
      {
         $ind=~s/\-/./g;
         $titre = $titre . " - $ind";
      }
      $titre = $titre . "]";
      
      # Et indiquer le cycle pour si diff‚rent du nom de cycle de r‚f‚rence
      print $canal "!--- SERIE : $cycle - $ind\n";

   }
   elsif (($ind ne "") && ($ind ne "_"))
   {
       $titre = $titre . " [$ind]";
   }
   $vo_cop = $cop;
   if (($vo ne '') && ($vo ne '_'))
   {
      $vo_cop = $vo_cop . " $vo";
   }
   $hg="o";
   $g=" ";
   $genre=lc($genre);

   if ($genre eq "fantasy") { $g="Y" };
   if ($genre eq "fy") { $g="Y" };
   if ($genre eq "sf") { $g="S" };
   if ($genre eq "fantastique") { $g="F" };
   if ($genre eq "fant") { $g="F" };
   if ($genre eq "hyb") { $g="I" };
   if ($genre eq "hybr") { $g="I" };
   if ($genre eq "terreur") { $g="T" };
   if ($genre eq "hg") { $hg="x" };
   if ($genre eq "h.g.") { $hg="x" };
   if ($genre eq "hors genre") { $hg="x" };
   if ($genre eq "hors genres") { $hg="x" };
   if ($genre eq "aventure") { $hg="x"; $g="A" };
   if ($genre eq "thriller") { $hg="x"; $g="A" };
   if ($genre eq "policier") { $hg="x"; $g="A" };
   if ($genre eq "chevalerie") { $hg="x"; $g="A" };

   $t = "R ";
   $pf = "_";
   $type=lc($type);
   if ($type eq "anthologie") { $t="Ax"; $pf="*"; };
   if ($type eq "coffret") { $t="C" };
   if ($type eq "essai") { $t="E" };
   if ($type eq "novelisation") { $t="F" };
   if ($type eq "omnibus") { $t="Rx" };
   if ($type eq "recueil") { $t="Nx" };
   if ($type eq "roman") { $t="R" };
   if ($type eq "nouvelle") { $t="N" };
   if ($type eq "novella") { $t="r" };
   if ($type eq "th‚atre") { $t="T" };

   $ouvrage_ou_contenu = ($ligne->{SCAN} eq '*') ? ":" : "-";

   $nom = uc($nom);
   $auteur = "$nom $prenom";
   $collab = " ";
   if ($ligne->{NB_AUTEUR} >= 2) { $collab = "&"; }
   $ref=sprintf("%s%s .%s%s.     %-2s    %s%-27s%s%s þ%s%s\n", $TBC, $ouvrage_ou_contenu, $hg, $g, $t, $pf, $auteur, $collab, $titre, $vo_cop, $trad);
   print $canal $ref;

   if ($ligne->{NB_AUTEUR} >= 2)
   {
      $nom=uc($ligne->{NOM}[1]);
      $prenom=$ligne->{PRENOM}[1];
      $auteur = "$nom $prenom";
      $ref=sprintf("&                _%-27s \n", $auteur);
      print $canal $ref;
   }

   $no++;
}

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#   par editeur, puis collection, puis num‚ro, puis ann‚e, puis mois, puis titre
#
# Variante : par editeur, puis collection, puis mois, puis num‚ro, puis titre
#---------------------------------------------------------------------------
sub tri_standard
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
      elsif (uc($a->{ORDRE}) ne uc($b->{ORDRE}))
      {
         uc($a->{ORDRE}) <=> uc($b->{ORDRE});
      }
      else
      {
         uc($a->{SCAN}) <=> uc($b->{SCAN});
      }
   }
}

sub tri_numero
{
   if (uc($a->{NUM}) ne uc($b->{NUM}))
   {
      uc($a->{NUM}) cmp uc($b->{NUM});
   }
   else
   {
      if (uc($a->{ANNEE}) ne uc($b->{ANNEE}))
      {
         uc($a->{ANNEE}) <=> uc($b->{ANNEE});
      }
      else
      {
         uc($a->{MOIS}) <=> uc($b->{MOIS});
      }
   }
}

sub format_trad ()
{
   ($noms, $nom3) = split (/ \+ /, $_[0]);
   ($nom1, $nom2) = split (/ \& /, $noms);

   my $result = "";
   if ($nom3 ne "") {
      $result = " + " . format_nom ($nom3);
   }
   if ($nom2 ne "") {
      $result = " & " . format_nom ($nom2) . $result;
   }
   $result = format_nom ($nom1) . $result;

   return $result;
}

sub format_nom ()
{
   my @noms = split (' ', $_[0]);

   $result = uc(pop(@noms)) . " " . join(' ', @noms);

   return $result;
}
