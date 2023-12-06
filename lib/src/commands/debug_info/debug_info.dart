import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/utils.dart';
import 'package:langsync/src/version.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template debug_info_command}
///  A command to show some useful info while debugging, this command is made for devlopemnet and it should not appear on production version
/// {@endtemplate}
class DebugInfoCommand extends Command<int> {
  /// The logger to use.
  final Logger logger;

  /// {@macro debug_info_command}
  DebugInfoCommand({required this.logger});

  @override
  String get description =>
      'show some useful info while debugging, this command is made for devlopemnet and it should not appear on production version';

  @override
  String get name => 'debug';

  @override
  Future<int> run() async {
    final debugFields = {
      'baseUrl': utils.baseUrl,
      'langsyncVersion': packageVersion,
    };

    final asEntriesList = debugFields.entries.toList();

    for (var index = 0; index < debugFields.length; index++) {
      final current = asEntriesList[index];

      logger.info('${current.key}: ${current.value}');
    }

    logger.success('all debug info printed successfully!');

    return ExitCode.success.code;
  }
}
