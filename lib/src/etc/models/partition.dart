// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class PartitionResponse extends Equatable {
  final String partitionId;

  const PartitionResponse({
    required this.partitionId,
  });

  factory PartitionResponse.fromJson(Map<String, dynamic> json) {
    print(json);

    return PartitionResponse(
      partitionId: json['partitionId'] as String,
    );
  }

  @override
  List<Object?> get props => [
        partitionId,
      ];
}
