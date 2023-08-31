import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:langsync/src/etc/models/user_info.dart';
import 'package:langsync/src/etc/utils.dart';

class NetClient {
  NetClient._();

  final client = HttpClient();

  static final NetClient _instance = NetClient._();

  static NetClient get instance => _instance;

  Future<UserInfo> userInfo({required String apiKey}) {
    return _makeRes<UserInfo>('users', 'GET', {
      'Authorization': 'Bearer $apiKey',
    }, (res) {
      return UserInfo.fromJson(res);
    });
  }

  Future<bool> supportsLang(String lang) {
    return _makeRes<bool>('langs/$lang', 'GET', {}, (res) {
      return res['isSupported'] as bool;
    });
  }

  Future<T> _makeRes<T>(
    String endpoint,
    String method,
    Map<String, String> headers,
    T Function(Map<String, dynamic> res) onSuccess,
  ) async {
    final uri = Uri.parse(utils.endpoint(endpoint));
    final request = http.Request(method, uri);

    request.headers.addAll({...headers});

    final res = await request.send();
    final asBytes = await res.stream.bytesToString();

    return onSuccess(jsonDecode(asBytes) as Map<String, dynamic>);
  }
}
