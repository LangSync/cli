import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:yaml/yaml.dart' as yaml;

class ConfigCreateCommand extends Command<int> {
  ConfigCreateCommand({
    required this.logger,
  });

  final Logger logger;

  @override
  String get description =>
      'Creates a new langsync.yaml file in the current directory.';

  @override
  String get name => 'create';
  @override
  Future<int> run() async {
    try {
      final file = File('./langsync.yaml');

      if (await file.exists()) {
        logger.info('langsync.yaml already exists in the current directory.');

        await _requestToOverwrite(file);
        return ExitCode.success.code;
      } else {
        await _promptForConfigFileCreation();

        return ExitCode.success.code;
      }
    } catch (e) {
      logger.err(e.toString());

      return ExitCode.software.code;
    }
  }

  Future<void> _requestToOverwrite(File file) async {
    final userAnswer = logger.prompt('Do you want to overwrite it? (Y/n)');
    final toL = userAnswer.toLowerCase();
    if (toL == 'y' || toL == 'yes' || toL == 'yep' || toL == 'yeah') {
      logger.info('Overwriting...');
      await file.delete();
      await run();
    } else {
      logger.info('Aborting...');
      return;
    }
  }

  Future<void> _promptForConfigFileCreation() async {
    final sourceLocalizationFilePath = logger.prompt(
      'Enter the path to the source localization file (e.g. ./locales/en.json): ',
    );
    final sourceFile = File(sourceLocalizationFilePath);

    if (!sourceFile.existsSync()) {
      logger.err(
        '''The source localization file at $sourceLocalizationFilePath does not exist. Please try again.''',
      );

      return;
    }

    final outputDir = logger.prompt(
      'Enter the path to the output directory (e.g. ./locales): ',
    );

    final outputDirectory = Directory(outputDir);

    if (!outputDirectory.existsSync()) {
      logger.err(
        '''The output directory at $outputDir does not exist. Please try again.''',
      );

      return;
    }

    final targetLangs = logger.prompt(
      'Enter the target languages (e.g. italian,spanish,german): ',
    );

    final targetLangsList = targetLangs.trim().split(',').map((e) => e.trim());
    if (targetLangsList.isEmpty) {
      logger.err('No target languages were provided. Please try again.');
      return;
    }

    final config = {
      'source': sourceLocalizationFilePath,
      'output': outputDir,
      'target': targetLangsList,
    };

    final configYaml = logger.info('Creating langsync.yaml file...');
    final yamlFile = await File('./langsync.yaml').create();
    await yamlFile.writeAsString("langsync:");

    for (final entr in config.entries) {
      await yamlFile.writeAsString(
        "\n  ${entr.key}: ${entr.value}",
        mode: FileMode.append,
      );
    }

    logger.info('langsync.yaml file created successfully.');
  }
}
