import 'package:equatable/equatable.dart';

class LocalizationDoc extends Equatable {
  const LocalizationDoc({
    required this.createdAt,
    required this.partitionId,
    required this.jsonPartsLength,
    this.outputLangs,
  });

  final DateTime createdAt;
  final String partitionId;
  final int jsonPartsLength;
  final List<String>? outputLangs;

  @override
  List<Object?> get props => [
        createdAt,
        partitionId,
        jsonPartsLength,
        outputLangs,
      ];

  factory LocalizationDoc.fromJson(Map<String, dynamic> json) {
    return LocalizationDoc(
      createdAt: DateTime.parse(json['createdAt'] as String),
      partitionId: json['partitionId'] as String,
      jsonPartsLength: json['jsonPartsLength'] is int
          ? json['jsonPartsLength'] as int
          : int.parse(json['jsonPartsLength'] as String),
      outputLangs: json['outputLangs'] != null
          ? (json['outputLangs'] as List<dynamic>)
              .map((dynamic e) => e as String)
              .toList()
          : null,
    );
  }
}
