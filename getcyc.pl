# Mettre Ö jour pour :
#  [OK] rechercher les "[" pour initier les relations
#  [OK] prendre en compte les titres alternatifs et VO
#

$fichier = $ARGV[0];

# Ouverture des series en lecture
$series_file="E:/sf/series.see";
open (f_ser, "<$series_file");
@series=<f_ser>;
close (f_ser);

# Ouverture du fichier de sortie stockant les ID de sÇrie
$idcycles="E:/sf/cycles.id";
open (IDC, ">$idcycles");
$file_idcycles=IDC;

# Ouverture du canal des "parents" en crÇation-Çcriture
$parents="E:/sf/parents.res";
open (PAR, ">$parents");
$file_par=PAR;

foreach $ligne (@series)
{
   $lig=$ligne;
   chop ($lig);
   if (($pos = index($lig," [")) != -1) {
      $serie = substr($lig, 0, $pos);
      $parent = substr($lig, $pos+2);
      $parent=~s/]//;
      print $file_par "$serie	$parent\n";
   }
}
close (PAR);

# Ouverture des titres alternatifs et vo en lecture
$alt_file="E:/sf/series.alt";
open (f_alt, "<$alt_file");
@alt=<f_alt>;
close (f_alt);

$vo_file="E:/sf/series.vo";
open (f_vo, "<$vo_file");
@vo=<f_vo>;
close (f_vo);

# Ouverture du canal des "parents" en lecture
$parents="E:/sf/parents.res";
open (f_par, "<$parents");
@parents=<f_par>;
close (f_par);

# Ouverture des canaux JSON de sortie en crÇation-Çcriture
$cyc="E:/laragon/www/bdfi-v2/storage/app/cycles.json";
open (CYC, ">$cyc");
$file_cyc=CYC;

#   Ajouter "{\n" au fichier json de sortie
#if (!(-s $file_cyc)) # fichier n'existe pas ou de taille nulle
#{
print $file_cyc "[\n";
#}


$id=0;
#--- Pour chaque nom de SERIES
foreach $ligne (@series)
{
   $lig=$ligne;
   chop ($lig);

   # virer les lignes vides et les commentaires
   if (length ($lig) == 0) {
      print "ERREUR, ligne vide\n";
      exit 0;
   }

   # On compte les lignes utiles pour mettre les virgules
   $id++ ;
   if ($id > 1) {
      print $file_cyc ",\n";
   }

   #-----------------------------------------------------------------------
   #--- $nom_bdfi = Supprimer le parent
   #--- $nom_seul = Supprimer le discriminateur entre parenthäses # TBD : pourquoi áa ?! áa crÇÇ des doublons !!
   #--- Ajouter 'name' et 'nom_bdfi' au fichier json de sortie
   #-----------------------------------------------------------------------
   $nom_bdfi = $lig;
   $nom_bdfi=~s/=//g;
   $nom_bdfi=~s/^ +//g;
   $nom_bdfi=~s/ +$//g;
   $nom_bdfi=~s/ \[.*$//g;
   $nom_bdfi=~s/\"/\\"/g;

   $nom_seul=$nom_bdfi;
   $nom_seul=~s/ \(.*$//g;

   print $file_cyc "{\n";

   print $file_cyc "\"name\": \"" . oem2utf($nom_seul) . "\"";
   print $file_cyc ",\n";

   print $file_cyc "\"nom_bdfi\": \"" . oem2utf($nom_bdfi) . "\"";

   print $file_idcycles "$nom_seul	$id\n";

   #-----------------------------------------------------------------------
   #--- Si $nom_seul appartient Ö la premiäre colonne de PARENTS
   #-----------------------------------------------------------------------
   @papa = grep(/^${nom_bdfi}	/, @parents);
   #if ($nom_seul eq "Shadowlands")
   #{
   #   print "[DBG][" . ${nom_bdfi} . "] Nb parents " . scalar(@papa) . "\n";
   #}
   if (scalar(@papa) == 2)
   {
      print "ERREUR, \"${nom_bdfi}\" a deux papas !\n";
      exit 0;
   }
   elsif (scalar(@papa) == 1)
   {
      # TBD : transformer en ID
      $parent = $papa[0];
      chop ($parent);
      ($serie, $serie_parent) = split (/\t/, $parent);

      #--- Retrouver le numÇro de la ligne parent => ce sera l'ID
      $parent_id = 0;
      open $fh, $series_file;
      while (<$fh>) {
         if ((/^${serie_parent}$/) || (/^${serie_parent} \[/)) {
            # print "$. : $_";
            $parent_id = $.;
         }
      }
      close $fh;
      #if ($nom_seul eq "World of Warcraft")
      #{
      #	  print "[DBG][" . ${nom_bdfi} . "] Id parent = " . $parent_id . "\n";
      #}

      print $file_cyc ",\n";
      print $file_cyc "\"parent\": \"$parent_id\"";
   }
   else
   {
      print $file_cyc ",\n";
      print $file_cyc "\"parent\": \"\"";
   }

   #-----------------------------------------------------------------------
   #--- Si $nom_seul appartient Ö la premiäre colonne de ALTS
   #--- Pour chaque ligne pour laquelle $nom_seul appartient Ö la premiäre colonne de ALTS
   #-----------------------------------------------------------------------
   $noms_alt = "";
   @noms = grep(/	${nom_bdfi}$/, @alt);
   if (scalar(@noms) != 0)
   {
      foreach $ligne (@noms)
      {
         $lig=$ligne;
         chop ($lig);
         ($serie_alt, $serie) = split (/\t/, $lig);
	 $noms_alt .= $noms_alt ? "; $serie_alt" : "$serie_alt";
      }
      $noms_alt=~s/\"/\\"/g;
      print $file_cyc ",\n";
      print $file_cyc "\"alt_names\": \"" . oem2utf($noms_alt) . "\"";
   }
   else
   {
      print $file_cyc ",\n";
      print $file_cyc "\"alt_names\": \"\"";
   }

   #-----------------------------------------------------------------------
   #--- Si $nom_seul appartient Ö la premiäre colonne de VOS
   #--- Pour chaque ligne pour laquelle $nom_seul appartient Ö la premiäre colonne de VOS
   #-----------------------------------------------------------------------
   $noms_vo = "";
   @noms = grep(/^${nom_bdfi}	/, @vo);
   if (scalar(@noms) != 0)
   {
      foreach $ligne (@noms)
      {
         $lig=$ligne;
         chop ($lig);
         ($serie, $serie_vo) = split (/\t/, $lig);
	 $noms_vo .= $noms_vo ? "; $serie_vo" : "$serie_vo";
      }
      $noms_vo=~s/\"/\\"/g;
      print $file_cyc ",\n";
      print $file_cyc "\"vo_names\": \"" . oem2utf($noms_vo) . "\"";
   }
   else
   {
      print $file_cyc ",\n";
      print $file_cyc "\"vo_names\": \"\"";
   }

   print $file_cyc "\n";

   print $file_cyc "}";
    
   next;
}
print $file_cyc "\n]\n";

close (IDC);
close (PAR);
close (f_ser);
exit;

sub oem2utf
{
   $chaine= $_[0];
   use Encode qw(decode);
   use Encode qw(encode);

   my $win = decode('cp437',$chaine);
   my $utf8 = encode('utf8',$win);

  return $utf8;
}


