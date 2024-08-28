import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from Bio import AlignIO
from collections import defaultdict

# Function to identify mutations in a multiple sequence alignment
def identify_mutations(alignment):
    reference_seq = str(alignment[0].seq).upper()  # Reference sequence
    mutation_data = []
    context_count = defaultdict(int)
    apobec3_mutations = defaultdict(int)

    mutation_signatures = {
        "C>T": 0,
        "G>A": 0,
        "A>G": 0,
        "T>C": 0,
        "C>A": 0,
        "G>T": 0,
        "A>C": 0,
        "T>G": 0,
        "C>G": 0,
        "G>C": 0,
        "A>T": 0,
        "T>A": 0
    }

    for record in alignment[1:]:  # Skip the reference sequence
        aligned_seq = str(record.seq).upper()  # Aligned sequence
        genome_signature_counts = mutation_signatures.copy()
        mutation_count = 0
        apobec3_count = 0

        for i in range(len(reference_seq)):  # Loop through all positions
            ref_base = reference_seq[i]
            seq_base = aligned_seq[i]

            # Skip if either the reference or aligned base is a gap or 'N', or if the bases are identical
            if ref_base == "-" or seq_base == "-" or ref_base == "N" or seq_base == "N" or ref_base == seq_base:
                continue

            mutation_count += 1
            mutation_type = f"{ref_base}>{seq_base}"

            if mutation_type in genome_signature_counts:
                genome_signature_counts[mutation_type] += 1

            if mutation_type == "C>T" or mutation_type == "G>A":
                apobec3_count += 1

        mutation_data.append({
            "Genome ID": record.id,
            "Total Mutations": mutation_count,
            "APOBEC3 Mutations": apobec3_count,
            "Mutation Signatures": genome_signature_counts
        })

        # Debugging: Print mutation information
        print(f"Genome {record.id}: {mutation_count} mutations identified")

    return mutation_data

# Load the multiple sequence alignment file
alignment_file = "mpox_msa.fasta"
alignment = AlignIO.read(alignment_file, "fasta")

# Debugging: Check the number of sequences and lengths
print(f"Loaded alignment with {len(alignment)} sequences")
print(f"Reference sequence length: {len(alignment[0].seq)}")

# Identify mutations and mutation signatures
mutation_data = identify_mutations(alignment)

# Convert mutation data to a DataFrame for analysis
df = pd.DataFrame(mutation_data)

# Calculate percentage of APOBEC3 mutations
df['APOBEC3 Percentage'] = df['APOBEC3 Mutations'] / df['Total Mutations'] * 100

# Save mutation data to a CSV file
df.to_csv("apobec3_mutation_analysis_msa.csv", index=False)

# Plot the total number of mutations across all genomes
plt.figure(figsize=(14, 8))
sns.barplot(x='Genome ID', y='Total Mutations', data=df, palette='coolwarm')
plt.title('Total Number of Mutations in Each MPOX Genome', fontsize=16)
plt.xlabel('Genome ID', fontsize=14)
plt.ylabel('Total Mutations', fontsize=14)
plt.xticks(rotation=45, ha='right', fontsize=12)
plt.yticks(fontsize=12)
plt.grid(True)
plt.tight_layout()
plt.show()

# Plot the percentage of APOBEC3 mutations compared to all mutations across genomes
plt.figure(figsize=(14, 8))
sns.barplot(x='Genome ID', y='APOBEC3 Percentage', data=df, palette='plasma')
plt.title('Percentage of APOBEC3-Induced Mutations in MPOX Genomes', fontsize=16)
plt.xlabel('Genome ID', fontsize=14)
plt.ylabel('APOBEC3 Mutation Percentage', fontsize=14)
plt.xticks(rotation=45, ha='right', fontsize=12)
plt.yticks(fontsize=12)
plt.grid(True)
plt.tight_layout()
plt.show()

# Plot the overall mutation signature distribution
plt.figure(figsize=(14, 8))
mutation_signatures_df = pd.DataFrame(df['Mutation Signatures'].tolist(), index=df['Genome ID'])
mutation_signatures_df = mutation_signatures_df.mean().sort_values(ascending=False)
sns.barplot(x=mutation_signatures_df.index, y=mutation_signatures_df.values, palette='magma')
plt.title('Average Mutation Signatures Across MPOX Genomes', fontsize=16)
plt.xlabel('Mutation Signature', fontsize=14)
plt.ylabel('Average Count', fontsize=14)
plt.xticks(rotation=45, ha='right', fontsize=12)
plt.yticks(fontsize=12)
plt.grid(True)
plt.tight_layout()
plt.show()



