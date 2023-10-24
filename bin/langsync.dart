import 'dart:io';
import 'package:hive/hive.dart';
import 'package:langsync/src/command_runner.dart';
import 'package:langsync/src/etc/utils.dart';

Future<void> main(List<String> args) async {
  final configDir = utils.localeDataDir();
  final langSyncDir =
      await Directory('${configDir.path}/langsync').create(recursive: true);

  Hive.init(langSyncDir.path);

  final box = await Hive.openBox<dynamic>('config');

  await box.put(
    'apiKey',
    'f3c5d5721020da969a0a1f65686723a1484ba4bd167b0b08daeaa6bb6312fefc',
  );

  await _flushThenExit(await LangsyncCommandRunner().run(args));
}

Future<void> _flushThenExit(int status) async {
  await Future.wait<void>([stdout.close(), stderr.close()]);

  exit(status);
}
