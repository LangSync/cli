import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:langsync/src/etc/enums.dart';

/// {@template lang_sync_server_sse}
/// A LangSync Server SSE model, it holds the message, the type, the status code and the date.
/// {@endtemplate}
class LangSyncServerSSE extends Equatable {
  /// {@macro lang_sync_server_sse}
  const LangSyncServerSSE({
    required this.message,
    required this.type,
    required this.statusCode,
    required this.date,
  });

  /// Creates a [LangSyncServerSSE] from a [Map].
  factory LangSyncServerSSE.fromJson(Map<String, dynamic> res) {
    final type = LangSyncServerSSEType.values.firstWhere(
      (element) => element.name == res['type'] as String,
    );

    if (type == LangSyncServerSSEType.result) {
      return LangSyncServerResultSSE.fromJson(res);
    } else {
      return LangSyncServerSSE(
        message: res['message'] as String,
        type: type,
        statusCode: res['statusCode'] as int,
        date: DateTime.parse(res['date'] as String),
      );
    }
  }

  /// The message of the SSE.
  final String message;

  /// The type of the SSE.
  final LangSyncServerSSEType type;

  /// The status code of the SSE.
  final int statusCode;

  /// The date of the SSE.
  final DateTime date;

  @override
  List<Object?> get props => [
        message,
        type,
        statusCode,
        date,
      ];
}

/// {@template lang_sync_server_result_sse}
/// A LangSync Server Result SSE model, it holds the message, the type, the status code, the date and the output operation id.
/// {@endtemplate}
class LangSyncServerResultSSE extends LangSyncServerSSE {
  /// {@macro lang_sync_server_result_sse}
  const LangSyncServerResultSSE({
    required this.outputOperationId,
    required super.message,
    required super.type,
    required super.statusCode,
    required super.date,
  });

  /// Creates a [LangSyncServerResultSSE] from a [Map].
  factory LangSyncServerResultSSE.fromJson(Map<String, dynamic> res) {
    final message = res['message'] as String;
    final decoded = jsonDecode(message) as Map<String, dynamic>;

    return LangSyncServerResultSSE(
      outputOperationId: decoded['operationId'] as String,
      message: message,
      statusCode: res['statusCode'] as int,
      type: // this is hardcoded, butsince we are sure that it is correct.
          LangSyncServerSSEType.result,
      date: DateTime.parse(
        res['date'] as String,
      ),
    );
  }

  /// The output operation id.
  final String outputOperationId;

  @override
  List<Object?> get props => [
        outputOperationId,
        super.message,
        super.type,
        super.statusCode,
        super.date,
      ];
}

/// {@template lang_sync_server_logger_sse}
/// A LangSync Server Logger SSE model, it holds the message, the type, the status code and the date.
/// {@endtemplate}
class LangSyncServerLoggerSSE extends LangSyncServerSSE {
  /// {@macro lang_sync_server_logger_sse}
  const LangSyncServerLoggerSSE({
    required super.date,
    required super.message,
    required super.statusCode,
    required super.type,
  });

  @override
  List<Object?> get props => [
        super.date,
        super.message,
        super.statusCode,
        super.type,
      ];
}
