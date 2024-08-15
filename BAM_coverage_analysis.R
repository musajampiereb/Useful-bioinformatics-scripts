
###############################
###Investigate the coverage####
###############################

#Ensure you are in the right directory 
getwd()
setwd("/Volumes/Biospace/mpox_rwanda/run03/barcode08") #This should be addapted to the PATH on your computer 

#Install bioconductor and its packages if necessary

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.19")

BiocManager::install(c("GenomicFeatures", "AnnotationDbi"))

BiocManager::available()

#Install Rsamtools 
BiocManager::install("Rsamtools", force = TRUE)

#load libraries
library(Rsamtools)
library(ggplot2)

depth <- read.csv("all_reads.depth")
View(depth)

# Plot the coverage over the position 

ggplot(depth, aes(x=X1,y=X0)) + geom_line(mapping = NULL, data = NULL, stat = "identity", position = "identity", na.rm = FALSE, orientation = NA, show.legend = NA, inherit.aes = TRUE)


#read in entire BAM file
bam <- scanBam("all_reads.bam")

#names of the BAM fields
names(bam[[1]])
# [1] "qname"  "flag"   "rname"  "strand" "pos"    "qwidth" "mapq"   "cigar"
# [9] "mrnm"   "mpos"   "isize"  "seq"    "qual"

#distribution of BAM flags
table(bam[[1]]$flag)

#      0       4      16 
#1472261  775200 1652949

#function for collapsing the list of lists into a single list
#as per the Rsamtools vignette
.unlist <- function (x){
  ## do.call(c, ...) coerces factor to integer, which is undesired
  x1 <- x[[1L]]
  if (is.factor(x1)){
    structure(unlist(x), class = "factor", levels = levels(x1))
  } else {
    do.call(c, x)
  }
}

#store names of BAM fields
bam_field <- names(bam[[1]])

#go through each BAM field and unlist
list <- lapply(bam_field, function(y) .unlist(lapply(bam, "[[", y)))

#store as data frame
bam_df <- do.call("DataFrame", list)
names(bam_df) <- bam_field

dim(bam_df)
#[1] 3900410      13

#use JX878417.1 as the name of chromosome since it is the same reference used for mapping
#how many entries on the negative strand of the chromosome?
table(bam_df$rname == 'JX878417.1' & bam_df$flag == 16)


#function for checking negative strand
check_neg <- function(x){
  if (intToBits(x)[5] == 1){
    return(T)
  } else {
    return(F)
  }
}

#test neg function with subset of JX878417.1
test <- subset(bam_df, rname == 'JX878417.1')
dim(test)

table(apply(as.data.frame(test$flag), 1, check_neg))


#function for checking positive strand
check_pos <- function(x){
  if (intToBits(x)[3] == 1){
    return(F)
  } else if (intToBits(x)[5] != 1){
    return(T)
  } else {
    return(F)
  }
}

#check pos function
table(apply(as.data.frame(test$flag), 1, check_pos))


#store the mapped positions on the plus and minus strands
JX878417.1_neg <- bam_df[bam_df$rname == 'JX878417.1' &
                      apply(as.data.frame(bam_df$flag), 1, check_neg),
                    'pos'
]
length(JX878417.1_neg)

JX878417.1_pos <- bam_df[bam_df$rname == 'JX878417.1' &
                      apply(as.data.frame(bam_df$flag), 1, check_pos),
                    'pos'
]
length(JX878417.1_pos)


#calculate the densities
JX878417.1_neg_density <- density(JX878417.1_neg)
JX878417.1_pos_density <- density(JX878417.1_pos)

#display the negative strand with negative values
JX878417.1_neg_density$y <- JX878417.1_neg_density$y * -1

plot(JX878417.1_pos_density,
     ylim = range(c(JX878417.1_neg_density$y, JX878417.1_pos_density$y)),
     main = "Coverage plot of mapped reads in BAM file",
     xlab = "whole genome coverage",
     col = 'blue',
     lwd=2.5)
lines(JX878417.1_neg_density, lwd=2.5, col = 'red')


plot(JX878417.1_pos_density,
     ylim = range(c(JX878417.1_neg_density$y, JX878417.1_pos_density$y)),
     main = "Coverage plot of mapped reads in BAM file",
     xlab = "whole genome coverage",
     col = 'blue',
     type='h'
)

lines(JX878417.1_neg_density, type='h', col = 'red')

