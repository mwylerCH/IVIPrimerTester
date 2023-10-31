#!/usr/bin/perl

use warnings;
use strict;
use English;
use File::Temp qw/ tempdir /;
use Getopt::Long 'HelpMessage';
use File::Basename;
use Cwd;
use POSIX;


# Script to parse output from EMBOSS primersearch
# Wyler M. 16.10.2023


my $PRMSEARCH = $ARGV[0];

# getwd
#my $dir = getcwd . "/";


## Read Description of sequences first
my $FASTA = $PRMSEARCH;
$FASTA =~ s/primerSearch.out/fastaFromNCBI.fa/;

my %FASTAdescriptions;
open(IN, $FASTA) or die "can't open $FASTA";
while (my $line = <IN>){
	chomp $line;
	$line =~ s/^\s*$//;
	if ($line =~ m/^>(.*)$/){
		# get only id
		my $ID = $line;
		$ID =~ s/(>\S*)\s.*/$1/; 
		$ID =~ s/>//;
		# get only description
		my $description = $line;
		$description =~ s/>\S*(\s.*)/$1/; 
		# add to hash
		$FASTAdescriptions{"$ID"} = $description;
	}
}
close (IN);

### Read primersearch File -------------------------------

# keep array as control to see if multiple marker hit the same sequence
my @CONTROLERsequence;
my @OUTput;
my @ResultRow;
my %seen;

my $TARGETseq ;
my $FORWARDmismatch ;
my $REVERSEmismatch ;
my $AMPLIMERlength ;

open(IN, $PRMSEARCH) or die "can't open $PRMSEARCH";
while(<IN>){
	chomp;
	# handle raw output
	if ($_ =~ m/Sequence:/){
		$TARGETseq = $_ ;
		$TARGETseq =~ s/\sSequence: //;
	# for and rev mismatch
	} elsif ($_ =~ m/hits forward strand/) {
		$FORWARDmismatch = $_;
		$FORWARDmismatch =~ s/.*\s(\d+)\smismatches/$1/;
	} elsif ($_ =~ m/hits reverse strand/) {
                $REVERSEmismatch = $_;
                $REVERSEmismatch =~ s/.*\s(\d+)\smismatches/$1/;
	} elsif ($_ =~ m/Amplimer length/) {
                $AMPLIMERlength = $_;
                $AMPLIMERlength =~ s/\sAmplimer length:\s//;
		$AMPLIMERlength =~ s/\sbp//;

		# Print out once reached last row of block (only if problematic)
		if ($FORWARDmismatch > 2 || $REVERSEmismatch > 2){
			$TARGETseq =~ s/\s+//;
			# make an array to see if it's problematic
			push(@CONTROLERsequence, $TARGETseq);
			# get description from fasta
			my $DESC = $FASTAdescriptions{"$TARGETseq"};
			# print out
			print "$TARGETseq\tForward=$FORWARDmismatch\tReverse=$REVERSEmismatch\tAmplemerLen=$AMPLIMERlength\t$DESC\n"; 
		}
	}
}
close (IN);


# print warning if multiple hits
foreach my $string (@CONTROLERsequence) {
	next unless $seen{$string}++;
	print "'$string' has multiple amplifications.\n";

}
