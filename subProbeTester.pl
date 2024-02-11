#!/usr/bin/perl

use warnings;
use strict;
use English;


# script that crops the amplicon (from primersearch) and tests the probe  
# Wyler M. 3.11.2023

my $TEMPfolder = $ARGV[0];


my $PSout = $TEMPfolder . "/primerSearch.out";
my $NCBIFASTA = $TEMPfolder . "/allFastas.fa"; 



### Probe fasta ---------------------------------------

# read in (only one line)
open my $probes, '<',  $TEMPfolder . "/probeToTest.txt";
my $PROBE = <$probes>;
close $probes;
chomp $PROBE;

# split row
my @PROBEpieces = split('\t', $PROBE, 2);

# print out
my $FILEname = $TEMPfolder . "/probeToTest.fa";
open(FH, '>', $FILEname) or die $FILEname;
print FH ">$PROBEpieces[0]\n$PROBEpieces[1]\n";
close(FH);

# get length of probe 
my $PROBElen = length($PROBEpieces[1]);


# tollerance (considering IUPAC)
my $NONNUCL = $PROBEpieces[1];
$NONNUCL =~ s/[ATCGatcg]//g ;
my $TOLLERANCE = length $NONNUCL ;
$TOLLERANCE += 2;


## Parse primer search output to quasi-bed ----------------------------------
# third column is reversed, from the back

my @BEDall ;
my $BEDseq;
my $BEDstart;
my $BEDend;

open(IN, $PSout) or die "can't open $PSout";
while(<IN>){
        chomp;
        # handle raw output
        if ($_ =~ m/Sequence:/){
                $BEDseq = $_ ;
                $BEDseq =~ s/\sSequence: //;
        # for and rev position
        } elsif ($_ =~ m/hits forward strand/) {
                $BEDstart = $_;
                $BEDstart =~ s/.*at\s(\d+)\s.*/$1/;
        } elsif ($_ =~ m/hits reverse strand/) {
                $BEDend = $_;
                $BEDend =~ s/.*at\s\[(\d+)\]\s.*/$1/;
		my $BEDrow = $BEDseq . "\t" .  $BEDstart . "\t" . $BEDend;
		push(@BEDall, $BEDrow);
        } 

}
close (IN);


## Read in Fasta --------------------------------------------------------


open(IN, $NCBIFASTA ) or die "can't open $NCBIFASTA";
my %NCBIseqs = ();
my $NCBIheader = '';

while (my $line = <IN>){
    chomp $line;
        $line =~ s/^\s*$//;
    if ($line =~ m/^>(.*)$/){
        $NCBIheader = $line;
        $NCBIheader =~ s/\s$//; # no empty lines
	$NCBIheader =~ s/(>\S+).*/$1/; # only sequence ID
    } else {
        $NCBIseqs{"$NCBIheader"} .= $line;
    }
}
close (IN);

## Crop fasta to amplicon  ----------------------------------


# load short fasta into an array (one seq one element)
my @CropForOut;

foreach(@BEDall){
	my @BEDrow = split("\t", $_, 3);
	my $ID = $BEDrow[0];
	$ID =~ s/\s+//g;
	my $FINE = $BEDrow[2];
	# crop out (add 1 at start and end to correct for 0 based)
	my $CROP = substr($NCBIseqs{">$ID"}, $BEDrow[1]-1 , -$BEDrow[2]+1);
	my $SEQ =  ">" . $ID . "\n" . $CROP;
	push(@CropForOut, $SEQ);
}


## Align  ----------------------------------

my @BLACKLIST;
my $TEMPcropped = $TEMPfolder . "/tempTemplate.fa";

foreach my $sequence (@CropForOut){
	# print out into temp fasta
	open(FH, '>', $TEMPcropped) or die $!;
	print FH $sequence;
	close(FH);

	# make alignment with water
	my $WATERout = `water -gapopen 10 -gapextend 10  -asequence $TEMPcropped -bsequence $FILEname  -outfile stdout -brief `;
	# check the length (perfect match)
	my $LEN = $WATERout;
	$LEN =~ s/\n/ /g;
	$LEN =~ s/.*# Length: (\d+).*/$1/;
	# SEQ name
	my $SEQname = $WATERout;
	$SEQname =~  s/\n/ /g;
	$SEQname =~ s/.*#\s1:\s(\S+).*/$1/;
	if ($LEN != $PROBElen){
		push(@BLACKLIST, $SEQname);
	} else {
                # check for Identity
                my $IDENTITY = $WATERout;
                $IDENTITY =~ s/\n/ /g;
                $IDENTITY =~ s/.*# Identity:\s+(\d+\/\d+).*/$1/;
                my @identity = split('/', $IDENTITY);
               # max 2 mismatch Identity
               if($identity[0] < $identity[1]-$TOLLERANCE){;
                        push(@BLACKLIST, $SEQname);

                }


	}
}

## Print Out a temp Seq Blacklist  ----------------------------------

my $BLACKname = $TEMPfolder . "/tempBLACKsequence.txt";

open(FH, '>', $BLACKname) or die $!;
foreach (@BLACKLIST){
	print FH "$_\n" ;
}
close(FH);
