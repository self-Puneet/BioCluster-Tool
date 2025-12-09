import 'constants.dart';
import '../models/sequence_model.dart';

/// Validation utility class for biological sequences
class SequenceValidator {
  SequenceValidator._();

  /// Validates a biological sequence and returns its type
  static SequenceType validateSequence(String sequence) {
    if (sequence.isEmpty) {
      return SequenceType.unknown;
    }

    final cleanSequence = sequence.trim().toUpperCase();

    // Check if it's a valid nucleotide sequence
    if (AppConstants.nucleotideRegex.hasMatch(cleanSequence)) {
      return SequenceType.nucleotide;
    }

    // Check if it's a valid protein sequence
    if (AppConstants.proteinRegex.hasMatch(cleanSequence)) {
      return SequenceType.protein;
    }

    return SequenceType.unknown;
  }

  /// Checks if a sequence is valid (either nucleotide or protein)
  static bool isValidSequence(String sequence) {
    return validateSequence(sequence) != SequenceType.unknown;
  }

  /// Validates sequence name
  static bool isValidSequenceName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }

  /// Parses FASTA format string into map of sequences
  static Map<String, String> parseFastaFormat(String fastaText) {
    final Map<String, String> sequences = {};
    final lines = fastaText.split('\n');

    String? currentName;
    StringBuffer currentSequence = StringBuffer();

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('>')) {
        // Save previous sequence if exists
        if (currentName != null && currentSequence.isNotEmpty) {
          sequences[currentName] = currentSequence.toString();
        }
        // Start new sequence
        currentName = line.substring(1).trim();
        currentSequence = StringBuffer();
      } else {
        currentSequence.write(line);
      }
    }

    // Save last sequence
    if (currentName != null && currentSequence.isNotEmpty) {
      sequences[currentName] = currentSequence.toString();
    }

    return sequences;
  }

  /// Parses simple format (name : sequence)
  static Map<String, String> parseSimpleFormat(String text) {
    final Map<String, String> sequences = {};
    final lines = text.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final parts = line.split(':');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final sequence = parts.sublist(1).join(':').trim().replaceAll(',', '');
        if (name.isNotEmpty && sequence.isNotEmpty) {
          sequences[name] = sequence;
        }
      }
    }

    return sequences;
  }

  /// Auto-detects format and parses accordingly
  static Map<String, String> parseInput(String text) {
    text = text.trim();
    if (text.isEmpty) return {};

    // Try FASTA format first
    if (text.contains('>')) {
      return parseFastaFormat(text);
    }

    // Try simple format
    return parseSimpleFormat(text);
  }
}
