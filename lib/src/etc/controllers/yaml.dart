import 'dart:io';

import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:yaml/yaml.dart' as yaml;

/// A YAML config file controller.
class YamlController extends ConfigFileController {
  /// The config file reference.
  @override
  File get configFileRef => File('./langsync.yaml');

  /// The config parsed as a [Map].
  @override
  Future<Map<dynamic, dynamic>> parsed() async {
    return super.parsedConfigFileControllerContent(
      loadConfigAsMapCallback: (fileContentAsString) async {
        return await yaml.loadYaml(fileContentAsString) as Map;
      },
    );
  }

  /// Writes the new [config] to the config file.
  @override
  void writeNewConfig(Map<String, dynamic> config) async {
    super.writeToConfigFileController('langsync:\n');
    return _iterateAndWriteToConfigFileController(config);
  }

  /// Iterates over the [config] and writes it to the config file.
  void _iterateAndWriteToConfigFileController(
    Map<dynamic, dynamic> config,
  ) {
    return super.iterateOverConfig(
      config,
      callback: (entry) {
        if (entry.value is String) {
          if ((entry.value as String).isPathToFileOrFolder()) {
            super.writeToConfigFileController(
              "\n  ${entry.key}: '${entry.value}' \n",
            );
            return;
          }
        }

        super.writeToConfigFileController(
          '\n  ${entry.key}: ${entry.value} \n',
        );
      },
    );
  }
}
