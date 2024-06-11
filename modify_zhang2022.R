

# Read input file
zhang2022 = read.csv("zhang2022.csv", header=F)

# Add a column for the new ID
zhang2022$V13 = paste(paste0("chr",zhang2022$V3), zhang2022$V5, zhang2022$V11, zhang2022$V12, sep=":")


# Output the new file
write.table(zhang2022, "zhang2022.tsv", quote=F, col.names=F, row.names=F, sep = "\t")



