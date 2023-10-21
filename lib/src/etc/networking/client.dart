import 'dart:convert';
import 'dart:io';
import 'package:langsync/src/etc/models/api_key_res.dart';
import 'package:langsync/src/etc/models/lang_output.dart';
import 'package:langsync/src/etc/models/partition.dart';
import 'package:langsync/src/etc/models/result_locale.dart';
import 'package:langsync/src/etc/models/user_info.dart';
import 'package:langsync/src/etc/networking/client_boilerplate.dart';
import 'package:langsync/src/version.dart';

class NetClient extends NetClientBoilerPlate {
  NetClient._();

  final client = HttpClient();

  static final NetClient _instance = NetClient._();

  static NetClient get instance => _instance;

  Future<UserInfo> userInfo({required String apiKey}) {
    return makeRes<UserInfo>('user', 'GET', {
      'Authorization': 'Bearer $apiKey',
    }, {}, (res) {
      return UserInfo.fromJson(res);
    });
  }

  Future<Map<String, bool>> supportsLang(List<String> lang) {
    return makeRes<Map<String, bool>>('/langs-support', 'POST', {}, {
      'langs': lang,
    }, (res) {
      final map = <String, bool>{};

      final list = (res['checkResultList'] as List<dynamic>).cast<String>();

      for (final element in list) {
        map[element] = true;
      }

      return map;
    });
  }

  Stream<List<LangSyncServerSSE>> startAIProcess({
    required Iterable<String> langs,
    required String apiKey,
    required String jsonPartitionId,
    required int? languageLocalizationMaxDelay,
    bool includeOutput = false,
  }) {
    return sseStreamReq<List<LangSyncServerSSE>>(
      '/process-translation',
      'POST',
      {'Authorization': 'Bearer $apiKey'},
      {
        'jsonPartitionsId': jsonPartitionId,
        'langs': langs.toList(),
        'includeOutput': includeOutput,
        'languageLocalizationMaxDelay': languageLocalizationMaxDelay,
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

  Future<PartitionResponse> savePartitionsJson({
    required String apiKey,
    required File sourceFile,
  }) {
    return makeMultiPartRes(
      '/save-partitioned-json-of-user',
      'post',
      {'Authorization': 'Bearer $apiKey'},
      {'sourceFile': sourceFile},
      PartitionResponse.fromJson,
    );
  }

  Future<bool> checkWetherApiKeyExistsForSomeUser({
    required String apiKey,
  }) async {
    return makeRes(
      '/verify-api-key-existence',
      'GET',
      {'Authorization': 'Bearer $apiKey'},
      {},
      (res) {
        final exists = res['exists'] as bool?;

        if (exists == null) {
          throw Exception(
            "the 'exists' field does not exist in the response of this API endpoint",
          );
        }
        return exists;
      },
    );
  }

  Future<List<LangOutput>> retrieveJsonPartitionWithOutput({
    required String outputPartitionId,
  }) {
    return makeRes(
      '/get-partitioned-json-of-user',
      'GET',
      {},
      {
        'jsonPartitionsId': outputPartitionId,
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
