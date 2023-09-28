import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
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
        'You need to authenticate first with your account API key, see Docs.',
      );

      return ExitCode.config.code;
    }

    if (!YamlController.configFileRef.existsSync()) {
      configFilesValidationProgress.fail(
        'No langsync.yaml file found, you need to create one and configure it.',
      );

      return ExitCode.config.code;
    }
    configFilesValidationProgress.update('Parsing langsync.yaml file..');

    final parsedYaml = await YamlController.parsedYaml;

    try {
      configFilesValidationProgress.update('Validating langsync.yaml file..');

      YamlController.validateConfigFields(parsedYaml);
      configFilesValidationProgress
          .complete('Your langsync.yaml file and configuration are valid.');
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

        logger.warn(
          '\nThis error has been reported to the LangSync team, we will definitely look into it!',
        );
      } catch (e) {}

      return ExitCode.config.code;
    }

    final asConfig = parsedYaml.toConfigModeled();

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
            // ..info("\n")
            ..warn(
              'The ID of this operation is: ${jsonPartitionRes.partitionId}. in case of any issues, please contact us providing this ID so we can help.',
            )
          // ..info("\n")
          ;

      final localizationProgress = logger.customProgress(
        'Starting localization & translation to your target languages..',
      );

      final result = await NetClient.instance.startAIProcess(
        apiKey: apiKey,
        asConfig: asConfig,
        jsonPartitionId: jsonPartitionRes.partitionId,
      );

      localizationProgress.complete(
        'Localization operation is completed successfully.',
      );

      logger.info('\n');

      logger.info(
        'Generating localization files: ${asConfig.langsJsonFiles.join(", ")}:',
      );

      final outputList =
          await NetClient.instance.retrieveJsonPartitionWithOutput(
        outputPartitionId: result.outputPartitionId,
      );

      await _writeNewLocalizationFiles(
        outputList: outputList,
        outputDir: Directory(asConfig.outputDir),
      );

      logger.success('All done!');

      return ExitCode.success.code;
    } catch (e, stacktrace) {
      logger.err(
        'Something went wrong while starting localization',
      );

      //   logger.customErr(
      //     progress: localizationProgress,
      //     update: 'Something went wrong while starting localization',
      //     error: stacktrace,
      //   );

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
  }) async {
    for (var index = 0; index < outputList.length; index++) {
      final current = outputList[index];
      final fileName = '${current.lang}.json';

      final progress = logger.customProgress('creating $fileName..');

      final file = File('${outputDir.path}/$fileName');

      await file.create();
      await file.writeAsString(
        const JsonEncoder.withIndent('   ')
            .convert(current.jsonFormattedResponse),
      );

      progress.complete('file $fileName is created successfully, ${file.path}');
    }

    logger.success('All files are created successfully.');
  }
}
