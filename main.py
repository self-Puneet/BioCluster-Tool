from flask import Flask, request, jsonify
from itertools import combinations

def calculate_similarity(seq1, seq2):
    """Calculate similarity percentage between two sequences."""
    if len(seq1) != len(seq2):
        return 0.0  # For simplicity, we return 0% if lengths mismatch
    
    matches = sum(1 for a, b in zip(seq1, seq2) if a == b)
    return (matches / len(seq1)) * 100


def generate_similarity_matrix(sequences):
    """Generate an n*n similarity matrix from a list of sequences."""
    n = len(sequences)
    matrix = [[0] * n for _ in range(n)]
    
    for i in range(n):
        for j in range(n):
            matrix[i][j] = calculate_similarity(sequences[i], sequences[j])
    
    return matrix

app = Flask(__name__)

@app.route('/similarity', methods=['POST'])
def similarity():
    """API endpoint to compute similarity matrix."""
    data = request.get_json()
    sequences = data.get("sequences", [])
    
    if not sequences or not all(isinstance(seq, str) for seq in sequences):
        return jsonify({"error": "Invalid input. Provide a list of nucleotide sequences."}), 400
    
    matrix = generate_similarity_matrix(sequences)
    return jsonify({"similarity_matrix": matrix})

if __name__ == '__main__':
    app.run(debug=True)