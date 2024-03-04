## If required, greographic location of problematic primers can be checked
# Wyler Michele, IVI Mittelhäusern, Switzerland, 26.2.2024

suppressMessages(suppressWarnings(require(rentrez)))
suppressMessages(suppressWarnings(require(data.table)))
suppressMessages(suppressWarnings(require(tidyverse)))
options(warn=-1)


args <- commandArgs(TRUE)
FILE <- args[1]

#FILE <- "//wsl.localhost/Ubuntu-22.04/home/mwyler/risultato_PRRS_ORF6_EU2_P"

# read in
rawFile <- fread(FILE, header = F, fill = T, data.table = F, sep = '\t')


# make function to extract informations
f.extractor <- function(GeneBank) {
  # split the vector
  splittedSingolo <- unlist(strsplit(as.character(GeneBank), '\n'))
  # parse ID
  ID <- splittedSingolo[grepl('VERSION', splittedSingolo)]
  ID <- gsub('VERSION\\s+','', ID)
  # parse ID
  Paese <- splittedSingolo[grepl('country', splittedSingolo)]
  Paese <- gsub('.*\\"(.*)\\"', '\\1', Paese)
  # output
  if(length(Paese) != 1){
    Paese <- NA
  }
  # prepare output
  OUT <- paste0(ID, '|(origin: ', Paese, ')')

  return(OUT)
}


## no work -------------------------------
# put aside if already known geo (and header/seq count)

OUTrow <- rawFile[grepl('Check primer:|No amplification for', rawFile$V1),]

## search geo -------------------------------

# make table with IDs as new column
workTable <- as.data.frame(rawFile[!grepl('Check primer:|No amplification for', rawFile$V1),])
colnames(workTable) <- 'entry'
workTable$IDs <- gsub(' => Problematic Probe annealing.', '', workTable$entry)
workTable$IDs <- gsub("' has multiple amplifications.", '', workTable$IDs)
workTable$IDs <- gsub("'", '', workTable$IDs)
workTable$IDs <- gsub("(+)\t.+", '\\1', workTable$IDs)

# make empty table for results
origine <- c()

# loop through (NCBI is not accepting long search terms)
BATCH <- 50
pezzi <- split(workTable$IDs, ceiling(seq_along(workTable$IDs)/BATCH))
for (PZ in 1:length(pezzi)){
  chunkString <- unlist(pezzi[PZ])
  SearchString <- paste(chunkString, collapse = ' OR ')
  
  # search (using web history because of large files)
  r_search <- as.data.frame(NA)
  r_search$ids <- NA
  while (length(na.omit(r_search$ids)) < 1) {
    r_search <- entrez_search(db="nucleotide", 
                              term=SearchString,
                              retmax = BATCH,
                              use_post=TRUE,
                              use_history = T)
  }
  
  # get large Genebank
  GB <-  entrez_fetch(db="nuccore", 
                      #id=IDs_ofInterest, 
                      rettype="GB",
                      web_history = r_search$web_history)
  
  # split each entry into a list element
  lista  <- tstrsplit(GB, 'LOCUS', fixed = T)
  lista[1] <- NULL
  # extraction
  # output
  origine <- append(origine, sapply(lista, f.extractor))
}

# add to table
workTable$Country <- NA
for (ROW in 1:nrow(workTable)){
  id <- workTable[ROW, 2]
  riga <- unique(origine[grepl(id, origine)])
  idorigine <- gsub('\\|.+', '', riga)
  workTable[workTable$IDs == idorigine, 3] <- gsub('.+\\|', '', riga)
}

# make vector
nuovoVec <- paste0(workTable$entry, "\t", workTable$Country)


# print out
fuori <- c(OUTrow, nuovoVec)
write(fuori, file = '')
