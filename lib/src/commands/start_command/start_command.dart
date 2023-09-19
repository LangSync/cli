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
    final localizationProgress = logger.progress('Starting localization');

    final apiKey = Hive.box<dynamic>('config').get('apiKey') as String?;

    if (apiKey == null) {
      localizationProgress.fail(
        'You need to authenticate first with your account API key.',
      );

      return ExitCode.config.code;
    }

    if (!YamlController.configFileRef.existsSync()) {
      localizationProgress.fail(
        'No langsync.yaml file found for configuration',
      );

      return ExitCode.config.code;
    }

    final parsedYaml = await YamlController.parsedYaml;

    try {
      YamlController.validateConfigFields(parsedYaml);
    } catch (e) {
      logger.customErr(
        progress: localizationProgress,
        update: 'Something went wrong while validating config file',
        error: e,
      );

      return ExitCode.config.code;
    }

    final asConfig = parsedYaml.toConfigModeled();

    localizationProgress.update(
      'Processing the provided source File at; ${asConfig.sourceFile}',
    );

    try {
      final jsonPartitionRes = await NetClient.instance.savePartitionsJson(
        apiKey: apiKey,
        sourceFile: File(asConfig.sourceFile),
      );

      localizationProgress
          .update('Your source file has been saved succesfully.');

      logger.info(
        '\n The ID of this operation is: ${jsonPartitionRes.partitionId}',
      );

      localizationProgress.update('Starting localization & translation..');

      final result = await NetClient.instance.startAIProcess(
        apiKey: apiKey,
        asConfig: asConfig,
        jsonPartitionId: jsonPartitionRes.partitionId,
      );

      localizationProgress.complete(
        'Localization Process completed, creating output files..',
      );

      final outputList =
          await NetClient.instance.retrieveJsonPartitionWithOutput(
        outputPartitionId: result.outputPartitionId,
      );

      logger.info(outputList.toString());

      await _writeNewLocalizationFiles(
        outputList: outputList,
        outputDir: Directory(asConfig.outputDir),
      );

      return ExitCode.success.code;
    } catch (e) {
      logger.customErr(
        progress: localizationProgress,
        update: 'Something went wrong while starting localization',
        error: e,
      );

      return ExitCode.software.code;
    }
  }

  void _writeResultToFiles({
    required Map<String, JsonContentMap> res,
    required Directory outputDir,
  }) {
    final progress = logger.progress('Writing results to files..');

    res.forEach((key, value) {
      final file = File('${outputDir.path}/$key.json');

      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      progress.update('Writing $key.json...');

      file.writeAsStringSync(value.toPrettyJson());
    });
  }

  Future<void> _writeNewLocalizationFiles({
    required List<LangOutput> outputList,
    required Directory outputDir,
  }) async {
    for (int index = 0; index < outputList.length; index++) {
      final current = outputList[index];

      final fileName = '${current.lang}.json';

      final file = File('${outputDir.path}/$fileName');

      await file.create();
      await file.writeAsString(
        const JsonEncoder.withIndent('   ')
            .convert(current.jsonFormattedResponse),
      );
      logger.info('file $fileName is created succesfully, ');
    }

    logger.info('All files are created ${outputDir.path} ');
  }
}
