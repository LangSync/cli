import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:langsync/src/commands/auth_command/auth.dart';
import 'package:langsync/src/commands/config_command/config_command.dart';
import 'package:langsync/src/commands/debug_info/debug_info.dart';
import 'package:langsync/src/commands/start_command/start_command.dart';
import 'package:langsync/src/etc/utils.dart';
import 'package:langsync/src/version.dart';
import 'package:mason_logger/mason_logger.dart';

const executableName = 'langsync';
const packageName = 'langsync';
final description = '''

An AI powered Command Line Interface (CLI) tool that helps you process your original language-specific files such translations, strings & texts.. and generates the corresponding translated files in the target language(s).

  ${utils.isDebugMode ? '\n${lightRed.wrap('Debug mode is enabled!')}' : ''}
''';

/// {@template langsync_command_runner}
/// A [CommandRunner] for the CLI.
///
/// ```
/// $ langsync --version
/// ```
/// {@endtemplate}
class LangsyncCommandRunner extends CompletionCommandRunner<int> {
  /// {@macro langsync_command_runner}
  LangsyncCommandRunner({
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super(executableName, description) {
    // Add root options and flags
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version of LangSync.',
      )
      ..addFlag(
        'verbose',
        help: 'Print verbose output.',
      );

    addCommand(AuthCommand(logger: _logger));
    addCommand(ConfigCommand(logger: _logger));
    addCommand(StartCommand(logger: _logger));

    if (utils.isDebugMode) addCommand(DebugInfoCommand(logger: _logger));
  }

  @override
  void printUsage() => _logger.info(usage);

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);

      return await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    // Verbose logs
    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }
    }

    // Run the command or show version
    final int? exitCode;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    return exitCode;
  }
}
