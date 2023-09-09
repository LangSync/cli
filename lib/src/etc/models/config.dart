// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

class LangSyncConfig extends Equatable {
  const LangSyncConfig({
    required this.sourceFile,
    required this.outputDir,
    required this.langs,
  });
  final String sourceFile;
  final String outputDir;
  final Iterable<String> langs;

  @override
  List<Object?> get props => [
        sourceFile,
        outputDir,
        langs,
      ];

  Map<String, dynamic> toMap() {
    return {
      'source': sourceFile,
      'output': outputDir,
      'target': langs.toList(),
    };
  }

  factory LangSyncConfig.fromMap(Map<dynamic, dynamic> map) {
    return LangSyncConfig(
      sourceFile: map['source'] as String,
      outputDir: map['output'] as String,
      langs: List<String>.from(
        map['target'] as List<String>,
      ),
    );
  }
}
