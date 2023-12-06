import 'dart:async';
import 'package:args/command_runner.dart';
import 'package:langsync/src/commands/config_command/sub_commands/create_command.dart';
import 'package:langsync/src/commands/config_command/sub_commands/validate_command.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template config_command}
/// A command to manage LangSync configuration in the current directory.
/// {@endtemplate}
class ConfigCommand extends Command<int> {
  /// {@macro config_command}
  ConfigCommand({
    required Logger logger,
  }) : _logger = logger {
    addSubcommand(ConfigCreateCommand(logger: _logger));
    addSubcommand(ConfigValidateCommand(logger: _logger));
  }

  @override
  String get description =>
      'Manage LangSync configuration in the current directory.';

  final Logger _logger;

  @override
  String get name => 'config';

  @override
  FutureOr<int>? run() {
    return ExitCode.success.code;
  }
}
