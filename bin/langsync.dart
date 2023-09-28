import 'dart:io';
import 'package:hive/hive.dart';
import 'package:langsync/src/command_runner.dart';
import 'package:langsync/src/etc/utils.dart';

Future<void> main(List<String> args) async {
  final configDir = utils.localeDataDir();
  final langSyncDir = await Directory('${configDir.path}/langsync').create();

  Hive.init(langSyncDir.path);

  await Hive.openBox<dynamic>('config');

  await _flushThenExit(await LangsyncCommandRunner().run(args));
}

Future<void> _flushThenExit(int status) async {
  await Future.wait<void>([stdout.close(), stderr.close()]);

  exit(status);
}
