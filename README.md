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


# quick overview of results

```
fgrep Forward * | sed 's/Forward=//g' | sed 's/Reverse=//g' | awk '{if($2 > 2) print $0}'
```
