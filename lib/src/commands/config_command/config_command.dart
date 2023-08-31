import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:langsync/src/commands/account_command/sub_commands/auth_command.dart';
import 'package:langsync/src/commands/account_command/sub_commands/info_command.dart';
import 'package:langsync/src/commands/account_command/sub_commands/logout_command.dart';
import 'package:langsync/src/commands/config_command/sub_commands/create_command.dart';
import 'package:mason_logger/mason_logger.dart';

class ConfigCommand extends Command<int> {
  ConfigCommand({
    required Logger logger,
  }) : _logger = logger {
    addSubcommand(ConfigCreateCommand(logger: _logger));
  }

  @override
  String get description =>
      'Manage LangSync configuration in the current directory.';

  @override
  String get name => 'config';

  @override
  FutureOr<int>? run() {
    return super.run();
  }

  final Logger _logger;
}
