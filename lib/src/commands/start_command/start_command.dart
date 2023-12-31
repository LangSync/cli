import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/models/config.dart';
import 'package:langsync/src/etc/models/lang_output.dart';
import 'package:langsync/src/etc/models/result_locale.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template start_command}
/// The start command, it starts the localization process.
/// {@endtemplate}
class StartCommand extends Command<int> {
  /// {@macro start_command}
  StartCommand({required this.logger});

  /// The logger to use.
  final Logger logger;

  @override
  String get description => 'Starts the AI Powered localization process';

  @override
  String get name => 'start';

  @override
  FutureOr<int>? run() async {
    logger.info('Localizing process starting..');

    final configFilesValidationProgress =
        logger.customProgress('Localizing process starting..');

    final apiKey = Hive.box<dynamic>('config').get('apiKey') as String?;

    final apiKeyError = _ensureApiKeyExists(
      apiKey: apiKey,
      configFilesValidationProgress: configFilesValidationProgress,
    );

    if (apiKeyError != null) {
      return apiKeyError;
    }

    ConfigFileController configFile;

    try {
      configFile = _controllerFromFile();
    } catch (e) {
      return e as int;
    }

    final configFileExistsErrorCode = _ensureConfigFileExists(
      configFile: configFile,
      configFilesValidationProgress: configFilesValidationProgress,
    );

    if (configFileExistsErrorCode != null) {
      return configFileExistsErrorCode;
    }

    configFilesValidationProgress
        .update('Parsing ${configFile.configFileName} file..');

    final parsedConfig = await configFile.parsed();

    final errorCode = await _ensureConfigFileIsNotCorrupted(
      parsedConfig: parsedConfig,
      configFilesValidationProgress: configFilesValidationProgress,
      configFile: configFile,
    );

    if (errorCode != null) {
      return errorCode;
    }

    final asConfig = parsedConfig.toConfigModeled();

    final savingSourceFileProgress = logger.customProgress(
      'Saving your source file at ${asConfig.sourceFile}..',
    );

    return await _loadResourcesAndStartProcess(
      apiKey: apiKey,
      asConfig: asConfig,
      savingSourceFileProgress: savingSourceFileProgress,
    );
  }

  /// Writes the new localization files to the output directory, it contains the error handler as well for errored results.
  Future<void> _writeNewLocalizationFiles({
    required List<LangOutput> outputList,
    required Directory outputDir,
    required String operationId,
  }) async {
    for (var index = 0; index < outputList.length; index++) {
      final current = outputList[index];

      final isError = current.objectDecodedResponse['langsyncError'] != null;

      if (isError) {
        final fileName = '${current.lang}.error.json';

        logger.err(
          'An error occurred while localizing to ${current.lang} file, see $fileName for more details.',
        );

        final progress = logger.progress(
          'Creating error file ${current.lang}.error.json file..',
        );

        final file = File('${outputDir.path}/$fileName');

        await file.create();

        await file.writeAsString(
          const JsonEncoder.withIndent('   ').convert(
            {
              'message':
                  'Please, if you think that this is an unexpected bug in LangSync, contact us so we can help',
              'operationId': operationId,
              'processedResponse': current.objectDecodedResponse,
              'target_language': current.lang,
              'success_file_name': '${current.lang}.json',
              'LocalizationTryDate': {
                'human_readable_format': current.localizedAt.toHumanReadable(),
                'ISO_8601_format': current.localizedAt.toIso8601String(),
              },
              'contact_link': 'https://langsync.app/#contact',
            },
          ),
        );

        progress.complete(
          'file $fileName is created successfully, ${file.path.replaceAll("//", "/")}',
        );
      } else {
        final fileName = '${current.lang}.json';
        final progress = logger.customProgress('creating $fileName..');

        final file = File('${outputDir.path}/$fileName');

        await file.create();
        await file.writeAsString(
          const JsonEncoder.withIndent('   ')
              .convert(current.objectDecodedResponse),
        );

        progress.complete(
          'file $fileName is created successfully, ${file.path.replaceAll("//", "/")}',
        );
      }
    }
    logger
      ..info('\n')
      ..success('All files are created successfully.');
  }

  /// Starts the AI process and returns the result as a [LangSyncServerResultSSE] object.
  Future<LangSyncServerResultSSE> _aiProcessResult({
    required String apiKey,
    required Iterable<String> langs,
    required String operationId,
    required int? languageLocalizationMaxDelay,
    required String? instruction,
  }) async {
    final completer = Completer<LangSyncServerResultSSE>();

    final processStream = NetClient.instance.startAIProcess(
      apiKey: apiKey,
      langs: langs,
      operationId: operationId,
      languageLocalizationMaxDelay: languageLocalizationMaxDelay,
      instruction: instruction,
    );

    LangSyncServerResultSSE? resultSSE;

    processStream.listen(
      (events) {
        for (var i = 0; i < events.length; i++) {
          final curr = events[i];

          if (curr is LangSyncServerResultSSE) {
            resultSSE = curr;
          } else {
            logger.info(curr.message);
          }
        }
      },
      onDone: () {
        completer.complete(resultSSE!);
      },
    );

    return completer.future;
  }

  /// Returns the [ConfigFileController] that should be used.
  ConfigFileController _controllerFromFile() {
    final configFiles = ConfigFileController.configFilesInCurrentDir.toList();

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

  /// Ensures that the config file is not corrupted, and that it contains all the required and valid fields.
  Future<int?> _ensureConfigFileIsNotCorrupted({
    required Map<dynamic, dynamic> parsedConfig,
    required Progress configFilesValidationProgress,
    required ConfigFileController configFile,
  }) async {
    try {
      configFilesValidationProgress
          .update('Validating ${configFile.configFileName} file..');

      configFile.validateConfigFields(parsedConfig);

      configFilesValidationProgress.complete(
        'Your ${configFile.configFileName} file and configuration are valid.',
      );

      return null;
    } catch (e, stacktrace) {
      logger.customErr(
        progress: configFilesValidationProgress,
        update: 'Something went wrong while validating your config file.',
        stacktrace: stacktrace,
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
      } catch (e) {
        logger
          ..info('\n')
          ..warn(
            'This error could not be reported to the LangSync team, please report it manually, see https://docs.langsync.app/bug_report',
          );
      }

      return ExitCode.config.code;
    }
  }

  /// Ensures that the config file exists.
  int? _ensureConfigFileExists({
    required ConfigFileController configFile,
    required Progress configFilesValidationProgress,
  }) {
    if (!configFile.configFileRef.existsSync()) {
      configFilesValidationProgress.fail(
        'No ${configFile.configFileName} file found, you need to create one and configure it.',
      );

      logger.docsInfo(path: '/cli-usage/configure');

      return ExitCode.config.code;
    } else {
      return null;
    }
  }

  /// Ensures that the API key is saved in the local database, and that it exists.
  int? _ensureApiKeyExists({
    required Progress configFilesValidationProgress,
    String? apiKey,
  }) {
    if (apiKey == null) {
      configFilesValidationProgress.fail(
        'You need to authenticate first with your account API key.',
      );

      logger.docsInfo(path: '/cli-usage/auth');

      return ExitCode.config.code;
    } else {
      return null;
    }
  }

  /// Loads the resources and starts the localization process.
  Future<int> _loadResourcesAndStartProcess({
    required String? apiKey,
    required LangSyncConfig asConfig,
    required Progress savingSourceFileProgress,
  }) async {
    try {
      final jsonPartitionRes = await NetClient.instance.saveFile(
        apiKey: apiKey!,
        sourceFile: File(asConfig.sourceFile),
      );

      savingSourceFileProgress
          .complete('Your source file has been saved successfully.');

      logger
        ..info('\n')
        ..warn(
          'The ID of this operation is: ${jsonPartitionRes.operationId}. in case of any issues, please contact us providing this ID so we can help.',
        );

      final result = await _aiProcessResult(
        apiKey: apiKey,
        langs: asConfig.langs,
        languageLocalizationMaxDelay: asConfig.languageLocalizationMaxDelay,
        operationId: jsonPartitionRes.operationId,
        instruction: asConfig.instruction,
      );

      logger
        ..info('\n')
        ..info(
          'Generating localization files: ${asConfig.langsJsonFiles().join(", ")}.',
        );

      final outputList =
          await NetClient.instance.retrieveJsonPartitionWithOutput(
        outputOperationId: result.outputOperationId,
        apiKey: apiKey,
      );

      await _writeNewLocalizationFiles(
        outputList: outputList,
        outputDir: Directory(asConfig.outputDir),
        operationId: jsonPartitionRes.operationId,
      );

      logger.success('All done!');

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.customErr(
        error: e,
        stacktrace: stacktrace,
        progress: savingSourceFileProgress,
        update: 'Something went wrong, try again!',
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
