import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from Bio import AlignIO
from collections import defaultdict

# Function to get the trinucleotide context
def get_context(sequence, position):
    if position <= 0 or position >= len(sequence) - 2:
        return None  # Avoid context extraction at the boundaries
    return sequence[position-1:position+2]

# Function to identify APOBEC3-induced mutations in a multiple sequence alignment
def identify_apobec3_mutations(alignment):
    reference_seq = str(alignment[0].seq)  # Assuming the first sequence is the reference
    mutation_data = []
    context_count = defaultdict(int)

    for record in alignment[1:]:  # Skip the reference sequence
        mutations = []
        aligned_seq = str(record.seq)

        for i in range(1, len(reference_seq) - 1):  # Avoid first and last base
            ref_base = reference_seq[i]
            seq_base = aligned_seq[i]

            # Skip if the reference or aligned base is a gap
            if ref_base == "-" or seq_base == "-":
                continue

            # Check for APOBEC3-induced mutations (C->T and G->A)
            if (ref_base == "c" and seq_base == "t") or (ref_base == "g" and seq_base == "a"):
                context = get_context(aligned_seq, i)
                mutations.append((i, ref_base, seq_base, context))
                if context:
                    context_count[context] += 1

        mutation_data.append({
            "Genome ID": record.id,
            "Total Mutations": len(mutations),
            "Mutations": mutations
        })

        # Debugging: Print mutation information
        print(f"Genome {record.id}: {len(mutations)} mutations identified")

    return mutation_data, context_count

# Load the multiple sequence alignment file
alignment_file = "mpox_msa.fasta"
alignment = AlignIO.read(alignment_file, "fasta")

# Debugging: Check the number of sequences and lengths
print(f"Loaded alignment with {len(alignment)} sequences")
print(f"Reference sequence length: {len(alignment[0].seq)}")

# Identify APOBEC3-induced mutations
mutation_data, context_count = identify_apobec3_mutations(alignment)

# Convert mutation data to a DataFrame for analysis
df = pd.DataFrame(mutation_data)

# Save mutation data to a CSV file
df.to_csv("apobec3_mutation_analysis_msa.csv", index=False)

# Analysis of mutation contexts
context_df = pd.DataFrame(list(context_count.items()), columns=["Context", "Count"])
context_df = context_df.sort_values(by="Count", ascending=False)

# Plot the distribution of mutations across genomes
for genome_data in mutation_data:
    genome_id = genome_data['Genome ID']
    mutation_positions = [m[0] for m in genome_data['Mutations']]

    plt.figure(figsize=(10, 4))
    sns.histplot(mutation_positions, bins=50, kde=False, color='blue')
    plt.title(f"Mutation Distribution in Genome: {genome_id}")
    plt.xlabel("Genome Position")
    plt.ylabel("Mutation Count")
    plt.grid(True)
    plt.show()

# Plot the mutation context distribution
plt.figure(figsize=(10, 6))
sns.barplot(x='Context', y='Count', data=context_df.head(10), palette='viridis')
plt.title('Top 10 Mutation Contexts in MPOX Genomes')
plt.xlabel('Trinucleotide Context')
plt.ylabel('Count')
plt.xticks(rotation=45)
plt.grid(True)
plt.show()
