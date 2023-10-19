# BTV_TaqMan_NS1_Toussaint Script for NCBI download 
# Wyler M., IVI, 14.10.2023

library(rentrez)

args <- commandArgs(TRUE)
TEMPfolder <- args[1]

# look for possible ways to search
entrez_db_searchable("nucleotide")

# search (using web history because of large files)
r_search <- entrez_search(db="nucleotide", 
                          term="NS1[TITL] OR segment 5[TITL] AND 1500:2000[SLEN] AND Bluetongue virus[PORG]",
                          retmax = 99999999,
                          use_history = T) 
# length(r_search$ids)


# get large fasta
fastaVec <- entrez_fetch(db="nuccore", 
                         #id=IDs_ofInterest, 
                         rettype="fasta",
                         web_history = r_search$web_history)


# write out
#write(fastaVec, file = '')
write(fastaVec, file = paste0(TEMPfolder, '/fastaFromNCBI.fa'))
