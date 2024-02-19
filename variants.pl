
# Ouverture du fichier des variants
$variants_file="E:/sf/variants.res";
open (f_var, "<$variants_file");
@variants=<f_var>;
close (f_var);

# Ouverture de la sortie variants dans storage
$utf="E:/laragon/www/bdfi-v2/storage/app/variants.json";
open (UTF, ">$utf");
$file_utf=UTF;

foreach $ligne (@variants)
{
   $lig=$ligne;
#   chop ($lig);
   if (($pos = index($lig,"#")) == -1) {
      print oem2utf($lig);
      print $file_utf oem2utf($lig);
   }
}
close (UTF);


sub oem2utf
{
   $chaine= $_[0];
   use Encode qw(decode);
   use Encode qw(encode);

   my $win = decode('cp437',$chaine);
   my $utf8 = encode('utf8',$win);

  return $utf8;
}


