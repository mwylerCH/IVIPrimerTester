#!/usr/bin/perl

use warnings;
use strict;
use English;


# Script that checks wich primer is not matching  
# Wyler Michele. IVI Mittelhäusern, Switzerland, 9.2.2024

my $TEMPfolder =  $ARGV[0];
my $FASTA =  $ARGV[1];


## Get Len primers ---------------------------------------

# read in (only one line)
open my $primer, '<',  $TEMPfolder . "/primerToTest.txt";
my $PRIMER = <$primer>;
close $primer;

# split
my @SEQUENCE = split("\t", $PRIMER);

# get Length
my $LENfor = length($SEQUENCE[1]);
my $LENrev = length($SEQUENCE[2]);


# get tollerance not consider IUPAC (not used, get considered by water)

my $FOR_IUPAC = $SEQUENCE[1];
$FOR_IUPAC =~ s/[ATCGatcg]//g ;
my $TOLLERANCE_FOR = length $FOR_IUPAC ;
$TOLLERANCE_FOR += 1;

my $REV_IUPAC = $SEQUENCE[2];
$REV_IUPAC =~ s/[ATCGatcg]//g ;
my $TOLLERANCE_REV = length $REV_IUPAC ;
$TOLLERANCE_REV += 1;

## Get Len Probe ---------------------------------------

# read only line
open my $probes, '<',  $TEMPfolder . "/probeToTest.txt";
my $PROBE2 = <$probes>;
close $probes;

# split
my @SEQUENCE2 = split("\t", $PROBE2);

# get Length
my $LENprobe = length($SEQUENCE2[1]);

## Run Water ------------------------------------------------

# for For

my $FORresult = `water -gapopen 10 -gapextend 10  -asequence $FASTA -bsequence $TEMPfolder/ForwardPrimer.fa  -outfile stdout -brief`;
my $Align_For = $FORresult;
$Align_For =~ s/\n/ /g;
$Align_For =~ s/.*# Similarity:\s+(\d+)\/.*/$1/;

# for Rev

my $REVresult = `water -gapopen 10 -gapextend 10  -asequence $FASTA -bsequence $TEMPfolder/ReversePrimer.fa  -outfile stdout -brief`;
my $Align_Rev = $REVresult;
$Align_Rev =~ s/\n/ /g;
$Align_Rev =~ s/.*# Similarity:\s+(\d+)\/.*/$1/;

# for Probe

my $PROBEresult = `water -gapopen 10 -gapextend 10  -asequence $FASTA -bsequence $TEMPfolder/Probe.fa  -outfile stdout -brief`;
my $Align_Probe = $PROBEresult;
$Align_Probe =~ s/\n/ /g;
$Align_Probe =~ s/.*# Similarity:\s+(\d+)\/.*/$1/;



# get sequence name
my $SeqName = $REVresult;
$SeqName =~ s/\n/ /g;
$SeqName =~ s/.*-asequence\s+(\S+).fa.*/$1/;

## Evaluate and output --------------------------------------------


$TOLLERANCE_FOR = 0;
$TOLLERANCE_REV = 0;


my $Result = $SeqName;
$Result =~ s/.*\/(.+)$/$1/;

if ($Align_For < $LENfor - $TOLLERANCE_FOR){
	$Result .= ' FORWARD ';
}

if ($Align_Rev < $LENrev - $TOLLERANCE_REV){
        $Result .= ' REVERSE ';
}

if ($Align_Probe < $LENprobe){
        $Result .= ' PROBE ';
}


print "$Result\n";


