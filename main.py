import io
import base64
import matplotlib.pyplot as plt
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS

def calculate_similarity(seq1, seq2):
    """Calculate similarity percentage between two sequences."""
    if len(seq1) != len(seq2):
        return 0.0  # For simplicity, return 0% if lengths mismatch
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
CORS(app)  # Enable CORS for all routes

@app.route('/similarity', methods=['POST'])
def similarity():
    """API endpoint to compute similarity matrix."""
    data = request.get_json()
    sequences = data.get("sequences", [])
    if not sequences or not all(isinstance(seq, str) for seq in sequences):
        return jsonify({"error": "Invalid input. Provide a list of nucleotide sequences."}), 400
    matrix = generate_similarity_matrix(sequences)
    return jsonify({"similarity_matrix": matrix})
@app.route('/heatmap', methods=['POST'])
def heatmap():
    """
    This endpoint receives a JSON with a similarity matrix and keys,
    creates a heatmap image with the keys as x and y axis labels, 
    and returns it as a base64 encoded string.
    """
    data = request.get_json()
    matrix = data.get("similarity_matrix", None)
    keys = data.get("keys", None)
    
    if matrix is None:
        return jsonify({"error": "Missing similarity_matrix"}), 400

    # Convert matrix to a NumPy array for plotting.
    np_matrix = np.array(matrix)

    plt.figure(figsize=(6, 6))
    plt.imshow(np_matrix, cmap='hot', interpolation='nearest')
    plt.colorbar()
    if keys is not None:
        plt.xticks(range(len(keys)), keys, rotation=45)
        plt.yticks(range(len(keys)), keys)
    plt.title("Heatmap")

    # Save the plot to a BytesIO buffer.
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    image_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close()

    return jsonify({"heatmap_image": image_base64})
    
if __name__ == '__main__':
    app.run(debug=True)
