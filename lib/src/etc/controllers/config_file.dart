import 'dart:io';

import 'package:args/src/arg_results.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

import 'package:langsync/src/etc/controllers/json.dart';
import 'package:langsync/src/etc/controllers/yaml.dart';

/// Decided and manages the LangSync config file controller.
abstract class ConfigFileController {
  /// Created the convenable [ConfigFileController] from the [argResults] of the CLI call.
  /// If no [argResults] are provided, the default controller is returned.
  static ConfigFileController fromArgResults(ArgResults argResults) {
    final isJson = argResults['json'] == true;
    final isYaml = argResults['yaml'] == true;

    if (isJson) {
      return JsonController();
    } else if (isYaml) {
      return YamlController();
    } else {
      return defaultController;
    }
  }

  /// The controllers that are supported by LangSync, the goal of this implementation is to make it easy to locate the expected config file name of each and to be able to add more in the future.
  static final Map<String, ConfigFileController> _controllers = [
    YamlController(),
    JsonController(),
  ].asMap().map(
        (_, controller) => MapEntry(controller.configFileName, controller),
      );

  /// Returns the existant expected config files of the controllers in the current directory. (the project directory)
  static Iterable<FileSystemEntity> get configFilesInCurrentDir {
    final fileEntities = Directory('.').listSync();

    return fileEntities.where(
      (file) => _controllers.containsKey(file.fileNameOnly),
    );
  }

  /// Returns the default controller of LangSync, which is the [YamlController].
  /// This is the controller that is used when no controller is specified.
  static ConfigFileController get defaultController => YamlController();

  /// The config file reference.
  File get configFileRef;

  // String get configFileExtension => configFileRef.path.split('.').last;
  String get configFileName => configFileRef.fileNameOnly;

  /// The config file content parsed as a map of dynamic keys and values.
  Future<Map<dynamic, dynamic>> parsed();

  /// !
  @protected
  Future<Map<dynamic, dynamic>> parsedConfigFileControllerContent({
    required Future<Map<dynamic, dynamic>> Function(String fileContentAsString)
        loadConfigAsMapCallback,
  }) async {
    if (!configFileRef.existsSync()) {
      throw Exception('Config file does not exist.');
    }

    final asString = configFileRef.readAsStringSync();

    return loadConfigAsMapCallback(asString);
  }

  /// Creates the config file if it does not exist.
  Future<File> createConfigFile() {
    return configFileRef.create();
  }

  /// Writes the raw [writableContent] string to the config file.
  void writeToConfigFileController(String writableContent) {
    if (!configFileRef.existsSync()) {
      throw Exception('Config file does not exist.');
    }

    configFileRef.writeAsStringSync(
      writableContent,
      mode: FileMode.append,
    );
  }

  /// Validates the config file fields of LangSync, this is universal and static because it relies on the config file content parsed as a map.
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

  /// Logs the config file fields of LangSync, this is universal and static because it relies on the config file content parsed as a map.
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

  /// Iterates over the config file fields of LangSync, this is universal and static because it relies on the config file content parsed as a map.
  void iterateOverConfig(
    Map<dynamic, dynamic> config, {
    required void Function(MapEntry<dynamic, dynamic> configEntry) callback,
  }) {
    for (final entry in config.entries) {
      callback(entry);
    }
  }

  /// Writes the new config file to the config file controller.
  void writeNewConfig(Map<String, dynamic> config);

  /// Returns the config file controller from the [file].
  static ConfigFileController controllerFromFile(FileSystemEntity file) {
    final fileName = file.fileNameOnly;

    return _controllers[fileName]!;
  }
}
