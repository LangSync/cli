import 'dart:io';
import 'dart:math';

final utils = Utils();

class Utils {
  final isDebugMode = false;

//! notice the "/"
  String get baseUrl =>
      isDebugMode ? 'http://192.168.0.5:5559' : 'https://api.langsync.app';

  bool isValidApiKeyFormatted(String apiKey) {
    final isNotEmpty = apiKey.isNotEmpty;
    final hasValidLength = apiKey.length == 64;

    return isNotEmpty && hasValidLength;
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
    return '$baseUrl${path.startsWith("/") ? path : "/$path"}';
  }

  List<String> randomLoadingFrames() {
    final framesList = [
      ..._firstTypeLists(),
      ['- ', r'\ ', '| ', '/ '],
      ['◐ ', '◓ ', '◑ ', '◒ '],
    ];

    final ran = Random();

    return framesList[ran.nextInt(framesList.length)];
  }

  List<List<String>> _firstTypeLists() {
    const firstTypeSymbols = '.-+*=~|o#x';

    return List.generate(firstTypeSymbols.length, (i) {
      final char = firstTypeSymbols[i];
      return [
        '$char   ',
        '${char * 2}  ',
        '${char * 3} ',
        (char * 4),
        ' ${char * 3}',
        '  ${char * 2}',
        '   $char',
      ];
    });
  }

  // bool isConsideredTrue(String answer) {
  //   return answer == 'y' ||
  //       answer == 'yes' ||
  //       answer == 'yep' ||
  //       answer == 'yeah' ||
  //       answer == 'true';
  // }
}
