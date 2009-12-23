#!/usr/bin/perl

# various defaults
# $infile = "favoritesdata.txt";
# $criteria = "datestamp =~ /2009-10/";
# $criteria = "faver eq favee";
$criteria = "1";
$format = "\$line";  # by default, output the line as read
$printheader = 1;
# $debug = 1;
# $verbose = 1;


# parse command line arguments
use Getopt::Std;
%options=();
getopts ("c:df:i:v", \%options);
if (defined $options{c}) { $criteria = $options{c} };
if (defined $options{d}) { $debug    = 1};
if (defined $options{i}) { 
  $infile   = $options{i} 
} else {
  # print help, require filename for input...
  die "Need an input file!  And, um, no help is written yet.\n";
}
if (defined $options{f}) { $format   = $options{f}; $printheader = 0};
if (defined $options{v}) { $verbose  = 1};


# parse header - get datestamp
$/ = "\r\n"; # input line terminators - 0d 0a
open infile, $infile;
$line = <infile>;
chomp $line;
if ($line =~ /(.+)/) {
  $filedatestamp = $1;
  if ($verbose) {print "reading file $infile made on: $filedatestamp\n"}
}


# parse header - column headers
$line = <infile>;
chomp $line;
$line =~ s/\?//;   # "best answer?" -> "best answer"
$line =~ tr/\ /_/; # "best answer"  -> "best_answer"
$header = $line;
@fields = split (/\t/, $line);


# rewrite filter criteria & format for speed in eval loop
if ($verbose) {print "criteria: $criteria\n  format: $format\n"}

foreach $item ($criteria, $format) {
  foreach $num (0 .. scalar(@fields) - 1 ) {
    $item =~ s/$fields[$num]/\$read_fields\[$num\]/g;
  }
}


# assemble eval loop
$code = "
while (\$line = <infile>) {
  chomp \$line; 
  # print \$line . \"\\n\";
  \@read_fields = split (/\\t/, \$line);
  if ($criteria) {
    print \"$format\\n\"; \
  }
}
return 1;
";

if ($verbose) { print "code:\t$code\n"; }

if ($printheader) { print "$header\n"; }

# magic happens here.  error catching is ... cryptic.
eval ($code) || die "Error in code: $@\n";
