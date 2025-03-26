# import requests
# import json

# def test_similarity_api():
#     url = "http://127.0.0.1:5000/similarity"
#     sample_sequences = [
#         "AGCTAGCTAG",
#         "AGCTTGCTAG",
#         "AGCTAGGTAG"
#     ]
    
#     payload = {"sequences": sample_sequences}
#     headers = {'Content-Type': 'application/json'}
    
#     response = requests.post(url, data=json.dumps(payload), headers=headers)
    
#     if response.status_code == 200:
#         print("Similarity Matrix:")
#         print(json.dumps(response.json(), indent=4))
#     else:
#         print("Error:", response.text)

# if __name__ == "__main__":
#     test_similarity_api()

from Bio import pairwise2
from Bio.pairwise2 import format_alignment

def calculate_identity(seq1, seq2):
    # Perform global alignment (Needleman-Wunsch algorithm)
    alignments = pairwise2.align.globalxx(seq1, seq2)

    # Take the best alignment (highest score)
    best_alignment = alignments[0]

    # Extract aligned sequences
    aligned_seq1, aligned_seq2, score, start, end = best_alignment

    # Calculate identity percentage
    matches = sum(1 for a, b in zip(aligned_seq1, aligned_seq2) if a == b)
    identity_percentage = (matches / len(aligned_seq1)) * 100

    return identity_percentage, best_alignment

# Example protein sequences
seq1 = "MKTLLILFLISLLLTLQS"
seq2 = "MKTLLILFLLSLLLTLES"

identity, alignment = calculate_identity(seq1, seq2)
print(f"Percentage Identity: {identity:.2f}%")
print(format_alignment(*alignment))
