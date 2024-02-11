#!/usr/bin/perl

use warnings;
use strict;
use English;

# Sub script to test which sequences are not ampliefied

my $TEMPfolder = $ARGV[0];

# make array with all headers from fasta
my $FASTA = "$TEMPfolder/allFastas.fa";
my @FASTAheader ;

open(IN, $FASTA) or die "can't open $FASTA";
while (my $line = <IN>){
    chomp $line;
    if ($line =~ m/^>(.*)$/){
	$line =~ s/>//;
	$line =~ s/(^\S+) .*/$1/;
	push(@FASTAheader, $line);
    }
}
close (IN);

# pull out headers with amplification
my $PrimerSearchOut = "$TEMPfolder/primerSearch.out";

open(IN, $PrimerSearchOut) or die "can't open $PrimerSearchOut";
while (my $line = <IN>){
	chomp $line;
	if ($line =~ m/Sequence/){
		$line =~ s/\s+Sequence:\s+//;
                $line =~ s/\s+$//;
		# test if still present in array
		if ( grep( /^$line$/, @FASTAheader ) ) {
			# remove from array
			# from https://stackoverflow.com/questions/174292/what-is-the-best-way-to-delete-a-value-from-an-array-in-perl
			my $index = 0;
			$index++ until $FASTAheader[$index] eq $line;
			splice(@FASTAheader, $index, 1);
		}
	} 
}
close (IN);


# if any found print out a file for geographic informations
my $ArrayLen = @FASTAheader;;
if ($ArrayLen > 0){
	open(FH, ">", "$TEMPfolder/noAmplifications.txt");
	foreach(@FASTAheader){
		print FH "$_\n";
	}
	close (FH);
}
