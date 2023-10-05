import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

class InfoCommand extends Command<int> {
  InfoCommand({
    required this.logger,
  }) {
    argParser.addFlag(
      'reveal-api-key',
      negatable: false,
      help: 'Shows the API key of the current account.',
    );
  }

  @override
  final name = 'info';

  @override
  final description = 'Show account information';

  final Logger logger;

  @override
  FutureOr<int>? run() async {
    final configBox = Hive.box<dynamic>('config');

    final apiKey = configBox.get('apiKey') as String?;

    if (apiKey == null) {
      logger
        ..info(
            'You are not authenticated, please provide an API key to authenticate.')
        ..docsInfo(path: '/cli-usage/auth');

      return ExitCode.usage.code;
    }

    final shouldRevealApiKey = argResults?['reveal-api-key'] == true;

    final shownApiKey = shouldRevealApiKey ? apiKey : apiKey.hiddenBy('*');

    final fetchingProgress = logger.customProgress(
      "Fetching account's information...",
    );

    try {
      final userInfo = await NetClient.instance.userInfo(apiKey: apiKey);

      fetchingProgress.complete("fetched account's information successfully.");

      logger
        ..info('')
        ..info('The API key in use: $shownApiKey');

      final fields = userInfo.toJson().entries.toList();

      for (var index = 0; index < fields.length; index++) {
        final curr = fields[index];
        logger.info('${curr.key}: ${curr.value}');
      }

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.customErr(
        error: e,
        progress: fetchingProgress,
        update: 'Failed to fetch account information.',
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
