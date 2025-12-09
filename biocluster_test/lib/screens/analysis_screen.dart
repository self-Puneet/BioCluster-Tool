import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';
import '../models/cluster_result.dart';
import '../utils/constants.dart';
import '../app_theme.dart';

/// Analysis screen for clustering and viewing results
class AnalysisScreen extends StatefulWidget {
  final Map<String, String> sequences;

  const AnalysisScreen({Key? key, required this.sequences}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ApiService _apiService = ApiService();
  final ExportService _exportService = ExportService();
  final TextEditingController _clusterController = TextEditingController();

  ClusterResult? _result;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedClusterCount = AppConstants.defaultClusterCount;

  @override
  void initState() {
    super.initState();
    _clusterController.text = _selectedClusterCount.toString();
    _performAnalysis();
  }

  @override
  void dispose() {
    _clusterController.dispose();
    super.dispose();
  }

  Future<void> _performAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.performAnalysis(
        sequences: widget.sequences,
        numberOfClusters: _selectedClusterCount,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateClusterCount() {
    final parsed = int.tryParse(_clusterController.text);
    if (parsed == null ||
        parsed < AppConstants.minClusterCount ||
        parsed > widget.sequences.length) {
      _showError(
        'Please enter a valid number between ${AppConstants.minClusterCount} and ${widget.sequences.length}',
      );
      return;
    }

    setState(() {
      _selectedClusterCount = parsed;
    });
    _performAnalysis();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportResults(String format) async {
    if (_result == null) return;

    setState(() => _isLoading = true);

    try {
      switch (format) {
        case 'TXT':
          await _exportService.exportAsTxt(
            result: _result!,
            originalSequences: widget.sequences,
          );
          break;
        case 'CSV':
          await _exportService.exportAsCsv(
            result: _result!,
            originalSequences: widget.sequences,
          );
          break;
        case 'JSON':
          await _exportService.exportAsJson(
            result: _result!,
            originalSequences: widget.sequences,
          );
          break;
        case 'Excel':
          await _exportService.exportAsExcel(
            result: _result!,
            originalSequences: widget.sequences,
          );
          break;
      }
      _showSuccess('Results exported successfully as $format');
    } catch (e) {
      _showError('Error exporting results: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  AppConstants.supportedExportFormats.map((format) {
                    return ListTile(
                      leading: Icon(
                        _getFormatIcon(format),
                        color: AppTheme.primaryLight,
                      ),
                      title: Text(format),
                      onTap: () {
                        Navigator.pop(context);
                        _exportResults(format);
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'TXT':
        return Icons.text_snippet;
      case 'CSV':
        return Icons.table_chart;
      case 'JSON':
        return Icons.code;
      case 'Excel':
        return Icons.table_view;
      default:
        return Icons.file_download;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Cluster Analysis',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.download, color: AppTheme.primaryLight),
              onPressed: _showExportDialog,
              tooltip: 'Export Results',
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: AppConstants.processingMessage,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Statistics Cards
                  FadeInDown(
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoCard(
                            icon: Icons.science,
                            title: 'Total Sequences',
                            value: '${widget.sequences.length}',
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InfoCard(
                            icon: Icons.category,
                            title: 'Clusters',
                            value: '$_selectedClusterCount',
                            color: AppTheme.secondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cluster Control Card
                  FadeInUp(
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cluster Configuration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _clusterController,
                                  decoration: InputDecoration(
                                    labelText: 'Number of Clusters',
                                    hintText: 'Enter cluster count',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primaryLight,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.category_outlined,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              PrimaryButton(
                                text: 'Update',
                                icon: Icons.refresh,
                                onPressed: _updateClusterCount,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Range: ${AppConstants.minClusterCount} - ${widget.sequences.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null)
                    FadeInUp(
                      child: CustomCard(
                        color: Colors.red[50],
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Results Section
                  if (_result != null) ...[
                    FadeInUp(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cluster Results',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SecondaryButton(
                            text: 'Export',
                            icon: Icons.download,
                            onPressed: _showExportDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildClusterCards(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildClusterCards() {
    if (_result == null) return [];

    List<Widget> cards = [];
    int index = 0;

    _result!.clusters.forEach((clusterName, sequenceNames) {
      cards.add(
        FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ClusterCard(
              clusterName: clusterName,
              sequences: sequenceNames,
              originalSequences: widget.sequences,
              clusterIndex: index,
            ),
          ),
        ),
      );
      index++;
    });

    return cards;
  }
}

class _ClusterCard extends StatefulWidget {
  final String clusterName;
  final List<String> sequences;
  final Map<String, String> originalSequences;
  final int clusterIndex;

  const _ClusterCard({
    required this.clusterName,
    required this.sequences,
    required this.originalSequences,
    required this.clusterIndex,
  });

  @override
  State<_ClusterCard> createState() => _ClusterCardState();
}

class _ClusterCardState extends State<_ClusterCard> {
  bool _isExpanded = true;

  final List<Color> _clusterColors = [
    const Color(0xFFFB8705),
    const Color(0xFF1565C0),
    const Color(0xFF4CAF50),
    const Color(0xFF9C27B0),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFFFF5722),
    const Color(0xFF607D8B),
  ];

  Color get _clusterColor =>
      _clusterColors[widget.clusterIndex % _clusterColors.length];

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _clusterColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.clusterIndex + 1}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _clusterColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clusterName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.sequences.length} sequences',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...widget.sequences.map((seqName) {
              final sequence = widget.originalSequences[seqName] ?? 'N/A';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _clusterColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seqName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sequence,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
