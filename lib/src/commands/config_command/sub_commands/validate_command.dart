import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:mason_logger/mason_logger.dart';

class ConfigValidateCommand extends Command<int> {
  ConfigValidateCommand({
    required this.logger,
  });

  final Logger logger;

  @override
  String get description =>
      'Show the current config file in the current directory if it exists.';

  @override
  String get name => 'validate';

  @override
  Future<int>? run() async {
    final configFiles = ConfigFileController.configFilesInCurrentDir.toList();

    ConfigFileController configFile;

    try {
      configFile = _controllerFromFile(configFiles: configFiles);
    } catch (e) {
      return e as int;
    }

    final validationProgress = logger.customProgress(
      'Validating the existent ${configFile.configFileName} file',
    );

    final configMap = await configFile.parsed();

    final langsyncConfig = configMap['langsync'];

    if (langsyncConfig == null) {
      validationProgress.complete(
        '${configFile.configFileName} file is missing a `langsync` key.',
      );

      return ExitCode.software.code;
    } else {
      validationProgress.update('Parsing the configuration file');

      final parsedLangsyncMap = await configFile.parsed();

      validationProgress.update('Validating the configuration file');

      final isValid = configFile.validateConfigFields(parsedLangsyncMap);

      validationProgress.complete('Validation task completed.');

      if (isValid) {
        configFile.iterateAndLogConfig(parsedLangsyncMap, logger);

        logger.info('${configFile.configFileName} file is valid.');
        return ExitCode.success.code;
      } else {
        logger
          ..info('${configFile.configFileName} file is invalid.')
          ..info(
            '''
            Please check your ${configFile.configFileName} file, or run `langsync config create` to create a new one.
            ''',
          )
          ..docsInfo(path: '/cli-usage/configure');

        return ExitCode.software.code;
      }
    }
  }

  ConfigFileController _controllerFromFile({
    required List<FileSystemEntity> configFiles,
  }) {
    if (configFiles.isEmpty) {
      logger
        ..info(
          'There is no LangSync configuration file in the current directory.',
        )
        ..info('Run `langsync config create` to create one.')
        ..docsInfo(path: '/cli-usage/configure');

      throw ExitCode.software.code;
    }

    if (configFiles.length > 1) {
      logger.info(
        'There are multiple LangSync configuration files in the current directory, please remove the extra ones and try again.',
      );

      throw ExitCode.software.code;
    }

    return ConfigFileController.controllerFromFile(configFiles.first);
  }
}
