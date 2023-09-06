import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hive/hive.dart';
import 'package:langsync/src/etc/controllers/yaml.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/networking/client.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../etc/models/result_locale.dart';

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

    final jsonPartitionRes = await NetClient.instance.savePartitionsJson(
      apiKey: apiKey,
      sourceFile: File(asConfig.sourceFile),
    );

    final langsL = asConfig.langs.toList();

    try {
      final result = await NetClient.instance.startAIProcess(
        apiKey: apiKey,
        asConfig: asConfig,
        jsonPartitionId: jsonPartitionRes.partitionId,
      );

      _writeResultToFiles(
        outputDir: Directory(asConfig.outputDir),
        res: result.result,
      );

      localizationProgress.complete('Localization Process completed');

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
}
