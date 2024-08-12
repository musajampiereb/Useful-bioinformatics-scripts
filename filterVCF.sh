#!/bin/bash

# Function to print usage instructions
usage() {
    echo "Usage: $0 -i <input_vcf> -o <output_vcf> [-af <min_allele_frequency>]"
    exit 1
}

# Default values
minAF=0.25

# Parse command-line arguments
while getopts ":i:o:af:" opt; do
    case "${opt}" in
        i)
            infile=${OPTARG}
            ;;
        o)
            outfile=${OPTARG}
            ;;
        af)
            minAF=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

# Check for required arguments
if [ -z "${infile}" ] || [ -z "${outfile}" ]; then
    usage
fi

# Create temporary files
header_file=$(mktemp)
temp_vcf=$(mktemp)

# Extract header from input VCF file
bcftools view -h "${infile}" > "${header_file}"

# Process VCF file and apply filters
bcftools view -H "${infile}" | awk -v minAF="${minAF}" '
{
    split($8, info, ";")
    major = 0
    af = 0.0
    indel_len = 0
    ref_len = length($4)
    alt_len = length($5)
    for (i in info) {
        split(info[i], kv, "=")
        if (kv[1] == "MAJOR") major = kv[2]
        if (kv[1] == "AF") af = kv[2]
    }
    indel_len = ref_len - alt_len

    if (major == 1 && af >= minAF && !(indel_len in [1,2])) {
        print
    }
}' > "${temp_vcf}"

# Combine header and filtered VCF data
cat "${header_file}" "${temp_vcf}" > "${outfile}"

# Clean up temporary files
rm -f "${header_file}" "${temp_vcf}"

echo "Filtered VCF file written to ${outfile}"
