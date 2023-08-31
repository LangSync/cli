import 'dart:io';
import 'package:hive/hive.dart';
import 'package:langsync/src/command_runner.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:langsync/src/etc/utils.dart';

Future<void> main(List<String> args) async {
  final configDir = utils.localeDataDir();
  final langSyncDir = await Directory('${configDir.path}/langsync').create();

  Hive.init(langSyncDir.path);

  await Hive.openBox<dynamic>('config');

  await _flushThenExit(await LangsyncCommandRunner().run(args));
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<void> _flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}
