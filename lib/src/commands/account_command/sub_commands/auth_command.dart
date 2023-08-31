import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/utils.dart';
import 'package:mason_logger/mason_logger.dart';

class AuthCommand extends Command<int> {
  AuthCommand({
    required this.logger,
  });

  final Logger logger;

  @override
  String get description => 'Authenticate your account with CLI';

  @override
  String get name => 'auth';

  @override
  FutureOr<int>? run() async {
    logger
      ..info('Please, provide your account API key to authenticate.')
      ..info('You can find & manage your API keys from your dashboard.');

    final apiKey = logger.prompt('Enter API Key here: ');

    if (utils.isValidApiKey(apiKey)) {
      final configBox = Hive.box<dynamic>('config');
      try {
        logger.info('Your API key is being saved..');
        if (configBox.get('apiKey') != null) {
          await configBox.delete('apiKey');

          logger.info('Your previous API key has been deleted.');
        }

        await configBox.put('apiKey', apiKey);

        logger.info('Your API key has been saved successfully.');

        return ExitCode.success.code;
      } catch (e) {
        logger.err(
          'Something went wrong while saving your API key, please try again.',
        );

        return ExitCode.ioError.code;
      }
    } else {
      logger.err('The API key you provided is not valid, please try again.');

      return ExitCode.ioError.code;
    }
  }
}
