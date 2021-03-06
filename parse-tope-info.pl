#! /usr/bin/perl -w

open F, "<$ARGV[0]" or die;
my $protons = $ARGV[1];
my $mass = $ARGV[2];
my $density = $ARGV[3];
die unless defined $protons;

my $in_table = 0;
while (<F>)
{
  if (/<th>\s*Isotope\s*<th>\s*conc\s*<th>\s*Coh b\s*<th>/) {
    $in_table = 1;
    last;
  }
}

open T, "<isotope-masses" or die "could not open isotope-masses";
my %isotope_masses = ();
while (<T>) {
  /^([A-Z][a-z]*\d+) ([\d\.]+)/ or die;
  $isotope_masses{$1} = $2;
}
close T;

  
while (<F>)
{
    last if (/<\/table>/);

    s/\<i\>i\<\/i\>//g;

    # tope    conc    cohb    incb    cohxs    incxs    scattxs    absxs
    if (/^<td>\s*(\d*)([A-Z][a-z]*)\s*<td>\s*([^<]*?)\s*<td>\s*([^<\s]+)\s*<td>\s*([^<\s]+)\s*<td>\s*([^<\s]+)\s*<td>\s*([^<\s]+)\s*<td>\s*([^<\s]+)\s*<td>\s*(\<?[^<\s]+)\s*<tr>/) {
      my $nucleons = $1;
      my $element = $2;
      my $isotope = "$2$1";
      my $conc = clean_num($3);
      my $cohb = clean_num($4);
      my $incb = clean_num($5);
      my $cohxs = clean_num($6);
      my $incxs = clean_num($7);
      my $scattxs = clean_num($8);
      my $absxs = clean_num($9);

      print "     '$isotope': {Z: $protons, ";
      if ($nucleons eq '') {
	print "mass: $mass, ";
	print "density: $density, " unless $density eq '';
      } else {
        $neutrons = $nucleons - $protons;
        $mass = $nucleons; 
        print "A: $nucleons, N: $neutrons, conc: '$conc', ";
        my $im = $isotope_masses{$isotope};
	print "mass: $im, " if defined $im;
      }
      print "'cohb': '$cohb', incb: '$incb', cohxs: '$cohxs', incxs: '$incxs', scaxs: '$scattxs', abs: '$absxs' },\n"
    } else {
        warn "error parsing line $_";
    }
}

sub clean_num {
    my $arg = shift;
    if ($arg eq "---") {
        return "null";
    } else {
        return $arg;
    }
}

#print "      },\n" if $in_table;
