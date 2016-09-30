# MerMEId2wiki
XQuery routine to output thematic catalogs made in MerMEId to wikimedia formatted text

(c) J. Ganseman , for the [Royal Conservatory of Brussels library](http://www.kcb.be/en/kcb/page/library/intro).

## License
[CC-BY-SA](http://creativecommons.org/licenses/by-sa/3.0/)

## Aim
[MerMEId](http://www.kb.dk/en/nb/dcm/projekter/mermeid.html) is a system to make thematic catalogs for composers ([Available on Github](https://github.com/Det-Kongelige-Bibliotek/MerMEId)). At Koninklijk Conservatorium Brussel it was used by researcher K. Sterckx to make a catalogue for Victor Legley.

For various reasons (lack of root access being one of them) MerMEId could not be installed on the webservers of KCB. It was decided to convert the database to a set of wiki pages, for use in a [MediaWiki](https://www.mediawiki.org/wiki/MediaWiki) environment.

This XQuery file dumps the most main fields of the XML database on which MerMEId runs ([eXist 1.4.3](https://sourceforge.net/projects/exist/files/Stable/1.4.3/)) into a file, formatted according to MediaWiki standards.

The resulting wiki files are just barebone and need subsequent manual editing. The result, for the Victor Legley thematic catalogue, can be seen on [the Royal Conservatory of Brussels library wiki](http://wiki.muziekcollecties.be/index.php?title=Victor_Legley), and was presented at the [IAML 2016](http://www.iaml.info/sites/default/files/pdf/2016-06-23_iaml_rome_programme.pdf) congress in Rome.

## Use
Run this file in the web interface of eXist.

## Known issues and incompletenesses
  * Currently only incorporates the most basic fields, as used in the initial Legley catalogue.
  * Everything is done in 1 big query, any further extension will require refactoring
  
Have fun!
