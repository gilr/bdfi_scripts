
$fichier = $ARGV[0];
$id_prix = $ARGV[1];

$award_file="E:/laragon/www/bdfi/imagine/data/pages/base/prix/" . $fichier . ".txt";

open (f_prix, "<$award_file");
@prix=<f_prix>;
close (f_prix);


# Ouverture des canaux JSON de sortie
$award="E:/laragon/www/bdfi-v2-beta2/storage/app/awards.json";
$categ="E:/laragon/www/bdfi-v2-beta2/storage/app/categories.json";
$recom="E:/laragon/www/bdfi-v2-beta2/storage/app/winners.json";
$icateg="icateg.txt";

if ($fichier eq "apollo") {
   open (AWARDS, ">$award");
   open (CATEGS, ">$categ");
   open (WINNERS, ">$recom");
   $indice_categ=0;
}
else {
   open (AWARDS, ">>$award");
   open (CATEGS, ">>$categ");
   open (WINNERS, ">>$recom");
   open (FICAT, "<$icateg");
   $indice_categ=<FICAT>;
}

$file_aw=AWARDS;
if (!(-s $award)) # fichier n'existe pas ou de taille nulle
{
   print $file_aw "[\n";
}

$file_cat=CATEGS;
if (!(-s $categ)) # fichier n'existe pas ou de taille nulle
{
   print $file_cat "[\n";
}

$file_win=WINNERS;
if (!(-s $recom)) # fichier n'existe pas ou de taille nulle
{
   print $file_win "[\n";
}

$nblig = 0;
$nb_zone = 0;
$is_titre = 0;
$titre_ok = 0;
$debutblocdata = 0;
$blocdata = "";
$catencours = 0;
$catorder = 0;
$is_code = 0;
$is_file = 0;

$name = "";
$alt_names ="";
$given_for = "";
$given_by = "";
$description = "";
$url = "";
$year_end = "";

foreach $ligne (@prix)
{
   $lig=$ligne;
   chop ($lig);

   $nblig++;

   # virer les lignes vides et les commentaires
   if (length ($lig) == 0) {
      if ($debutblocdata == 1) {
         $debutblocdata = 0;
         # Fin du bloc de description ([texte] ou [description])
         $description = $blocdata . " " . $description . " ";
      }
      next;
   }
   if (substr ($lig, 0, 1) eq "#") {
      next;
   }
   if ($debutblocdata == 1)
   {
      $blocdata = $blocdata . " " . $lig;
      next;
   }
   if (substr($lig, 0, 5) eq "<code") {
      $is_code = 1;
      next;
   }
   elsif (substr($lig, 0, 5) eq "</cod") {
      $is_code = 0;
      next;
   }
   elsif (substr($lig, 0, 5) eq "<file") {
      $is_file = 1;
      next;
   }
   elsif (substr($lig, 0, 5) eq "</fil") {
      $is_file = 0;
      next;
   }
   elsif ($is_code == 1) {
      next;
   }

   $is_titre = 0;
   $prem=substr ($lig, 0, 3);
   if ($prem eq "===") {
      $nb_zone++;
      $is_titre = 1;
   }

   if ($nb_zone == 1) {
      if ($is_titre == 1) {
         # Le (ou les) titre(s) du prix
         $name = $lig;
         $name=~s/=//g;
         $name=~s/^ +//g;
         $name=~s/ +$//g;
         $name=~s/^Le //g;
         $name = ucfirst($name);
         print $file_aw "{\n";
         print $file_aw "\"name\": \"$name\",\n";
         $titre_ok = 1;
         next;
      }
      else {
         # Aucune autre info utile
         #print "ligne inutile zone 1\n";
         next;
      }
   }

   if ($nb_zone == 2) {
      # Zone des infos du prix : "En Bref"
      if ($is_titre == 1) {
         $name = $lig;
         $name=~s/=//g;
         $name=~s/^ +//g;
         $name=~s/ +$//g;
         $name = lc($name);
         if ($name ne "en bref") {
            print "pb !!! : $name\n";
            exit;
         }
         next;
      }
      else {
         #print "debut zone 2 - info\n";
         # Les infos à récupérer : awards.json
         #print "On arrive dans les infos prix\n";
         $bloc="";
         $data="";

         $lig=~s/ +$//;
         $lig=~s/\\//g;
         $lig=~s/\.$//;
         ($bloc, $data)=split (/]/, $lig);
         $bloc=~s/\[//;
         $bloc = lc($bloc);
         $data=~s/^ +//g;

         if ($bloc eq "nom") {
            if ($alt_names eq "") {
               $alt_names = $data;
            }
            else {
               $alt_names .= ", " . $data;
            }
            next;
         }
         elsif ($bloc eq "creation") {
            print $file_aw "\"year_start\": \"$data\",\n";
            print $file_aw "\"year_end\": \"\",\n";
            next;
         }
         elsif ($bloc eq "periode") {
            ($start, $end) = split('-', $data);
            print $file_aw "\"year_start\": \"$start\",\n";
            print $file_aw "\"year_end\": \"$end\",\n";
            next;
         }
         elsif ($bloc eq "origine") {
            $pays=getpays($data);
            print $file_aw "\"country_id\": \"$pays\",\n";
            next;
         }
         elsif ($bloc eq "categories") {
            $given_for .= $data . " ";
            next;
         }
         elsif ($bloc eq "genres") {
            $given_for .= $data . " ";
            next;
         }
         elsif ($bloc eq "cible") {
            $given_for .= $data . " ";
            next;
         }
         elsif ($bloc eq "votants") {
            $given_by .= $data . " ";
            next;
         }
         elsif ($bloc eq "dates") {
            $description = $description . " " . $data . " ";
            next;
         }
         elsif ($bloc eq "url") {
            $url .= $data . " ";
            next;
         }
         elsif ($bloc eq "texte") {
            $blocdata = $data;
            $debutblocdata = 1;
            next;
         }
         elsif ($bloc eq "description") {
            $blocdata = $data;
            $debutblocdata = 1;
            next;
         }
         else {
            print "pb 'bloc' !!! :[$bloc]\n";
            next;
         }
         next;
      }
   }

   if (($nb_zone == 3) && ($is_titre == 1)) {
      # Fin fichier award
      $alt_names =~ s/  / /g;
      $alt_names =~ s/ $//g;
      print $file_aw "\"alt_names\": \"$alt_names\",\n";

      $url =~ s/  / /g;
      $url =~ s/ $//g;
      print $file_aw "\"url\": \"$url\",\n";

      $given_by =~ s/  / /g;
      $given_by =~ s/ $//g;
      print $file_aw "\"given_by\": \"$given_by\",\n";

      $given_for =~ s/  / /g;
      $given_for =~ s/ $//g;
      print $file_aw "\"given_for\": \"$given_for\",\n";

      $description =~ s/  / /g;
      $description =~ s/ +$//g;
      $description =~ s/ \././g;
      $description =~ s/"/\\"/g;
      $description =~ s/$/\./g;
      $description =~ s/\.\.$/./g;
      print $file_aw "\"description\": \"$description\"\n";

   }
   if ($nb_zone > 2) {
      # On entre dans les différentes catégories
      $catorder++;
      if ($is_titre == 1) {
         if ($catencours == 1) {
            print $file_cat "},\n";
         }
         $catencours = 1;
         $indice_categ++;

         # Création d'une nouvelle catégorie : pousser dans award_categories.json
         $categorie = $lig;
         $categorie=~s/=//g;
         $categorie=~s/"//g;
         $categorie=~s/^ +//g;
         $categorie=~s/ +$//g;
         $categorie=~s/^Les //;
         $categorie=~s/Cat.gorie : //;
         $categorie=~s/Cat..gorie : //;
         $categorie=~s/Cat..gorie //;
         $categorie=~s/Cat.gorie //;
         $categorie=~s/ romans / roman /;
         $categorie=~s/ nouvelles / nouvelle /;
         $categorie=~s/ oeuvres / oeuvre /;
         $categorie=~s/ r‚compens‚es//;
         $categorie=~s/ r‚compens‚s//;
         $categorie=~s/ r‚compens‚e//;
         $categorie=~s/ r‚compens‚//;
         ($name, $type, $genre) = get_type_genre ($categorie);

         $name = ucfirst($name);
         if ($type eq "") { $type = "autre"; }
         if ($genre eq "") { $genre = "autre"; }

         print $file_cat "{\n";
         print $file_cat "\"name\": \"$name\",\n";
         print $file_cat "\"award_id\": \"$id_prix\",\n";
         print $file_cat "\"internal_order\": \"$catorder\",\n";
         print $file_cat "\"type\": \"$type\",\n";
         print $file_cat "\"genre\": \"$genre\",\n";
         print $file_cat "\"subgenre\": \"\",\n";
         print $file_cat "\"description\": \"\"\n";
         next;
      }
      elsif ($is_file == 1) {
         # Les prix eux-même: à récupérer dans award_winners.json

         # Chaque ligne est un prix
         print $file_win "{\n";

         $note = "";
         $lig=~s/"/\\"/g;
         $str = lc($lig);
         if (($pos = index($str,"[+recueil]")) != -1) {
            $lig = substr($lig,0,$pos) . '-' . substr($lig,$pos+10);
            $note = 'Recueil.';
         }
         elsif (($pos = index($str,"[+ recueil]")) != -1) {
            $lig = substr($lig,0,$pos) . '-' . substr($lig,$pos+11);
            $note = 'Recueil.';
         }

         if (($pos = index($lig,"[+Cycle]")) != -1) {
            $lig = substr($lig,0,$pos) . '-' . substr($lig,$pos+8);
            $note = 'Cycle.';
         }
         if (($pos = index($lig,"((")) != -1) {
            $note = $note . substr($lig,$pos+2);
            $note =~ s/\)\)//;
            $lig = substr($lig,0,$pos);
            # printf "DEBUG [$en][$note]\n";
         }

         ($an, $auteurs, $fr, $en, $cinq) = split (";", $lig);
         if ($cinq ne "") {
            ($an, $soustype, $auteurs, $fr, $en, $six) = split (";", $lig);
            if ($six ne "") {
               print "Fichier à corriger (6 ';' : [$lig])\n";
               exit;
            }
         }

	 # TODO : les soustypes ne sont pas g‚r‚s -> mettre dans un champ sp‚cifique winner
         $auteurs =~ s/ et / & /;

         print $file_win "\"year\": \"$an\",\n";
         ($names, $author, $author2, $author3) = get_auteurs($auteurs);
         print $file_win "\"auteurs\": \"$names\",\n";
         print $file_win "\"author\": \"$author\",\n";
         print $file_win "\"author2\": \"$author2\",\n";
         print $file_win "\"author3\": \"$author3\",\n";
         print $file_win "\"award_id\": \"$id_prix\",\n";
         print $file_win "\"award_category_id\": \"$indice_categ\",\n"; # TBD le numéro global de categorie
         print $file_win "\"note\": \"$note\",\n";
         if ($auteurs ne "") {
            print $file_win "\"position\": \"1\",\n";
            print $file_win "\"title\": \"$fr\",\n";
            print $file_win "\"vo_title\": \"$en\",\n";
            print $file_win "\"title_id\": \"\"\n";
         }
         else {
            print $file_win "\"position\": \"99\",\n";
            print $file_win "\"title\": \"$fr\",\n";
            print $file_win "\"vo_title\": \"$en\",\n";
            print $file_win "\"title_id\": \"\"\n";
         }
         print $file_win "},\n";
      }
   }

}

open (f_icat, ">$icateg");
print f_icat "$indice_categ";


if ($fichier eq "zonefranche") {
   print $file_aw "}\n";
   print $file_aw "]\n";
   print $file_cat "}\n";
   print $file_cat "]\n";
   print $file_win "]\n";
}
else{
   print $file_aw "},\n";
   print $file_cat "},\n";
}

exit;



sub getpays ()
{
   $data = lc ($_[0]);
   if ($data eq "france") { return 2; }
   elsif ($data eq "allemagne") { return 6; }
   elsif ($data eq "australie") { return 9; }
   elsif ($data eq "belgique") { return 11; }
   elsif ($data eq "canada") { return 14; }
   elsif ($data eq "espagne") { return 23; }
   elsif ($data eq "italie") { return 36; }
   elsif (($data eq "royaume uni") || ($data eq "angleterre")) { return 4; }
   elsif (($data eq "etats-unis") || ($data eq "u.s.a.") || ($data eq "u.s.a")) { return 3; }
   else
   {
      printf "Error $data \n";
      exit;
   }
}

sub get_auteurs ()
{
   my ($a1, $a2, $a3) = split (/ & /, $_[0]);
#   printf "DEBUG [$a1][$a2][$a3]\n";
   $final = "";
   # transformer chaque nom d'auteur
   if ($a1 ne "") {
      $final = get_truename ($a1);
   }
   if ($a2 ne "") {
      $final = $final . ($a3 ne "" ? ", " : " et ") . get_truename ($a2);
   }
   if ($a3 ne "") {
      #printf "DEBUG [$a1][$a2][$a3]\n";
      $final = $final . " et " . get_truename ($a3);
      # printf "DEBUG [$final]\n";
   }
   return ($final, $a1, $a2, $a3);
}

sub get_truename ()
{
   ($n1, $reste) = split (' ', $_[0], 2);
   
   if ($reste eq "") {
      return ucfirst(lc($n1));
   }

   $n1 = ucfirst(lc($n1));
   if ($n1 eq "De") {
      $n1 = "de";
   }
   elsif (lc(substr($n1, 0, 2)) eq "mc") {
      $n1 = "Mc" . ucfirst(lc(substr($n1,2)));
   }
   elsif (lc(substr($n1, 0, 2)) eq "o'") {
      $n1 = "O'" . ucfirst(lc(substr($n1,2)));
   }

   $l2 = substr($reste, 1, 1); 
   if (($l2 ge "A") && ($l2 le "Z")) {
      #printf "DEBUG [$reste][$n1]\n";
      ($n2, $reste) = split (' ', $reste, 2);
      $n2 = ucfirst(lc($n2));
      $n1 = "$n1 $n2";

      $l3 = substr($reste, 1, 1); 
      if (($l3 ge "A") && ($l3 le "Z")) {
         ($n3, $reste) = split (' ', $reste, 2);
         # printf "DEBUG [$reste][$n1][$n3]\n";
         $n3 = ucfirst(lc($n3));
         $n1 = "$n1 $n3";
         # printf "DEBUG => [$reste][$n1]\n";
      }
   }

   if (($pos = index($n1, '-')) != -1)
   {
      # printf "DEBUG [$n1] ([$reste])\n";
      $n1 = substr($n1,0,$pos) . '-' . ucfirst(substr($n1,$pos+1));
      # printf "DEBUG => [$n1]([$reste])\n";
   }


   $result = join (' ', $reste, $n1);

   return $result;
}

sub get_type_genre
{
   $categ = lc($_[0]);

   if    ($categ eq "auteur (sf")              { return ("Jeune auteur de SF", "auteur", "sf"); }
   elsif ($categ eq "auteur (imaginaire")      { return ("Meilleur auteur de l'ann‚e", "auteur", "imaginaire"); }
   elsif ($categ eq "roman de sf")             { return ("Roman de SF", "roman", "sf"); }
   elsif ($categ eq "roman d'horreur")         { return ("Roman d'horreur", "roman", "horreur"); }
   elsif ($categ eq "roman de fantasy")        { return ("Roman de fantasy", "roman", "fantasy"); }
   elsif ($categ eq "roman ‚tranger de sf")    { return ("Roman ‚tranger de SF", "roman", "sf"); }
   elsif ($categ eq "roman (sf)")              { return ("Roman", "roman", "sf"); }
   elsif ($categ eq "roman (fantasy)")         { return ("Roman", "roman", "fantasy"); }
   elsif ($categ eq "roman (horreur)")         { return ("Roman", "roman", "horreur"); }
   elsif ($categ eq "recueil (horreur)")       { return ("Recueil", "recueil", "horreur"); }
   elsif ($categ eq "recueil (fantasy)")       { return ("Recueil", "recueil", "fantasy"); }
   elsif ($categ eq "anthologie (horreur)")    { return ("Anthologie", "anthologie", "horreur"); }
   elsif ($categ eq "anthologie (fantasy)")    { return ("Anthologie", "anthologie", "fantasy"); }
   elsif ($categ eq "premier roman (horreur)") { return ("Premier roman", "roman", "horreur"); }
   elsif ($categ eq "roman (fantasy)")         { return ("Roman", "roman", "fantasy"); }
   elsif ($categ eq "roman (imaginaire)")      { return ("Roman", "roman", "imaginaire"); }
   elsif ($categ eq "roman jeunesse (imaginaire)")      { return ("Roman jeunesse", "roman", "imaginaire"); }
   elsif ($categ eq "roman, recueil (imaginaire)")      { return ("Roman, recueil", "texte", "imaginaire"); }
   elsif ($categ eq "roman jeunesse - young adult (horreur)")      { return ("Roman jeunesse - Young Adult", "roman", "horreur"); }
   elsif ($categ eq "roman ‚tranger (sf)")     { return ("Roman ‚tranger", "roman", "sf"); }
   elsif ($categ eq "roman traduit (sf)")      { return ("Roman traduit", "roman", "sf"); }
   elsif ($categ eq "roman francophone (sf)")  { return ("Roman francophone", "roman", "sf"); }
   elsif ($categ eq "novella de sf")           { return ("Novella de SF", "novella", "sf"); }
   elsif ($categ eq "novella de fantasy")      { return ("Novella de fantasy", "novella", "fantasy"); }
   elsif ($categ eq "novella d'horreur")       { return ("Novella d'horreur", "novella", "horreur"); }
   elsif ($categ eq "novella (sf)")            { return ("Novella", "novella", "sf"); }
   elsif ($categ eq "novella (fantasy)")       { return ("Novella", "novella", "fantasy"); }
   elsif ($categ eq "novella (horreur)")       { return ("Novella", "novella", "horreur"); }
   elsif ($categ eq "court roman de sf")       { return ("Court roman de SF", "novella", "sf"); }
   elsif ($categ eq "court roman de fantasy")  { return ("Court roman de fantasy", "novella", "fantasy"); }
   elsif ($categ eq "court roman d'horreur")   { return ("Court roman d'horreur", "novella", "horreur"); }
   elsif ($categ eq "court roman (sf)")        { return ("Court roman", "novella", "sf"); }
   elsif ($categ eq "court roman (fantasy)")   { return ("Court roman", "novella", "fantasy"); }
   elsif ($categ eq "court roman (horreur)")   { return ("Court roman", "novella", "horreur"); }
   elsif ($categ eq "nouvelle de sf")          { return ("Nouvelle de SF", "nouvelle", "sf"); }
   elsif ($categ eq "nouvelle de fantasy")     { return ("Nouvelle de fantasy", "nouvelle", "fantasy"); }
   elsif ($categ eq "nouvelle d'horreur")      { return ("Nouvelle d'horreur", "nouvelle", "horreur"); }
   elsif ($categ eq "nouvelle (sf)")           { return ("Nouvelle", "nouvelle", "sf"); }
   elsif ($categ eq "nouvelle (fantasy)")      { return ("Nouvelle", "nouvelle", "fantasy"); }
   elsif ($categ eq "nouvelle (horreur)")      { return ("Nouvelle", "nouvelle", "horreur"); }
   elsif ($categ eq "nouvelle (imaginaire)")   { return ("Nouvelle", "nouvelle", "imaginaire"); }
   elsif ($categ eq "nouvelle ‚trangŠre (sf)") { return ("Nouvelle ‚trangŠre", "nouvelle", "sf"); }

   elsif ($categ eq "oeuvres (sf)")            { return ("Oeuvre", "texte", "sf"); }
   elsif ($categ eq "oeuvres (fantastique)")   { return ("Oeuvre", "texte", "fantastique"); }

   elsif ($categ eq "citation sp‚ciale (sf)")   { return ("Citation sp‚ciale", "special", "sf"); }
   elsif ($categ eq "richard ewans award")      { return ("Richard Ewans Award", "auteur", "sf"); }
   elsif ($categ eq "grand master award")      { return ("Grand Master Award", "auteur", "sf"); }
   elsif ($categ eq "author emeritus award")      { return ("Author Emeritus Award", "auteur", "sf"); }

   else
   {
      printf "non extrait [$categ]";
      exit;
   }
}
