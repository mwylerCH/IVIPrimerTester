# IVIPrimerTester

## Introduction

Testing is available for 41 primer sets/combinations (complete list visible [here](RefFiles/primerIVI.txt)).
Briefly, IVIPrimerTester will mine available sequences from NCBI. These hits are subsequently evaluatd against a local reference sequence (length difference +/- 20% of the reference). To screen also for incomplete sequences, the NCBI hits are imputed using the reference, SNPs are however maintaned. Primers are then tested on the whole available sequence, allowing for multiple possible amplicons (specially indicated in the output generated).

## Output

IVIPrimerTester produces a stdout containing mismatches (bp) for each primer, the length of the amplification and the sequence description. A header of the file indicates the tested primer and the number of screened samples.
```
Check primer: PRRSV_US_TaqMan_ORF7 (1833 seqs from NCBI)
AY262352.1      Forward=3       Reverse=0       AmplemerLen=10962        PRRSV HB-2(sh)/2002, complete genome
EF641008.1      Forward=1       Reverse=3       AmplemerLen=113  Porcine respiratory and reproductive syndrome virus strain JXwn06, complete genome
KY495781.1      Forward=3       Reverse=0       AmplemerLen=115  Porcine reproductive and respiratory syndrome virus strain SH/CH/2016, complete genome
KY495781.1      Forward=3       Reverse=0       AmplemerLen=2417         Porcine reproductive and respiratory syndrome virus strain SH/CH/2016, complete genome
'KY495781.1' has multiple amplifications.
```
As visible for KY495781.1, multiple amplicons are possible. In this case, IVIPrimerTester mentions them at the bottom of the output.


## Usage

### installation

IVIPrimerTester requires the availability of the programm languages perl and R ([rentrez](https://cran.r-project.org/web/packages/rentrez/index.html)).
Furthermore IVIPrimerTester dependes from the [EMBOSS](https://emboss.sourceforge.net/) suit.

```
sudo apt-get install emboss

git clone https://github.com/mwylerCH/IVIPrimerTester.git
```

### Run

Basic function
```
perl IVIPrimerTester/MASTER.pl $PRIMER
```


Loop through each primers
```
mkdir -p primerTestOUT
 
ls IVIPrimerTester/miners/* | while read line; do
  PRIMER=`basename $line .R`
  echo $PRIMER
  perl IVIPrimerTester/MASTER.pl $PRIMER > primerTestOUT/resultScreening_$PRIMER.txt
done
```
