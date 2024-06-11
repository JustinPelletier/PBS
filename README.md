# Author: Justin Pelletier
# Contact: justin.pelletier2@mcgill.ca


# Variant Extraction and PBS Computation Pipeline

This pipeline is designed to process VCF files, extract specific variants, and compute Population Branch Statistics (PBS). It includes multiple steps, from renaming files and modifying variant IDs to computing PBS and generating plots.

## Requirements

- SLURM for job scheduling
- `bcftools`
- `R`
- `python`
- `scipy-stack`
- `virtualenv`
- `plink`

## Pipeline Steps

### Step 1: Rename Files and Modify Variant IDs

Rename the files and modify the variant IDs to `chr:pos:ref:alt`.
All output files of this step are located here: `/lustre06/project/6061810/shared/PBS/PAPER_version/all_variants`


### Step 2: Extract pQTL from Zhang Paper 2022

Prepare the Zhang file and extract the variants per chromosome.


### Step 3: Compute PBS for the Final VCF File

Set up the environment and compute PBS values.


## Usage

Edit the script to activate the desired steps by setting the corresponding variables to "TRUE".
Submit the script to the SLURM scheduler.

    sbatch script_name.sh

## Notes

- Ensure all required modules and dependencies are loaded and installed.
- Modify paths and filenames as needed.
- Monitor the job outputs for any errors or required adjustments.
