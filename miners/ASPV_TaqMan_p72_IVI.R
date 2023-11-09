# ASPV_TaqMan_p72_IVI Script for NCBI download 
# Wyler M., IVI, 14.10.2023

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
                          term="African swine fever virus[PORG]",
                          retmax = 99999999,
                          use_history = T) 
}

# length(r_search$ids)


# get large fasta
fastaVec <- entrez_fetch(db="nuccore", 
                         #id=IDs_ofInterest, 
                         rettype="fasta",
                         web_history = r_search$web_history)


# write out
#write(fastaVec, file = '')
write(fastaVec, file = paste0(TEMPfolder, '/fastaFromNCBI.fa'))
