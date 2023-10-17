import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/controllers/config_file.dart';
import 'package:langsync/src/etc/controllers/yaml.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/models/lang_output.dart';
import 'package:langsync/src/etc/models/result_locale.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

class StartCommand extends Command<int> {
  StartCommand({
    required this.logger,
  });

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

    if (apiKey == null) {
      configFilesValidationProgress.fail(
        'You need to authenticate first with your account API key.',
      );

      logger.docsInfo(path: '/cli-usage/auth');

      return ExitCode.config.code;
    }

    ConfigFile configFile;

    try {
      final configFiles = ConfigFile.configFilesInCurrentDir.toList();

      configFile = _controllerFromFile(configFiles: configFiles);
    } catch (e) {
      return e as int;
    }

    if (!configFile.configFileRef.existsSync()) {
      configFilesValidationProgress.fail(
        'No ${configFile.configFileName} file found, you need to create one and configure it.',
      );

      logger.docsInfo(path: '/cli-usage/configure');

      return ExitCode.config.code;
    }

    configFilesValidationProgress
        .update('Parsing ${configFile.configFileName} file..');

    final parsedConfig = await configFile.parsed();

    try {
      configFilesValidationProgress
          .update('Validating ${configFile.configFileName} file..');

      configFile.validateConfigFields(parsedConfig);

      configFilesValidationProgress.complete(
          'Your ${configFile.configFileName} file and configuration are valid.');
    } catch (e, stacktrace) {
      logger.customErr(
        progress: configFilesValidationProgress,
        update: 'Something went wrong while validating your config file.',
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
      } catch (e) {}

      return ExitCode.config.code;
    }

    final asConfig = parsedConfig.toConfigModeled();

    final savingSourceFileProgress = logger.customProgress(
      'Saving your source file at ${asConfig.sourceFile}..',
    );

    try {
      final jsonPartitionRes = await NetClient.instance.savePartitionsJson(
        apiKey: apiKey,
        sourceFile: File(asConfig.sourceFile),
      );

      savingSourceFileProgress
          .complete('Your source file has been saved successfully.');

      logger
        ..info('\n')
        ..warn(
          'The ID of this operation is: ${jsonPartitionRes.partitionId}. in case of any issues, please contact us providing this ID so we can help.',
        );

      final result = await aIProcessResult(
        apiKey: apiKey,
        langs: asConfig.langs,
        partitionId: jsonPartitionRes.partitionId,
      );

      logger
        ..info('\n')
        ..info(
          'Generating localization files: ${asConfig.langsJsonFiles.join(", ")}.',
        );

      final outputList =
          await NetClient.instance.retrieveJsonPartitionWithOutput(
        outputPartitionId: result.outputPartitionId,
      );

      await _writeNewLocalizationFiles(
        outputList: outputList,
        outputDir: Directory(asConfig.outputDir),
        partitionId: jsonPartitionRes.partitionId,
      );

      logger.success('All done!');

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.customErr(
        error: e,
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
      } catch (e) {}

      return ExitCode.software.code;
    }
  }

  void _writeResultToFiles({
    required Map<String, JsonContentMap> res,
    required Directory outputDir,
  }) {
    final progress = logger.customProgress('Writing results to files..');

    res.forEach((key, value) {
      final file = File('${outputDir.path}/$key.json');

      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      progress.update('Writing $key.json');

      file.writeAsStringSync(value.toPrettyJson());
    });
  }

  Future<void> _writeNewLocalizationFiles({
    required List<LangOutput> outputList,
    required Directory outputDir,
    required String partitionId,
  }) async {
    for (var index = 0; index < outputList.length; index++) {
      final current = outputList[index];

      final isError = current.jsonFormattedResponse['langsyncError'] != null;

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
              'partitionId': partitionId,
              'processedResponse': current.jsonFormattedResponse.toString(),
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
              .convert(current.jsonFormattedResponse),
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

  Future<LangSyncServerResultSSE> aIProcessResult({
    required String apiKey,
    required Iterable<String> langs,
    required String partitionId,
  }) async {
    final completer = Completer<LangSyncServerResultSSE>();

    final processStream = NetClient.instance.startAIProcess(
      apiKey: apiKey,
      langs: langs,
      jsonPartitionId: partitionId,
    );

    LangSyncServerResultSSE? resultSSE;

    processStream.listen(
      (event) {
        if (event is LangSyncServerResultSSE) {
          resultSSE = event;
        } else {
          logger.info(event.message);
        }
      },
      onDone: () {
        completer.complete(resultSSE!);
      },
    );

    return completer.future;
  }

  ConfigFile _controllerFromFile({
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

    return ConfigFile.controllerFromFile(configFiles.first);
  }
}
