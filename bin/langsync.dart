import 'dart:io';
import 'package:hive/hive.dart';
import 'package:langsync/src/command_runner.dart';
import 'package:langsync/src/etc/utils.dart';

Future<void> main(List<String> args) async {
  final configDir = utils.localeDataDir();
  final langSyncDir = await Directory('${configDir.path}/langsync').create();
  final a = utils.isValidApiKeyFormatted(
    '1939cf5177f5ae3805c24cc56c03a8186969c8e15a26bcbf1ab3caf96daacabb',
  );

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
