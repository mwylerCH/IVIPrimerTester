# IVIPrimerTester

### Run

Loop through each primers
```
mkdir -p primerTestOUT
 
ls PrimerMacho/miners/* | while read line; do
  PRIMER=`basename $line .R`
  echo $PRIMER
  perl PrimerMacho/MASTER.pl $PRIMER > primerTestOUT/resultScreening_$PRIMER.txt
done
```
