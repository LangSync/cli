import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/controllers/yaml.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

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

      if (file.existsSync()) {
        logger.info('langsync.yaml already exists in the current directory.');

        return await _requestToOverwrite(file);
      } else {
        return await _promptForConfigFileCreation();
      }
    } catch (e) {
      logger.err(e.toString());

      return ExitCode.software.code;
    }
  }

  Future<int> _requestToOverwrite(File file) async {
    final confirmOverwrite = logger.confirm('Do you want to overwrite it?');

    if (confirmOverwrite) {
      final deleteLogger =
          logger.customProgress('Deleting the existant langsync.yaml file');

      await file.delete();

      deleteLogger.complete(
          'The already existing langsync.yaml file is deleted successfully',);

      return run();
    } else {
      logger.info('Aborting');

      return ExitCode.success.code;
    }
  }

  Future<int> _promptForConfigFileCreation() async {
    final sourceLocalizationFilePath = logger.prompt(
      'Enter the path to the source localization file (e.g. ./locales/en.json): ',
    );

    final sourceFile = File(sourceLocalizationFilePath);

    if (!sourceFile.existsSync()) {
      logger.err(
        '''The source localization file at $sourceLocalizationFilePath does not exist.''',
      );

      return ExitCode.software.code;
    }

    final outputDir = logger.prompt(
      'Enter the path to the output directory (e.g. ./locales): ',
    );

    final outputDirectory = Directory(outputDir);

    if (!outputDirectory.existsSync()) {
      final confirmOverwrite = logger.confirm(
        '''The output directory at $outputDir does not exist, do you want to create it? (Y/n)''',
      );

      if (confirmOverwrite) {
        final createDirProgress =
            logger.customProgress('Creating the output directory');

        await outputDirectory.create(recursive: true);

        createDirProgress.complete(
          'The output directory is created successfully.',
        );
      } else {
        logger.info('Aborting');
        return ExitCode.success.code;
      }
    }

    final targetLangs = logger.prompt(
      'Enter the target languages (e.g. italian,spanish,german): ',
    );

    final targetLangsList = targetLangs.trim().split(',').map((e) => e.trim());

    if (targetLangsList.isEmpty) {
      logger.err('No target languages were provided.');

      return ExitCode.software.code;
    } else {
      if (targetLangsList.any((e) => e.length < 2)) {
        logger.err('Some of the target languages are invalid.');

        return ExitCode.software.code;
      }
    }

    final config = YamlController.futureYamlFormatFrom(
      outputDir: outputDir,
      sourceLocalizationFilePath: sourceLocalizationFilePath,
      targetLangsList: targetLangsList,
    );

    final creationProgress =
        logger.customProgress('Creating langsync.yaml file');

    try {
      await YamlController.createConfigFile();

      creationProgress.update(
        'langsync.yaml file IS created, updating it with your config...',
      );

      await YamlController.writeToConfigFile('langsync:\n');

      await YamlController.iterateAndWriteToConfigFile(config);

      creationProgress.complete(
        'langsync.yaml file created & updated with your config successfully.',
      );

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.customErr(
        error: e,
        progress: creationProgress,
        update:
            'Something went wrong while creating the langsync.yaml file, please try again.',
      );

      try {
        await NetClient.instance.logException(
          e: e,
          stacktrace: stacktrace,
          commandName: name,
        );

        logger.info('\n');
        logger.warn(
          'This error has been reported to the LangSync team, we will definitely look into it!',
        );
      } catch (e) {}

      return ExitCode.software.code;
    }
  }
}
