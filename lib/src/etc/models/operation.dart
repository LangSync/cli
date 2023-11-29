// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class PartitionResponse extends Equatable {
  final String operationId;

  const PartitionResponse({
    required this.operationId,
  });

  factory PartitionResponse.fromJson(Map<String, dynamic> json) {
    return PartitionResponse(
      operationId: json['operationId'] as String,
    );
  }

  @override
  List<Object?> get props => [
        operationId,
      ];
}
