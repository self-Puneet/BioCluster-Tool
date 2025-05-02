from flask import Blueprint, request, jsonify
from utils.sequence_tools import generate_similarity_matrix
similarity_bp = Blueprint('similarity', __name__)

@similarity_bp.route('/similarity', methods=['POST'])
def similarity():
    data = request.get_json()
    sequences = data.get("sequences", [])
    if not sequences or not all(isinstance(seq, str) for seq in sequences):
        return jsonify({"error": "Invalid input. Provide a list of sequences."}), 400
    matrix = generate_similarity_matrix(sequences)
    return jsonify({"similarity_matrix": matrix})
