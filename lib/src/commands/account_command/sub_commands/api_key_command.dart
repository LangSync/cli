import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

class ApiKeyCommand extends Command<int> {
  ApiKeyCommand({
    required this.logger,
  });

  final Logger logger;

  @override
  String get description => 'Create your unique API key & LangSync account.';

  @override
  String get name => 'create';

  @override
  FutureOr<int>? run() async {
    final userSure = logger.confirm(
      "You're about to create a brand new unique API key, do you want to continue?",
    );

    if (!userSure) {
      logger.info('Aborted!');
      return 0;
    }

    logger.info('\n');

    final userName = logger.prompt(
      'Please enter your desired username (will be used to identify you): ',
    );

    if (userName.isEmpty) {
      logger.err("Username can't be empty!");
      return 1;
    }

    final progress = logger.progress('Creating your API key...');

    try {
      final apiKeyDoc = await NetClient.instance.createApiKey(userName);

      progress.complete('API key created successfully!');
      logger.info('\n');

      logger
        // ..info('Your username: ${apiKeyDoc.username}')
        ..success('Your API key: ${apiKeyDoc.apiKey}')
        ..info('\n')
        ..warn(
          "Please make sure to save your API key somewhere safe, as you won't be able to retrieve it again!",
        )
        ..info('\n')
        ..info(
          "run 'langsync account auth' to configure LangSync with that API key to start using it.",
        );

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.customErr(
        progress: progress,
        update: 'Failed to create API key!',
        error: e,
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

      return ExitCode.software.code;
    }
  }
}
