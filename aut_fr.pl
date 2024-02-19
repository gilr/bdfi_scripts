#===========================================================================
#
# Script de recherche des auteurs d'un pays
#
#===========================================================================
push  (@INC, "c:/util/");
require "bdfi.pm";
require "home.pm";
require "html.pm";

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------

if ($ARGV[0] eq "")
{
   print STDERR "Fournir le pays\n";
   exit;
}
else
{
   $pays=&win2dos($ARGV[0]);
   $pays=~s/ +$//o;
   $pays=~s/^ +//o;
   $pays=~s/_/ /og;
   $cmp_pays=lc($pays);
   $cmp_pays=&noacc($cmp_pays);
   $choix=$cmp_pays;
   $choix=~s/-/_/og;
   $choix=~s/ /_/og;
   print STDERR "PAYS $pays - Fichier $choix\n";
}

#---------------------------------------------------------------------------
# Ouverture du fichier auteurs.txt (export MS-DOS txt de excel)
#---------------------------------------------------------------------------
$file="auteurs.txt";
open (f_bio, "<$file");
@bio=<f_bio>;
close (f_bio);
   
@cf_renvois=();
$cf_renvoi=();
@aut=();

#---------------------------------------------------------------------------
# Recherche des auteurs du pays
#---------------------------------------------------------------------------
foreach $lig (@bio)
{
   ($key1,$key2,$nom,$sexe,$pseu,$vrai,$renvoi,$nation,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
   $key = "$key1 $key2";
   if (($renvoi eq '') || ($renvoi eq ' '))
   {
      # Pas de renvoi, info locale :
      $cmp_nation = &noacc(lc($nation));
      if ($cmp_nation eq $cmp_pays)
      {
         #------------------------------------------------------------
         # le pays est OK, memoriser l'auteur
         #------------------------------------------------------------
         push (@aut, $key);
      }
   }
   else
   {
      $cf_renvoi = $renvoi;
      @cf_renvois = split (/\+/, $renvoi);

      $cfr = $cf_renvois[0];

      $cfr=~s/^ +//;
      $cfr=~s/ +$//;
      #--------------------------------------------------------
      # Recherche de la reference du renvoi
      #--------------------------------------------------------
      foreach $lig (@bio)
      {
         ($keyb1,$keyb2,$nom,$sexe,$pseu,$vrai,$ref,$nation,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
         $keyb = "$keyb1 $keyb2";
         $cmp_nation = &noacc(lc($nation));
         if (($keyb eq $cfr) && ($cmp_nation eq $cmp_pays))
         {
            #------------------------------------------------------------
            # le pays est OK, memoriser l'auteur
            #------------------------------------------------------------
            push (@aut, $key);
         }
      }
   }
}

#---------------------------------------------------------------------------
# Controle du nombre d'auteurs
#---------------------------------------------------------------------------
$nb=$#aut+1;
if ($nb == 0)
{
   print STDERR " Aucun auteur trouve dans du pays $pays\n";
   exit;
}
print STDERR "Nombre de signatures du pays : $nb\n";

#---------------------------------------------------------------------------
# Ajouter les liens de tous les auteurs dont la page existe
#---------------------------------------------------------------------------
$iaut=0;
foreach $auteur (@aut)
{
   #chop ($auteur);

   #
   # inserer eventuellement un rejet de certains noms
   #
   $auteur=~s/ *$//;
   $url=&url_auteur($auteur);
   $url=~s/$/.php/g;
   $initiale=substr ($url, 0, 1);
   $initiale=lc($initiale);

   # print STDERR "[$page/$pages] - [$debut] [$initiale] [$fin]\n";
   # Ici, v‚rifier l'existence.
   $url_bdfi="http://www.bdfi.net/auteurs/${initiale}/${url}";
            
   print STDOUT "$auteur	$url_bdfi\n";
}

exit;

# --- fin ---
