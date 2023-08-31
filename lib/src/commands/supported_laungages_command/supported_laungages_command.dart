import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

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
      logger.err("Can't use both --lang and --langs at the same time.");
      return ExitCode.usage.code;
    }

    if (langOption != null) {
      final lang = langOption.toLowerCase();
      return await _handleLangSupport(lang);
    } else if (langsOption != null) {
      final langs = langsOption.split(',').map((e) => e.trim()).toList();

      return await _checkLangsSupport(langs);
    } else {
      logger.info('you will need to provide one or many langs to check.');

      String langPrompt = logger.prompt(
        'What language(s) do you want to check? (comma separated): ',
      );

      langPrompt = langPrompt.trim();

      if (langPrompt.isEmpty) {
        logger.err('No language(s) provided.');
        return ExitCode.usage.code;
      } else {
        final langs = langPrompt.split(',').map((e) => e.trim()).toList();
        if (langs.length == 1) {
          return await _handleLangSupport(langs.first);
        } else {
          return await _checkLangsSupport(langs);
        }
      }
    }
  }

  Future<int> _handleLangSupport(String lang) async {
    try {
      final isSupported = await NetClient.instance.supportsLang(lang);
      if (isSupported) {
        logger.info('Language $lang is supported.');
      } else {
        logger.info('Language $lang is not supported.');
      }

      return ExitCode.success.code;
    } catch (e) {
      logger.err("Couldn't check language support.");

      return ExitCode.software.code;
    }
  }

  Future<int> _checkLangsSupport(List<String> langs) async {
    final langsStatusCode = <int>{};

    for (final lang in langs) {
      langsStatusCode.add(await _handleLangSupport(lang));
    }

    return langsStatusCode.contains(ExitCode.software.code)
        ? ExitCode.software.code
        : ExitCode.success.code;
  }
}