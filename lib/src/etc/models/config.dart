import 'package:equatable/equatable.dart';
import 'package:yaml/yaml.dart';

/// {@template langsync_config}
/// The LangSync config model, it holds possible configurations that relates to the config file reference that will be read or/and write to.
/// {@endtemplate}
class LangSyncConfig extends Equatable {
  /// {@macro langsync_config}
  const LangSyncConfig({
    required this.sourceFile,
    required this.outputDir,
    required this.langs,
    this.languageLocalizationMaxDelay,
    this.instruction,
  });

  /// Creates a [LangSyncConfig] from a [Map].
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

  /// The source localization file path.
  final String sourceFile;

  /// The output directory path.
  final String outputDir;

  /// The target languages to generate localizations for.
  final Iterable<String> langs;

  /// The maximum language localization can take to be generated in seconds, if a language localization takes more than this value, it will be skipped.
  final int? languageLocalizationMaxDelay;

  /// The AI instruction to generate localizations, if any.
  final String? instruction;

  @override
  List<Object?> get props => [
        sourceFile,
        outputDir,
        langs,
        languageLocalizationMaxDelay,
        instruction,
      ];

  /// Converts the [LangSyncConfig] to a [Map].
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
