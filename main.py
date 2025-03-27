import matplotlib
matplotlib.use('Agg') 
import os
import io
import base64
import matplotlib.pyplot as plt
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
from Bio import pairwise2  # Import Biopython's pairwise2 module
import scipy.cluster.hierarchy as sch

def calculate_similarity(seq1, seq2):
    """Calculate similarity percentage between two sequences using global alignment."""
    # Perform global alignment with no gap penalties (globalxx)
    alignments = pairwise2.align.globalxx(seq1, seq2)
    best_alignment = alignments[0]
    aligned_seq1, aligned_seq2, score, start, end = best_alignment
    
    # Count the number of identical positions
    matches = sum(1 for a, b in zip(aligned_seq1, aligned_seq2) if a == b)
    return (matches / len(aligned_seq1)) * 100  # Return percentage identity

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
        return jsonify({"error": "Invalid input. Provide a list of sequences."}), 400
    matrix = generate_similarity_matrix(sequences)
    return jsonify({"similarity_matrix": matrix})

# @app.route('/dendrogram', methods=['POST'])
# def dendrogram():
#     """
#     This endpoint receives a JSON with a similarity matrix and keys,
#     performs hierarchical clustering, creates a dendrogram image,
#     and returns it as a base64 encoded string.
#     """
#     data = request.get_json()
#     matrix = data.get("similarity_matrix", None)
#     keys = data.get("keys", None)
#     print(matrix)
    
#     if matrix is None:
#         return jsonify({"error": "Missing similarity_matrix"}), 400
    
#     # Convert matrix to a NumPy array
#     np_matrix = np.array(matrix)
    
#     # Perform hierarchical clustering
#     linkage_matrix = sch.linkage(np_matrix, method='ward')
    
#     # Plot dendrogram
#     plt.figure(figsize=(8, 6))
#     sch.dendrogram(linkage_matrix, labels=keys, orientation='top', leaf_rotation=45)
#     plt.title("Hierarchical Clustering Dendrogram")
#     plt.xlabel("Samples")
#     plt.ylabel("Distance")
    
#     # Save plot to buffer
#     buf = io.BytesIO()
#     plt.savefig(buf, format='png', bbox_inches='tight', pad_inches=0.2)

#     plt.clf()  # Clears the figure to free memory
#     plt.close('all')  # Ensures all figures are closed
#     buf.seek(0)
#     image_base64 = base64.b64encode(buf.read()).decode('utf-8')
#     plt.close()
    
#     return jsonify({"dendrogram_image": image_base64})


# @app.route('/heatmap', methods=['POST'])
# def heatmap():
#     """
#     This endpoint receives a JSON with a similarity matrix and keys,
#     creates a heatmap image with the keys as x and y axis labels,
#     annotates each cell with its value, and returns it as a base64 encoded string.
#     """
#     data = request.get_json()
#     matrix = data.get("similarity_matrix", None)
#     keys = data.get("keys", None)
    
#     if matrix is None:
#         return jsonify({"error": "Missing similarity_matrix"}), 400

#     # Convert matrix to a NumPy array for plotting.
#     np_matrix = np.array(matrix)

#     plt.figure(figsize=(6, 6))
#     plt.imshow(np_matrix, cmap='plasma', interpolation='nearest')
#     plt.clim(0, 100)  # Set the color scale to range between 0 and 100.
#     plt.colorbar()
#     if keys is not None:
#         plt.xticks(range(len(keys)), keys, rotation=45)
#         plt.yticks(range(len(keys)), keys)
#     plt.title("Confusion Matrix")

#     buf = io.BytesIO()
#     plt.savefig(buf, format='png', bbox_inches='tight')
#     buf.seek(0)
#     image_base64 = base64.b64encode(buf.read()).decode('utf-8')
#     plt.close()

#     return jsonify({"heatmap_image": image_base64})
@app.route('/dendrogram', methods=['POST'])
def dendrogram():
    """
    Generates a dendrogram image and saves it in the 'generated_images' folder.
    """
    data = request.get_json()
    matrix = data.get("similarity_matrix", None)
    keys = data.get("keys", None)
    
    if matrix is None:
        return jsonify({"error": "Missing similarity_matrix"}), 400
    
    np_matrix = np.array(matrix)
    linkage_matrix = sch.linkage(np_matrix, method='ward')
    
    plt.figure(figsize=(8, 6))
    sch.dendrogram(linkage_matrix, labels=keys, orientation='top', leaf_rotation=45)
    plt.title("Hierarchical Clustering Dendrogram")
    plt.xlabel("Samples")
    plt.ylabel("Distance")

    # Save the image to the directory
    dendrogram_path = os.path.join("E:\BioCluster-Tool\images", "dendrogram.png")
    plt.savefig(dendrogram_path, format='png', bbox_inches='tight', pad_inches=0.2)
    
    plt.clf()
    plt.close('all')

    return jsonify({"message": "Dendrogram saved successfully", "path": dendrogram_path})

@app.route('/heatmap', methods=['POST'])
def heatmap():
    """
    Generates a heatmap image and saves it in the 'generated_images' folder.
    """
    data = request.get_json()
    matrix = data.get("similarity_matrix", None)
    keys = data.get("keys", None)

    if matrix is None:
        return jsonify({"error": "Missing similarity_matrix"}), 400

    np_matrix = np.array(matrix)

    plt.figure(figsize=(6, 6))
    plt.imshow(np_matrix, cmap='plasma', interpolation='nearest')
    plt.clim(0, 100)
    plt.colorbar()

    if keys is not None:
        plt.xticks(range(len(keys)), keys, rotation=45)
        plt.yticks(range(len(keys)), keys)
    
    plt.title("Confusion Matrix")

    # Save the image to the directory
    heatmap_path = os.path.join("E:\BioCluster-Tool\images", "heatmap.png")
    plt.savefig(heatmap_path, format='png', bbox_inches='tight')

    plt.clf()
    plt.close('all')

    return jsonify({"message": "Heatmap saved successfully", "path": heatmap_path})
from sklearn.cluster import AgglomerativeClustering

@app.route('/cluster', methods=['POST'])
def cluster():
    """
    This endpoint receives a confusion matrix (with percentage values), labels, 
    and the number of clusters, then applies hierarchical clustering and returns 
    a dictionary of clusters.
    """
    data = request.get_json()
    matrix = data.get("confusion_matrix", None)
    labels = data.get("labels", None)
    num_clusters = data.get("num_clusters", None)

    print(data, matrix, labels, num_clusters)

    # Validate inputs
    if matrix is None or labels is None or num_clusters is None:
        return jsonify({"error": "Missing confusion_matrix, labels, or num_clusters"}), 400
    if len(matrix) != len(labels):
        return jsonify({"error": "Matrix size does not match label count"}), 400
    if num_clusters < 1 or num_clusters > len(labels):
        return jsonify({"error": "Invalid number of clusters"}), 400

    # Convert matrix to a NumPy array and normalize it (assuming values are in percentage)
    np_matrix = np.array(matrix) / 100.0

    # Convert normalized similarity matrix to a distance matrix
    dist_matrix = 1 - np_matrix

    # Perform hierarchical clustering
    clustering = AgglomerativeClustering(n_clusters=num_clusters, metric='precomputed', linkage='average')
    cluster_labels = clustering.fit_predict(dist_matrix)

    # Organize clusters into dictionary
    cluster_dict = {}
    for i, cluster in enumerate(cluster_labels):
        cluster_name = f"cluster{cluster + 1}"
        if cluster_name not in cluster_dict:
            cluster_dict[cluster_name] = []
        cluster_dict[cluster_name].append(labels[i])
    print(cluster_dict)
    return jsonify(cluster_dict)

if __name__ == '__main__':
    app.run(debug=True)