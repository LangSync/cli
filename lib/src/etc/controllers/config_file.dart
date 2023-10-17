import 'dart:io';

import 'package:args/src/arg_results.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

import 'package:langsync/src/etc/controllers/json.dart';
import 'package:langsync/src/etc/controllers/yaml.dart';
import 'package:langsync/src/etc/models/config.dart';

abstract class ConfigFile {
  static ConfigFile fromArgResults(ArgResults argResults) {
    if (argResults['json'] == true) {
      return JsonController();
    } else if (argResults['yaml'] == true) {
      return YamlController();
    } else {
      return defaultController;
    }
  }

  static final Map<String, ConfigFile> _controllers = [
    YamlController(),
    JsonController(),
  ].asMap().map(
        (_, controller) => MapEntry(controller.configFileExtension, controller),
      );

  static Iterable<FileSystemEntity> get configFilesInCurrentDir =>
      Directory('.').listSync().where(
        (file) {
          final extension = file.path.split('.').last;

          return _controllers.containsKey(extension);
        },
      );

  static ConfigFile get defaultController => YamlController();

  File get configFileRef;

  String get configFileExtension => configFileRef.path.split('.').last;

  String get configFileName => configFileRef.path.split('/').last;

  Future<Map<dynamic, dynamic>> parsed();

  @protected
  Future<Map<dynamic, dynamic>> parsedConfigFileContent({
    required Future<Map<dynamic, dynamic>> Function(String fileContentAsString)
        loadConfigAsMapCallback,
  }) async {
    if (!configFileRef.existsSync()) {
      throw Exception('Config file does not exist.');
    }

    final asString = configFileRef.readAsStringSync();

    return loadConfigAsMapCallback(asString);
  }

  Future<File> createConfigFile() {
    return configFileRef.create();
  }

  Future<void> writeToConfigFile(String writableContent) async {
    if (!configFileRef.existsSync()) {
      throw Exception('Config file does not exist.');
    }

    configFileRef.writeAsStringSync(
      writableContent,
      mode: FileMode.append,
    );
  }

  bool validateConfigFields(Map<dynamic, dynamic> parsedConfigAsMap) {
    final langsyncConfig = parsedConfigAsMap['langsync'] as Map?;

    if (langsyncConfig == null) {
      throw Exception('$configFileName file is missing the `langsync` key.');
    } else {
      final sourceLocalizationFilePath = langsyncConfig['source'] as String?;

      final outputDir = langsyncConfig['output'] as String?;

      final targetLangsList = langsyncConfig['target'] as List?;

      // final languageLocalizationMaxDelay =
      //     langsyncConfig['languageLocalizationMaxDelay'] as int?;

      if (sourceLocalizationFilePath == null) {
        throw Exception(
          '$configFileName file is missing the `source` value that represents the path to the source localization file.',
        );
      }

      if (outputDir == null) {
        throw Exception(
          '$configFileName file is missing the `output` value that represents the path to the output directory.',
        );
      }

      if (targetLangsList == null) {
        throw Exception(
          'langsync.yaml file is missing a `target` value that represents the target languages to generate localizations for.',
        );
      }

      // if (languageLocalizationMaxDelay == null) {
      //   throw Exception(
      //     'langsync.yaml file is missing a `languageLocalizationMaxDelay` value that represents the maximum language localization can take to be generated in seconds, if a language localization takes more than this value, it will be skipped.',
      //   );
      // }
      return true;
    }
  }

  Map<String, dynamic> futureConfigToWrite({
    required String sourceLocalizationFilePath,
    required String outputDir,
    required Iterable<String> targetLangsList,
    int? languageLocalizationMaxDelay,
  }) {
    return LangSyncConfig(
      sourceFile: sourceLocalizationFilePath,
      outputDir: outputDir,
      langs: targetLangsList,
      languageLocalizationMaxDelay: languageLocalizationMaxDelay,
    ).toMap();
  }

  void iterateAndLogConfig(Map<dynamic, dynamic> parsedYaml, Logger logger) {
    logger.info('');

    iterateOverConfig(
      parsedYaml['langsync'] as Map<dynamic, dynamic>,
      callback: (entry) {
        logger.info('${entry.key}: ${entry.value}\n');
      },
    );

    logger.info('');
  }

  void iterateOverConfig(
    Map<dynamic, dynamic> config, {
    required void Function(MapEntry<dynamic, dynamic> configEntry) callback,
  }) {
    for (final entry in config.entries) {
      callback(entry);
    }
  }

  Future<void> writeNewConfig(Map<String, dynamic> config);

  static ConfigFile controllerFromFile(FileSystemEntity first) {
    final extension = first.path.split('.').last;

    return _controllers[extension]!;
  }
}
