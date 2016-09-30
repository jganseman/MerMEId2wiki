xquery version "1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace exist="http://exist.sourceforge.net/NS/exist";

(: 
Conversion routine from MerMEId catalogs to WikiMedia
To be used with eXist 1.4.3 (supporting MerMEId at time of writing)
author: Joachim Ganseman
date: 10 november 2015
version: 0.1
TODO: only incorporates the most basic fields now, needs to be extended
:)

for $item in doc('/db/dcm/__contents__.xml')//exist:resource
let $currentfile := doc(string($item/@filename))

let $maintitle := string($currentfile//mei:meiHead/mei:fileDesc/mei:titleStmt/mei:title) (: Titel vh werk :)
let $maintitlestring := if ($maintitle) then $maintitle else "(Geen titel)"

let $opus := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:identifier[@label="Opus"] (: Opusnr :)
let $opusstring := if ($opus) then concat("Opus ", $opus) else "(Geen opus)"

let $subtitles := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:titleStmt/mei:title[@type="subordinate"]
let $subtitlestring := string-join( for $item in $subtitles return $item, "
" )

let $roles := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:titleStmt/mei:respStmt/mei:persName
let $rolesstring := string-join( for $item in $roles return concat( "* ", $item/@role, " : ", $item ), "
")

let $compositiondate := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:history/mei:creation/mei:date
let $compositionplace := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:history/mei:creation/mei:geogName

let $performances := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:history/mei:eventList/mei:event
let $performancesstring := string-join( for $item in $performances return 
concat("* event: ", $item/mei:date, " ", $item/mei:geogName[@role='venue'], " ", $item/mei:geogName[@role='place'], " ",
 string-join($item/mei:corpName[@role='ensemble'], '+') , " ", $item/mei:persName[@role='conductor'], " - ", 
 $item/mei:p ), "
")

let $musicmain := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:expressionList/mei:expression
let $musicmainextent := string-join ($musicmain/mei:extent, "+")
let $musicmaincast := string-join( $musicmain/mei:perfMedium/mei:castList, ", ")
let $musicmaininstr := string-join( for $instrument in $musicmain/mei:perfMedium/mei:instrumentation//mei:instrVoice return
	concat( $instrument/@count, " ", $instrument), ", ")

let $musicparts := $currentfile//mei:meiHead/mei:workDesc/mei:work/mei:expressionList/mei:expression//mei:expression
let $musicpartsdesc := string-join( 
	for $currentpart in $musicparts
	let $currenttempo := $currentpart/mei:tempo
	let $currentmeter := if($currentpart/mei:meter/@count) then concat($currentpart/mei:meter/@count, "/", $currentpart/mei:meter/@unit) else ''
	let $currentkey := $currentpart/mei:key/text()
	let $currentincip := $currentpart/mei:incip/mei:incipText/text()
	let $currentcast := string-join( $currentpart/mei:perfMedium/mei:castList, ', ')
	let $currentinstr := string-join( for $curinstr in $currentpart/mei:perfMedium/mei:instrumentation//mei:instrVoice return concat( $curinstr/@count, " ", $curinstr), ', ')
	(: where($currentpart/@n) :)
return
	concat( "* ", $currentpart/@n , if($currentpart/@n) then ". " else "", string-join( if ($currentpart//mei:title/text()) then $currentpart//mei:title/text() else '' , ' - '), "
", 
if($currenttempo/text()) then concat('** Tempo: ', $currenttempo, '
') else '', if($currentmeter) then concat('** Maatsoort: ', $currentmeter, '
') else '', if($currentkey) then concat('** Toonaard: ', $currentkey, '
') else '', if($currentincip) then concat('** Incipit: ', $currentincip, '
') else '', if($currentcast) then concat('** Cast: ', $currentcast, '
') else '', if($currentinstr) then concat('** Instrumentatie: ', $currentinstr, '
') else ''
), "
")

let $sources := $currentfile//mei:meiHead/mei:fileDesc/mei:sourceDesc/mei:source/mei:itemList/mei:item
let $sourcesstring := string-join( for $item in $sources return 
	concat( "* ", 
		$item/../../mei:titleStmt/mei:title, ": ", 
		if($item/mei:physDesc/mei:extent) then concat( $item/mei:physDesc/mei:extent, " ", $item/mei:physDesc/mei:extent/@unit, ", ") else "", 
		if($item/mei:physDesc/mei:dimensions) then concat($item/mei:physDesc/mei:dimensions, " ",  $item/mei:physDesc/mei:dimensions/@unit) else "",
		"<br />",  
		$item/mei:physLoc/mei:repository/mei:corpName , 
		if ($item/mei:physLoc/mei:repository/mei:identifier) then concat( " (", $item/mei:physLoc/mei:repository/mei:identifier, ")") else "",
		if ($item/mei:physLoc/mei:repository/mei:corpName) then " : " else "", 
		$item/mei:physLoc/mei:identifier, "<br />",
		if ($item/mei:physDesc/mei:titlePage) then concat( "<br />", $item/mei:physDesc/mei:titlePage ) else ""
		), "
")

let $biblio := $currentfile//mei:bibl
let $bibliostring := string-join( for $item in $biblio where boolean($item/mei:author/text()) return
	concat( "* ", $item/../mei:head, ": ", $item/mei:author, " ", $item/mei:imprint/mei:date, " : ", string-join($item/mei:title, " ") ), "
")

order by $opus

return 
concat("<!-- ", $maintitlestring, " -->
", 
if($subtitlestring) then concat($subtitlestring, '
') else '',
if($opusstring) then concat($opusstring, '
') else '',
"
== Algemeen ==
", 
if($rolesstring) then concat($rolesstring, '
') else '',
if($compositiondate) then concat("* composed : ", $compositiondate, ", ", $compositionplace, "
") else '',
if($performancesstring) then concat($performancesstring, '
') else '',
"
== Muziek ==
", 
if($musicmainextent) then concat('* Duur: ', $musicmainextent, '
') else '',  
if($musicmaincast) then concat('* Cast: ', $musicmaincast, '
') else '', 
if($musicmaininstr) then concat('* Instrumentatie: ', $musicmaininstr, '
') else '', "

=== Onderdelen ===
",
if($musicpartsdesc) then concat($musicpartsdesc, '
') else '',
"
== Bronnen ==
", 
if($sourcesstring) then concat($sourcesstring, '
') else '', 
"
== Bibliografie ==
", 
if($bibliostring) then concat($bibliostring, '
') else '',
"
[[Category:Thematische Catalogus Victor Legley]]

<!-- end of file -->

" )
