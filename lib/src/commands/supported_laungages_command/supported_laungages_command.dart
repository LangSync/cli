import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

// TODO: openai offers 3 requests/min.

class SupportedLangsCommand extends Command<int> {
  SupportedLangsCommand({
    required this.logger,
  }) {
    argParser
      ..addOption(
        'lang',
        help: 'Check for a single language support.',
      )
      ..addOption(
        'langs',
        help: 'Check for multiple languages support.',
      );
  }

  final Logger logger;

  @override
  String get description => 'Check supported languages that can be used.';

  @override
  String get name => 'supported-langs';

  @override
  FutureOr<int>? run() async {
    final langOption = argResults?['lang'] as String?;
    final langsOption = argResults?['langs'] as String?;

    if (langOption != null && langsOption != null) {
      logger.err(
          "Can't use both --lang and --langs at the same time, try again with only one of them.");
      return ExitCode.usage.code;
    }

    if (langOption != null) {
      final lang = langOption.toLowerCase();

      return await _handleLangSupport(lang, _progressFor(lang));
    } else if (langsOption != null) {
      final langs = langsOption.split(',').map((e) => e.trim()).toList();

      return await _checkLangsSupport(langs);
    } else {
      logger.info('you will need to provide one or many langs to check.');

      var langPrompt = logger.prompt(
        'What language(s) do you want to check? (comma separated): ',
      );

      langPrompt = langPrompt.trim();

      if (langPrompt.isEmpty) {
        logger.err('No language(s) provided.');
        return ExitCode.usage.code;
      } else {
        final langs = langPrompt.split(',').map((e) => e.trim()).toList();
        if (langs.length == 1) {
          return await _handleLangSupport(
            langs.first,
            _progressFor(langs.first),
          );
        } else {
          return await _checkLangsSupport(langs);
        }
      }
    }
  }

  Future<int> _handleLangSupport(String lang, Progress prog) async {
    if (lang.split(',').length > 1) {
      logger.err('Only one language is allowed with the --lang flag');

      return ExitCode.usage.code;
    }

    try {
      prog.update('Checking language $lang support');

      final isSupported = await NetClient.instance.supportsLang(lang);
      if (isSupported) {
        prog.complete('Language $lang is supported.');
      } else {
        prog.complete('Language $lang is not supported.');
      }

      return ExitCode.success.code;
    } catch (e) {
      logger.customErr(
        error: e,
        progress: prog,
        update:
            'Something went wrong while checking language $lang support, please try again.',
      );

      return ExitCode.software.code;
    }
  }

  Future<int> _checkLangsSupport(List<String> langs) async {
    final langsStatusCode = <int>{};

    for (final lang in langs) {
      langsStatusCode.add(
        await _handleLangSupport(lang, _progressFor(lang)),
      );
    }

    return langsStatusCode.contains(ExitCode.software.code)
        ? ExitCode.software.code
        : ExitCode.success.code;
  }

  Progress _progressFor(String lang) {
    return logger.customProgress('Checking language $lang support');
  }
}
