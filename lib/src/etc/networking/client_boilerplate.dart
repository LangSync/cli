import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:langsync/src/etc/utils.dart';

class NetClientBoilerPlate {
  Future<T> makeRes<T>(
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

  Future<T> makeMultiPartRes<T>(
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

  Stream<T> sseStreamReq<T>(
    String endpoint,
    String method,
    Map<String, String> headers,
    Map<String, dynamic> body,
    T Function(String res) onSuccess,
  ) {
    final controller = StreamController<T>.broadcast();

    final uri = Uri.parse(utils.endpoint(endpoint));
    final request = http.Request(method, uri);

    request.headers.addAll({
      ...headers,
      'Content-Type': 'application/json',
    });

    request.body = jsonEncode(body);

    request.send().then(
      (streamedRes) {
        streamedRes.stream
            .transform(utf8.decoder)
            // .transform(json.decoder)
            .map((data) => onSuccess(data))
            .listen(
          (event) {
            controller.sink.add(event);
          },
          onError: (Object e) {
            controller.sink.addError(e);
          },
          cancelOnError: true,
          onDone: controller.close,
        );
      },
    );

    return controller.stream;
  }
}
