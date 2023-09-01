// ignore_for_file: strict_raw_type
import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:yaml/yaml.dart' as yaml;

abstract class YamlController {
  static Future<Map<dynamic, dynamic>> get parsedYaml async {
    if (!configFileRef.existsSync()) {
      throw Exception('Config file does not exist.');
    }

    final asString = configFileRef.readAsStringSync();

    return await yaml.loadYaml(asString) as Map;
  }

  static File get configFileRef => File('./langsync.yaml');

  static Future<File> createConfigFile() {
    return configFileRef.create();
  }

  static Future<void> writeToConfigFile(String s) async {
    if (!configFileRef.existsSync()) {
      throw Exception('Config file does not exist.');
    }

    configFileRef.writeAsStringSync(
      s,
      mode: FileMode.append,
    );
  }

  static Map<String, dynamic> futureYamlFormatFrom({
    required String sourceLocalizationFilePath,
    required String outputDir,
    required Iterable<String> targetLangsList,
  }) {
    return {
      'source': sourceLocalizationFilePath,
      'output': outputDir,
      'target': targetLangsList.toList(),
    };
  }

  static void iterateOverConfig(
    Map<dynamic, dynamic> config, {
    required void Function(MapEntry<dynamic, dynamic> configEntry) callback,
  }) {
    for (final entry in config.entries) {
      callback(entry);
    }
  }

  static Future<void> iterateAndWriteToConfigFile(
    Map<dynamic, dynamic> config,
  ) async {
    iterateOverConfig(
      config,
      callback: (entry) async {
        await YamlController.writeToConfigFile(
          "\n  ${entry.key}: \'${entry.value}' \n",
        );
      },
    );
  }

  static bool validateConfigFields(Map parsedYaml) {
    final langsyncConfig = parsedYaml['langsync'];

    if (langsyncConfig == null) {
      throw Exception('langsync.yaml file is missing a `langsync` key.');
    } else {
      final sourceLocalizationFilePath = langsyncConfig['source'];
      final outputDir = langsyncConfig['output'];
      final targetLangsList = langsyncConfig['target'];

      if (sourceLocalizationFilePath == null) {
        throw Exception(
          'langsync.yaml file is missing a `source` key under `langsync`.',
        );
      } else if (outputDir == null) {
        throw Exception(
          'langsync.yaml file is missing a `output` key under `langsync`.',
        );
      } else if (targetLangsList == null) {
        throw Exception(
          'langsync.yaml file is missing a `target` key under `langsync`.',
        );
      } else {
        return true;
      }
    }
  }

  static void iterateAndLogConfig(Map parsedYaml, Logger logger) {
    logger.info('');

    iterateOverConfig(
      parsedYaml['langsync'] as Map<dynamic, dynamic>,
      callback: (entry) {
        logger.info('${entry.key}: ${entry.value}\n');
      },
    );

    logger.info('');
  }
}
