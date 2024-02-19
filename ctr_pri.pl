#===========================================================================
#
# Script de controle et ajout d'une page prix
#
#---------------------------------------------------------------------------
# Historique :
#  26/09/2001 creation 
#  ../../2001 
#---------------------------------------------------------------------------
# Utilisation :
#    perl maj_prix.pl [-c|-m] <fichier_prix> : g‚n‚ration fichier html,
#                                   livr‚ sur le site local
#
#---------------------------------------------------------------------------
#
# A FAIRE :
#
#
#===========================================================================

#---------------------------------------------------------------------------
# Variables de definition du fichier prix
#---------------------------------------------------------------------------
$prix_start=2;                                          $prix_size=4;
$prix_date_start=7;                                     $prix_date_size=4;
$prix_type_start=12;                                    $prix_type_size=3;
$prix_author_start=$prix_type_start+$prix_type_size;    $prix_author_size=28;
$prix_title_start=$prix_author_start+$prix_author_size;

$prix_collab_f_pos=$prix_author_start+$prix_author_size-1;
$prix_collab_n_pos=0;

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------
$coll_start=2;                                $coll_size=4;
$num_start=6;                                 $num_size=5;
$date_start=12;                               $date_size=4;
$type_start=17;                               $type_size=4;
$author_start=$type_start+$type_size;         $author_size=24;
$title_start=$author_start+$author_size;

$collab_f_pos=$author_start+$author_size-1;
$collab_n_pos=0;

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------
$ref_en_cours=0;
$in=0;
$oldin=0;
$old_date="";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$type_tri=0;
$oper="CTRL";      # CTRL, MAJ
$catprix="TOUS";   # ROMANS, NOUVELLES
$no_coll=0;

#---------------------------------------------------------------------------
# Help
#---------------------------------------------------------------------------
sub usage
{
   print STDERR "usage : $0 [-h|-c|-m] <fichier_prix>\n";
   print STDERR "        -h : help \n";
   print STDERR "        -c : controle des traductions\n";
   print STDERR "        -m : mise a jour des traductions\n";
   exit;
}

if (($ARGV[0] eq "") || ($ARGV[0] eq "-h"))
{
   usage;
}
$i=0;

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-c")
   {
      $oper="CTRL";
   }
   elsif ($ARGV[$i] eq "-m")
   {
      $oper="MAJ";
   }
   else
   {
      $award_file=lc($ARGV[$i]);
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
# Lecture du fichier ouvrages
#---------------------------------------------------------------------------
$file="ouvrages.res";
open (f_ouv, "<$file");
@ouv=<f_ouv>;
close (f_ouv);

#---------------------------------------------------------------------------
$nom="";
$creation="";
$periode="";
$categories="";
$origine="";
$genres="";
$cible="";
$vote="";
$dates="";
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
            ($descr, @values)=split (/\./,$entete);
            $descr=~s/ +$//;
            $descr=lc($descr);
            $value=$values[0];
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
      elsif ($prem ne '!')
      {

         $flag_collab_suite=substr ($lig, $prix_collab_n_pos, 1);
         $flag_collab_a_suivre=substr ($lig, $prix_collab_f_pos, 1);

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
            $auteur=substr ($lig, $prix_author_start, $prix_author_size-1);
            $auteur=~s/ +$//;

            $note=""; $comment="";

            if ($ref_en_cours == 0)
            {
               if ($prem eq 'x')
               {
                  # Nouvelle reference : creation
                  $date=substr ($lig, $prix_date_start, $prix_date_size);
                  $date=~s/ +$//;
                  $date=~s/^ +//;
      
                  $type=substr ($lig, $prix_type_start, $prix_type_size);
                  $type=~s/ +$//;
      
                  $reste=substr ($lig, $prix_author_start);
                  $reste=~s/^ +//;
                  ($attrib, $note)=split (/ \[/,$reste);
                  $attrib=~s/ +$//;
                  $note=~s/ +$//;
                  if (substr($note, 0, 1) eq '*')
                  {
                     $comment=substr($note, 2);
                     $note="*]";
                  }

                  $reference = {
                     TITRE=>"",
                     VOTITRE=>"",
                     NB_AUTEUR=>0,
                     AUTEUR=>"",
                     AUTEUR2=>"",
                     AUTEUR3=>"",
                     DATE=>"$date",
                     NON_ATTRIBUE=>1,
                     ATTRIB=>"$attrib",
                     NOTE=>"$note",
                  };
               }
               else
               {
                  # Nouvelle reference : creation
                  $date=substr ($lig, $prix_date_start, $prix_date_size);
                  $date=~s/ +$//;
                  $date=~s/^ +//;

                  $type=substr ($lig, $prix_type_start, $prix_type_size);
                  $type=~s/ +$//;

                  $suite=substr ($lig, $prix_title_start);
                  $titre=""; $vo=""; $votitre="";

                  ($reste, $note)=split (/ \[/,$suite);
                  $reste=~s/ +$//;
                  $note=~s/ +$//;
                  if (substr($note, 0, 1) eq '*')
                  {
                     $comment=substr($note, 2);
                     $note="*]";
                  }

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
                     NOTE=>"$note",
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
#              if ($type eq "R")
#              {
#                 push (@romans, $reference);
#                 if ($comment ne "")
#                 { push (@cmt_r, $comment); $comment=""; }
#              }
#              elsif ($type eq "R_")
#              {
#                 push (@romans_etr, $reference);
#                 if ($comment ne "")
#                 { push (@cmt_re, $comment); $comment=""; }
#              }
#              elsif ($type eq "N")
#              {
#                 push (@nouvelles, $reference);
#                 if ($comment ne "")
#                 { push (@cmt_n, $comment); $comment=""; }
#              }
#              elsif ($type eq "N_")
#              {
#                 push (@nouvelles_etr, $reference);
#                 if ($comment ne "")
#                 { push (@cmt_ne, $comment); $comment=""; }
#              }
            }
#           print STDOUT "$reference->{TITRE} --- $reference->{VOTITRE} \n";
            if (($reference->{TITRE} eq "") && ($reference->{VOTITRE} ne ""))
            {
# rechercher dans ouvrages.res un titre VO identique, auteur identique
               $cherche=lc($reference->{VOTITRE});
               print STDOUT "($reference->{AUTEUR}) $reference->{TITRE} --- $cherche \n";
@res=grep (m/$cherche/i, @ouv);

$nb=$#res+1;
if ($nb >= 1)
{
   foreach $i (@res) { print STDOUT "$i"; }
}

            }

         }
         $old=$lig;
      }
   }

}

# --- fin ---

