import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/file_upload_widget.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import 'sequence_editor_screen.dart';

/// Home screen - landing page with input options
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final TextEditingController _bulkTextController = TextEditingController();

  @override
  void dispose() {
    _bulkTextController.dispose();
    super.dispose();
  }

  Future<void> _handleFileUpload() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'fasta', 'fa', 'fas'],
      );

      if (result != null && result.files.single.bytes != null) {
        String fileContent = String.fromCharCodes(result.files.single.bytes!);

        // Parse the file content
        Map<String, String> sequences = SequenceValidator.parseInput(
          fileContent,
        );

        if (sequences.isEmpty) {
          _showError('No valid sequences found in the file.');
          return;
        }

        // Navigate to sequence editor with loaded data
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      SequenceEditorScreen(initialSequences: sequences),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error reading file: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleManualEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SequenceEditorScreen()),
    );
  }

  void _handleBulkTextUpload() {
    final text = _bulkTextController.text.trim();
    if (text.isEmpty) {
      _showError('Please enter sequence data.');
      return;
    }

    try {
      // Parse the bulk text
      Map<String, String> sequences = SequenceValidator.parseInput(text);

      if (sequences.isEmpty) {
        _showError('No valid sequences found in the text.');
        return;
      }

      // Navigate to sequence editor with loaded data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SequenceEditorScreen(initialSequences: sequences),
        ),
      );
    } catch (e) {
      _showError('Error parsing text: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'BioCluster Tool'),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Hero Section
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFB8705), Color(0xFFE65100)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFB8705).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.biotech,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome to BioCluster Tool',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Analyze and cluster biological sequences with ease',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Upload + Text input area (side by side with equal height)
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // File upload area
                        Expanded(
                          child: FileUploadWidget(
                            onUpload: _handleFileUpload,
                            isLoading: _isLoading,
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Bulk text input area
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFFB8705),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.text_fields,
                                        color: const Color(0xFFFB8705),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Paste Sequences',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _bulkTextController,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      hintText:
                                          'seq1 : ATCGATCG\nseq2 : GCTAGCTA\n...',
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
                                          color: Color(0xFFFB8705),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                  const SizedBox(height: 16),
                                  PrimaryButton(
                                    text: 'Proceed with Pasted Text',
                                    icon: Icons.check_circle_outline,
                                    onPressed:
                                        _bulkTextController.text.trim().isEmpty
                                            ? null
                                            : _handleBulkTextUpload,
                                    fullWidth: true,
                                  ),
                                  const SizedBox(height: 12),
                                  SecondaryButton(
                                    text: 'Enter Sequences Manually',
                                    icon: Icons.edit_note,
                                    onPressed:
                                        _bulkTextController.text
                                                .trim()
                                                .isNotEmpty
                                            ? null
                                            : _handleManualEntry,
                                    fullWidth: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
