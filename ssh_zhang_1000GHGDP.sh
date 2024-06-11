#!/bin/bash
#SBATCH --account=rrg-vmooser
#SBATCH --time=40:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --output=ssh_zhang_1000GHGDP.out


#------------------------------

path_1000G=<path/to/HGDP+1KG>

module load bcftools
module load r


step1="TRUE"
step2="TRUE"
step2_2="TRUE"
step3_0="TRUE"
step3="TRUE"


#-----------------------------



# ---------------------- STEP 1 ---------------------------------------------#
# Rename the files and modify the variant IDs to chr:pos:ref:alt


if [ $step1 == "TRUE" ]; then

	for i in $(seq 22); do

		echo $i
	
		sed "s/HERE/$i/g" STEP1.sh > chr${i}_STEP1.sh
		sbatch chr${i}_STEP1.sh

	done
fi



# ---------------------- STEP 2 ---------------------------------------------#
# Extract the pQTL from zhang paper 2022


if [ $step2 == "TRUE" ]; then

	# Prepare the Zhang file to create the ID of the variant
	Rscript modify_zhang2022.R 
	cut -f 13 zhang2022.tsv > zhang2022_varID.txt
	cut -f 13 zhang2022.tsv | cut -d":" -f1,2 | sed 's/:/\t/g' > zhang2022_varRegion.txt


	# Find the variants per chromosome
	for i in $(seq 22); do
	
		echo $i
		sed "s/HERE/$i/g" STEP2.sh > chr${i}_STEP2.sh
		sbatch chr${i}_STEP2.sh

	done

fi

if [ $step2_2 == "TRUE" ]; then

	# Concat all chromosome and the header
	bcftools concat -o zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf.gz -Oz \
	zhang.gnomad.genomes.v3.1.2.hgdp_tgp.chr{1..22}.vcf.gz

	# Compress and index the final VCF
	tabix -f zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf.gz
	
	# Keep only the unrelated set
	cut -d"," -f1 list_unrelated_no_outliers_AFR_EAS_EUR.metadata | sed '1d' > list_unrelated_no_outliers_AFR_EAS_EUR.metadata.txt
	bcftools view -S list_unrelated_no_outliers_AFR_EAS_EUR.metadata.txt -Oz -o tmp_UNR_zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf.gz zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf.gz

	# Make sure we only keep the variant matching chrom:pos:ref:alt and not only chrom:pos
	plink --vcf tmp_UNR_zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf.gz --extract zhang2022_varID.txt --double-id --recode vcf --out UNR_zhang.gnomad.genomes.v3.1.2.hgdp_tgp
	rm *.nosex
	bgzip -f UNR_zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf

fi




# ---------------------- STEP 3 ---------------------------------------------#
# Compute PBS for the final vcf file

if [ $step3_0 == "TRUE" ]; then

	# Install ENV with packages for python
	module load python
	module load scipy-stack
	virtualenv --no-download ENV
	source ENV/bin/activate
	echo "numpy
	scipy
	pandas
	scikit-allel
	h5py
	matplotlib" > requirements.txt
	
	# Load the modules in the ENV
	pip install -r requirements.txt
fi


if [ $step3 == "TRUE" ]; then

	#launch PBS computation
	python3 FINAL_MAF_PBS_computation.py UNR_zhang.gnomad.genomes.v3.1.2.hgdp_tgp.vcf.gz 

	
	
fi
