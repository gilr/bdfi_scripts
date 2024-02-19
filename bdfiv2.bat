REM -----------------------------------------------------------------
REM  Creation des fichiers necessaires aux generations de pages web
REM   o ouvrages
REM   o sigles
REM   o auteurs
REM   o liste de collections
REM -----------------------------------------------------------------

call c:\util\sf.bat
REM call c:\util\base.bat
call c:\util\series_c.bat

# call c:\util\util.bat
REM Ne fonctionne plus parce que fichier provenant de "Imagine" ‚cras‚s -> reprise depuis les fichiers de V2
REM call c:\util\getprix.bat
call c:\util\getcyc.bat
call c:\util\getsig.bat

call c:\util\sf.bat
del titres.id
call c:\util\variants.bat

type supplem.imp > ouvrages.imp

type am_ed.col >> ouvrages.imp
type am_supf.col >> ouvrages.imp
type am_suppf.col >> ouvrages.imp
type clevy_ds.col >> ouvrages.imp
type clevy_fy.col >> ouvrages.imp
type fn_shado.col >> ouvrages.imp
type foliofa.col >> ouvrages.imp
type payotsf.col >> ouvrages.imp
type riv_fant.col >> ouvrages.imp
type fn_t3v2w.col >> ouvrages.imp
type argyll.col >> ouvrages.imp
type jai_mill.col >> ouvrages.imp
type basis.col >> ouvrages.imp
type aliregf.col >> ouvrages.imp
type uhl.col >> ouvrages.imp
type pdfant.col >> ouvrages.imp
type fn_thrfa.col >> ouvrages.imp
type vmag.col >> ouvrages.imp
type masqsf.col >> ouvrages.imp
type masqfa.col >> ouvrages.imp
type galaxbis.col >> ouvrages.imp
type dumarest.col >> ouvrages.imp
type fn_ang.col >> ouvrages.imp

call c:\util\getouv.bat
call c:\util\sf.bat

