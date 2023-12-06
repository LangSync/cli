import 'dart:io';

import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:yaml/yaml.dart' as yaml;

class YamlController extends ConfigFileController {
  @override
  File get configFileRef => File('./langsync.yaml');

  @override
  Future<Map<dynamic, dynamic>> parsed() async {
    return super.parsedConfigFileControllerContent(
      loadConfigAsMapCallback: (fileContentAsString) async {
        return await yaml.loadYaml(fileContentAsString) as Map;
      },
    );
  }

  @override
  void writeNewConfig(Map<String, dynamic> config) async {
    super.writeToConfigFileController('langsync:\n');

    await _iterateAndWriteToConfigFileController(config);
  }

  Future<void> _iterateAndWriteToConfigFileController(
    Map<dynamic, dynamic> config,
  ) async {
    super.iterateOverConfig(
      config,
      callback: (entry) async {
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
