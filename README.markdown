beanplate - a tool for filtering the Metafilter Infodump.

Infodump
--------

The Metafilter Infodump is "a collection of data culled from the Metafilter database, for explorin' and crunchin' and statistifyin'."  It's [available for download,][1] with [wiki documentation][2] & it's catalyzed [much analysis & pretty graphs.][3]

Usage
-----

Usage: beanplate.pl [OPTION]... [CONDITION] [FILE]...

The condition & input files can be listed or specified as options.

  - -c "CONDITION"  condition for a match
  - -i "FILE"       input file   
  - -f "FORMAT"     what to print in case of a match

  
Huh?

  - -h              help!  (you're reading it.)
  - -v              verbose
  - -d              debug

Examples
--------

Show posts from October 2009: 
  
    ./beanplate.pl "datestamp =~ /2009-10/" postdata_mefi.txt

List users with 3-character usernames: 

    ./beanplate.pl "name =~ /^...$/" usernames.txt

Show comments with the same id # as their post:

    ./beanplate.pl -v "commentid eq postid" commentdata_*

  (this only shows a couple of first comments to first posts in subsites)

Show Metafilter posts without titles (note, there are 21,000):

    ./beanplate.pl -i posttitles_mefi.txt -c "title =~ /^$/" 

(This page was written using the [WMD Editor.][4])


  [1]: http://stuff.metafilter.com/infodump/
  [2]: http://mssv.net/wiki/index.php/Infodump
  [3]: http://mssv.net/wiki/index.php/MetaAnalysis "spawning much analysis"
  [4]: http://wmd-editor.com/

