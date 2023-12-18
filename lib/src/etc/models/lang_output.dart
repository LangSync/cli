import 'package:equatable/equatable.dart';

/// {@template lang_output}
/// A Language Output model, it holds the language name, the localized at date and the json formatted response.
/// {@endtemplate}
class LangOutput extends Equatable {
  /// {@macro lang_output}
  const LangOutput({
    required this.lang,
    required this.localizedAt,
    required this.objectDecodedResponse,
    required this.adaptedResponse,
  });

  /// Creates a [LangOutput] from a [Map].
  factory LangOutput.fromJson(Map<String, dynamic> json) {
    return LangOutput(
      lang: json['lang'] as String,
      localizedAt: DateTime.parse(json['localizedAt'] as String),
      objectDecodedResponse:
          json['objectDecodedResponse'] as Map<String, dynamic>,
      adaptedResponse: json['adaptedResponse'] as String,
    );
  }

  /// The language name.
  final String lang;

  /// The localized at date.
  final DateTime localizedAt;

  /// The json formatted response.
  final Map<String, dynamic> objectDecodedResponse;

  /// The adapted response.
  final String adaptedResponse;

  @override
  List<Object?> get props => [
        lang,
        localizedAt,
        objectDecodedResponse,
        adaptedResponse,
      ];
}
