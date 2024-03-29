#!/usr/bin/perl

use warnings;
use strict;
use English;
use File::Temp qw/ tempdir /;
use Getopt::Long 'HelpMessage';
use File::Basename;
use Cwd;
use POSIX;

# script controls subprocess for primer searching in NCBI.
# Wyler M. 13.10.2023

# my $TEMPfolder = $ARGV[0];
my $VIRUS = $ARGV[0];
# my $VIRUS = "AHSV_TaqMan_NS2";
# my $TEMPfolder = "/home/mwyler/tempDevPrimer";

# $VIRUS = 'ciaone';

my $MACHOPATH = dirname $0;
my $dir = getcwd . "/";
my $TEMPfolder = tempdir( DIR => $dir, CLEANUP => 1 );

# check if a parameter is present
if( $#ARGV == -1 ){
	print "You missed a primer\n";
	exit;
}


## PRIMER Prep ------------------------------------

# run external perl script to make subset of primer list
my $RUNprimer = `perl $MACHOPATH/subPrimerSelecter.pl $TEMPfolder $VIRUS`;

# test if primers where found
if ($RUNprimer ne "APPOSTO"){
	print "$RUNprimer\n";
	exit;
}

# run external perl script to make subset of probe list
my $RUNprobe = `perl $MACHOPATH/subProbeSelecter.pl $TEMPfolder $VIRUS`;

# test if primers where found
if ($RUNprobe ne "APPOSTO"){
        print "$RUNprobe\n";
        exit;
}


## NCBI mining ------------------------------------

# get required script to proceed with mining
my $AAL = $MACHOPATH . "/miners";
my $RMINER;
my @MINERlist;

opendir (DIR, $AAL) or die $!;
while (my $file = readdir(DIR)) {	
	if ($file =~ m/^${VIRUS}.R/){
		push(@MINERlist, $file);
	}
}
closedir(DIR);

# test if only one miner found
my $gugus = scalar @MINERlist;

if (scalar @MINERlist != 1){
	print "ERROR: No miner found for $VIRUS\n";
	exit;
}


# NCBI Mining
system "Rscript $AAL/$MINERlist[0] $TEMPfolder >/dev/null 2>&1";




## Read NCBI fasta and filter ---------------------------------

# filter by length and make single seq fastas into a new folder

system "perl $MACHOPATH/subFastaFilter.pl $TEMPfolder $MACHOPATH/RefFasta/${VIRUS}.fa.gz $MACHOPATH/RefFiles/BlackList.txt";

# print header
my $NUMERO = `ls $TEMPfolder/singleRawFasta/*.fa | wc -l`;
$NUMERO =~ s/\n//;
print "Check primer: $VIRUS ($NUMERO seqs from NCBI)\n";



## Merge with Reference ---------------------------------

my $MERGEDfolder =  $TEMPfolder . "/mergedCandidates";
system "mkdir -p $MERGEDfolder";

# use EMBOSS merger to fill up NCBI sequences
system "ls $TEMPfolder/singleRawFasta/*.fa | parallel 'megamerger -wordsize 20 -prefer=T -asequence {} -bsequence ${TEMPfolder}/REFERENCE.fa -outseq $MERGEDfolder/{/} -outfile $MERGEDfolder/{/.}.txt'  >/dev/null 2>&1";




## Primer Search ---------------------------------

# run primer search
system "cat $MERGEDfolder/*.fa > $TEMPfolder/allFastas.fa";
system "primersearch -infile $TEMPfolder/primerToTest.txt -seqall $TEMPfolder/allFastas.fa -mismatchpercent 20 -outfile $TEMPfolder/primerSearch.out >/dev/null 2>&1";

# write out to temp File with which sequences are not even amplified
system "perl $MACHOPATH/subAmpliTester.pl $TEMPfolder";

## test which primer is not amplified of the previous list
# make first fasta for each primer...
system "perl $MACHOPATH/subMakePrimerFasta.pl $TEMPfolder";
# then test them with water (and parse results to file for later)
system "cat $TEMPfolder/noAmplifications.txt | parallel \"perl $MACHOPATH/subSideChecker.pl $TEMPfolder $TEMPfolder/mergedCandidates/{}.fa\" > $TEMPfolder/MismatchedPrimers.txt 2>&1";

# print out problematic and location
system "Rscript $MACHOPATH/subGeograph.R $TEMPfolder";


# make Probe testing
system "perl $MACHOPATH/subProbeTester.pl $TEMPfolder >/dev/null 2>&1";


# parse output
my $OUT = `perl $MACHOPATH/subPrimerSearch.pl $TEMPfolder/primerSearch.out`;

print "$OUT";

## Output Fasta ---------------------------------

# Run only with problematic primers (count lines of stdout)
my $NEWLINEcount = ($OUT =~ tr/\n//);

if ($NEWLINEcount > 0){
	# concatenate complemented fasta and add primers
	system "perl $MACHOPATH/subResultOutputter.pl $TEMPfolder";
}else{
	print "Primers cover everything.\n"
}

