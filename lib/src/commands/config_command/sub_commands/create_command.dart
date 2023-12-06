import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/models/config.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

class ConfigCreateCommand extends Command<int> {
  ConfigCreateCommand({
    required this.logger,
  }) {
    argParser
      ..addFlag(
        'json',
        help: 'Create a JSON file for the configuration (langsync.json)',
        negatable: false,
        abbr: 'j',
      )
      ..addFlag(
        'yaml',
        help: 'Create a YAML file for the configuration (langsync.yaml)',
        negatable: false,
        abbr: 'y',
        aliases: ['yml'],
      );
  }

  final Logger logger;

  @override
  String get description =>
      'Creates a new LangSync configuration file in the current directory, you can also specify the type of the configuration file (JSON, YAML)';

  @override
  String get name => 'create';

  @override
  Future<int> run() async {
    final configFileController =
        ConfigFileController.fromArgResults(argResults!);

    try {
      final file = configFileController.configFileRef;

      if (file.existsSync()) {
        logger.info(
          '${configFileController.configFileName} already exists in the current directory.',
        );

        return await _requestToOverwrite(file, configFileController);
      } else {
        return await _promptForConfigFileControllerCreation(
            configFileController);
      }
    } catch (e) {
      logger.err(e.toString());

      return ExitCode.software.code;
    }
  }

  Future<int> _requestToOverwrite(
    File file,
    ConfigFileController configFileController,
  ) async {
    final confirmOverwrite = logger.confirm('Do you want to overwrite it?');

    if (confirmOverwrite) {
      final deleteLogger = logger.customProgress(
        'Deleting the existent ${configFileController.configFileName} file',
      );

      await file.delete();

      deleteLogger.complete(
        'The already existing ${configFileController.configFileName} file is deleted successfully',
      );

      return run();
    } else {
      logger.info('Aborting');

      return ExitCode.success.code;
    }
  }

  Future<int> _promptForConfigFileControllerCreation(
    ConfigFileController configFileController,
  ) async {
    const examplePath = './locales/en.json';

    var sourceLocalizationFilePath = logger.prompt(
      'Enter the path to the source localization file (e.g. $examplePath): ',
    );

    sourceLocalizationFilePath = sourceLocalizationFilePath.isEmpty
        ? examplePath
        : sourceLocalizationFilePath;

    final sourceFile = File(
      sourceLocalizationFilePath,
    );

    if (!sourceFile.existsSync()) {
      logger
        ..err(
          'The source localization file at $sourceLocalizationFilePath does not exist.',
        )
        ..docsInfo(path: '/cli-usage/configure');

      return ExitCode.software.code;
    }

    const defaultOutpitDir = './locales';

    var outputDir = logger.prompt(
      'Enter the path to the output directory (e.g. $defaultOutpitDir): ',
    );

    outputDir = outputDir.isEmpty ? defaultOutpitDir : outputDir;

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
        logger
          ..info('Aborting')
          ..docsInfo(path: '/cli-usage/configure');

        return ExitCode.success.code;
      }
    }

    const defaultTarget = 'zh, ru, ar, fr';

    var targetLangs = logger.prompt(
      'Enter the target languages (e.g. $defaultTarget): ',
    );

    targetLangs = targetLangs.isEmpty ? defaultTarget : targetLangs;

    final targetLangsList = targetLangs.trim().split(',').map((e) => e.trim());

    if (targetLangsList.any((e) => e.length < 2)) {
      logger.err('Some of the target languages are invalid.');

      return ExitCode.software.code;
    }

    final instruction = logger.prompt(
      'Enter your AI instruction (optional): ',
    );

    // Create the config with the given
    final config = LangSyncConfig(
      outputDir: outputDir,
      sourceFile: sourceLocalizationFilePath,
      langs: targetLangsList,
      instruction: instruction,
    ).toMap();

    final creationProgress = logger.customProgress(
      'Creating ${configFileController.configFileName} file',
    );

    try {
      await configFileController.createConfigFile();

      creationProgress.update(
        '${configFileController.configFileName} file is created, updating it with your config...',
      );

      configFileController.writeNewConfig(config);

      creationProgress.complete(
        '${configFileController.configFileName} file created & updated with your config successfully.',
      );

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.customErr(
        error: e,
        progress: creationProgress,
        update:
            'Something went wrong while creating the ${configFileController.configFileName} file, please try again.',
        stacktrace: stacktrace,
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
      } catch (e) {
        logger
          ..info('\n')
          ..warn(
            'This error could not be reported to the LangSync team, please report it manually, see https://docs.langsync.app/bug_report',
          );
      }

      return ExitCode.software.code;
    }
  }
}
