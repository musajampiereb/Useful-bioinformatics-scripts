#!/bin/bash

# Function to print usage instructions
usage() {
    echo "Usage: $0 -v <vcf_file> -d <depth_file> -o <output_file> -n <output_name> -dp <min_depth> -r <reference_genome>"
    exit 1
}

# Default values
minDepth=30

# Parse command-line arguments
while getopts ":v:d:o:n:dp:r:" opt; do
    case "${opt}" in
        v)
            vcffile=${OPTARG}
            ;;
        d)
            depthfile=${OPTARG}
            ;;
        o)
            outfile=${OPTARG}
            ;;
        n)
            outname=${OPTARG}
            ;;
        dp)
            minDepth=${OPTARG}
            ;;
        r)
            reference=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

# Check for required arguments
if [ -z "${vcffile}" ] || [ -z "${depthfile}" ] || [ -z "${outfile}" ] || [ -z "${outname}" ] || [ -z "${reference}" ]; then
    usage
fi

# Create a dictionary of variants
declare -A variant_dict
while read -r line; do
    # Extract position, reference, and alternative alleles
    pos=$(echo "$line" | cut -f2)
    ref=$(echo "$line" | cut -f4)
    alt=$(echo "$line" | cut -f5)
    variant_dict[$pos]="$ref,$alt"
done < <(bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' "$vcffile")

# Create a set of depth failures
declare -A depth_failures
while read -r line; do
    # Extract position and depth
    pos=$(echo "$line" | cut -f2)
    dp=$(echo "$line" | cut -f3)

    # Check if depth is below the minimum threshold
    if [ "$dp" -lt "$minDepth" ]; then
        depth_failures[$pos]=1
    fi
done < "$depthfile"

# Read the reference sequence
reference_seq=$(awk '/^>/ {if (seq) print seq; seq=""; next} {seq=seq$0} END {print seq}' "$reference")

# Generate consensus sequence
consensus=""
for (( pos=1; pos<=${#reference_seq}; pos++ )); do
    # Check for depth failures
    if [ "${depth_failures[$pos]}" ]; then
        consensus+="N"
    # Check for variant at the current position
    elif [ "${variant_dict[$pos]}" ]; then
        IFS=',' read -r ref alt <<< "${variant_dict[$pos]}"
        consensus+="$alt"
        # Handle deletion by skipping over deleted bases in the reference
        ref_len=${#ref}
        alt_len=${#alt}
        if [ "$ref_len" -gt "$alt_len" ]; then
            ((pos+=ref_len-alt_len))
        fi
    else
        # No variant, add reference base
        consensus+=${reference_seq:pos-1:1}
    fi
done

# Write the consensus sequence to the output file
echo ">${outname}" > "$outfile"
echo "$consensus" >> "$outfile"

echo "Consensus sequence written to ${outfile}"
