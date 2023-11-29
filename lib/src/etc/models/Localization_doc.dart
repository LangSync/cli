import 'package:equatable/equatable.dart';

class LocalizationDoc extends Equatable {
  const LocalizationDoc({
    required this.createdAt,
    required this.operationId,
    required this.jsonPartsLength,
    this.outputLangs,
  });

  factory LocalizationDoc.fromJson(Map<String, dynamic> json) {
    return LocalizationDoc(
      createdAt: DateTime.parse(json['createdAt'] as String),
      operationId: json['operationId'] as String,
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

  final DateTime createdAt;
  final String operationId;
  final int jsonPartsLength;
  final List<String>? outputLangs;

  @override
  List<Object?> get props => [
        createdAt,
        operationId,
        jsonPartsLength,
        outputLangs,
      ];
}
