// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

typedef JsonContentMap = Map<String, dynamic>;

enum LangSyncServerSSEType { info, warn, error, result }

class LangSyncServerSSE extends Equatable {
  final String message;
  final LangSyncServerSSEType type;
  final int statusCode;
  final DateTime date;

  const LangSyncServerSSE({
    required this.message,
    required this.type,
    required this.statusCode,
    required this.date,
  });
  @override
  List<Object?> get props => [
        message,
        type,
        statusCode,
        date,
      ];

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
}

class LangSyncServerResultSSE extends LangSyncServerSSE {
  final String outputoperationId;

  const LangSyncServerResultSSE({
    required this.outputoperationId,
    required super.message,
    required super.type,
    required super.statusCode,
    required super.date,
  });

  factory LangSyncServerResultSSE.fromJson(Map<String, dynamic> res) {
    final message = res['message'] as String;
    final decoded = jsonDecode(message) as Map<String, dynamic>;

    return LangSyncServerResultSSE(
      outputoperationId: decoded['operationId'] as String,
      message: message,
      statusCode: res['statusCode'] as int,
      type: // this is hardcoded, butsince we are sure that it is correct.
          LangSyncServerSSEType.result,
      date: DateTime.parse(
        res['date'] as String,
      ),
    );
  }

  @override
  List<Object?> get props => [
        outputoperationId,
        super.message,
        super.type,
        super.statusCode,
        super.date,
      ];
}

class LangSyncServerLoggerSSE extends LangSyncServerSSE {
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
