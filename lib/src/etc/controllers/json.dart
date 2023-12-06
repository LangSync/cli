import 'dart:convert';
import 'dart:io';

import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';

/// A JSON config file controller.
class JsonController extends ConfigFileController {
  @override
  File get configFileRef => File('./langsync.json');

  @override
  Future<Map<dynamic, dynamic>> parsed() {
    return super.parsedConfigFileControllerContent(
      loadConfigAsMapCallback: (fileContentAsString) async {
        return await jsonDecode(fileContentAsString) as Map<dynamic, dynamic>;
      },
    );
  }

  @override
  void writeNewConfig(Map<String, dynamic> config) {
    return super.writeToConfigFileController(
      {'langsync': config}.toPrettyJson(),
    );
  }
}
