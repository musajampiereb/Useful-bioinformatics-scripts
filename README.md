These shell scripts are designed to facilitate the conversion of genomic data from BAM and VCF files into VCF files and consensus sequences. They are useful for researchers working with next-generation sequencing data who need to generate variant calls and consensus sequences.

Scripts Overview
BAM to VCF Conversion Script

Converts a BAM file to a VCF file using bcftools.
Ensures the BAM file is indexed before proceeding.
Outputs a VCF file with identified variants.
VCF to Consensus Sequence Script

Generates a consensus sequence from a VCF file and a depth file.
Uses a reference genome to ensure accurate consensus building.
Supports filtering based on minimum depth and outputs the consensus sequence in FASTA format.
Requirements
bcftools: Required for processing BAM and VCF files.
samtools: Used for generating depth information from BAM files.
Shell environment (e.g., bash).
Usage
BAM to VCF Conversion Script
bash
Copy code
./bam_to_vcf.sh -b <input_bam_file> -r <reference_genome> -o <output_vcf_file>
Arguments:

-b, --bam: Path to the input BAM file.
-r, --reference: Path to the reference genome in FASTA format.
-o, --output: Path to the output VCF file.
Example:

bash
Copy code
./bam_to_vcf.sh -b sample.bam -r reference.fasta -o output.vcf
VCF to Consensus Sequence Script
bash
Copy code
./vcf_to_consensus.sh -v <vcf_file> -d <depth_file> -o <output_file> -n <output_name> -dp <min_depth> -r <reference>
Arguments:

-v, --vcffile: Path to the VCF file.
-d, --depthfile: Path to the depth file generated by samtools depth.
-o, --outfile: Path to the output consensus FASTA file.
-n, --outname: Name to be assigned to the output consensus sequence.
-dp, --mindepth: Minimum depth threshold for considering alleles (default: 30).
-r, --reference: Path to the reference genome in FASTA format.

Example:

bash
Copy code
./vcf_to_consensus.sh -v variants.vcf -d depth.tsv -o consensus.fasta -n "SampleConsensus" -dp 30 -r reference.fasta
Output
The BAM to VCF script outputs a VCF file containing variant calls.
The VCF to Consensus script outputs a FASTA file containing the consensus sequence, with regions of low coverage marked with 'N'.
Notes
Ensure that the BAM file is sorted and indexed before running the BAM to VCF script.
The VCF to Consensus script assumes a single reference sequence and processes it in its entirety. Adjustments may be needed for multi-contig references.
The bcftools and samtools utilities must be installed and accessible in your system's PATH.
Troubleshooting
Ensure all input files are correctly formatted and paths are specified correctly.
Verify that bcftools and samtools are installed and accessible.
For questions or issues, please contact the script author or maintainer.
