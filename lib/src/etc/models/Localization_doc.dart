import 'package:equatable/equatable.dart';

/// {@template localization_doc}
/// A Localization Doc model, it holds the created at date, the operation id, the json parts length and the output langs.
/// {@endtemplate}
class LocalizationDoc extends Equatable {
  /// {@macro localization_doc}
  const LocalizationDoc({
    required this.createdAt,
    required this.operationId,
    required this.jsonPartsLength,
    this.outputLangs,
  });

  /// Creates a [LocalizationDoc] from a [Map].
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

  /// The created at date.
  final DateTime createdAt;

  /// The operation id.
  final String operationId;

  /// The json parts length.
  final int jsonPartsLength;

  /// The output langs.
  final List<String>? outputLangs;

  @override
  List<Object?> get props => [
        createdAt,
        operationId,
        jsonPartsLength,
        outputLangs,
      ];
}
