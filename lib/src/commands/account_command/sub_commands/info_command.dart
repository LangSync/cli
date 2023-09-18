import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:langsync/src/etc/utils.dart';
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
          'You are not authenticated, please authenticate your account with the CLI by running: ',
        )
        ..info('langsync account auth');

      return ExitCode.usage.code;
    }

    final shouldRevealApiKey = argResults?['reveal-api-key'] == true;

    final shownApiKey = shouldRevealApiKey ? apiKey : apiKey.hiddenBy('*');

    final fetchingProgress = logger.progress(
      "Fetching account's information...",
      options: ProgressOptions(
        animation: ProgressAnimation(
          frames: utils.randomLoadingFrames(),
        ),
      ),
    );

    try {
      final userInfo = await NetClient.instance.userInfo(apiKey: apiKey);
      fetchingProgress.update("fetched account's information successfully.");
      logger
        ..info('')
        ..info('The API key in use: $shownApiKey');

      final fields = userInfo.toJson().entries.toList();

      for (var index = 0; index < fields.length; index++) {
        final curr = fields[index];
        logger.info('${curr.key}: ${curr.value}');
      }

      fetchingProgress.complete();

      return ExitCode.success.code;
    } catch (e) {
      logger.customErr(
        error: e,
        progress: fetchingProgress,
        update: 'Failed to fetch account information.',
      );

      return ExitCode.software.code;
    }
  }
}
