/// Model class representing clustering results
class ClusterResult {
  final Map<String, List<String>> clusters;
  final List<List<double>> similarityMatrix;
  final List<String> labels;
  final int numberOfClusters;

  ClusterResult({
    required this.clusters,
    required this.similarityMatrix,
    required this.labels,
    required this.numberOfClusters,
  });

  Map<String, dynamic> toJson() {
    return {
      'clusters': clusters,
      'similarity_matrix': similarityMatrix,
      'labels': labels,
      'number_of_clusters': numberOfClusters,
    };
  }

  factory ClusterResult.fromJson(Map<String, dynamic> json) {
    return ClusterResult(
      clusters: Map<String, List<String>>.from(
        json['clusters'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      similarityMatrix:
          (json['similarity_matrix'] as List)
              .map(
                (row) =>
                    (row as List).map((e) => (e as num).toDouble()).toList(),
              )
              .toList(),
      labels: List<String>.from(json['labels']),
      numberOfClusters: json['number_of_clusters'] as int,
    );
  }
}
