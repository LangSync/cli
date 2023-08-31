import 'dart:io';

final utils = Utils();

class Utils {
  bool isValidApiKey(String apiKey) {
    return true;
  }

  Directory localeDataDir() {
    if (Platform.isWindows) {
      final appDataDir = Directory(Platform.environment['APPDATA']!);
      return appDataDir;
    } else if (Platform.isLinux) {
      final homeDir = Directory(Platform.environment['HOME']!);
      final configDir = Directory('${homeDir.path}/.config');
      return configDir;
    } else if (Platform.isMacOS) {
      final homeDir = Directory(Platform.environment['HOME']!);
      final appSupportDir =
          Directory('${homeDir.path}/Library/Application Support');
      return appSupportDir;
    } else {
      throw Exception('LangSync is available only on Windows, Linux & MacOs.');
    }
  }

  String endpoint(String path) {
    return 'http://192.168.1.106:5559${path.startsWith("/") ? path : "/$path"}';
  }
}
