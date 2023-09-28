import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:langsync/src/commands/account_command/sub_commands/api_key_command.dart';
import 'package:langsync/src/commands/account_command/sub_commands/auth_command.dart';
import 'package:langsync/src/commands/account_command/sub_commands/info_command.dart';
import 'package:langsync/src/commands/account_command/sub_commands/logout_command.dart';
import 'package:mason_logger/mason_logger.dart';

class AccountCommand extends Command<int> {
  AccountCommand({
    required Logger logger,
  }) : _logger = logger {
    addSubcommand(AuthCommand(logger: _logger));
    addSubcommand(InfoCommand(logger: _logger));
    addSubcommand(LogoutCommand(logger: _logger));
    addSubcommand(ApiKeyCommand(logger: _logger));
  }

  @override
  String get description => 'Manage the authenticated account in use.';

  @override
  String get name => 'account';

  final Logger _logger;
}
