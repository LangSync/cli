import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:langsync/src/etc/utils.dart';
import 'package:mason_logger/mason_logger.dart';

class AuthCommand extends Command<int> {
  AuthCommand({
    required this.logger,
  });

  final Logger logger;

  @override
  String get description => 'Authenticate your account with CLI.';

  @override
  String get name => 'auth';

  @override
  FutureOr<int>? run() async {
    logger
      ..info('Please, provide your account API key to authenticate.')
      ..info('You can find & manage your API keys from your dashboard.');

    final apiKey = logger.prompt('Enter API key here: ');

    if (utils.isValidApiKeyFormatted(apiKey)) {
      final configBox = Hive.box<dynamic>('config');

      final savingProgress =
          logger.customProgress('Your API key is being saved..');

      try {
        if (configBox.get('apiKey') != null) {
          savingProgress.update('Deleting your previous set API key..');

          await configBox.delete('apiKey');

          savingProgress
              .update('Your Previous API key has been deleted successfully.');
        }

        savingProgress.update('Saving your API key..');

        await configBox.put('apiKey', apiKey);

        savingProgress.complete('Your API key has been saved successfully.');

        return ExitCode.success.code;
      } catch (e, stacktrace) {
        logger.customErr(
          error: e,
          progress: savingProgress,
          update:
              'Something went wrong while saving your API key, please try again.',
        );

        try {
          await NetClient.instance.logException(
            e: e,
            stacktrace: stacktrace,
            commandName: name,
          );

          logger
            ..info('\n')
            ..warn(
              'This error has been reported to the LangSync team, we will definitely look into it!',
            );
        } catch (e) {}

        return ExitCode.ioError.code;
      }
    } else {
      logger
        ..err('The API key you provided is not valid, please try again.')
        ..docsInfo(path: '/cli-usage/auth');

      return ExitCode.ioError.code;
    }
  }
}
