use warnings;
use strict;
use English;
use File::Temp qw/ tempdir /;
use Getopt::Long 'HelpMessage';
use File::Basename;
use Cwd;
use POSIX;

# script takes a reference sequence and checks names and size of NCBI mined
# Wyler M. 13.10.2023

#my $TEMPfolder = "/home/mwyler/tempDevPrimer";
#my $NCBIFASTA = "/home/mwyler/tempDevPrimer/fastaFromNCBI.fa";
#my $REFFASTA = "/home/mwyler/PrimerMacho/RefFasta/AHSV_TaqMan_NS2.fa.gz";

my $TEMPfolder = $ARGV[0];
my $NCBIFASTA = $TEMPfolder . "/fastaFromNCBI.fa";
my $REFFASTA = $ARGV[1];
my $BLACKLIST = $ARGV[2];


## Read Black listed sequence ----------------------------------------

my @BLACK;
open(IN, $BLACKLIST ) or die "can't open $BLACKLIST";
while(<IN>){
	chomp;
	$_ =~ s/^\s*$//;
	if ($_ =~ m/^(\S*)$/){
		push(@BLACK, $_);
	}
}
close(IN);

## Read in Reference ----------------------------------------

open(IN, "gunzip -c $REFFASTA |") or die "can't open $REFFASTA";
my %seqs = ();
my $header = '';

while (my $line = <IN>){
    chomp $line;
	$line =~ s/^\s*$//;
    if ($line =~ m/^>(.*)$/){
        $header = $line;
    } else {
        $seqs{"$header"} .= $line;
    }
}
close (IN);

# get length of the sequence (and print fata for later)

my $REFLEN;
my $REFNAME = $TEMPfolder . "/REFERENCE.fa";

open(FH, '>', $REFNAME) or die "can't write $REFNAME";
while ( my ($k,$v) = each %seqs ) {
	$REFLEN = length($v); 
	print FH "$k\n$v\n";
}
close(FH);

# 20% tollerance
#my $MINLEN = $REFLEN*0.8;
#my $MAXLEN = $REFLEN*1.2;
my $MINLEN = 1;
my $MAXLEN = $REFLEN*1.2;

## Read in from NCBI ----------------------------------------

open(IN, $NCBIFASTA ) or die "can't open $NCBIFASTA";
my %NCBIseqs = ();
my $NCBIheader = '';

while (my $line = <IN>){
    chomp $line;
        $line =~ s/^\s*$//;
    if ($line =~ m/^>(.*)$/){
        $NCBIheader = $line;
	$NCBIheader =~ s/\s$//;
    } else {
        $NCBIseqs{"$NCBIheader"} .= $line;
    }
}
close (IN);


## Delete Black listed sequences ----------------------------------------

# full name of sequence
my @HEADERSFASTA = keys %NCBIseqs;

foreach my $nero (@BLACK){
	# which one should be removed
	my @TOeliminate = grep(/>${nero}/, @HEADERSFASTA);
	# remove
	foreach my $Remover (@TOeliminate){
		delete($NCBIseqs{"$Remover"});
	}
}


## filter length ----------------------------------------

# filter NCBI hits by length

while ( my ($k,$v) = each %NCBIseqs ) {
	# Len of candidate
	my $CANDlen = length($v);		
	# check Len and eliminate if inappropriate
	if ($CANDlen <= $MINLEN || $CANDlen >= $MAXLEN){
        	delete($NCBIseqs{"$k"});
	} 
}


## Make single fasta files ----------------------------------------

# new folder inside temp Folder for all files
my $SINGLEfolder = $TEMPfolder . "/singleRawFasta";
system "mkdir -p $SINGLEfolder";

while ( my ($k,$v) = each %NCBIseqs ) {
	# first parte of the name 
	my @HeadName = (split ' ', $k );
	my $NAME = $HeadName[0];
	$NAME =~ s/>//;
	
	# file name
	my $FILEname = $SINGLEfolder . "/" . $NAME . ".fa";
	
	# print out
	open(FH, '>', $FILEname) or die $!;
	print FH "$k\n$v\n";
	close(FH);

}
