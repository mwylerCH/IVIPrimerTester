#!/usr/bin/perl

use warnings;
use strict;
use English;


my $TEMPfolder = $ARGV[0];


### Prepare primer file ---------------------------------------

# read in (only one line)
open my $primers, '<',  $TEMPfolder . "/primerToTest.txt"; 
my $PRIMER = <$primers>; 
close $primers;

chomp $PRIMER;

# split row
my @PRIMERpieces = split('\t', $PRIMER, 3);

## prepare 4 lines of the output

# forward header
my $HEADforward = $PRIMERpieces[0] . "_For";
# reverse header
my $HEADreverse = $PRIMERpieces[0] . "_Rev";

# forward sequence
my $SEQforward = $PRIMERpieces[1];

# reverse sequence (reverse and complement)
my $SEQreverse = reverse $PRIMERpieces[2];
$SEQreverse =~ tr/ATGCatgc/TACGtacg/;


### Add Probe sequence ---------------------------------------

# read in (only one line)
open my $probes, '<',  $TEMPfolder . "/probeToTest.txt";
my $PROBE = <$probes>;
close $probes;

chomp $PROBE;

# split row
my @PROBEpieces = split('\t', $PROBE, 2);

# probe sequence
my $PROBEseq = $PROBEpieces[1];


## remember --------- IUPAC uncertainity ----------------

### Prepare whole fasta ---------------------------------------

# concatenate merged files

system "cat $TEMPfolder/mergedCandidates/*.fa > Results_$PRIMERpieces[0].fa";

# add primers
open(FH, ">>", "Results_$PRIMERpieces[0].fa") or die "File couldn't be opened"; 
print FH ">$HEADforward\n$SEQforward\n>$HEADreverse\n$SEQreverse\n>Probe\n$PROBEseq\n";
close(FH);
