import os
import re
import gzip

# Function to concatenate gzipped fastq files into a properly gzipped output
def concatenate_files(file_list, output_file):
    with gzip.open(output_file, 'wb') as outfile:
        for filename in file_list:
            with gzip.open(filename, 'rb') as infile:
                outfile.write(infile.read())  # Append the contents properly
    print(f"Concatenated into {output_file}")

# Directory containing the fastq files
fastq_dir = "/Volumes/Biospace/MVD_Rwanda_VSP/Fastq"

# Regular expression to capture sample, read direction (R1/R2), and lane information
fastq_pattern = re.compile(r"^(Sample\d+_S\d+)_L\d{3}_(R\d)_\d{3}\.fastq\.gz$")

# Dictionary to store files by sample and read direction
samples = {}

# Walk through the directory and collect files
for filename in os.listdir(fastq_dir):
    if filename.endswith(".fastq.gz"):
        match = fastq_pattern.match(filename)
        if match:
            sample = match.group(1)  # e.g., "Sample001_S1"
            read_direction = match.group(2)  # "R1" or "R2"
            
            # Add the file to the appropriate sample and read direction list
            if sample not in samples:
                samples[sample] = {"R1": [], "R2": []}
            samples[sample][read_direction].append(os.path.join(fastq_dir, filename))

# Concatenate files for each sample
for sample, reads in samples.items():
    for read_direction, file_list in reads.items():
        if file_list:
            output_file = f"{sample}_{read_direction}_combined.fastq.gz"
            concatenate_files(file_list, output_file)
