#!/usr/bin/perl

# $infile = "unpack/commentdata_askme.txt";
# $infile = "unpack/commentlength_askme.txt";
$infile = "unpack/favoritesdata.txt";
# $filter = "\$datestamp =~ /2009-10/";
$filter = "\$faver eq \$favee";
# $filter = "1";

$printheader = 1;

$/ = "\r\n"; # input line terminators - 0d 0a
open infile, $infile;
$line = <infile>;
chomp $line;
if ($line =~ /(.+)/) {
  $filedatestamp = $1;
}

$line = <infile>;
chomp $line;
$header = $line;
@fields = split (/\t/, $line);

print scalar(@fields). "\n";

# print @fields;
# $format = "\$" .join ("\" \".\t\" . \$", @fields);
$format = "\$" . join ("\ . \"\\t\" . \$", @fields);

print "format - $format\n";

foreach $item ($filter, $format) {
  print "pre:  $item.\n";
  foreach $num (1 .. scalar(@fields) ) {
    $src = $fields [$num - 1];
    # $dest = "\$$num";
    $dest = $num - 1;
    # print $fields[$num] . " - $num\n";
    #print "midway: $src - $dest - $format.\n";
    # $item =~ s/\$$src/\$$num/;
    $item =~ s/\$$src/\$read_fields \[$dest\]/;
  }
  print "post: $item.\n";
}

#print "proc: $format\n";

$to_eval = "
while (\$line = <infile>) {
  chomp \$line; 
  # print \$line . \"\\n\";
  \@read_fields = split (/\\t/, \$line);
  if ($filter) {
    print $format . \"\\n\"; \
  }
}
";

print "eval: $to_eval";

if ($printheader) {
  print "$header\n";
}

eval ($to_eval) || print $@ . "\n";
