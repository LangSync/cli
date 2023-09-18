// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class LangOutput extends Equatable {
  final String lang;
  final DateTime localizedAt;
  final Map<String, dynamic> jsonFormattedResponse;

  const LangOutput({
    required this.lang,
    required this.localizedAt,
    required this.jsonFormattedResponse,
  });

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
