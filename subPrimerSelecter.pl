#!/usr/bin/perl

use warnings;
use strict;
use English;
use File::Temp qw/ tempdir /;
use Getopt::Long 'HelpMessage';
use File::Basename;
use Cwd;
use POSIX;

# script to search primers from the list and produce a new subset for subsequent testing.
# Wyler M. 13.10.2023

my $TEMPfolder = $ARGV[0];
my $VIRUS = $ARGV[1];
# my $VIRUS = "WNV";
# my $TEMPfolder = "/home/mwyler/tempDevPrimer";

# getwd
my $dir = getcwd . "/";


# get position of primer file
my $MACHOPATH = dirname $0;
my $PRIMERPATH = $MACHOPATH . "/RefFiles/primerIVI.txt";
my $PRIMERout = $TEMPfolder . "/primerToTest.txt";

# read and filter for marker of interest
my @PRIMERS;

open(IN, $PRIMERPATH) or die "can't open $PRIMERPATH";
while(<IN>){
	chomp;
	if ($_ =~ m/^${VIRUS}.*/){
		push(@PRIMERS, $_);
	} 
}
close (IN);

# test if primers are found
my $PRIMERcount = scalar @PRIMERS;

if ($PRIMERcount > 0) {
	open(FH, '>', $PRIMERout) or die $!;
	foreach (@PRIMERS){
		print FH "$_\n";
	}
	close(FH);
	print "APPOSTO"
	
} else {
	print "Virus $VIRUS not present in primer list. Check $PRIMERPATH\n";
}
