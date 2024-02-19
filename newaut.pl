
printf "Creation nouveau fichier auteurs (auteurs.new)     [    ]\r";

$auteurs="auteurs.txt";
open (f_aut, "<$auteurs");
@aut=<f_aut>;
close (f_aut);

$sites="url.res";
open (f_www, "<$sites");
@www=<f_www>;
close (f_www);

@new_auteurs=();

foreach $ligne (@aut)
{
  $lig=$ligne;
  chop ($lig);

  # Decomposition du nom 
  # AARONS Edward	Edward S. Aarons	H				Etats-Unis	../../1916	?	16/06/1975		Auteur de romans policiers ou d'espionnage
  ($clef, $liste_noms, $hf, $pseu, $vrai, $lien, $pays, $dn, $vn, $dd, $vd, $bio) = split (/\t/,$lig);

  # Recherche si URL existe
  $type = "?";
  $site = "?";
  foreach $url (@www)
  {
    $url2 = $url;
    chop ($url2);
    ($a, $t, $s) = split (/\t/,$url2);
    if ($a eq $clef) {
      $type = $t;
      $site = $s;
    }
  } 

  # Decomposition clef en 2 parties
  $nom = "";
  $prenom = "";
  ($premier, @morceaux) = split (/ /, $clef);
  $nom = $premier;
  $prenom_en_cours = 0;
  foreach $morceau (@morceaux)
  {
     $un = substr($morceau, 0, 1);
     $deux = substr($morceau, 1, 1);
     # if (lc($un) eq $un) { print "($un)"; }
     if (($morceau eq "&") || ($deux eq ".")) {
       $prenom = ($prenom eq "" ? $morceau : $prenom . " ". $morceau );
       $prenom_en_cours = 1;
     }
     elsif (($morceau eq "Y") && ($prenom_en_cours == 0)) {
       $nom = ($nom eq "" ? $morceau : $nom . " ". $morceau );
     }
     elsif (uc($morceau) ne $morceau) {
       $prenom = ($prenom eq "" ? $morceau : $prenom . " ". $morceau );
       $prenom_en_cours = 1;
     }
     elsif ($prenom_en_cours == 0) {
       $nom = ($nom eq "" ? $morceau : $nom . " ". $morceau );
     }
     else {
       $prenom = ($prenom eq "" ? $morceau : $prenom . " ". $morceau );
     }
  }
  $new_auteur = "$nom\t$prenom\t$liste_noms\t$hf\t$pseu\t$vrai\t$lien\t$pays\t$dn\t$vn\t$dd\t$vd\t$type\t$site\t$bio";
  # test
  # $new_auteur = "$nom $prenom\t$liste_noms\t$hf\t$pseu\t$vrai\t$lien\t$pays\t$dn\t$vn\t$dd\t$vd\t$bio";

  push (@new_auteurs, $new_auteur);
  
}

#---------------------------------------------------------------------------
# sortie dans le fichier auteurs
#---------------------------------------------------------------------------
$file="auteurs.new";
open (INP, ">$file");

foreach $newaut (@new_auteurs)
{
   print INP "$newaut\n";
}
close (INP);
printf "Creation nouveau fichier auteurs (auteurs.new)     [ OK ]\n";



