#===========================================================================
#
# Script de generation d'une page prix
#
#---------------------------------------------------------------------------
# Historique :
#       - 21/12/2000 Creation 
#       - 22/12/2000 : Ajout des liens auteurs
#       - 26/12/2000 : Liens auteurs sans d‚co (CSS)
#       - 27/12/2000 : Am‚liorations, gestion ex-aequos
#       - 16/12/2001 : Modifs pour liens (CSS), gestion Na/Ne/S
#       - 18/12/2001 : Nouvelle charte graphique (menus, entˆtes)
#       - 21/12/2001 : Gestion complete des entˆtes "categories" des fichiers prix
#                      + test existence du lien auteur
#       - 26/12/2001 : Possibilit‚ d'avoir commentaire et note de bas de section
#       - 28/02/2002 : Changement de taille police (2 au lieu de 3),
#                      correction (non attribu‚) en nouvelles avec jointure Na/Ne/S
#       - 20/06/2002 : ajout du descripteur  "URL"
#       - 21/06/2002 : utilisation du module bdfi.pm
#       - 05/06/2003 : Menu par fonction javascript (un seul menu_xxx.js)
#       - ../06/2004 : Ajout du type "auteur de l'ann‚e"
#  v0.9 - 15/01/2005 : Modification CSS
#   1.0 - 12/08/2005 : Mise a jour du design d‚finitif (xhtml)
#   1.1 - 22/10/2007 : Passage a l'extension PHP
#
#---------------------------------------------------------------------------
# Utilisation :
#    perl prix.pl <fichier_prix> : g‚n‚ration fichier html,
#                                   livr‚ sur le site local
#
#    perl prix.pl [-r|-n|-a][-j] [-s|-c] <fichier_prix>
#                        -r : prix romans seulement
#                        -n : prix nouvelles seulement
#                        -a : prix auteur seulement
#                        -j : jointure Na Ne et S
#                        -s : (par d‚faut) livraison fichier HTML sur arbo site
#                        -c : sortie console
#---------------------------------------------------------------------------
#
# A FAIRE :
#
#   Option fichier texte DOS et WINDOWS
#
#   Si plusieurs ex-aequos, l'‚crire une seul fois (la derniŠre)
#
#   Si plusieurs commentaires identiques, n'en gardez qu'un
#    (actuellement, on n'en garde qu'un parmi les identiques qui se suivent !)
#
#   Nouvelles et romans generes en meme temps selon entete
#
#===========================================================================
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Variables de definition du fichier prix
#---------------------------------------------------------------------------
$prix_start=2;                           $prix_size=4;
$date_start=7;                           $date_size=4;
$type_start=12;                          $type_size=3;
$author_start=$type_start+$type_size;         $author_size=28;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
my $livraison_site=$local_dir . "/prix";

$ref_en_cours=0;
$in=0;
$oldin=0;
$old_date="";
$old_auteur="";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$catprix="TOUS";   # TOUS, ROMANS, NOUVELLES, AUTEURS
$join_nvl="NON";   # Na/ne/S regroup‚s ou non

#---------------------------------------------------------------------------
# Help
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "usage : $0 [-r|-n|-j] <fichier_prix>\n";
   print STDERR "        -h : help \n";
   print STDERR "        -r : prix romans seulement\n";
   print STDERR "        -n : prix nouvelles seulement\n";
   print STDERR "        -j : jointure Na Ne et S\n";
   print STDERR "      : Livraison fichier prix xhtml/php sur arbo site \n";
   exit;
}

if (($ARGV[0] eq "") || ($ARGV[0] eq "-h"))
{
   usage;
}
$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-r")
   {
      $catprix="ROMANS";
   }
   elsif ($ARGV[$i] eq "-a")
   {
      $catprix="AUTEURS";
   }
   elsif ($ARGV[$i] eq "-n")
   {
      $catprix="NOUVELLES";
   }
   elsif ($ARGV[$i] eq "-j")
   {
      $join_nvl="OUI";
   }
   else
   {
      $award_file=$ARGV[$i];
   }
   $i++;
}

#---------------------------------------------------------------------------
# Lecture du fichier prix
#---------------------------------------------------------------------------
$award_file=~s/.pri//;
$award_file=~s/$/.pri/;
open (f_prix, "<$award_file");
@prix=<f_prix>;
close (f_prix);

#---------------------------------------------------------------------------
# Recuperation des donnees
#---------------------------------------------------------------------------
$nbsigl_rom=0;
@sigle_rom=();
@titre_rom=();
@rom0=();
@rom1=();
@rom2=();
@rom3=();
@rom4=();
@rom5=();
@rom6=();
$max_rom=7;
@bdp_r0=();
@bdp_r1=();
@bdp_r2=();
@bdp_r3=();
@bdp_r4=();
@bdp_r5=();
@bdp_r6=();
$nbsigl_aut=0;
@sigle_aut=();
@titre_aut=();
@aut0=();
$max_aut=1;

$nbsigl_nvl=0;
@sigle_nvl=();
@titre_nvl=();
@nvl0=();
@nvl1=();
@nvl2=();
@nvl3=();
@nvlj=();
$max_nvl=4;
@bdp_n0=();
@bdp_n1=();
@bdp_n2=();
@bdp_n3=();
@bdp_nj=();

$nom="";
$creation="";
$periode="";
$categories="";
$origine="";
$genres="";
$cible="";
$vote="";
$dates="";
$url="";
$texte="";

foreach $ligne (@prix)
{
   # Recuperer, sur plusieurs lignes, le descriptif de la reference
   $lig=$ligne;
   chop ($lig);

   # virer les lignes vides et les commentaires
   if (length ($lig) != 0)
   {
      $prem=substr ($lig, 0, 1);
      if ($prem eq '.')
      {
         # lignes d'entete
         $entete=substr ($lig, 1);
         if (substr($entete, 0, 1) eq ' ')
         {
            $texte="$texte $entete";
         }
         else
         {
            ($descr)=split (/\./, $entete);
            $value=$entete;
            $value =~ s/$descr\.//;
            $descr=~s/ +$//;
            $descr=lc($descr);
            $value=~s/ +$//;
            $value=~s/^ +//;
            if ($descr eq "nom")
            {
               $nom=$value;
            }
            elsif ($descr eq "creation")
            {
               $creation=$value;
            }
            elsif ($descr eq "periode")
            {
               $periode=$value;
            }
            elsif ($descr eq "categories")
            {
               $categories=$value;
            }
            elsif ($descr eq "origine")
            {
               $origine=$value;
            }
            elsif ($descr eq "cible")
            {
               $cible=$value;
            }
            elsif ($descr eq "genres")
            {
               $genres=$value;
            }
            elsif ($descr eq "votants")
            {
               $vote=$value;
            }
            elsif ($descr eq "dates")
            {
               $dates=$value;
            }
            elsif ($descr eq "url")
            {
               $url=$value;
            }
            else
            {
               print STDERR "Type d'entete inconnu : $descr\n";
            }
         }
      }
      elsif ($prem eq "_")
      {
         #
         $catpage=substr ($lig, 2, 1);
         $sigprix=substr ($lig, 4, 2);
         $sigprix=~s/ $//;
         $titprix=substr ($lig, 7);
         if ($catpage eq "r")
         {
            if (($catprix eq "ROMANS") || ($catprix eq "TOUS")) {
#              print STDERR " OK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
               $nbsigl_rom++;
               if ($nbsigl_rom > $max_rom ) { print STDERR " Augmenter le nombre de tableaux romans $nbsigl_rom (max=$max_rom)\n"; exit; }
               push (@sigle_rom, $sigprix);
               push (@titre_rom, $titprix);
            }
            else {
#              print STDERR "NOK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
            }
         }
         elsif ($catpage eq "a")
         {
            if ($catprix eq "AUTEURS") {
               print STDERR " OK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
               $nbsigl_aut++;
               if ($nbsigl_aut > $max_aut ) { print STDERR " Augmenter le nombre de tableaux romans $nbsigl_aut (max=$max_aut)\n"; exit; }
               push (@sigle_aut, $sigprix);
               push (@titre_aut, $titprix);
            }
            else {
               print STDERR "NOK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
            }
         }
         elsif ($catpage eq "n")
         {
            if (($catprix eq "NOUVELLES") || ($catprix eq "TOUS")) {
#              print STDERR " OK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
               if ($join_nvl eq "NON")
               {
                  $nbsigl_nvl++;
                  if ($nbsigl_nvl > $max_nvl ) { print STDERR " Augmenter le nombre de tableaux nouvelles...\n"; exit; }
                  push (@sigle_nvl, $sigprix);
                  push (@titre_nvl, $titprix);
               }
               else
               {
                  if (($sigprix ne "Na") && ($sigprix ne "Ne") && ($sigprix ne "L") && ($sigprix ne "S"))
                  {
                     $nbsigl_nvl++;
                     if ($nbsigl_nvl > $max_nvl ) { print STDERR " Augmenter le nombre de tableaux nouvelles...\n"; exit; }
                     push (@sigle_nvl, $sigprix);
                     push (@titre_nvl, $titprix);
                  }
               }
            }
            else {
#              print STDERR "NOK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
            }
         }
         else
         {
            if ($catpage eq "p") {
#              print STDERR " OK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
               $nbsigl_rom++;
               push (@sigle_rom, $sigprix);
               push (@titre_rom, $titprix);
            }
            else {
#              print STDERR "NOK : CAT $catpage - SIG $sigprix - TIT $titprix \n";
            }
         }
         
      }
      elsif ($prem ne '!')
      {

         $flag_collab_suite=substr ($lig, $collab_n_pos, 1);
         $flag_collab_a_suivre=substr ($lig, $collab_f_pos, 1);

         if (($ref_en_cours == 1) && ($flag_collab_suite ne '&'))
         {
            # erreur, arret
            print STDERR "*** Error ***\n";
            print STDERR " <xxx &> non suivi de <& xxx> :\n";
            print STDERR "$old\n";
            print STDERR "$lig\n";
            exit;
         }
         elsif (($ref_en_cours == 0) && ($flag_collab_suite eq '&'))
         {
            # erreur, arret
            print STDERR "*** Error ***\n";
            print STDERR " <& xxx> non pr‚c‚d‚ de <xxx &> :\n";
            print STDERR "$old\n";
            print STDERR "$lig\n";
            exit;
         }
         else
         {
            $auteur=substr ($lig, $author_start, $author_size-1);
            $auteur=~s/ +$//;
            $auteur=~s/\*$//;

            $noteBdP=""; $numnote=""; $comment="";

            if ($ref_en_cours == 0)
            {
               if ($prem eq 'x')
               {
                  # Nouvelle reference : creation
                  $date=substr ($lig, $date_start, $date_size);
                  $date=~s/ +$//;
                  $date=~s/^ +//;
      
                  $type=substr ($lig, $type_start, $type_size);
                  $type=~s/ +$//;
      
                  $reste=substr ($lig, $author_start);
                  $reste=~s/^ +//;
                  # extraction note de BdP [*<i>] <...>
                  ($attrib, $noteBdP)=split (/ \[\*/,$reste);
                  $attrib=~s/ +$//;
                  $noteBdP=~s/ +$//;
                  if ($noteBdP ne "")
                  {
                     if (substr($noteBdP, 0, 1) ne ']') {
                        $numnote=substr($noteBdP, 0, 1);
                     }
                     $noteBdP="[*" . $noteBdP;
                  }
                  $noteBdP=~s/ +$//;
                  # extraction commentaire [+<...>]
                  ($attrib, $cmt)=split (/ \[\+/,$attrib);
                  $attrib=~s/ +$//;
                  $cmt=~s/ +$//;
                  if ($cmt ne "")
                  {
                     $comment="[" . $cmt;
                  }
                  $reference = {
                     TITRE=>"",
                     VOTITRE=>"",
                     NB_AUTEUR=>0,
                     AUTEUR=>"",
                     AUTEUR2=>"",
                     AUTEUR3=>"",
                     CAT_NOV=>"",
                     DATE=>"$date",
                     NON_ATTRIBUE=>1,
                     ATTRIB=>"$attrib",
                     NOTE=>"$noteBdP",
                     NUMNOTE=>"$numnote",
                     CMT=>"$comment",
                  };
               }
               else
               {
                  # Nouvelle reference : creation
                  $date=substr ($lig, $date_start, $date_size);
                  $date=~s/ +$//;
                  $date=~s/^ +//;

                  $type=substr ($lig, $type_start, $type_size);
                  $type=~s/ +$//;

                  $suite=substr ($lig, $title_start);

                  #--- extraction note de BdP [*<i>] <...>
                  ($reste, $noteBdP)=split (/ \[\*/,$suite);
                  $reste=~s/ +$//;
                  $noteBdP=~s/ +$//;
                  if ($noteBdP ne "")
                  {
                     if (substr($noteBdP, 0, 1) ne "]") {
                        $numnote=substr($noteBdP, 0, 1);
                     }
                     $noteBdP="[*" . $noteBdP;
                  }
                  #--- extraction commentaire [+<...>]
                  ($reste, $cmt)=split (/ \[\+/,$reste);
                  $reste=~s/ +$//;
                  $cmt=~s/ +$//;
                  if ($cmt ne "")
                  {
                     $comment="[" . $cmt;
                  }
                  $titre=""; $votitre="";
                  ($titre, $votitre)=split (/þ/,$reste);
                  $titre=~s/ +$//;
                  $votitre=~s/ +$//;


                  $reference = {
                     TITRE=>"$titre",
                     VOTITRE=>"$votitre",
                     NB_AUTEUR=>1,
                     AUTEUR=>"$auteur",
                     AUTEUR2=>"",
                     AUTEUR3=>"",
                     DATE=>"$date",
                     NON_ATTRIBUE=>0,
                     ATTRIB=>"",
                     NOTE=>"$noteBdP",
                     NUMNOTE=>"$numnote",
                     CMT=>"$comment",
                  };
               };
            }
            else
            {
               # Reference existante : update
               if ($reference->{NB_AUTEUR} == 1)
               {
                  $reference->{NB_AUTEUR} = 2;
                  $reference->{AUTEUR2} = "$auteur";
               }
               elsif ($reference->{NB_AUTEUR} == 2)
               {
                  $reference->{NB_AUTEUR} = 3;
                  $reference->{AUTEUR3} = "$auteur";
               }
               else
               {
                  # erreur, arret
                  print STDERR "*** Error ***\n";
                  print STDERR " plus de 3 auteurs ?!\n";
                  print STDERR "$lig\n";
                  exit;
               }
            }

            if ($flag_collab_a_suivre eq '&')
            {
               # A suivre...
               $ref_en_cours = 1;
            }
            else
            {
               # Reference complete
               $ref_en_cours = 0;
# essai
#print "nbsigl_rom = $nbsigl_rom \n";
#print "(${sigle_rom[0]}-$type)";
#               if ($nbsigl_rom > 0) { print "greater ! \n"; }
#               if ($type == $sigle_rom[0]) { print "sigle OK ! \n"; }
               if (($nbsigl_rom > 0) && ($type eq $sigle_rom[0]))
               {
#print "A";
                  push (@rom0, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r0, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_rom > 1) && ($type eq $sigle_rom[1]))
               {
                  push (@rom1, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r1, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_rom > 2) && ($type eq $sigle_rom[2]))
               {
                  push (@rom2, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r2, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_rom > 3) && ($type eq $sigle_rom[3]))
               {
                  push (@rom3, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r3, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_rom > 4) && ($type eq $sigle_rom[4]))
               {
                  push (@rom4, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r4, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_rom > 5) && ($type eq $sigle_rom[5]))
               {
                  push (@rom5, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r5, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_rom > 6) && ($type eq $sigle_rom[6]))
               {
                  push (@rom6, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r6, $noteBdP); $noteBdP=""; }
               }

#print "(${sigle_nvl[0]}-$type)";
               if (($nbsigl_aut > 0) && ($type eq $sigle_aut[0]))
               {
#print "A";
                  push (@aut0, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_r0, $noteBdP); $noteBdP=""; }
               }
               if (($join_nvl eq "OUI") && (($type eq "Na") || ($type eq "Ne") || ($type eq "L") || ($type eq "S")))
               {
                  $reference->{CAT_NOV} = $type;
                  push (@nvlj, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_nj, $noteBdP); $noteBdP=""; }
               }
               if (($nbsigl_nvl > 0) && ($type eq $sigle_nvl[0]))
               {
                  push (@nvl0, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_n0, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_nvl > 1) && ($type eq $sigle_nvl[1]))
               {
                  push (@nvl1, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_n1, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_nvl > 2) && ($type eq $sigle_nvl[2]))
               {
                  push (@nvl2, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_n2, $noteBdP); $noteBdP=""; }
               }
               elsif (($nbsigl_nvl > 3) && ($type eq $sigle_nvl[3]))
               {
                  push (@nvl3, $reference);
                  if ($noteBdP ne "")
                  { push (@bdp_n3, $noteBdP); $noteBdP=""; }
               }
            }
         }
         $old=$lig;
      }
   }

}


#print " ROM ($nbsigl_rom)\n";
#foreach $item (@sigle_rom) { print " $item \n" }
#foreach $item (@titre_rom) { print " $item \n" }
#print " NVL ($nbsigl_nvl)\n";
#foreach $item (@sigle_nvl) { print " $item \n" }
#foreach $item (@titre_nvl) { print " $item \n" }

# test
#print "new :\n";
#foreach $item (@rom0) { print " $item->{TITRE} \n"; }
#print "old :\n";
#foreach $item (@romans) { print " $item->{TITRE} \n"; }

# Trier les tableaux (new)
#--------------------
@romtri0=sort tri @rom0;
@romtri1=sort tri @rom1;
@romtri2=sort tri @rom2;
@romtri3=sort tri @rom3;
@romtri4=sort tri @rom4;
@romtri5=sort tri @rom5;
@romtri6=sort tri @rom6;

@auttri0=sort tri @aut0;

@nvltri0=sort tri @nvl0;
@nvltri1=sort tri @nvl1;
@nvltri2=sort tri @nvl2;
@nvltri3=sort tri @nvl3;

@nvltrij=sort tri @nvlj;

#---------------------------------------------------------------------------
# Determination du device de sortie
#---------------------------------------------------------------------------
# remplacer ‚galement les caractŠres accentu‚s
$outfile=lc($award_file);
$outfile=~s/.pri//;

# A  FAIRE : virer le l final des que OK pour tous...
if ($catprix eq "ROMANS")
{
   $outf="${livraison_site}/${outfile}_r.php";
}
elsif ($catprix eq "NOUVELLES")
{
   $outf="${livraison_site}/${outfile}_n.php";
}
else
{
   $outf="${livraison_site}/${outfile}.php";
}

open (OUTP, ">$outf");
print STDERR "resultat dans $outf\n";
$canal=OUTP;

# Sortie resultats
#---------------------
   &web_begin($canal, "../commun/", "$nom");
   &web_head_meta ("author", "Moulin Christian, Richardot Gilles");
   &web_head_meta ("description", "Prix SF : $nom");
   &web_head_meta ("keywords", "Prix, Award, distinction, SF, science-fiction, fantastique, fantasy, imaginaire, $nom");
   &web_head_css ("screen", "../styles/bdfi.css");
   &web_head_js ("../scripts/outils.js");
   &web_body ();
   &web_menu (1, "prix");

   &web_data ("<div id='menbib'>");
   &web_data (" [ <a href='javascript:history.back();' onmouseover='window.status=\"Back\";return true;'>Retour</a> ] ");
   &web_data ("Vous &ecirc;tes ici : <a href='../..'>BDFI</a>\n");
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> Base\n");
   &web_data ("<img src='../images/sep.png' alt='--&gt;'/> <a href='.'>Prix</a>\n");
   $pays=$origine; $pays=~s/\.$//;
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> $pays\n");
   $nommenu=$nom; $nommenu=~s/<BR>/ - /i; $nommenu=~s/<BR \/>/ - /i;
   &web_data ("<img src='../images/sep.png'  alt='--&gt;'/> $nommenu\n");
   &web_data ("<br />");
   &web_data ("Les principaux prix de l'imaginaire (SF, fantasy, fantastique, horreur) ");
   &web_data (" - <a href='javascript:mail_prix();'>Ecrire &agrave; BDFI</a> pour compl&eacute;ments &amp; corrections.");
   &web_data ("</div>\n");

   print $canal "<a name='$outfile'></a>";
   print $canal "<h1>";

   # si fichier _n, ajouter (nouvelles), sinon ajouter (romans)
   #doser la taille en fonction de la longueur du nom
   if (length ($nom) < 15) { $size=5; }
   elsif (length ($nom) < 45) { $size=4; }
   else { $size=3; }
    
   if ($catprix eq "ROMANS")
   {
      &web_data ("$nom (romans)");
   }
   elsif ($catprix eq "NOUVELLES")
   {
      &web_data ("$nom (nouvelles)");
   }
   else
   {
      &web_data ("$nom");
   }
   &web_data ("</h1>\n");

   print $canal "<h2>En bref</h2>";

   # ici, les infos d'entete...
   if ($creation ne "")
   {
      &web_data ("<br /><em>Cr‚ation :</em> $creation\n");
   }
   if ($periode ne "")
   {
      &web_data ("<br /><em>P‚riode :</em> $periode\n");
   }
   if ($origine ne "")
   {
      &web_data ("<br /><em>Origine :</em> $origine\n");
   }
   if ($genres ne "")
   {
      &web_data ("<br /><em>Genres :</em> $genres\n");
   }
   if ($cible ne "")
   {
      &web_data ("<br /><em>Cibles :</em> $cible\n");
   }
   if ($categories ne "")
   {
      &web_data ("<br /><em>Cat‚gories :</em> $categories\n");
   }
   if ($vote ne "")
   {
      &web_data ("<br /><em>Votants :</em> $vote\n");
   }
   if ($dates ne "")
   {
      &web_data ("<br /><em>Dates :</em> $dates\n");
   }
   if ($url ne "")
   {
      &web_data ("<br /><em>Site officiel :</em> <a href='$url'>$url</a>\n");
   }
   if ($texte ne "")
   {
      &web_data ("<p>$texte</p>\n");
   }

   &web_data ("<h2>Les r‚compenses</h2>");

if (($catprix eq "AUTEURS") && ($#auttri0 + 1 > 0))
{
   &web_data ("<h3>$titre_aut[0]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@auttri0) { &AFFICHE_AUTEUR ($item); }
   &web_data ("</table>\n\n");
   if ($#bdp_r0 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r0+1; $ind++) {
#print STDERR "bdp $bdp_r0[$ind] \n";
         if (($ind == 0) || ($bdp_r0[$ind] ne $bdp_r0[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r0[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri0 + 1 > 0))
{
   &web_data ("<h3>$titre_rom[0]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri0) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r0 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r0+1; $ind++) {
#print STDERR "bdp $bdp_r0[$ind] \n";
         if (($ind == 0) || ($bdp_r0[$ind] ne $bdp_r0[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r0[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri1 + 1 > 0))
{
   &web_data ("<h3>$titre_rom[1]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri1) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r1 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r1+1; $ind++) {
         if (($ind == 0) || ($bdp_r1[$ind] ne $bdp_r1[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r1[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri2 + 1 > 0))
{
   &web_data ("<h3>$titre_rom[2]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri2) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r2 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r2+1; $ind++) {
         if (($ind == 0) || ($bdp_r2[$ind] ne $bdp_r2[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r2[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri3 + 1 > 0))
{
   &web_data ("<h3>$titre_rom[3]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri3) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r3 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r3+1; $ind++) {
         if (($ind == 0) || ($bdp_r3[$ind] ne $bdp_r3[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r3[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri4 + 1 > 0))
{

   &web_data ("<h3>$titre_rom[4]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri4) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r4 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r4+1; $ind++) {
         if (($ind == 0) || ($bdp_r4[$ind] ne $bdp_r4[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r4[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri5 + 1 > 0))
{
   &web_data ("<h3>$titre_rom[5]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri5) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r5 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r5+1; $ind++) {
         if (($ind == 0) || ($bdp_r5[$ind] ne $bdp_r5[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r5[$ind]);
         }
      }
   }
}
$old_date="";
if (($catprix ne "NOUVELLES") && ($#romtri6 + 1 > 0))
{
   &web_data ("<h3>$titre_rom[6]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@romtri6) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_r6 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_r6+1; $ind++) {
         if (($ind == 0) || ($bdp_r6[$ind] ne $bdp_r6[$ind - 1])) {
            &AFFICHE_BDP ($bdp_r6[$ind]);
         }
      }
   }
}

print $canal "<a name='forme_courte'></a>";
if (($catprix ne "ROMANS") && ($#nvltrij + 1 > 0))
{
   &web_data ("<h3>Nouvelles</h3>\n");
   &web_data ("<div style='margin: 10px 100px;'><span style='color:#305000'><b>Na</b></span>&nbsp;= Novella<br />\n");
   &web_data ("<span style='color:#208000'><b>Ne</b></span>&nbsp;= Novelette<br />\n");
   &web_data ("<span style='color:#402000'><b>L</b> &nbsp;</span>&nbsp;= Long Fiction<br />\n");
   &web_data ("<span style='color:#10B000'><b>S</b> &nbsp;</span>&nbsp;= Short Story<br /></div>\n");
   &web_data ("\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@nvltrij) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");
   if ($#bdp_nj + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_nj+1; $ind++) {
         if (($ind == 0) || ($bdp_nj[$ind] ne $bdp_nj[$ind - 1])) {
            &AFFICHE_BDP ($bdp_nj[$ind]);
         }
      }
   }
}
if (($catprix ne "ROMANS") && ($#nvltri0 + 1 > 0))
{
   &web_data ("<h3>$titre_nvl[0]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@nvltri0) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_n0 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_n0+1; $ind++) {
         if (($ind == 0) || ($bdp_n0[$ind] ne $bdp_n0[$ind - 1])) {
            &AFFICHE_BDP ($bdp_n0[$ind]);
         }
      }
   }
}
if (($catprix ne "ROMANS") && ($#nvltri1 + 1 > 0))
{
   &web_data ("<h3>$titre_nvl[1]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@nvltri1) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_n1 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_n1+1; $ind++) {
         if (($ind == 0) || ($bdp_n1[$ind] ne $bdp_n1[$ind - 1])) {
            &AFFICHE_BDP ($bdp_n1[$ind]);
         }
      }
   }
}
if (($catprix ne "ROMANS") && ($#nvltri2 + 1 > 0))
{
   &web_data ("<h3>$titre_nvl[2]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@nvltri2) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_n2 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_n2+1; $ind++) {
         if (($ind == 0) || ($bdp_n2[$ind] ne $bdp_n2[$ind - 1])) {
            &AFFICHE_BDP ($bdp_n2[$ind]);
         }
      }
   }
}
if (($catprix ne "ROMANS") && ($#nvltri3 + 1 > 0))
{
   &web_data ("<h3>$titre_nvl[3]</h3>\n");
   &web_data ("<table class='prix'>\n");

   foreach $item (@nvltri3) { &AFFICHE_TITRE ($item); }
   &web_data ("</table>\n\n");

   if ($#bdp_n3 + 1 > 0)
   {
      for ($ind=0; $ind<$#bdp_n3+1; $ind++) {
         if (($ind == 0) || ($bdp_n3[$ind] ne $bdp_n3[$ind - 1])) {
            &AFFICHE_BDP ($bdp_n3[$ind]);
         }
      }
   }
}

&web_end();
close (OUTP);

#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference
#---------------------------------------------------------------------------
sub AFFICHE_BDP {
   $note=@_[0];
#print "AFF: note = $note \n";
   ($sig, @txt)=split(/ /, $note);
#print "AFF: sig = $sig ; txt = @txt \n";

   &web_data ("<span style='margin: 0 0 0 40px'><em>${sig}</em>");
   &web_data (" @{txt}");
   &web_data ("</span>\n");
}

#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference par auteur
# -->  date / auteur / titre (s)
#---------------------------------------------------------------------------
$old_auteur="";
sub AFFICHE_AUTEUR {
   local($aa)=$_[0];

      &web_data (" <tr>\n");
      if ($aa->{DATE} ne $old_date)
      {
         &web_data ("  <td><span class='date'>$aa->{DATE}&nbsp;&nbsp;&nbsp;</span></td>\n");
      }
      else
      {
         &web_data ("  <td></td>\n");
      }
      if ($aa->{NON_ATTRIBUE} == 0)
      {
         if (($aa->{AUTEUR} ne $old_auteur) || ($aa->{DATE} ne $old_date))
         {
         &web_data ("  <td>");
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR});
         $initiale=substr ($lien_auteur, 0, 1);
         $initiale=lc($initiale);
         $url="../bdfi/auteurs/${initiale}/${lien_auteur}.php";
   
         $nf=1;
#        &web_data ("    (");
         open(AUTHOR, "<$url") or $nf=0;
         if ($nf == 1)   # lien existe
         {
            close AUTHOR;
            &web_data ("<a class='auteur' href='../auteurs/$initiale/$lien_auteur.php'>");
            &web_data ("$aa->{AUTEUR}");
            &web_data ("</a>");
         }
         else
         {
            &web_data ("<span class='nom'>$aa->{AUTEUR}</span>");
         }
         if ($aa->{NB_AUTEUR} > 1)
         {
            # nom du lien, et initiale
            $lien_auteur=&url_auteur($aa->{AUTEUR2});
            $initiale=substr ($lien_auteur, 0, 1);
            $initiale=lc($initiale);
            $url="$local_dir/auteurs/$initiale/${lien_auteur}.php";
         #  $url="../bdfi/auteurs/${initiale}/${lien_auteur}.php";
   
            $nf=1;
            open(AUTHOR, "<$url") or $nf=0;
            &web_data (" &amp; ");
            if ($nf == 1)   # lien existe
            {
               &web_data ("<a class='auteur' href='../auteurs/$initiale/$lien_auteur.php'>");
               &web_data ("$aa->{AUTEUR2}\n");
               &web_data ("</a>");
            }
            else
            {
               &web_data ("<span class='nom'>$aa->{AUTEUR2}</span>");
            }
            if ($aa->{NB_AUTEUR} > 2)
            {
               # nom du lien, et initiale
               $lien_auteur=&url_auteur($aa->{AUTEUR3});
               $initiale=substr ($lien_auteur, 0, 1);
               $initiale=lc($initiale);
               $url="$local_dir/auteurs/$initiale/${lien_auteur}.php";
           #   $url="../bdfi/auteurs/${initiale}/${lien_auteur}.php";
   
               $nf=1;
               open(AUTHOR, "<$url") or $nf=0;
               &web_data (" &amp; ");
               if ($nf == 1)   # lien existe
               {
                  &web_data ("<a class='auteur' href='../auteurs/$initiale/$lien_auteur.php'>");
                  &web_data ("$aa->{AUTEUR3}\n");
                  &web_data ("</a>");
               }
               else
               {
                  &web_data ("<span class='nom'>$aa->{AUTEUR3}</span>");
               }
            }
         }
         &web_data ("&nbsp;&nbsp;&nbsp;</td>\n");
         }
         else
         {
            &web_data ("<td></td>\n");
         }

         &web_data ("  <td> $aa->{TITRE} ");
         if ($aa->{VOTITRE} ne "")
         {
            &web_data (" (<i>$aa->{VOTITRE}</i>) ");
         }
      }
      else
      {
         &web_data ("  <td> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <em>$aa->{ATTRIB}</em>");
      }
      if ($aa->{CMT} ne "")
      {
         &web_data (" &nbsp;&nbsp;<span class='cmt'>$aa->{CMT}</span>\n");
      }
      if ($aa->{NOTE} ne "")
      {
         &web_data (" &nbsp;&nbsp;<em>[*$aa->{NUMNOTE}]</em>\n");
      }
      if (($aa->{DATE} eq $old_date) && ($aa->{AUTEUR} ne $old_auteur))
      {
         &web_data (" <em>ex-aequos.</em>\n");
      }
      &web_data ("</td></tr>\n");

   $old_date=$aa->{DATE};
   $old_auteur=$aa->{AUTEUR};
}

#---------------------------------------------------------------------------
# Subroutine d'affichage d'une reference par titre
# -->  date / titre / auteur(s)
#---------------------------------------------------------------------------
sub AFFICHE_TITRE {
   local($aa)=$_[0];

      &web_data (" <tr>\n");
      if ($aa->{DATE} ne $old_date)
      {
         &web_data ("  <td><span class='date'>$aa->{DATE}</span>&nbsp;&nbsp;&nbsp;</td>\n");
      }
      else
      {
         &web_data ("  <td></td>\n");
      }
      if ($aa->{NON_ATTRIBUE} == 0)
      {
         if ($join_nvl eq "OUI") {
            if ($aa->{CAT_NOV} eq "L") {
               &web_data ("<td><span style='color:#402000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
            elsif ($aa->{CAT_NOV} eq "Na") {
               &web_data ("<td><span style='color:#305000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
            elsif ($aa->{CAT_NOV} eq "Ne") {
               &web_data ("<td><span style='color:#208000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
            elsif ($aa->{CAT_NOV} eq "S") {
               &web_data ("<td><span style='color:#10B000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
         }
         &web_data ("  <td>$aa->{TITRE} ");
         if ($aa->{VOTITRE} ne "")
         {
            &web_data (" (<i>$aa->{VOTITRE}</i>) ");
         }
         &web_data (" &nbsp;");
   
         # nom du lien, et initiale
         $lien_auteur=&url_auteur($aa->{AUTEUR});
         $initiale=substr ($lien_auteur, 0, 1);
         $initiale=lc($initiale);
      #  $url="../bdfi/auteurs/${initiale}/${lien_auteur}.php";
         $url="$local_dir/auteurs/$initiale/${lien_auteur}.php";
   
         $nf=1;
         open(AUTHOR, "<$url") or $nf=0;
         &web_data ("    (");
         if ($nf == 1)   # lien existe
         {
            close AUTHOR;
            &web_data ("<a class='auteur' href='../auteurs/$initiale/$lien_auteur.php'>");
            &web_data ("$aa->{AUTEUR}");
            &web_data ("</a>");
         }
         else
         {
            &web_data ("<span class='nom'>$aa->{AUTEUR}</span>");
         }
         if ($aa->{NB_AUTEUR} > 1)
         {
            # nom du lien, et initiale
            $lien_auteur=&url_auteur($aa->{AUTEUR2});
            $initiale=substr ($lien_auteur, 0, 1);
            $initiale=lc($initiale);
        #   $url="../bdfi/auteurs/${initiale}/${lien_auteur}.php";
            $url="$local_dir/auteurs/$initiale/${lien_auteur}.php";
   
            $nf=1;
            open(AUTHOR, "<$url") or $nf=0;
            &web_data (" &amp; ");
            if ($nf == 1)   # lien existe
            {
               &web_data ("<a class='auteur' href='../auteurs/$initiale/$lien_auteur.php'>");
               &web_data ("$aa->{AUTEUR2}\n");
               &web_data ("</a>");
            }
            else
            {
               &web_data ("<span class='nom'>$aa->{AUTEUR2}</span>");
            }
            if ($aa->{NB_AUTEUR} > 2)
            {
               # nom du lien, et initiale
               $lien_auteur=&url_auteur($aa->{AUTEUR3});
               $initiale=substr ($lien_auteur, 0, 1);
               $initiale=lc($initiale);
           #   $url="../bdfi/auteurs/${initiale}/${lien_auteur}.php";
               $url="$local_dir/auteurs/$initiale/${lien_auteur}.php";
   
               $nf=1;
               open(AUTHOR, "<$url") or $nf=0;
               &web_data (" &amp; ");
               if ($nf == 1)   # lien existe
               {
                  &web_data ("<a class='auteur' href='../auteurs/$initiale/$lien_auteur.php'>");
                  &web_data ("$aa->{AUTEUR3}\n");
                  &web_data ("</a>");
               }
               else
               {
                  &web_data ("<span class='nom'>$aa->{AUTEUR3}</span>");
               }
            }
         }
         &web_data (")\n");
      }
      else
      {
         if ($join_nvl eq "OUI") {
            if ($aa->{CAT_NOV} eq "L") {
               &web_data ("<td><span style='color:#402000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
            elsif ($aa->{CAT_NOV} eq "Na") {
               &web_data ("<td><span style='color:#305000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
            elsif ($aa->{CAT_NOV} eq "Ne") {
               &web_data ("<td><span style='color:#208000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
            elsif ($aa->{CAT_NOV} eq "S") {
               &web_data ("<td><span style='color:#10B000'><b>$aa->{CAT_NOV}</b>&nbsp;&nbsp;</span></td>");
            }
         }
         &web_data ("  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <em>$aa->{ATTRIB}</em>");
      }
      if ($aa->{CMT} ne "")
      {
         &web_data (" &nbsp;&nbsp;<span class='cmt'>$aa->{CMT}</span>\n");
      }
      if ($aa->{NOTE} ne "")
      {
         &web_data (" &nbsp;&nbsp;<em>[*$aa->{NUMNOTE}]</em>\n");
      }
      if (($aa->{DATE} eq $old_date) && ($aa->{CAT_NOV} eq $old_cat))
      {
         &web_data (" <em>ex-aequos.</em>\n");
      }
      &web_data ("</td></tr>\n");

   $old_date=$aa->{DATE};
   $old_cat=$aa->{CAT_NOV};
}

#---------------------------------------------------------------------------
# Subroutine de tri des listes obtenues
#---------------------------------------------------------------------------
sub tri
{
   # ----------------------------------------------
   #  tri par date
   # ----------------------------------------------
   if (uc($a->{DATE}) ne uc($b->{DATE}))
   {
    uc($a->{DATE}) cmp uc($b->{DATE});
   }
   else
   {
    uc($a->{DATE}) cmp uc($b->{DATE});
   }
}

# --- fin ---

