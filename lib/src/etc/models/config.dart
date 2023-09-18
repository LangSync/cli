// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:yaml/yaml.dart';

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
    final langsyncMapField = map['langsync'] as Map;

    final target = (langsyncMapField['target'] as YamlList)
        .nodes
        .map((e) => e.value as String);

    return LangSyncConfig(
      sourceFile: langsyncMapField['source'] as String,
      outputDir: langsyncMapField['output'] as String,
      langs: target,
    );
  }
}
