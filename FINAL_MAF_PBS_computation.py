import sys
import numpy as np
import scipy
import pandas as pd
import allel
import h5py
from pandas import DataFrame
from scipy.stats import uniform
from scipy.stats import randint
import numpy as np
import matplotlib.pyplot as plt


"""
Documentation on the package:  https://scikit-allel.readthedocs.io/en/stable/stats/selection.html?highlight=allel.pbs#allel.pbs
Script to compute Population Branch Statistic (PBS)
Tutorial:
http://alimanfoo.github.io/2016/06/10/scikit-allel-tour.html
"""

#----------Compute Allele count ----------------


def main(vcf_file):
    # Read VCF file
    data = allel.read_vcf(vcf_file)
    genotypes = allel.GenotypeArray(data['calldata/GT'][:])
    chrom = (data['variants/CHROM'][:])
    SNPid = (data['variants/ID'][:])
    POS = (data['variants/POS'][:])


    # Read metadata file
    metadata = "list_unrelated_no_outliers_AFR_EAS_EUR.metadata"
    samples = pd.read_csv(metadata, sep=',')

    # Define subpopulations
    subpops = {
        'AFR': samples[samples.POP == 'AFR'].index.tolist(),
        'EAS': samples[samples.POP == 'EAS'].index.tolist(),
        'EUR': samples[samples.POP == 'EUR'].index.tolist(),
    }

    # Compute Allele counts
    ac_subpops = genotypes.count_alleles_subpops(subpops, max_allele=1)

    # Function to replace zeros with ones and ensure dtype is integer
    def replace_zeros_with_one(allele_counts):
        allele_counts = np.where(allele_counts == 0, 1, allele_counts)
        return allele_counts.astype(int)

    # Apply the function to replace zeros and ensure integer dtype
    ac_subpops['AFR'] = replace_zeros_with_one(ac_subpops['AFR'])
    ac_subpops['EAS'] = replace_zeros_with_one(ac_subpops['EAS'])
    ac_subpops['EUR'] = replace_zeros_with_one(ac_subpops['EUR'])

    # Calculate Minor Allele Frequencies (MAF)
    maf_afr = ac_subpops['AFR'][:, 1].astype(float) / np.sum(ac_subpops['AFR'], axis=1)
    maf_eas = ac_subpops['EAS'][:, 1].astype(float) / np.sum(ac_subpops['EAS'], axis=1)
    maf_eur = ac_subpops['EUR'][:, 1].astype(float) / np.sum(ac_subpops['EUR'], axis=1)

    # Debug: Print Allele Counts
    print("AC_afr:", ac_subpops['AFR'])
    print("AC_eas:", ac_subpops['EAS'])
    print("AC_eur:", ac_subpops['EUR'])

    # Compute PBS on 3 populations
    PBS_afr_eas_eur = allel.pbs(ac_subpops['AFR'], ac_subpops['EAS'], ac_subpops['EUR'], window_size=1, window_step=1, normed=False)

    # Switching outgroup to EAS
    PBS_eas_afr_eur = allel.pbs(ac_subpops['EAS'], ac_subpops['AFR'], ac_subpops['EUR'], window_size=1, window_step=1, normed=False)

    # Switching outgroup to EUR
    PBS_eur_afr_eas = allel.pbs(ac_subpops['EUR'], ac_subpops['AFR'], ac_subpops['EAS'], window_size=1, window_step=1, normed=False)

    # Save results
    df = pd.DataFrame({
        'SNPid': SNPid,
        'CHROM': chrom,
        'POS': POS,
        'PBS_AFR_EAS_EUR': PBS_afr_eas_eur,
        'PBS_EAS_AFR_EUR': PBS_eas_afr_eur,
        'PBS_EUR_AFR_EAS': PBS_eur_afr_eas,
        'MAF_AFR': maf_afr,
        'MAF_EAS': maf_eas,
        'MAF_EUR': maf_eur,
    })
    df.to_csv('PBS_MAF.csv', index=False, sep="\t")




if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <vcf_file>")
        sys.exit(1)
    vcf_file = sys.argv[1]
    main(vcf_file)


