# KSPV_TaqMan_5NTR_FLI Script for NCBI download 
# Wyler M., IVI, 7.11.2023

library(rentrez)

args <- commandArgs(TRUE)
TEMPfolder <- args[1]

# look for possible ways to search
# entrez_db_searchable("nucleotide")

# search (using web history because of large files)
r_search <- as.data.frame(NA)
r_search$ids <- NA
while (length(r_search$ids) < 2) {
  r_search <- entrez_search(db="nucleotide", 
                          term="Classical swine fever virus[PORG]",
                          #term="VP7[TITL] OR segment 7[TITL] AND African horse sickness virus[PORG]",
                          retmax = 99999999,
                          use_history = T) 
}



# get large fasta
fastaVec <- entrez_fetch(db="nuccore", 
                         #id=IDs_ofInterest, 
                         rettype="fasta",
                         web_history = r_search$web_history)


# write out
# write(fastaVec, file = '')
write(fastaVec, file = paste0(TEMPfolder, '/fastaFromNCBI.fa'))