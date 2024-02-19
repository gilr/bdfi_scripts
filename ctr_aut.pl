#===========================================================================
# Script 
#---------------------------------------------------------------------------
# Historique :
#---------------------------------------------------------------------------
# Utilisation :
#---------------------------------------------------------------------------
#
# Export fichier auteur excel : exporter en Texte (DOS) (*.txt)
#
# A FAIRE
#
#
#===========================================================================

#---------------------------------------------------------------------------
# Variables de definition du fichier ouvrage
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Variables globales
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Parametres
#---------------------------------------------------------------------------
$i=0;

if ($ARGV[0] eq "")
{
   print STDERR "usage : $0 -p[0|1|2|3|5|9]\n";
   print STDERR "        Contr“les et manques relatif au fichier auteurs.txt )\n";
   print STDERR "        -c  : controle complet\n";
   print STDERR "        -c1 : longueur de la clef inferieure a 28\n";
   print STDERR "        -c2 : existence et coh‚rence des r‚f‚rences\n";
   print STDERR "        -c3 : non simultan‚‹t‚ de la r‚f‚rence et des infos\n";
   print STDERR "        -c4 : existence P lorsque pseudonyme\n";
   print STDERR "        -c5 : controle de vrai nom identique dans le cas des r‚f‚rences\n";
   print STDERR "        -i1 : indique les noms manquants (issus de auteurs.res)\n";
   print STDERR "        -m1 : indique les noms a nationalit‚ inconnue\n";

   exit;
}

while ($ARGV[$i] ne "")
{
   if ($ARGV[$i] eq "-c")
   {
      $oper='CTRL';
   }
   elsif ($ARGV[$i] eq "-c1")
   {
      $oper='CTRL_1';
   }
   elsif ($ARGV[$i] eq "-c2")
   {
      $oper='CTRL_2';
   }
   elsif ($ARGV[$i] eq "-c3")
   {
      $oper='CTRL_3';
   }
   elsif ($ARGV[$i] eq "-c4")
   {
      $oper='CTRL_4';
   }
   elsif ($ARGV[$i] eq "-c5")
   {
      $oper='CTRL_5';
   }
   elsif ($ARGV[$i] eq "-i1")
   {
      $oper='INDI_1';
   }
   elsif ($ARGV[$i] eq "-m1")
   {
      $oper='MANK_1';
   }
   else
   {
      $choix=$ARGV[$i];
   }
   $i++;
}

#---------------------------------------------------------------------------
# Ouverture du fichier auteurs.txt (export MS-DOS txt de excel)
#---------------------------------------------------------------------------
$file="auteurs.txt";
print STDERR "file: $file \n";
open (f_bio, "<$file");
@bio=<f_bio>;
close (f_bio);

# $ibio=0;
# $maxbio=$#bio;

if (($oper eq 'CTRL_1') || ($oper eq 'CTRL'))
{
   print STDOUT "Longueur superieure a 28 caracteres :\n";
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key="$key1 $key2";
      if (length ($key) >= 28)
      {
          print STDOUT "$key\n";
      }
   }
}
if (($oper eq 'CTRL_2') || ($oper eq 'CTRL'))
{
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key="$key1 $key2";
      # gerer les simples ou multiples
      if (($ref ne '') && ($ref ne ' '))
      {
#print STDOUT " $key - $nom - $pseu - $vrai - [$ref]\n";
         $old_key=$key;
         @auteurs=split (/\+/,$ref);
         foreach $auteur (@auteurs)
         {
            $auteur=~s/^ +//;
            $auteur=~s/ +$//;
#print STDOUT "++++ $auteur \n";
            @res=grep (/^$auteur\t/, @bio);
            $nb=$#res+1;
            if ($nb == 0)
            {
#                print STDOUT "$key (1): sa ref [$auteur] n'est pas une clef existante\n";
            }
            elsif ($nb > 1)
            {
#                print STDOUT "$key (1): sa ref [$auteur] se retrouve $nb fois en clef\n";
            }
            else
            {
                ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$res[0]);
                $key="$key1 $key2";
                if (($ref ne '') && ($ref ne ' '))
                {
                   print STDOUT "$old_key (1): sa ref [$key], est une clef dont la ref est renseignee [$ref] (double redirection)\n";
                }
            }
         }
      }
   }
}
if (($oper eq 'CTRL_3') || ($oper eq 'CTRL'))
{
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key="$key1 $key2";
      if (($ref eq '') || ($ref eq ' '))
      {
         if (($pays eq '') || ($pays eq ' ')) {
            print STDOUT "$key (2): manque au moins le pays...\n"
         }
         elsif (($date1 eq '') || ($date1 eq ' ')) {
            print STDOUT "$key (2): manque au moins la dateN...\n"
         }
         elsif (($lieu1 eq '') || ($lieu1 eq ' ')) {
            print STDOUT "$key (2): manque au moins le lieuN...\n"
         }
         elsif (($date2 eq '') || ($date2 eq ' ')) {
            print STDOUT "$key (2): manque au moins la dateDC...\n"
         }
      }
      else
      {
         if (($pays ne '') && ($pays ne ' ') && ($pays ne '?')) {
            print STDOUT "$key (2): sa ref [$ref] existe et le pays au moins est renseign‚...\n"
         }
         elsif (($date1 ne '') && ($date1 ne ' ') && ($date1 ne '../../....')) {
            print STDOUT "$key (2): sa ref [$ref] existe et la dateN au moins est renseign‚e...\n"
         }
         elsif (($lieu1 ne '') && ($lieu1 ne ' ') && ($lieu1 ne '?')) {
            print STDOUT "$key (2): sa ref [$ref] existe et le lieuN au moins est renseign‚...\n"
         }
         elsif (($date2 ne '') && ($date2 ne ' ') && ($date2 ne '../../....')) {
            print STDOUT "$key (2): sa ref [$ref] existe et la dateDC au moins est renseign‚e...\n"
         }
         chop($bio);
         $bio =~ s/^ +//g;
         if (($bio ne '') && ($bio ne ' ')) {
            # verif si reference multiple ou non
            @cf_ref = split (/\+/, $ref);
            $nbref = $#cf_ref + 1;
            if ($nbref == 1) {
               print STDOUT "$key (2): ref unique [$ref] et la bio existe [$bio] !\n"
            }
         }
      }
   }
}
if (($oper eq 'CTRL_4') || ($oper eq 'CTRL'))
{
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key="$key1 $key2";
      if ((($vrai ne '') && ($vrai ne ' ')) && ($pseu ne 'P'))
#     if (($vrai ne '') && ($pseu ne 'P'))
      {
         print STDOUT "$key (3): vrai nom renseign‚ [$vrai] mais pas le flag P [$pseu]...\n"
      }
   }
}
if (($oper eq 'CTRL_5') || ($oper eq 'CTRL'))
{
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key="$key1 $key2";
      if (($pseu ne '') && ($vrai ne '') && ($ref ne ''))
      {
         foreach $lig_2 (@bio)
         {
            ($key2_1,$key2_2,$nom_2,$sexe_2,$pseu_2,$vrai_2,$ref_2,$pays_2,$date1_2,$lieu1_2,$date2_2,$lieu2_2,$tsite_2,$site_2,$bio_2)=split (/\t/,$lig_2);
            $key_2="$key2_1 $key2_2";
            if (($key_2 ne $key) && ($ref_2 eq $ref))
            {
               if ($vrai ne $vrai_2)
               {
                  print STDOUT "$key (5): mm ref que $key_2, vrai noms diff‚rent ([$vrai]/[$vrai_2])\n";
               }
            }
            elsif (($key_2 ne $key) && ($ref eq $key_2))
            {
               if ($vrai ne $nom_2)
               {
                  print STDOUT "$key (5): $ref et $key_2 : vrai noms diff‚rent ([$vrai]/[$nom_2])\n";
               }
            }
         }
      }
   }
}
if ($oper eq 'INDI_1')
{
 $file="auteurs.res";
 open (f_aut, "<$file");
 @aut=<f_aut>;
 close (f_aut);

 my $k_bio=0;
 my @debut=split(/	/, $bio[$k_bio]);
 my $nombio= $debut[0] . " " . $debut[1];
 $nombio=~s/ +$//;
 my $first=substr($bio[$k_bio],0,1);
 my $maxbio=$#bio+1;

 print STDERR "Resultat dans auteurs.dif...\n";
 $file="auteurs.dif";
 open (SFS, ">$file");

 foreach $nom (@aut)
 {
    next if ($nom=~/^\*/);
    next if ($nom=~/^\?/);
    next if ($nom=~/^---/);
    chomp ($nom);
    while (($k_bio != $maxbio) && (($first eq "-") || (lc($nombio) lt lc($nom))))
    {
       # Si le nom de txt est inferieur a res,
       #  prendre le suivant de txt jusqu'a egal ou superieur
       $k_bio++;
       @debut=split(/	/, $bio[$k_bio]);
       $nombio= $debut[0] . " " . $debut[1];
       $nombio=~s/ +$//;
       @first=substr($bio[$k_bio],0,1);
    }
    if ($nom eq $nombio)
    {
       # Identique - on ne fait rien
    }
    else
    {
       # Absent de txt => sortie au format txt
       ($n, $p)=split (/ /, $nom, 2);
       print STDOUT "($debut[0]) [$nom] [$n] [$p] --> ";
       $n=~s/(\w+)/\u\L$&/g;
       print STDOUT "[$p] [$n]\n";
       if ($p eq "") {
          print SFS "$nom	$n	?				?	../../....	?	../../....		\n";
       } else {
          print SFS "$nom	$p $n	?				?	../../....	?	../../....		\n";
       }
    }
 }
 close (SFS);
}
if ($oper eq 'MANK_1')
{
   print STDOUT "Auteur a nationalit‚ inconnue :\n";
   foreach $lig (@bio)
   {
      ($key1,$key2,$nom,$sexe,$pseu,$vrai,$ref,$pays,$date1,$lieu1,$date2,$lieu2,$tsite,$site,$bio)=split (/\t/,$lig);
      $key="$key1 $key2";
      if (($pays eq "?") || ($pays=""))
      {
          print STDOUT "$key";
          for ($i=length($key);$i<28;$i++) { print STDOUT (" "); }
          print STDOUT "\t[$sexe]\t[$pays]\t[$date1]\t[$lieu1]\n";
      }
   }
}

exit;

