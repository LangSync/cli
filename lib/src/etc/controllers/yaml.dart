import 'dart:io';

import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:yaml/yaml.dart' as yaml;

class YamlController extends ConfigFile {
  @override
  File get configFileRef => File('./langsync.yaml');

  @override
  Future<Map<dynamic, dynamic>> parsed() async {
    return super.parsedConfigFileContent(
      loadConfigAsMapCallback: (fileContentAsString) async {
        return await yaml.loadYaml(fileContentAsString) as Map;
      },
    );
  }

  @override
  Future<void> writeNewConfig(Map<String, dynamic> config) async {
    await super.writeToConfigFile('langsync:\n');

    await _iterateAndWriteToConfigFile(config);
  }

  Future<void> _iterateAndWriteToConfigFile(
    Map<dynamic, dynamic> config,
  ) async {
    super.iterateOverConfig(
      config,
      callback: (entry) async {
        if (entry.value is String) {
          if ((entry.value as String).isPathToFileOrFolder()) {
            await super.writeToConfigFile(
              "\n  ${entry.key}: '${entry.value}' \n",
            );
            return;
          }
        }

        await super.writeToConfigFile(
          '\n  ${entry.key}: ${entry.value} \n',
        );
      },
    );
  }
}
