// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

typedef JsonContentMap = Map<String, dynamic>;

class LocalizationResult extends Equatable {
  final Map<String, JsonContentMap> result;

  const LocalizationResult({
    required this.result,
  });

  factory LocalizationResult.fromJson(Map<String, dynamic> res) {
    return LocalizationResult(
      result: res['result'] as Map<String, JsonContentMap>,
    );
  }

  @override
  List<Object?> get props => [
        result,
      ];
}
