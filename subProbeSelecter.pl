use warnings;
use strict;
use English;
use Cwd;
use POSIX;
use File::Basename;

# script to search probes from the list and produce a new subset for subsequent testing.
# Wyler M. 2.11.2023

my $TEMPfolder = $ARGV[0];
my $VIRUS = $ARGV[1];
# my $VIRUS = "WNV";
# my $TEMPfolder = "/home/mwyler/tempDevPrimer";

# getwd
my $dir = getcwd . "/";


# get position of probe file
my $MACHOPATH = dirname $0;
my $PROBEPATH = $MACHOPATH . "/RefFiles/sondenIVI.txt";
my $PROBEout = $TEMPfolder . "/probeToTest.txt";

# read and filter for marker of interest
my @PROBES;

open(IN, $PROBEPATH) or die "can't open $PROBEPATH";
while(<IN>){
        chomp;
        if ($_ =~ m/^${VIRUS}.*/){
                push(@PROBES, $_);
        }
}
close (IN);

# test if primers are found
my $PROBEcount = scalar @PROBES;

if ($PROBEcount == 1) {
        open(FH, '>', $PROBEout) or die $!;
        foreach (@PROBES){
                print FH "$_\n";
        }
        close(FH);
        print "APPOSTO"

} else {
        print "Virus $VIRUS not present in probe list. Check $PROBEPATH\n";
}



