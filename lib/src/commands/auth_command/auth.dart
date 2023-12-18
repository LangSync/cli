// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:mason_logger/mason_logger.dart';

class AuthCommand extends Command<int> {
  final Logger logger;

  AuthCommand({
    required this.logger,
  }) {
    argParser.addOption(
      'apiKey',
      abbr: 'k',
      help: 'The API key to use for authentication.',
      valueHelp: 'API_KEY',
    );
  }

  @override
  String get description =>
      'Authenticate with the LangSync CLI using an API key. (You can get an API key from https://my.langsync.app)';

  @override
  String get name => 'auth';

  @override
  Future<int> run() async {
    final apiKey = argResults!['apiKey'] as String?;

    if (apiKey == null) {
      logger.info('Please provide an API key.');
      return ExitCode.usage.code;
    }

    final progress = logger.progress('Saving Your API Key...');

    try {
      await _saveApiKey(apiKey);

      progress.complete('Your API key has been saved successfully.');

      return ExitCode.success.code;
    } catch (e, stack) {
      logger.customErr(
        update:
            'An error occurred while saving your API key, please try again.',
        progress: progress,
        error: e,
        stacktrace: stack,
      );

      return ExitCode.software.code;
    }
  }

  Future<void> _saveApiKey(String apiKey) async {
    final box = Hive.box<dynamic>('config');

    await box.put('apiKey', apiKey);
  }
}
