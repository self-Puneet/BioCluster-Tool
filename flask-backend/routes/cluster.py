from flask import Blueprint, request, jsonify
import numpy as np
from sklearn.cluster import AgglomerativeClustering

cluster_bp = Blueprint('cluster', __name__)

@cluster_bp.route('/cluster', methods=['POST'])
def cluster():
    data = request.get_json()
    matrix = data.get("confusion_matrix", None)
    labels = data.get("labels", None)
    num_clusters = data.get("num_clusters", None)

    if matrix is None or labels is None or num_clusters is None:
        return jsonify({"error": "Missing confusion_matrix, labels, or num_clusters"}), 400
    if len(matrix) != len(labels):
        return jsonify({"error": "Matrix size does not match label count"}), 400
    if num_clusters < 1 or num_clusters > len(labels):
        return jsonify({"error": "Invalid number of clusters"}), 400

    np_matrix = np.array(matrix) / 100.0
    dist_matrix = 1 - np_matrix

    clustering = AgglomerativeClustering(n_clusters=num_clusters, metric='precomputed', linkage='average')
    cluster_labels = clustering.fit_predict(dist_matrix)

    cluster_dict = {}
    for i, cluster in enumerate(cluster_labels):
        cluster_name = f"cluster{cluster + 1}"
        cluster_dict.setdefault(cluster_name, []).append(labels[i])
    return jsonify(cluster_dict)
