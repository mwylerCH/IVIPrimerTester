# extract country information from genebank (for no amplification)
# Wyler Michele, IVI Mittelhäusern, Switzerland, 9.2.2023

suppressMessages(suppressWarnings(require(rentrez)))
suppressMessages(suppressWarnings(require(data.table)))
suppressMessages(suppressWarnings(require(tidyverse)))
options(warn=-1)


args <- commandArgs(TRUE)
TEMPfolder <- args[1]

# TEMPfolder <- "~/backup_PRRSV_US_TaqMan_ORF7/"
# file name 
Problematic <- paste0(TEMPfolder, '/noAmplifications.txt')
PrimerInfo <- paste0(TEMPfolder, '/MismatchedPrimers.txt')

# test if any problem is present
stopifnot(file.exists(Problematic))

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
  # extract primer information 
  qualePrimer <- paste0(PrimerFailed[PrimerFailed$V1 == ID, 2:4], collapse = ',')
  OUT <- paste0('No amplification for: ', ID, '       (origin: ', Paese, ')', '       Check Primer: ', qualePrimer)
  OUT <- gsub(',$', '', OUT)
  
  return(OUT)
}

# read in informations about failing primers
PrimerFailed <- fread(PrimerInfo, data.table = F, fill = T, header = F)


# read in problematics
ProblemIDs <- fread(Problematic, header = F, data.table = F)

# prepare string for searching
ProblemIDs$V1 <- gsub('$', '[ACCN]', ProblemIDs$V1)

# loop through (NCBI is not accepting long search terms)
BATCH <- 100
pezzi <- split(ProblemIDs$V1, ceiling(seq_along(ProblemIDs$V1)/BATCH))
for (PZ in 1:length(pezzi)){
 chunkString <- unlist(pezzi[PZ])
 SearchString <- paste(chunkString, collapse = ' OR ')

 # search (using web history because of large files)
 r_search <- as.data.frame(NA)
 r_search$ids <- NA
 while (length(r_search$ids) < 2) {
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
  write(sapply(lista, f.extractor), file = '')
}

