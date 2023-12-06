import 'package:equatable/equatable.dart';

/// {@template lang_output}
/// A Language Output model, it holds the language name, the localized at date and the json formatted response.
/// {@endtemplate}
class LangOutput extends Equatable {
  /// The language name.
  final String lang;

  /// The localized at date.
  final DateTime localizedAt;

  /// The json formatted response.
  final Map<String, dynamic> jsonFormattedResponse;

  /// {@macro lang_output}
  const LangOutput({
    required this.lang,
    required this.localizedAt,
    required this.jsonFormattedResponse,
  });

  /// Creates a [LangOutput] from a [Map].
  factory LangOutput.fromJson(Map<String, dynamic> json) {
    return LangOutput(
      lang: json['lang'] as String,
      localizedAt: DateTime.parse(json['localizedAt'] as String),
      jsonFormattedResponse:
          json['jsonDecodedResponse'] as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [
        lang,
        localizedAt,
        jsonFormattedResponse,
      ];
}
