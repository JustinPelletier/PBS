#!/bin/bash
#SBATCH --account=rrg-vmooser
#SBATCH --time=2:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --output=chrHERE_STEP2.out


# ---------------------- STEP 2 ---------------------------------------------#
# Extract the pQTL from zhang paper 2022
#zgrep -Fwf zhang2022_varID.txt gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.gz > zhang.gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf
module load bcftools 


bcftools view -R zhang2022_varRegion.txt gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.gz -Oz -o zhang.gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.gz
tabix -f zhang.gnomad.genomes.v3.1.2.hgdp_tgp.chrHERE.vcf.gz

