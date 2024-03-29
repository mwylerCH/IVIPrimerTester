# IVIPrimerTester

## Introduction

Testing is available for 41 primer sets/combinations (complete list visible [here](RefFiles/primerIVI.txt)).
Briefly, IVIPrimerTester will mine available sequences from NCBI. These hits are subsequently evaluatd against a local reference sequence (length difference +/- 20% of the reference). To screen also for incomplete sequences, the NCBI hits are imputed using the reference, SNPs and indels are however maintaned. Primers are then tested on the whole available sequence, allowing for multiple possible amplicons (specifically indicated in the output generated).
Goal was the development of a modular tool capable to be adapted to new viruses and new primer pairs.

*A tollerance of two mismatches is tollerated (for primers and probes.)*

## Output

IVIPrimerTester produces a stdout containing mismatches (bp) for each primer, the length of the amplification and the sequence description. A header of the file indicates the tested primer and the number of screened samples.
```
Check primer: PRRSV_US_TaqMan_ORF7 (1833 seqs from NCBI)
No amplification for: EU076704.1       (origin: Hong Kong)       Check Primer: FORWARD,REVERSE,PROBE
AY262352.1      Forward=3       Reverse=0       AmplemerLen=10962        PRRSV HB-2(sh)/2002, complete genome
EF641008.1      Forward=1       Reverse=3       AmplemerLen=113  Porcine respiratory and reproductive syndrome virus strain JXwn06, complete genome
KY495781.1      Forward=3       Reverse=0       AmplemerLen=115  Porcine reproductive and respiratory syndrome virus strain SH/CH/2016, complete genome
KY495781.1      Forward=3       Reverse=0       AmplemerLen=2417         Porcine reproductive and respiratory syndrome virus strain SH/CH/2016, complete genome
'KY495781.1' has multiple amplifications.
EF641008.1 => Problematic Probe annealing.
```
As visible for KY495781.1, multiple amplicons are possible. In this case, IVIPrimerTester mentions them at the bottom of the output.
Similarly, also Probes with more then two mismatches are indicated at the bottom of the output.

Furthermore, problematic primers/probes are written out for subsequent visual inspections (file ending with ".fa"). Please consult the [wiki](https://github.com/mwylerCH/IVIPrimerTester/wiki) page for details.

## Usage

### installation

IVIPrimerTester requires the availability of the programm languages perl and R ([rentrez](https://cran.r-project.org/web/packages/rentrez/index.html)).
Furthermore IVIPrimerTester dependes from the [EMBOSS](https://emboss.sourceforge.net/) suit.

```
sudo apt-get install emboss
git clone https://github.com/mwylerCH/IVIPrimerTester.git
```

### Basic Run

Basic function
```
perl IVIPrimerTester/MASTER.pl $PRIMER
```
IVIPrimerTester allows to exclude specific sequences available on NCBI. This feature can be used to exclude special strains from remote regions, untrustworthy source or of low interest. The corresponding IDs need to be listed in the IVIPrimerTester [Blacklist](RefFiles/BlackList.txt).


Loop through each primers
```
mkdir -p primerTestOUT
 
ls IVIPrimerTester/miners/* | while read line; do
  PRIMER=`basename $line .R`
  echo $PRIMER
  perl IVIPrimerTester/MASTER.pl $PRIMER > primerTestOUT/Results_$PRIMER.txt
done
```

### Geographical information

By default, the basic function will output any geographical information available for unamplified sequences. If these informations are required also for other problematic entries, it's possible to retrieve these with a secondary script.
```
Rscript IVIPrimerTester/GeoFinder.R primerTestOUT/Results_$PRIMER.txt primerTestOUT/Results_${PRIMER}_geo.txt
```

### Intersect marker combinations

IVIPrimerTester is accepting a single primer/probe set. However, specific tests are run with a combination of primers. The script *PrimerCompare.pl* provides an intersect of problematic sequences from two primer sets. Required files are two outputs from testing. 
```
perl PrimerCompare.pl WNV_TaqMan_5NTR_comb1.txt WNV_TaqMan_5NTR_comb2.txt
```

## Future development

The next generation of IVIPrimerTester will 
- screen also for influenza strains from GISAID
- implement a scoring method to assess the annealing efficiency
- implement IUPAC code 
