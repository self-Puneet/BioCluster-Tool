import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../models/sequence_model.dart';
import 'package:dotted_border/dotted_border.dart';
import 'analysis_screen.dart';

/// Sequence editor screen for entering and validating sequences
class SequenceEditorScreen extends StatefulWidget {
  final Map<String, String>? initialSequences;

  const SequenceEditorScreen({Key? key, this.initialSequences})
    : super(key: key);

  @override
  State<SequenceEditorScreen> createState() => _SequenceEditorScreenState();
}

class _SequenceEditorScreenState extends State<SequenceEditorScreen> {
  final List<SequenceEntry> _sequences = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialSequences != null &&
        widget.initialSequences!.isNotEmpty) {
      int index = 1;
      widget.initialSequences!.forEach((name, sequence) {
        final type = SequenceValidator.validateSequence(sequence);
        _sequences.add(
          SequenceEntry(
            id: 'seq_${DateTime.now().millisecondsSinceEpoch}_$index',
            nameController: TextEditingController(text: name),
            sequenceController: TextEditingController(text: sequence),
            type: type,
          ),
        );
        index++;
      });
    } else {
      _addNewSequence();
    }
  }

  @override
  void dispose() {
    for (var entry in _sequences) {
      entry.nameController.dispose();
      entry.sequenceController.dispose();
    }
    super.dispose();
  }

  void _addNewSequence() {
    setState(() {
      _sequences.add(
        SequenceEntry(
          id: 'seq_${DateTime.now().millisecondsSinceEpoch}_${_sequences.length}',
          nameController: TextEditingController(),
          sequenceController: TextEditingController(),
        ),
      );
    });
  }

  void _removeSequence(int index) {
    if (_sequences.length > 1) {
      setState(() {
        _sequences[index].nameController.dispose();
        _sequences[index].sequenceController.dispose();
        _sequences.removeAt(index);
      });
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      // Check if all sequences are valid
      bool allValid = true;
      for (var entry in _sequences) {
        final type = SequenceValidator.validateSequence(
          entry.sequenceController.text,
        );
        if (type == SequenceType.unknown) {
          allValid = false;
          break;
        }
      }

      if (!allValid) {
        _showError('Please fix invalid sequences before proceeding.');
        return;
      }

      if (_sequences.isEmpty) {
        _showError('Please add at least one sequence.');
        return;
      }

      // Build sequences map
      Map<String, String> sequencesMap = {};
      for (var entry in _sequences) {
        final name = entry.nameController.text.trim();
        final sequence = entry.sequenceController.text.trim();
        if (name.isNotEmpty && sequence.isNotEmpty) {
          sequencesMap[name] = sequence;
        }
      }

      if (sequencesMap.isEmpty) {
        _showError('Please add at least one valid sequence.');
        return;
      }

      // Navigate to analysis screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(sequences: sequencesMap),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Edit Sequences',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  FadeInDown(
                    child: CustomCard(
                      color: const Color(0xFFFB8705).withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFFFB8705),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enter your biological sequences below. Each sequence must have a unique name.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sequences list (responsive 2-column grid)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final bool useGrid = screenWidth >= 900;

                      // Single column layout for all screens
                      List<Widget> children =
                          _sequences.asMap().entries.map((entry) {
                            int index = entry.key;
                            SequenceEntry seq = entry.value;

                            return FadeInUp(
                              key: ValueKey(seq.id),
                              duration: AppConstants.animationMedium,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SequenceCard(
                                  index: index,
                                  entry: seq,
                                  onRemove: () => _removeSequence(index),
                                  canRemove: _sequences.length > 1,
                                  onSequenceChanged: (text) {
                                    setState(() {
                                      seq.type =
                                          SequenceValidator.validateSequence(
                                            text,
                                          );
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList();

                      // Add the + button
                      children.add(
                        FadeInUp(
                          duration: AppConstants.animationMedium,
                          child: InkWell(
                            onTap: _addNewSequence,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFB8705,
                                ).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFB8705,
                                  ).withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFB8705),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Add New Sequence',
                                    style: TextStyle(
                                      color: Color(0xFFFB8705),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      return Column(children: children);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SecondaryButton(
                          text: 'Clear All',
                          icon: Icons.clear_all,
                          onPressed: () {
                            setState(() {
                              for (var entry in _sequences) {
                                entry.nameController.clear();
                                entry.sequenceController.clear();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        PrimaryButton(
                          text: 'Analyze Sequences',
                          icon: Icons.analytics,
                          onPressed: _validateAndProceed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SequenceEntry {
  final String id;
  final TextEditingController nameController;
  final TextEditingController sequenceController;
  SequenceType type;

  SequenceEntry({
    required this.id,
    required this.nameController,
    required this.sequenceController,
    this.type = SequenceType.unknown,
  });
}

class _SequenceCard extends StatelessWidget {
  final int index;
  final SequenceEntry entry;
  final VoidCallback onRemove;
  final bool canRemove;
  final Function(String) onSequenceChanged;

  const _SequenceCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.canRemove,
    required this.onSequenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Index
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFB8705).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFFFB8705),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Name and Sequence fields in a row
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: [
                  // Name field
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      controller: entry.nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFFB8705),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Sequence field
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: entry.sequenceController,
                      decoration: InputDecoration(
                        hintText: 'Sequence',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFFB8705),
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (!SequenceValidator.isValidSequence(value)) {
                          return 'Invalid sequence';
                        }
                        return null;
                      },
                      onChanged: onSequenceChanged,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    entry.type == SequenceType.nucleotide
                        ? Colors.green.withOpacity(0.1)
                        : entry.type == SequenceType.protein
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.type == SequenceType.nucleotide
                    ? 'DNA'
                    : entry.type == SequenceType.protein
                    ? 'Protein'
                    : 'Unknown',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      entry.type == SequenceType.nucleotide
                          ? Colors.green[700]
                          : entry.type == SequenceType.protein
                          ? Colors.blue[700]
                          : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Delete button
            if (canRemove)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red[400],
                onPressed: onRemove,
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }
}
