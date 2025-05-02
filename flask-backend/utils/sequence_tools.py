from Bio import pairwise2

def calculate_similarity(seq1, seq2):
    alignments = pairwise2.align.globalxx(seq1, seq2)
    best_alignment = alignments[0]
    aligned_seq1, aligned_seq2, _, _, _ = best_alignment
    matches = sum(1 for a, b in zip(aligned_seq1, aligned_seq2) if a == b)
    return (matches / len(aligned_seq1)) * 100

def generate_similarity_matrix(sequences):
    n = len(sequences)
    return [
        [calculate_similarity(sequences[i], sequences[j]) for j in range(n)]
        for i in range(n)
    ]
