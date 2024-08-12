#!/bin/bash

# Usage function to display help
usage() {
    echo "Usage: $0 -b <bam_file> -o <output_file> -c <cores> -d <mindepth> -af <minAF> -r <reference> [--debug]"
    exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--bam) BAM_FILE="$2"; shift ;;
        -o|--out) OUTPUT_FILE="$2"; shift ;;
        -c|--cores) CORES="$2"; shift ;;
        -d|--mindepth) MIN_DEPTH="$2"; shift ;;
        -af|--minAF) MIN_AF="$2"; shift ;;
        -r|--reference) REFERENCE="$2"; shift ;;
        --debug) DEBUG=true ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check for mandatory arguments
if [[ -z "$BAM_FILE" || -z "$OUTPUT_FILE" || -z "$REFERENCE" ]]; then
    usage
fi

# Set default values for optional parameters
CORES=${CORES:-1}
MIN_DEPTH=${MIN_DEPTH:-10}
MIN_AF=${MIN_AF:-0.01}

# Index the BAM file if index doesn't exist
if [[ ! -f "${BAM_FILE}.bai" ]]; then
    echo "Indexing BAM file..."
    samtools index "$BAM_FILE"
fi

# Generate VCF using bcftools mpileup and call
echo "Generating BCF file..."
bcftools mpileup -f "$REFERENCE" -Ou "$BAM_FILE" | \
    bcftools call -mv -Ou | \
    bcftools filter -e "DP<$MIN_DEPTH || FMT/AF<$MIN_AF" -Ov > "$OUTPUT_FILE"

# Optionally print debug information
if [[ "$DEBUG" == true ]]; then
    echo "Debugging Information:"
    echo "BAM file: $BAM_FILE"
    echo "Reference: $REFERENCE"
    echo "Output: $OUTPUT_FILE"
    echo "Cores: $CORES"
    echo "Min Depth: $MIN_DEPTH"
    echo "Min AF: $MIN_AF"
fi

echo "VCF generation completed: $OUTPUT_FILE"
