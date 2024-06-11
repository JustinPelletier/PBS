#!/bin/bash
#SBATCH --account=rrg-vmooser
#SBATCH --time=40:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --output=chrHERE_STEP1.out

#------------------------------

path_1000G=/lustre06/project/6061810/shared/HGDP_1KG/unfiltered_vcfs

module load bcftools

#-----------------------------



# ---------------------- STEP 1 ---------------------------------------------#
# Rename the files and modify the variant IDs to chr:pos:ref:alt


	
	bcftools view $path_1000G/gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.bgz | \
	bcftools annotate --set-id '%CHROM:%POS:%REF:%ALT' -Oz -o gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.gz
	tabix -f gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.gz
