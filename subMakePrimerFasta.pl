#!/usr/bin/perl

use warnings;
use strict;
use English;


# Script that checks wich primer is not matching  
# Wyler Michele. IVI Mittelhäusern, Switzerland, 9.2.2024

my $TEMPfolder =  $ARGV[0];

## Make a primer fasta ---------------------------------------

# read in (only one line)
open my $probes, '<',  $TEMPfolder . "/primerToTest.txt";
my $PROBE = <$probes>;
close $probes;
chomp $PROBE;

# print out two files
my @SEQUENCE = split("\t", $PROBE);

open(FH, ">", "$TEMPfolder/ForwardPrimer.fa");
print FH ">Forward\n$SEQUENCE[1]";
close (FH);

open(FH, ">", "$TEMPfolder/ReversePrimer.fa");
print FH ">Reverse\n$SEQUENCE[2]";
close (FH);


## Make a probe fasta ---------------------------------------

# read in (only one line)
open my $probes, '<',  $TEMPfolder . "/probeToTest.txt";
my $PROBE = <$probes>;
close $probes;
chomp $PROBE;

# print out two files
my @PROBE = split("\t", $PROBE);

open(FH, ">", "$TEMPfolder/Probe.fa");
print FH ">Probe\n$PROBE[1]";
close (FH);

