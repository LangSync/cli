import 'package:equatable/equatable.dart';

/// {@template operation}
/// An Operation model, it holds the operation id and the operation type.
/// {@endtemplate}
class SaveFileOperation extends Equatable {
  /// {@macro operation}
  const SaveFileOperation({
    required this.operationId,
  });

  /// Creates a [SaveFileOperation] from a [Map].
  factory SaveFileOperation.fromJson(Map<String, dynamic> json) {
    return SaveFileOperation(
      operationId: json['operationId'] as String,
    );
  }

  /// The operation id.
  final String operationId;

  @override
  List<Object?> get props => [
        operationId,
      ];
}
