// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

typedef JsonContentMap = Map<String, dynamic>;

class LocalizationOutput extends Equatable {
  final String outputPartitionId;

  const LocalizationOutput({
    required this.outputPartitionId,
  });

  factory LocalizationOutput.fromJson(Map<String, dynamic> res) {
    return LocalizationOutput(
      outputPartitionId: res['partitionId'] as String,
    );
  }

  @override
  List<Object?> get props => [outputPartitionId];
}
