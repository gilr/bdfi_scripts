#===========================================================================
# Module HTML.PM
#===========================================================================
#    Librairie HTML et FTP
#===========================================================================
#
# Librairie de fonction de gestion des pages web, par exemple :
#   - web_begin (canal, chemin commun, title)
#   - web_canal (canal)
#   - web_head_meta (name, content)
#   - web_head_css (media, href)
#   - web_head_js (src)
#   - web_body (chaine js optionnelle)
#   - web_menu (presence_menu, fonction_js, path_fonction)
#   - web_data
#   - web_end
#   - web_alphab (presence_09, presence_X)
#
# Revu le 17/10 pour passage au PHP - Ajout web_alphab
# Revu le 03/08/2010 pour ajout fonction d'upload
#===========================================================================

my $WEB_CANAL="";
my $WEB_MENU=0;
my $WEB_COMMUN="";

#---------------------------------------------------------------------------
# Entete fichier HTML
# Paramètres : canal de sortie + chemin communs + titre
#---------------------------------------------------------------------------
sub web_begin
{
   $WEB_CANAL=$_[0];
   $WEB_COMMUN=$_[1];

   print $WEB_CANAL "<?php include('" . $WEB_COMMUN . "config.inc.php'); ?>\n";
   print $WEB_CANAL "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
   print $WEB_CANAL "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"fr\" xml:lang=\"fr\">\n";
   print $WEB_CANAL "<head>\n";

   print $WEB_CANAL &tohtml("<title>$_[2]</title>\n");
   print $WEB_CANAL '<link rel="icon" type="image/x-icon" href="/favicon32.ico" />';
   print $WEB_CANAL "\n";
   print $WEB_CANAL '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
   print $WEB_CANAL "\n";
}

#---------------------------------------------------------------------------
# Changement de canal
#---------------------------------------------------------------------------
sub web_canal
{
   $WEB_CANAL=$_[0];
}

#---------------------------------------------------------------------------
# Ajout ligne meta dans l'entête
# Paramètres : nom + contenu
#---------------------------------------------------------------------------
sub web_head_meta
{
   print $WEB_CANAL &tohtml("<meta name=\"$_[0]\" content=\"$_[1]\" />\n");
}
#---------------------------------------------------------------------------
# Inclusion fichier CSS dans l'entête
# Paramètres : media + reference fichier
#---------------------------------------------------------------------------
sub web_head_css
{
   print $WEB_CANAL " <link rel=\"stylesheet\" type=\"text/css\" media=\"$_[0]\" href=\"$_[1]\" />\n";
}
#---------------------------------------------------------------------------
# Inclusion fichier js dans l'entête
# Paramètres : reference fichier
#---------------------------------------------------------------------------
sub web_head_js
{
   print $WEB_CANAL " <script type=\"text/javascript\" src=\"$_[0]\"></script>\n";
}
#---------------------------------------------------------------------------
# Ajout fin entête + début body
# Paramètres : chaine js optionnelle
#---------------------------------------------------------------------------
sub web_body
{
   print $WEB_CANAL "</head>";
   if (($_[1] eq undefined) || ($_[0] eq "")) {
      print $WEB_CANAL "<body>";
   }
   else {
#print "Debug js body = [" . $_[1] . "]\n";
      print $WEB_CANAL "<body " . $_[0] . ">";
   }

   print $WEB_CANAL "<div id=\"conteneur\">\n";
   print $WEB_CANAL "<?php include('" . $WEB_COMMUN . "bandeau-v2.inc.php'); ?>\n\n";
}
sub web_body_v2
{
   print $WEB_CANAL "</head>";
   if (($_[1] eq undefined) || ($_[0] eq "")) {
      print $WEB_CANAL "<body>";
   }
   else {
#print "Debug js body = [" . $_[1] . "]\n";
      print $WEB_CANAL "<body " . $_[0] . ">";
   }

   print $WEB_CANAL "<div id=\"conteneur\">\n";
   print $WEB_CANAL "<?php include('" . $WEB_COMMUN . "bandeau-v2.inc.php'); ?>\n\n";
}

#---------------------------------------------------------------------------
# Ajout menu
# Paramètres : presence_menu (0/1) + menu
#---------------------------------------------------------------------------
sub web_menu
{
   $WEB_MENU=$_[0];
   if ($WEB_MENU == 1)
   {
      print $WEB_CANAL "<div id=\"menu\">";
      print $WEB_CANAL "<?php include('../commun/menu_" . $_[1]. ".inc.php') ?>";
      print $WEB_CANAL "</div>\n\n";
      print $WEB_CANAL "<div id=\"page_menu\">\n";
   }
   else
   {
      print $WEB_CANAL "<div id=\"page\">\n";
   }
}

#---------------------------------------------------------------------------
# Ajout liens alphabetiques
# Paramètres : presence_09 (0/1) + presence_X (0/1)
#---------------------------------------------------------------------------
sub web_alphab
{
   print $WEB_CANAL "<div class='index'>";
   print $WEB_CANAL "<?php\n";
   if ($_[0] == 1)
   {
      print $WEB_CANAL " echo \"<a href='09.php'>0-9</a> \";\n";
   }
   if ($_[1] == 1)
   {
      print $WEB_CANAL " for (\$i = 'A'; \$i != 'AA'; \$i++) {\n";
      print $WEB_CANAL "   echo \"<a href='\" . strtolower(\$i) . \".php'>\$i</a> \";\n";
      print $WEB_CANAL " }\n";
   }
   else
   {
      print $WEB_CANAL " for (\$i = 'A'; \$i < 'X'; \$i++) {\n";
      print $WEB_CANAL "   echo \"<a href='\" . strtolower(\$i) . \".php'>\$i</a> \";\n";
      print $WEB_CANAL " }\n";
      print $WEB_CANAL " echo \"<span style='color:gray;'>X</span> \";\n";
      print $WEB_CANAL " echo \"<a href='y.php'>Y</a> \";\n";
      print $WEB_CANAL " echo \"<a href='z.php'>Z</a> \";\n";
   }
   print $WEB_CANAL "?>\n";
   print $WEB_CANAL "</div>";
}

#---------------------------------------------------------------------------
# Ajout ligne quelconque
# Paramètres : ligne
#---------------------------------------------------------------------------
sub web_data
{
   print $WEB_CANAL &tohtml("$_[0]");
}

#---------------------------------------------------------------------------
# Fin page
# Paramètres : non
#---------------------------------------------------------------------------
sub web_end
{
   print $WEB_CANAL "\n</div>\n";
   $dt = localtime;
   print $WEB_CANAL "<?php include('" . $WEB_COMMUN . "pied.inc.php'); ?>\n";
   print $WEB_CANAL "</div>\n";
   print $WEB_CANAL "</body>\n</html>\n";
}

#---------------------------------------------------------------------------
# Upload FTP d'une page
# Parametres : URL relative fichier
#---------------------------------------------------------------------------
push  (@INC, "c:/perl/lib/");
use Net::FTP;

sub bdfi_upload
{
   my $local_file = $_[0];
   my $remote_rep = $_[1];

   $ftp = Net::FTP->new("ftp.cluster010.hosting.ovh.net", Debug => 0)
    or die "Cannot connect to ftp.cluster010.hosting.ovh.net: $@";

   $ftp->login("bdfi",'ga2002es2004')
    or die "Cannot login ", $ftp->message;

   $ftp->cwd($remote_rep)
    or die "Cannot change working directory ", $ftp->message;

   $ftp->put($local_file)
    or die "get failed ", $ftp->message;

   $ftp->quit;

#   sleep(5);

}

#---------------------------------------------------------------------------
# Fin du module HTML
#---------------------------------------------------------------------------
1;

