/// Model class representing a biological sequence
class SequenceModel {
  final String id;
  final String name;
  final String sequence;
  final SequenceType type;

  SequenceModel({
    required this.id,
    required this.name,
    required this.sequence,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sequence': sequence,
      'type': type.toString(),
    };
  }

  factory SequenceModel.fromJson(Map<String, dynamic> json) {
    return SequenceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sequence: json['sequence'] as String,
      type: SequenceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SequenceType.unknown,
      ),
    );
  }

  SequenceModel copyWith({
    String? id,
    String? name,
    String? sequence,
    SequenceType? type,
  }) {
    return SequenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      type: type ?? this.type,
    );
  }
}

enum SequenceType { nucleotide, protein, unknown }

extension SequenceTypeExtension on SequenceType {
  String get displayName {
    switch (this) {
      case SequenceType.nucleotide:
        return 'Nucleotide';
      case SequenceType.protein:
        return 'Protein';
      case SequenceType.unknown:
        return 'Unknown';
    }
  }
}
