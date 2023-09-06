import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:langsync/src/etc/models/config.dart';
import 'package:langsync/src/etc/models/user_info.dart';
import 'package:langsync/src/etc/utils.dart';
import 'package:langsync/src/etc/models/partition.dart';
import 'package:langsync/src/etc/models/result_locale.dart';

class NetClient {
  NetClient._();

  final client = HttpClient();

  static final NetClient _instance = NetClient._();

  static NetClient get instance => _instance;

  Future<UserInfo> userInfo({required String apiKey}) {
    return _makeRes<UserInfo>('users', 'GET', {
      'Authorization': 'Bearer $apiKey',
    }, {}, (res) {
      return UserInfo.fromJson(res);
    });
  }

  Future<bool> supportsLang(String lang) {
    return _makeRes<bool>('langs/$lang', 'GET', {}, {}, (res) {
      return res['isSupported'] as bool;
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

    request.headers.addAll({...headers});

    final res = await request.send();
    final asBytes = await res.stream.bytesToString();

    return onSuccess(jsonDecode(asBytes) as Map<String, dynamic>);
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

  Future<LocalizationResult> startAIProcess({
    required LangSyncConfig asConfig,
    required String apiKey,
    required String jsonPartitionId,
  }) {
    return _makeRes(
      '/process-translation',
      'POST',
      {'Authorization': 'Bearer $apiKey'},
      {'jsonPartitionId': jsonPartitionId, 'langs': asConfig.langs},
      LocalizationResult.fromJson,
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
}
