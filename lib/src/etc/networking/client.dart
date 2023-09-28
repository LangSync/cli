import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:langsync/src/etc/models/api_key_res.dart';
import 'package:langsync/src/etc/models/config.dart';
import 'package:langsync/src/etc/models/partition.dart';
import 'package:langsync/src/etc/models/result_locale.dart';
import 'package:langsync/src/etc/models/user_info.dart';
import 'package:langsync/src/etc/utils.dart';

import '../models/lang_output.dart';

class NetClient {
  NetClient._();

  final client = HttpClient();

  static final NetClient _instance = NetClient._();

  static NetClient get instance => _instance;

  Future<UserInfo> userInfo({required String apiKey}) {
    return _makeRes<UserInfo>('user', 'GET', {
      'Authorization': 'Bearer $apiKey',
    }, {}, (res) {
      return UserInfo.fromJson(res);
    });
  }

  Future<Map<String, bool>> supportsLang(List<String> lang) {
    return _makeRes<Map<String, bool>>('/langs-support', 'POST', {}, {
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

  Future<T> _makeRes<T>(
    String endpoint,
    String method,
    Map<String, String> headers,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> res) onSuccess,
  ) async {
    final uri = Uri.parse(utils.endpoint(endpoint));

    final request = http.Request(method, uri);

    request.headers.addAll({
      ...headers,
      'Content-Type': 'application/json',
    });

    // include body in request.

    request.body = json.encode(body);

    final res = await request.send();
    final asBytes = await res.stream.bytesToString();

    final decoded = jsonDecode(asBytes) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return onSuccess(decoded);
    } else {
      throw Exception(decoded);
    }
  }

  Future<T> _makeMultiPartRes<T>(
    String endpoint,
    String method,
    Map<String, String> headers,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> res) onSuccess,
  ) async {
    final uri = Uri.parse(utils.endpoint(endpoint));
    final request = http.MultipartRequest(method, uri);

    request.headers.addAll({...headers});
    body.forEach((key, value) {
      if (value is File) {
        final multipartFile = http.MultipartFile.fromBytes(
          key,
          value.readAsBytesSync(),
          filename: value.path.split('/').last,
        );

        request.files.add(multipartFile);
      } else {
        request.fields[key] = value.toString();
      }
    });

    final res = await request.send();
    final asBytes = await res.stream.bytesToString();

    return onSuccess(jsonDecode(asBytes) as Map<String, dynamic>);
  }

  Future<LocalizationOutput> startAIProcess({
    required LangSyncConfig asConfig,
    required String apiKey,
    required String jsonPartitionId,
    bool includeOutput = false,
  }) {
    return _makeRes(
      '/process-translation',
      'POST',
      {'Authorization': 'Bearer $apiKey'},
      {
        'jsonPartitionsId': jsonPartitionId,
        'langs': asConfig.langs.toList(),
        'includeOutput': includeOutput,
      },
      LocalizationOutput.fromJson,
    );
  }

  Future<PartitionResponse> savePartitionsJson({
    required String apiKey,
    required File sourceFile,
  }) {
    return _makeMultiPartRes(
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
    return _makeRes(
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
    return _makeRes(
      "/get-partitioned-json-of-user",
      "GET",
      {},
      {
        "jsonPartitionsId": outputPartitionId,
      },
      (res) {
        final output = (res["output"] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final modelled = output.map(LangOutput.fromJson).toList();

        return modelled;
      },
    );
  }

  Future<APIKeyResponse> createApiKey(String userName) {
    return _makeRes('/create-account-with-api-key-beta', 'POST', {}, {
      'username': userName,
    }, (res) {
      return APIKeyResponse.fromJson(res);
    });
  }
}
