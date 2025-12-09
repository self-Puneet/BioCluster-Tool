import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/cluster_result.dart';

/// Service class for API interactions
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Fetches similarity matrix from the API
  Future<List<List<double>>> getSimilarityMatrix(List<String> sequences) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.apiUrl}/similarity'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'sequences': sequences}),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['similarity_matrix'] as List)
            .map(
              (row) => (row as List).map((e) => (e as num).toDouble()).toList(),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch similarity matrix: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching similarity matrix: $e');
    }
  }

  /// Fetches cluster results from the API
  Future<Map<String, List<String>>> getClusters({
    required List<List<double>> similarityMatrix,
    required List<String> labels,
    required int numberOfClusters,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.apiUrl}/cluster'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'confusion_matrix': similarityMatrix,
              'labels': labels,
              'num_clusters': numberOfClusters,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> rawClusters = jsonDecode(response.body);
        final Map<String, List<String>> clusters = {};
        rawClusters.forEach((key, value) {
          clusters[key] = List<String>.from(value);
        });
        return clusters;
      } else {
        throw Exception('Failed to fetch clusters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching clusters: $e');
    }
  }

  /// Performs complete analysis: similarity matrix + clustering
  Future<ClusterResult> performAnalysis({
    required Map<String, String> sequences,
    required int numberOfClusters,
  }) async {
    try {
      final labels = sequences.keys.toList();
      final sequenceValues = sequences.values.toList();

      // Step 1: Get similarity matrix
      final similarityMatrix = await getSimilarityMatrix(sequenceValues);

      // Step 2: Get clusters
      final clusters = await getClusters(
        similarityMatrix: similarityMatrix,
        labels: labels,
        numberOfClusters: numberOfClusters,
      );

      return ClusterResult(
        clusters: clusters,
        similarityMatrix: similarityMatrix,
        labels: labels,
        numberOfClusters: numberOfClusters,
      );
    } catch (e) {
      throw Exception('Error performing analysis: $e');
    }
  }
}
