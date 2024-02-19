#===========================================================================
#
# Script de generation d'un fichier d'aide a l'int‚gration des parution
#
#
#---------------------------------------------------------------------------
# Historique :
#  0.0  - 27/08/2005 : Creation a partir de parution.pl
#  0.1  - 04/01/2010 : Mise … jour de la ligne couverture
#  0.2  - 11/11/2012 : ligne couv pour tous les ouvrages
#
#---------------------------------------------------------------------------
# Utilisation :
#
#    perl parution.pl [-C|-D] <fichier_prix>
#                        -C : groupe par collection
#                        -d : tri date avant num‚ro
#---------------------------------------------------------------------------
#
# A FAIRE :
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
$tri="NUM";       # NUM, DATE

#---------------------------------------------------------------------------
# Help
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "usage : $0 [-h] [-C|-d] <fichier_parution>\n";
   print STDERR "        -E : groupe par editeur, sans collection\n";
   print STDERR "        -d : Tri par date avant num‚ros\n";
   exit;
}

if (($ARGV[0] eq "") || ($ARGV[0] eq "-h"))
{
   usage;
}

$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-E")
   {
      $groupe="EDIT";
   }
   elsif ($ARGV[$i] eq "-d")
   {
      $tri="DATE";
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

$file="sigles.cm2";
open (f_cm, "<$file");
@cm=<f_cm>;
close (f_cm);

#---------------------------------------------------------------------------
# Determination du device de sortie
#---------------------------------------------------------------------------
   $outf=$name_file . ".pgm";
   $outf=lc($outf);

   open (OUTP, ">$outf");
   print STDERR "resultat dans $outf\n";
   $canal=OUTP;

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
   $ind_cycle="";
   $vo="";
   $genre="";
   $rno="";
   $aj="";
   $format="";
   $dim="";
   $pages="";
   $edit="";
   $coll="";
   $num="";
   $cop="";
   $mp="";
   $ap="";
   $reimp="";
   $vn="";
   $traduct="";
   $isbn="";
   $couv="";
   $antholog="";

# ($prenom, $nom, $titre, $cycle, $ind_cycle, $vo, $genre, $rno,               $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn, $couv) = split ("	", $ligne);
# ($prenom, $nom, $titre, $cycle, $ind_cycle, $vo, $genre, $rno, $aj, $format, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn, $couv) = split ("	", $ligne);
# ($prenom, $nom, $titre, $cycle, $ind_cycle, $vo, $genre, $rno, $aj, $format, $dim, $pages, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn, $couv, $comment) = split ("	", $ligne);
  ($prenom, $nom, $titre, $cycle, $ind_cycle, $vo, $genre, $rno, $aj, $format, $dim, $pages, $edit, $coll, $num, $cop, $mp, $ap, $reimp, $traduct, $isbn, $couv) = split ("	", $ligne);
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
   $nom = uc($nom);
#  $coll=~s/^_$//g;

#  Essai am‚liorer les regroupements : lc + pour vide / - / HC / Hors Collections
   $coll = lc($coll);
   if (($coll eq "") || ($coll eq "_") || ($coll eq "hc") || ($coll eq "hors collections")) { $coll = "_"; }


   # Mettre dans tableau, en regroupant les collaborations

   if (($no >= 1) &&
       ($edit eq $refs[$no-1]->{EDIT}) &&
       ($coll eq $refs[$no-1]->{COLL}) &&
       ($ind_cycle eq $refs[$no-1]->{INDICE}) &&
       ($num eq $refs[$no-1]->{NUM}) &&
       ($ap eq $refs[$no-1]->{ANNEE}) &&
       ($reimp eq $refs[$no-1]->{REIMP}) &&
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
      $edicol="$edit	$coll";
      $edicol=lc($edicol);
      $sigle="XXXX   ";
      foreach $toto (@cm)
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

      $reference = {
         NB_AUTEUR=>1,
         NOM=>["$nom","","","",""],
         PRENOM=>["$prenom","","","",""],
         TITRE=>"$titre",
         TYPE=>"$rno",
         AJ=>"$aj",
         FORMAT=>"$format",
         DIM=>"$dim",
         PAGES=>"$pages",
         COMMENT=>"$comment",
         COP=>"$cop",
         VOTITRE=>"$vo",
         CYCLE=>"$cycle",
         INDICE=>$ind_cycle,
         EDIT=>"$edit",
         COLL=>"$coll",
         SIGLE=>"$sigle",
         GENRE=>"$genre",
         NUM=>"$num",
         REIMP=>"$reimp",
         PARUTION=>"$paru",
         NB_COLL_BY_EDIT=>0,
         TRADUCT=>"$traduct",
         ISBN=>"$isbn",
         VN=>"$vn",
         ANNEE=>"$ap",
         MOIS=>"$mp",
         ANTHOLOG=>"$antholog",
         COUV=>"$couv",
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
   if (($isbn eq '') || ($isbn eq ' '))
   {
      $isbn="?";
   }
   $vn=$ligne->{VN};
   $vn=~s/\n//;
   $couv=$ligne->{COUV};
   $couv=~s/\n//;
   if ($couv eq '_')
   {
      $couv="";
   }
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

   #--- Affichage references livre

   $markref = ($reimp eq 'R') ? "+" : "o";
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
        $ref=sprintf("} noimg          _%-27s ?\n",  $couv);
      }
      else {
        $ref=sprintf("} noimg          _%s\n",  $couv);
      }
      print $canal $ref;
   }
   else {
      $ref=sprintf("} noimg          _?                           ?\n",  $couv);
      print $canal $ref;
   }
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
   elsif ($format eq "GF") {
      print $canal "GF ";
   }
   elsif ($format eq "GFR") {
      print $canal "GF Reli‚ ";
   }
   elsif ($format eq "MF") {
      print $canal "MF ";
   }
   elsif ($format eq "A") {
      print $canal "Audio ";
   }
   else {
      print $canal "? ";
   }

   if (($dim ne "") && ($dim ne "_")) {
      print $canal "- $dim ";
   }
   if (($pages ne "") && ($pages ne "_")) {
      print $canal "- $pages pages";
   }

   print $canal "\n";

   if (($comment ne "") && ($comment ne "_")) {
      print $canal "!--- $comment \n";
   }

   #--- Affichage references texte

   if (($cycle ne "") && ($cycle ne "_"))
   {
      $titre = $titre . " [$cycle";
      if (($ind ne "") && ($ind ne "_"))
      {
         $titre = $titre . " - $ind";
       }
      $titre = $titre . "]";
    }
   elsif (($ind ne "") && ($ind ne "_"))
   {
       $titre = $titre . "[$ind]";
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

   $nom = uc($nom);
   $auteur = "$nom $prenom";
   $collab = " ";
   if ($ligne->{NB_AUTEUR} >= 2) { $collab = "&"; }
   $ref=sprintf("%s- .%s%s.     %-2s    %s%-27s%s%s þ%s%s\n", $TBC, $hg, $g, $t, $pf, $auteur, $collab, $titre, $vo_cop, $trad);
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
            if (uc($a->{ANNEE}) ne uc($b->{ANNEE}))
            {
               uc($a->{ANNEE}) <=> uc($b->{ANNEE});
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
