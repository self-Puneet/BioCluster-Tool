import 'dart:convert';
import 'dart:html' as html;
import 'package:excel/excel.dart' as excel_pkg;
import 'package:csv/csv.dart';
import '../models/cluster_result.dart';

/// Service for exporting cluster results in various formats
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  /// Export clusters as TXT file
  Future<void> exportAsTxt({
    required ClusterResult result,
    required Map<String, String> originalSequences,
  }) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('BioCluster Analysis Results');
      buffer.writeln('=' * 50);
      buffer.writeln('Number of Clusters: ${result.numberOfClusters}');
      buffer.writeln('Total Sequences: ${result.labels.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      result.clusters.forEach((clusterName, sequenceNames) {
        buffer.writeln('$clusterName:');
        buffer.writeln('-' * 40);
        for (var seqName in sequenceNames) {
          final sequence = originalSequences[seqName] ?? 'N/A';
          buffer.writeln('  Name: $seqName');
          buffer.writeln('  Sequence: $sequence');
          buffer.writeln();
        }
        buffer.writeln();
      });

      _downloadFile(buffer.toString(), 'biocluster_results.txt', 'text/plain');
    } catch (e) {
      throw Exception('Error exporting TXT: $e');
    }
  }

  /// Export clusters as CSV file
  Future<void> exportAsCsv({
    required ClusterResult result,
    required Map<String, String> originalSequences,
  }) async {
    try {
      List<List<dynamic>> rows = [];

      // Header
      rows.add(['Cluster', 'Sequence Name', 'Sequence']);

      // Data rows
      result.clusters.forEach((clusterName, sequenceNames) {
        for (var seqName in sequenceNames) {
          final sequence = originalSequences[seqName] ?? 'N/A';
          rows.add([clusterName, seqName, sequence]);
        }
      });

      final csvData = const ListToCsvConverter().convert(rows);
      _downloadFile(csvData, 'biocluster_results.csv', 'text/csv');
    } catch (e) {
      throw Exception('Error exporting CSV: $e');
    }
  }

  /// Export clusters as JSON file
  Future<void> exportAsJson({
    required ClusterResult result,
    required Map<String, String> originalSequences,
  }) async {
    try {
      final Map<String, dynamic> jsonData = {
        'metadata': {
          'number_of_clusters': result.numberOfClusters,
          'total_sequences': result.labels.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'clusters': result.clusters.map((clusterName, sequenceNames) {
          return MapEntry(
            clusterName,
            sequenceNames.map((seqName) {
              return {
                'name': seqName,
                'sequence': originalSequences[seqName] ?? 'N/A',
              };
            }).toList(),
          );
        }),
        'similarity_matrix': result.similarityMatrix,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      _downloadFile(jsonString, 'biocluster_results.json', 'application/json');
    } catch (e) {
      throw Exception('Error exporting JSON: $e');
    }
  }

  /// Export clusters as Excel file
  Future<void> exportAsExcel({
    required ClusterResult result,
    required Map<String, String> originalSequences,
  }) async {
    try {
      var excel = excel_pkg.Excel.createExcel();

      // Remove default sheet
      excel.delete('Sheet1');

      // Create Summary sheet
      var summarySheet = excel['Summary'];
      summarySheet.appendRow([
        excel_pkg.TextCellValue('BioCluster Analysis Results'),
      ]);
      summarySheet.appendRow([
        excel_pkg.TextCellValue('Number of Clusters'),
        excel_pkg.IntCellValue(result.numberOfClusters),
      ]);
      summarySheet.appendRow([
        excel_pkg.TextCellValue('Total Sequences'),
        excel_pkg.IntCellValue(result.labels.length),
      ]);
      summarySheet.appendRow([]);

      // Create Clusters sheet
      var clustersSheet = excel['Clusters'];
      clustersSheet.appendRow([
        excel_pkg.TextCellValue('Cluster'),
        excel_pkg.TextCellValue('Sequence Name'),
        excel_pkg.TextCellValue('Sequence'),
      ]);

      result.clusters.forEach((clusterName, sequenceNames) {
        for (var seqName in sequenceNames) {
          final sequence = originalSequences[seqName] ?? 'N/A';
          clustersSheet.appendRow([
            excel_pkg.TextCellValue(clusterName),
            excel_pkg.TextCellValue(seqName),
            excel_pkg.TextCellValue(sequence),
          ]);
        }
      });

      // Save and download
      final bytes = excel.encode();
      if (bytes != null) {
        final blob = html.Blob([
          bytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.document.createElement('a') as html.AnchorElement
              ..href = url
              ..style.display = 'none'
              ..download = 'biocluster_results.xlsx';
        html.document.body!.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      throw Exception('Error exporting Excel: $e');
    }
  }

  /// Helper method to download file in browser
  void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = filename;
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
