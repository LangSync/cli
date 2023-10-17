import 'package:equatable/equatable.dart';
import 'package:yaml/yaml.dart';

class LangSyncConfig extends Equatable {
  const LangSyncConfig({
    required this.sourceFile,
    required this.outputDir,
    required this.langs,
    required this.languageLocalizationMaxDelay,
  });

  factory LangSyncConfig.fromMap(Map<dynamic, dynamic> map) {
    final langsyncMapField = map['langsync'] as Map;

    final target = (langsyncMapField['target'] as YamlList)
        .nodes
        .map((e) => e.value as String);

    return LangSyncConfig(
      sourceFile: langsyncMapField['source'] as String,
      outputDir: langsyncMapField['output'] as String,
      langs: target,
      languageLocalizationMaxDelay:
          langsyncMapField['languageLocalizationMaxDelay'] as int,
    );
  }

  final String sourceFile;
  final String outputDir;
  final Iterable<String> langs;
  final int languageLocalizationMaxDelay;

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
      'languageLocalizationMaxDelay': languageLocalizationMaxDelay,
    };
  }
}
