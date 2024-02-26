#!/usr/bin/perl

use warnings;
use strict;
use English;
use File::Temp qw/ tempdir /;
use Getopt::Long 'HelpMessage';
use File::Basename;
use Cwd;
use POSIX;
use List::MoreUtils 'uniq';

# script for Primer testing comparison
# Wyler Michele, IVI Mittelhäusern, Switzerland, 19.02.2024

my $FIRST = $ARGV[0];
my $SECOND = $ARGV[1];

#my $FIRST = "risultato_PRRSV_US_TaqMan_ORF7";
#my $SECOND = "risultato_PRRS_ORF6_EU2_P";

my $NAME1 = basename($FIRST);
my $NAME2 = basename($SECOND);

my @FILE1;
my @FILE2;

# read in First file ---------------------------


my @FirstTable;

open(IN, $FIRST ) or die "can't open $FIRST";
while(<IN>){
	chomp;
	# for problem collection
	my $PROBLEM = "$NAME1 :\t$_";
	push(@FILE1, $PROBLEM);
	
	$_ =~ s/No amplification for: //;
	my @ROW = split(/\t/, $_);
	my $ID = $ROW[0];
	$ID =~ s/'//g;
        $ID =~ s/\s.*$//g;
	# check if not already in the list
	if (!grep( /^$ID$/, @FirstTable)){
		push(@FirstTable, $ID);
	}
}
close(IN);


# read in second file ------------------------------


my @SecondTable;

open(IN, $SECOND ) or die "can't open $SECOND";
while(<IN>){
        chomp;
        # for problem collection
        my $PROBLEM = "$NAME2 :\t$_";
        push(@FILE2, $PROBLEM);
    
	$_ =~ s/No amplification for: //;
        my @ROW = split(/\t/, $_);
        my $ID = $ROW[0];
        $ID =~ s/'//g;
        $ID =~ s/\s.*$//g;
        # check if not already in the list
        if (!grep( /^$ID$/, @SecondTable)){
                push(@SecondTable, $ID);
        }
}
close(IN);

# merge files --------------------------------------


# into a single array with all IDs
my @allIDs = uniq(@FirstTable, @SecondTable);


# and all raw rows 
#my @BOTH = uniq(@FILE1, @FILE2); 
my @BOTH = uniq(@FILE2, @FILE1);
# remove last column with primers for non amplified
s/\s+Check Primer:.+$// for @BOTH;
@BOTH = uniq(@BOTH);


# check for non amplification 
my @goodIDs;
my $OUTtext;
foreach (@allIDs){
	chomp;
        my $IDX = $_;
	# get all lines of an ID
        my $hit = join("|", grep(/$IDX/, @BOTH));
	# count no Amplifications
	my @matchesNOamp = $hit =~ /No amplification for/gi;
	if (scalar @matchesNOamp == 2){
		$OUTtext = $hit;		
		$OUTtext =~ s/\).+$/\)/;
		$OUTtext =~ s/^[^:]+:\s+//;
		push(@goodIDs, $OUTtext);
	} elsif (scalar @matchesNOamp == 0){
	#if nothing missing amplification found
		$OUTtext = $hit;
		$OUTtext =~ s/\|/\n/g;
                #$OUTtext =~ s/\).+$/\)/;
                #$OUTtext =~ s/^[^:]+:\s+//;
               push(@goodIDs, $OUTtext);
	} elsif (scalar @matchesNOamp == 1){
	# if no amplification only in one
		$OUTtext = $hit;
		# see if other file as issues
		my @matchesOthers = $hit =~ /Problematic Probe annealing|AmplemerLen|No amplifications|Check primer/gi;
		if (scalar @matchesOthers > 0){
			$OUTtext =~ s/[^|]+No amplification for[^|]+//g;
			$OUTtext =~ s/^\|//g;
			$OUTtext =~ s/\|/\n/g;
			push(@goodIDs, $OUTtext);
		}
	}
}

# screen through original outputs ------------------------




foreach (@allIDs){
# if($_ =~ m/OL516349/){
	my $string = $_;
	#my $hit = join("\n", grep(/$string/, @BOTH));
#	print "$hit\n\n";
#}
}


foreach (@goodIDs){
print "$_\n\n";
}
