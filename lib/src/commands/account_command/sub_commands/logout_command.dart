import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:mason_logger/mason_logger.dart';

class LogoutCommand extends Command<int> {
  LogoutCommand({
    required this.logger,
  });

  @override
  String get description => 'Logout from the current account';

  @override
  String get name => 'logout';

  final Logger logger;

  @override
  Future<int> run() async {
    final configBox = Hive.box<dynamic>('config');
    final apiKey = configBox.get('apiKey') as String?;
    if (apiKey == null) {
      logger
        ..info('No account was associated with the CLI.')
        ..info(
          'if you intend to authenticate with an account, run the following command:',
        )
        ..info('langsync account auth');

      return ExitCode.success.code;
    } else {
      final logoutProgress = logger.progress('Logging out from the account..');

      try {
        await configBox.delete('apiKey');
        logoutProgress.complete('Successfully logged out.');

        return ExitCode.success.code;
      } catch (e) {
        logger.customErr(
          error: e,
          progress: logoutProgress,
          update: 'Something went wrong while logging out, please try again.',
        );

        return ExitCode.ioError.code;
      }
    }
  }
}
