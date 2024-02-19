# ------------------------------------------------------------
#   ../../.. V 1 : avec collection obligatoire et directement rattach‚e … 1 ‚diteur
#   ../../.. V 2 : collection non obligatoire + rattachement … 1 … 3 ‚diteurs
#   20/12/23 V 3 : gestion plus propre des collections / sous-collections
#   20/12/23 V 4 : gestion finalis‚e des collections / sous-collections
#                  - cr‚ation auto de collection si [num‚rique], [GF], [poche], [hardcover]
#                  - tri propre en repoussant les " & " en fin de liste
#   24/12/23 V 5 : pb avec les "GF" (name/coll="A GFlire...")
#   28/12/23 V 6 : Collection & sous-collection, avec lien vers parent
#                  - et stockage de l'id de collection parent
#   03/01/24 V 7 : Gestion des p‚riodicit‚s
# ------------------------------------------------------------
#
# --- Correctifs pour le format de la version 1 :
# [ok] traiter les dates ‚diteur et collection
# [ok] traiter les sp‚cificit‚s dans un ordre quelconque (faire une subroutine !)
# [ok] sauvegarder les sigles + ID collection pour r‚utilisation lors du seed publications
# [ok] ne remplir "coll" que si sous-coll
#
# --- Correctifs pour le format de la version 2 :
# [OK] Pas de cr‚ation collection si n'existe pas
# [OK] Ajout "sigle BDFI" optionnel dans publishers (si pas de collec)
# [OK] le tableau des ID de sigles doit comporter l'id ‚diteur + optionnellement l'id collection
# [OK] voir comment ‚viter les ‚diteurs dupliqu‚s parce que dans plusieurs fichiers (test non pas '‚gal previous ?', mais 'existe d‚j… ?'
# 	=> en cr‚ant un fichier (‚dit / sigle / coll) au lieu de (sigles / edit / coll) et en le triant
#
# --- Correctifs pour le format des versions 3 et 4 :
# [OK] Gestion propre collection (avec affichage des sous-collections, et ordonn‚)
# [OK] gestion finalis‚e des collections / sous-collections - cr‚ation auto de collection si [num‚rique], [GF], [poche], [hardcover]
# [OK] Ajout pays
# [..] 
# [..] TBC pour collector, reli‚, etc.
#
#
# [..] voir si/comment g‚rer les grands caractŠres, collector & reli‚s (hardcover)
# [..] Arriver, si "sous-collection", … attacher … la collection parente
# [..] Traiter les ‚diteurs multiples pour une collection (via le +) 
#       Pb comment diff‚rencier les deux types :
#        - le mˆme ouvrage est une publication des deux ‚diteurs (les 2 sont cr‚dit‚s) --> en fait devrait ˆtre niveau publication
#        - des ouvrages diff‚rents de la mˆme collection appartiennent … plusieurs ‚diteurs
#      Exemples : Alsatia + Hachette, Belin + Gallimard, Retz + F.M. Ricci (peut-ˆtre)
# 

   #
   # Pour tous : voir si pr‚-traitements n‚cessaires
   # Retirer les " (livre-audio)$" -> sp‚cificit‚
   # Retirer les " (num‚rique)$" -> sp‚cificit‚
   # Retirer les " (poche)$" -> sp‚cificit‚
   # Retirer les " (jeunesse)$" -> sp‚cificit‚
   # Retirer les " [auto-‚dition]" -> sp‚cificit‚
   # Retirer les " (GF)$" -> sp‚cificit‚
   # Retirer les " (grands caractŠres)," -> sp‚cificit‚
   # Retirer les " (Hors s‚rie), (premiŠre s‚rie), (seconde s‚rie)" ... -> TBD
   # Retirer les " (Belgique)(Canada)(Suisse)(Qu‚bec ?)$" -> pays
   # ...
   # ...
   # ...
   # A partir de l… ne devrait rester que les (villes), (pays) et (ville, pays)
   # ... et les <in> ... (date)
   #
   # Remplacer tous les "‚diteur, Collection, S‚rie" par "‚diteur - Collection - S‚rie"
   #
   #
   #


# Ouverture des sigles en lecture
$editcolls_file="E:/sf/sigles.res";
open (f_sig, "<$editcolls_file");
@editcolls=<f_sig>;
close (f_sig);

@edicol_tri = sort tri_edicol @editcolls;
sub tri_edicol
{
   $aaa=$a;
   $aaa=~s/ \& / _ /;
   $bbb=$b;
   $bbb=~s/ \& / _ /;
   substr($aaa, 10) cmp substr($bbb, 10);
}

# Ouverture des canaux JSON de sortie en cr‚ation-‚criture
$edit="E:/laragon/www/bdfi-v2/storage/app/editeurs.json";
open (EDIT, ">$edit");
$file_edit=EDIT;

$coll="E:/laragon/www/bdfi-v2/storage/app/collections.json";
open (COLL, ">$coll");
$file_coll=COLL;

# Ouverture du fichier de sortie stockant les ID d'‚diteur et optionnellement de collection
$idsigles="E:/sf/sigles.id";
open (IDC, ">$idsigles");
$file_idsigles=IDC;

print $file_edit "[\n";
print $file_coll "[\n";

#--- index des ‚diteurs et collections - croissants
$id_ed = 0;
$id_col = 0;
$previous = "";

foreach $ligne (@edicol_tri)
{
   #   print "DEBUG aprŠs tri - $ligne";
   # Format g‚n‚ral: _ SIGLEXX Editeur [Sp‚cificit‚] {Localisation} - Collection [Sp‚cificit‚] - Sous-collection [Sp‚cificit‚]
   #   $dates = "";

   # R‚cup‚ration du sigle
   $lig=$ligne;
   chop ($lig);
   $sigle = substr($lig, 2, 7);
   $edicol = substr($lig, 10);

   $date1 = 0;
   $date2 = 0;

   # Spliter ‚diteur, et { collection + sous-collection }
   ($editeur, $collection)=split (/ - /,$edicol,2);

   # Traitement ‚diteur
   #--------------------------------

   # R‚cup‚ration d'‚ventuelles date d‚but / fin
   # TODO puisque s'applique aux collection... Ou ne conserver que si collection eq "" ?
   ($reste, $dates)=split (/þ/,$editeur);
   if (($collection eq "") && ($dates ne ""))
   {
       ($date1, $date2) = split (/-/, $dates);
       $date1=~s/ //g;
       $date2=~s/ //g;
       if (($date1 gt "2023") || ($date1 lt "0"))
       {
          $date1 = 0;
       }
       if (($date2 gt "2023") || ($date2 lt "0"))
       {
          $date2 = 0;
       }
   }

   $editeur = $reste;
   $editeur=~s/^ +//g;
   $editeur=~s/ +$//g;

   # 
   # Recherche du pays - 1=inconnu, 2=France, 11=Belgique, 14=Canada, 59=Suisse
   $pays = 1;
   if (($pos = index($editeur,"(Paris")) != -1) {
      $pays= 2;
   }
   elsif (($pos = index($editeur,"(?)")) != -1) {
      $pays= 1;
   }
   elsif ((($pos = index($editeur,"(Suisse")) != -1) ||
          (($pos = index($editeur,"(GenŠve")) != -1) ||
          (($pos = index($editeur,"(Sierre")) != -1) ||
          (($pos = index($editeur,"(Lausanne")) != -1) ||
          (($pos = index($editeur,"(Neuchƒtel")) != -1) ||
          (($pos = index($editeur,", Suisse)")) != -1) ||
          (($pos = index($editeur,"(La Chaux de Fonds")) != -1)) {
      $pays= 59;
   }
   elsif ((($pos = index($editeur,"(Belgique")) != -1) ||
          (($pos = index($editeur,"(LiŠge")) != -1)  ||
          (($pos = index($editeur,", Belgique)")) != -1)  ||
          (($pos = index($editeur,"(Bruxelles")) != -1)) {
      $pays= 11;
   }
   elsif ((($pos = index($editeur,"(Canada")) != -1) ||
          (($pos = index($editeur,"(Montr‚al")) != -1)  ||
          (($pos = index($editeur,"(Qu‚bec")) != -1)  ||
          (($pos = index($editeur,"(St-Lambert")) != -1)  ||
          (($pos = index($editeur,"(Laval")) != -1)  ||
          (($pos = index($editeur,"(Ottawa")) != -1)  ||
          (($pos = index($editeur,"(Toronto")) != -1)  ||
          (($pos = index($editeur,", Canada)")) != -1)  ||
          (($pos = index($editeur,"(Longueuil")) != -1)) {
      $pays= 14;
   }
   else {
      $pays= 2;
   }

   # Retrait des sp‚cificit‚s qui s'appliquent … l'‚diteur seul
   $specif = "";
   $localisation = "";
   if (($pos = index($editeur," [auto-‚dition]")) != -1)
   {
      $editeur = substr($editeur, 0, $pos);
      $specif = "autoediteur";
   }

   # 
   # Si pas de collection mais que l'‚diteur a certaines sp‚cificit‚s, on cr‚‚e quand mˆme la collection
   # 
   if (($collection eq "") &&
      ((index($editeur," [num‚rique]") != -1) ||
      (index($editeur," [GF]") != -1) ||
      (index($editeur," [poche]") != -1) ||
      (index($editeur," [hardcover]") != -1)))
   {
      $collection = $editeur;
      # la sp‚cificit‚ doit ˆtre ajout‚e … la collection de fa‡on … diff‚rencier avec la "sans-sp‚cificit‚" ou les autres sp‚cificit‚s
      if (($pos = index($editeur," [num‚rique]")) != -1) {
         $collection = substr($editeur, 0, $pos) . " num‚rique" . substr($editeur, $pos);
      }
      if (($pos = index($editeur," [GF]")) != -1) {
         $collection = substr($editeur, 0, $pos) . " GF" . substr($editeur, $pos);
      }
      if (($pos = index($editeur," [poche]")) != -1) {
         $collection = substr($editeur, 0, $pos) . " poche" . substr($editeur, $pos);
      }
      if (($pos = index($editeur," [hardcover]")) != -1) {
         $collection = substr($editeur, 0, $pos) . " hardcover" . substr($editeur, $pos);
      }
      # $collection=~s/ \[/, /g;
      # $collection=~s/\]//g;

      $pos = index($editeur, " [");
      $editeur = substr($editeur, 0, $pos);

      if (($pos = index($collection," (")) != -1)
      {
         # 
         # Retrait des "(xxx)" des collections
         # 
         $collection = substr($collection, 0, $pos);
      }
            print "DEBUG creation collection suppl. [$collection] pour ‚diteur [$editeur]\n";
   }

   if (($pos = index($editeur," (")) != -1)
   {
      $pos2 = index(substr($editeur, $pos),")");
      $localisation = substr($editeur, $pos + 2, $pos2-2);
      $editeur = substr($editeur, 0, $pos);
   }

   if ($editeur ne $previous) {
      # Nouvel ‚diteur
      $id_ed++;
      $previous = $editeur;
      if ($id_ed > 1) {
         print $file_edit ",\n";
      }
      print $file_edit "\{\n";

      $editeur=~s/\"/\\"/g;

      print $file_edit "\"name\": \"" . oem2utf($editeur) . "\",\n";
      print $file_edit "\"type\": \"" . $specif . "\",\n";

#     TODO si on garde un sigle
#     if ($collection eq "")
#     {
         print $file_edit "\"sigle\": \"" . $sigle . "\",\n";
#     }
#     else
#     {
#        print $file_edit "\"sigle\": \"\",\n";
#     }
      print $file_edit "\"localisation\": \"" . oem2utf($localisation) . "\",\n";
      print $file_edit "\"creation\": \"" . $date1 . "\",\n";
      print $file_edit "\"fin\": \"" . $date2 . "\",\n";
      print $file_edit "\"pays\": \"" . $pays . "\"\n";

      print $file_edit "\}";
   }

   # Traitement collection + sous-collection, rattach‚e … $id_ed
   #------------------------------------------------------
   if ($collection ne "")
   {
      $dates = "";
      $date1 = 0;
      $date2 = 0;

      # R‚cup‚ration d'‚ventuelles date d‚but / fin
      ($reste, $dates)=split (/þ/,$collection);
      if ($dates ne "")
      {
          ($date1, $date2) = split (/-/, $dates);
          $date1=~s/ //g;
          $date2=~s/ //g;
          if (($date1 gt "2023") || ($date1 lt "0"))
          {
             $date1 = 0;
          }
          if (($date2 gt "2023") || ($date2 lt "0"))
          {
             $date2 = 0;
          }
      }

      $collection = $reste;
      $collection=~s/^ +//g;
      $collection=~s/ +$//g;

      # Attention … l'ordre des sp‚cificit‚s
      #
      $support = "";
      $type = "";
      $format = "";
      $cible = "";
      $genre = "";
      $periodicite = "";

      ($collection, $support) = extract_support ($collection);
      ($collection, $type) = extract_type ($collection);
      ($collection, $format) = extract_format ($collection);
      ($collection, $cible) = extract_cible ($collection);
      ($collection, $genre) = extract_genre ($collection);
      ($collection, $periodicite) = extract_periodicite ($collection);

      if ($format eq "gf") {
         $collection = $collection . " (grand format)";
      }
      $collection=~s/\"/\\"/g;
      ($coll, $subcoll, $oups)=split (/ - /,$collection);
      if ($oups ne "") {
         print "Erreur 2 sous-collections : $reste\n";
         exit;
      }
      $coll=~s/^ +//g;
      $coll=~s/ +$//g;
      $subcoll=~s/^ +//g;
      $subcoll=~s/ +$//g;


      if (($subcoll eq "") ||
          ($subcoll ne "") && ($coll ne $old_coll)) {
         # Stockage collection de plus haut niveau
         # ...mˆme si elle a des sous-collection (mais alors une seule fois)

         $id_col++;
         if ($id_col > 1) {
            print $file_coll ",\n";
         }
         print $file_coll "\{\n";

	 # TODO : pas forc‚ment format & co pour la coll qui a une sous-coll
         print $file_coll "\"name\": \"" . oem2utf($coll) . "\",\n";
         print $file_coll "\"subcoll\": \"\",\n";
         print $file_coll "\"coll\": \"" . oem2utf($coll) . "\",\n";
         print $file_coll "\"sigle\": \"" . $sigle . "\",\n";
         print $file_coll "\"id_parent\": 0,\n";
         print $file_coll "\"id_ed\": \"" . $id_ed . "\",\n";
         print $file_coll "\"support\": \"" . $support . "\",\n";
         print $file_coll "\"type\": \"" . $type . "\",\n";
         print $file_coll "\"format\": \"" . $format . "\",\n";
         print $file_coll "\"cible\": \"" . $cible . "\",\n";
         print $file_coll "\"genre\": \"" . $genre . "\",\n";
         print $file_coll "\"periodicite\": \"" . $periodicite . "\",\n";
         print $file_coll "\"creation\": \"" . $date1 . "\",\n";
         print $file_coll "\"fin\": \"" . $date2 . "\"\n";
         print $file_coll "\}";

         print $file_idsigles "$sigle	$id_ed	$id_col	0	$editeur - $coll\n";

         # ... et m‚moriser l'id de collection
	 $old_id_col = $id_col;
      }

      if ($subcoll ne "") {
         # Puis stocker la sous-collection si elle existe
         $id_col++;
         if ($id_col > 1) {
            print $file_coll ",\n";
         }
         print $file_coll "\{\n";

         $name = $collection;
         $name=~s/ - /, /;

         print $file_coll "\"name\": \"" . oem2utf($name) . "\",\n";
         print $file_coll "\"subcoll\": \"" . oem2utf($subcoll) . "\",\n";
         print $file_coll "\"coll\": \"" . oem2utf($coll) . "\",\n";
         print $file_coll "\"sigle\": \"" . $sigle . "\",\n";
         print $file_coll "\"id_parent\": \"" . $old_id_col . "\",\n";
         print $file_coll "\"id_ed\": \"" . $id_ed . "\",\n";
         print $file_coll "\"support\": \"" . $support . "\",\n";
         print $file_coll "\"type\": \"" . $type . "\",\n";
         print $file_coll "\"format\": \"" . $format . "\",\n";
         print $file_coll "\"cible\": \"" . $cible . "\",\n";
         print $file_coll "\"genre\": \"" . $genre . "\",\n";
         print $file_coll "\"creation\": \"" . $date1 . "\",\n";
         print $file_coll "\"fin\": \"" . $date2 . "\"\n";
         print $file_coll "\}";

	 # On indique aussi si besoin le num‚ro de collection principale, pour servir pour l'ordonnancement.
         print $file_idsigles "$sigle	$id_ed	$id_col	$old_id_col	$editeur - $coll\n";
      }

      $old_coll = $coll;
   }
   else
   {
      # pas de collection :
      # Il faut quand mˆme stocker l'ID de l'‚diteur
      print $file_idsigles "$sigle	$id_ed	0	0	$editeur\n";
   }
   next;
}
print $file_edit "\n]\n";
print $file_coll "\n]\n";
exit;

sub extract_support
{
   $chaine= $_[0];
   $pattern = " [num‚rique]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "numerique";
      return ($collection, $value);
   }
   $pattern = " [livre-audio]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "audio";
      return ($collection, $value);
   }
   return ($collection, "");
}

sub extract_type
{
   $input= $_[0];
   $chaine= lc($_[0]);
   $pattern = " [journal]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "journal";
      return ($collection, $value);
   }
   $pattern = " [revue]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "revue";
      return ($collection, $value);
   }
   $pattern = " [almanach]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "almanach";
      return ($collection, $value);
   }
   $pattern = " [fanzine]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "fanzine";
      return ($collection, $value);
   }
   $pattern = " [magazine]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "magazine";
      return ($collection, $value);
   }
   return ($collection, "");
}

sub extract_periodicite
{
   $input= $_[0];
   $chaine= lc($_[0]);
   $pattern = " [quotidien]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "quotidien";
      return ($collection, $value);
   }
   $pattern = " [hebdo]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "hebdo";
      return ($collection, $value);
   }
   $pattern = " [bimensuel]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "bimensuel";
      return ($collection, $value);
   }
   $pattern = " [mensuel]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "mensuel";
      return ($collection, $value);
   }
   $pattern = " [bimestriel]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "bimestriel";
      return ($collection, $value);
   }
   $pattern = " [trimestriel]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "trimestriel";
      return ($collection, $value);
   }
   $pattern = " [semestriel]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "semestriel";
      return ($collection, $value);
   }
   $pattern = " [annuel]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "annuel";
      return ($collection, $value);
   }
   $pattern = " [aperiodique]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "aperiodique";
      return ($collection, $value);
   }
   return ($collection, "");
}


sub extract_format
{
   $input= $_[0];
   $chaine= lc($_[0]);
   $pattern = " [gf]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "gf";
      return ($collection, $value);
   }
   $pattern = " [mf]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "mf";
      return ($collection, $value);
   }
   $pattern = " [poche]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($input, $pattern, $pos);
      $value = "poche";
      return ($collection, $value);
   }
   return ($collection, "");
}

sub extract_cible
{
   $chaine= $_[0];
   $pattern = " [jeunesse]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "jeunesse";
      return ($collection, $value);
   }
   $pattern = " [YA]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "YA";
      return ($collection, $value);
   }
   $pattern = " [adulte]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "adulte";
      return ($collection, $value);
   }
   return ($collection, "");
}

sub extract_genre
{
   $chaine= $_[0];
   $pattern = " [sf]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "sf";
      return ($collection, $value);
   }
   $pattern = " [fantasy]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "fantasy";
      return ($collection, $value);
   }
   $pattern = " [fantastique]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "fantastique";
      return ($collection, $value);
   }
   $pattern = " [gore]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "gore";
      return ($collection, $value);
   }
   $pattern = " [policier]";
   if (($pos = index($chaine, $pattern)) != -1)
   {
      $collection = extract_caract($chaine, $pattern, $pos);
      $value = "policier";
      return ($collection, $value);
   }
   return ($collection, "");
}

sub extract_caract
{
   my $chaine= $_[0];
   my $pattern= $_[1];
   my $pos= $_[2];

   $reste = substr($chaine, 0, $pos) . substr($chaine, $pos + length($pattern));
   return $reste;
}


sub oem2utf
{
   $chaine= $_[0];
   use Encode qw(decode);
   use Encode qw(encode);

   my $win = decode('cp437',$chaine);
   my $utf8 = encode('utf8',$win);

  return $utf8;
}

