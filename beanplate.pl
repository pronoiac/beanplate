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
@infiles = ();

# within code.
$line_count = 0;
$match_count = 0;


# parse command line arguments
use Getopt::Std;
%options=();
getopts ("c:df:hi:v", \%options);
if (defined $options{c}) { $criteria = $options{c} };
if (defined $options{d}) { $debug    = 1};
if (defined $options{h}) {&help};
if (defined $options{i}) { 
  push (@infiles, $options{i});
} 
if (defined $options{f}) { $format   = $options{f}; $printheader = 0};
if (defined $options{v}) { $verbose  = 1};

# leftover arguments?
while ($ARGV[0]) {
  if (-e $ARGV[0]) {
    push (@infiles, $ARGV[0]);
    # print "infile: $ARGV[0]\n";
  } else {
    if (defined $options{c}) { 
      die "Multiple conditions specified: $options{c} and $ARGV[0].\n";
    } 
    $criteria = $ARGV[0];
  }
  shift;
}

# if ($#infiles == 0) {
if (!defined $infiles[0]) {
  print "Need an input file!\n";
  &help;
}


# loop over infiles
foreach (@infiles) {
  $infile = $_;

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
  $code = <<EOF;
  while (\$line = <infile>) {
    chomp \$line; 
    \$line_count++;
    # print \$line . \"\\n\";
    \@read_fields = split (/\\t/, \$line);
    if ($criteria) {
      \$match_count ++;
      print \"$format\\n\"; \
    }
  }
  return 1;
EOF

  if ($debug) { print "code:\t$code\n"; }

  if ($printheader) { print "$header\n"; }
  
  # magic happens here.  error catching is ... cryptic.
  eval ($code) || die "Error in code: $@\n";

  close infile;
} # end loop over @infiles

if ($verbose) { print "lines read: $line_count\nmatches: $match_count\n"; }

sub help {
  die <<'EOF';
beanplate - filter Metafilter Infodump files
  
Usage: beanplate.pl [OPTION]... [CONDITION] [FILE]...

The condition & input files can be listed or specified as options.

  -c "CONDITION"  condition for a match
  -i "FILE"       input file
  -f "FORMAT"     what to print in case of a match
  
Huh?
  -h              help!  (you're reading it.)
  -v              verbose
  -d              debug


Examples: 
  Show posts from October 2009: 
    ./beanplate.pl "datestamp =~ /2009-10/" postdata_mefi.txt

  List users with 3-character usernames: 
    ./beanplate.pl "name =~ /^...$/" usernames.txt 

EOF
}  

