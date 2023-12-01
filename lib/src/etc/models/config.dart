import 'package:equatable/equatable.dart';
import 'package:yaml/yaml.dart';

class LangSyncConfig extends Equatable {
  const LangSyncConfig({
    required this.sourceFile,
    required this.outputDir,
    required this.langs,
    this.languageLocalizationMaxDelay,
    this.instruction,
  });

  factory LangSyncConfig.fromMap(Map<dynamic, dynamic> map) {
    final langsyncMapField = map['langsync'] as Map;

    final targetField = langsyncMapField['target'];

    final target = targetField is YamlList
        ? targetField.nodes.map((e) => e.value as String)
        : (targetField as List<dynamic>).map((e) => e as String);

    final languageLocalizationMaxDelay =
        langsyncMapField['languageLocalizationMaxDelay'] as int?;

    final instruction = langsyncMapField['instruction'] as String?;

    return LangSyncConfig(
      sourceFile: langsyncMapField['source'] as String,
      outputDir: langsyncMapField['output'] as String,
      langs: target,
      languageLocalizationMaxDelay: languageLocalizationMaxDelay ?? 450,
      instruction: instruction,
    );
  }

  final String sourceFile;
  final String outputDir;
  final Iterable<String> langs;
  final int? languageLocalizationMaxDelay;
  final String? instruction;

  List<String> get langsJsonFiles => langs.map((e) => '$e.json').toList();

  @override
  List<Object?> get props => [
        sourceFile,
        outputDir,
        langs,
        languageLocalizationMaxDelay,
      ];

  Map<String, dynamic> toMap() {
    return {
      'source': sourceFile,
      'output': outputDir,
      'target': langs.toList(),
      'languageLocalizationMaxDelay': languageLocalizationMaxDelay ?? 200,
      if (instruction != null && instruction!.isNotEmpty)
        'instruction': instruction,
    };
  }
}
