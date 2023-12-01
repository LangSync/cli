import 'dart:convert';
import 'dart:io';
import 'package:langsync/src/etc/models/api_key_res.dart';
import 'package:langsync/src/etc/models/config.dart';
import 'package:langsync/src/etc/models/lang_output.dart';
import 'package:langsync/src/etc/models/operation.dart';
import 'package:langsync/src/etc/models/result_locale.dart';
import 'package:langsync/src/etc/models/user_info.dart';
import 'package:langsync/src/etc/networking/client_boilerplate.dart';
import 'package:langsync/src/version.dart';

class NetClient extends NetClientBoilerPlate {
  NetClient._();

  final client = HttpClient();

  static final NetClient _instance = NetClient._();

  static NetClient get instance => _instance;

  Stream<List<LangSyncServerSSE>> startAIProcess({
    required Iterable<String> langs,
    required String apiKey,
    required String operationId,
    bool includeOutput = false,
    required int? languageLocalizationMaxDelay,
    required String? instruction,
  }) {
    return sseStreamReq<List<LangSyncServerSSE>>(
      '/process-translation',
      'POST',
      {'Authorization': 'Bearer $apiKey'},
      {
        'operationId': operationId,
        'langs': langs.toList(),
        'includeOutput': includeOutput,
        'languageLocalizationMaxDelay': languageLocalizationMaxDelay,
        if (instruction != null && instruction.isNotEmpty)
          'instruction': instruction,
      },
      (res) {
        final split = res.split('\n\n').where((element) => element.isNotEmpty);

        return split.map((event) {
          final decodedEvent = jsonDecode(event.trim().replaceAll('\n', ''))
              as Map<String, dynamic>;

          return LangSyncServerSSE.fromJson(decodedEvent);
        }).toList();
      },
    );
  }

  Future<PartitionResponse> saveFile({
    required String apiKey,
    required File sourceFile,
  }) {
    return makeMultiPartRes(
      'json/save-file',
      'post',
      {'Authorization': 'Bearer $apiKey'},
      {'sourceFile': sourceFile},
      PartitionResponse.fromJson,
    );
  }

  Future<List<LangOutput>> retrieveJsonPartitionWithOutput({
    required String outputoperationId,
    required String apiKey,
  }) {
    return makeRes(
      '/file-operation-of-user',
      'GET',
      {
        'Authorization': 'Bearer ${apiKey}',
      },
      {
        'operationId': outputoperationId,
      },
      (res) {
        final output = (res['output'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final modelled = output.map(LangOutput.fromJson).toList();

        return modelled;
      },
    );
  }

  Future<APIKeyResponse> createApiKey(String userName) {
    return makeRes('/create-account-with-api-key-beta', 'POST', {}, {
      'username': userName,
    }, (res) {
      return APIKeyResponse.fromJson(res);
    });
  }

  Future<void> logException({
    required Object e,
    required StackTrace stacktrace,
    required String commandName,
    String? processId,
  }) {
    return makeRes(
      '/log-exception',
      'POST',
      {},
      {
        'exception': e.toString(),
        'stacktrace': stacktrace.toString(),
        'platform': Platform.operatingSystem,
        'langsyncVersion': packageVersion,
        'Date': DateTime.now().toIso8601String(),
        'processId': processId,
        'commandName': commandName,
      },
      (res) {},
    );
  }
}
