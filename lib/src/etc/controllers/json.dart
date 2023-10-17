import 'dart:convert';
import 'dart:io';

import 'package:langsync/src/etc/controllers/config_file.dart';

class JsonController extends ConfigFile {
  @override
  File get configFileRef => File('./langsync.json');

  @override
  Future<Map<dynamic, dynamic>> parsed() {
    return super.parsedConfigFileContent(
      loadConfigAsMapCallback: (fileContentAsString) async {
        return await jsonDecode(fileContentAsString) as Map<dynamic, dynamic>;
      },
    );
  }

  @override
  Future<void> writeNewConfig(Map<String, dynamic> config) {
    return super.writeToConfigFile(
      jsonEncode({'langsync': config}),
    );
  }
}
