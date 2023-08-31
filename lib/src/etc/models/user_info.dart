import 'package:equatable/equatable.dart';
import 'package:langsync/src/etc/extensions.dart';

class UserInfo extends Equatable {
  const UserInfo({
    required this.userId,
    required this.createdAt,
    required this.apiKeysLength,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return UserInfo(
      userId: userJson['userId'] as String,
      createdAt: DateTime.parse(userJson['createdAt'] as String),
      apiKeysLength: userJson['apiKeysLength'] is int
          ? userJson['apiKeysLength'] as int
          : int.parse(userJson['apiKeysLength'] as String),
    );
  }

  final String userId;
  final DateTime createdAt;
  final int apiKeysLength;

  @override
  List<Object?> get props => [
        userId,
        createdAt,
        apiKeysLength,
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'User ID': userId,
      'User Account Creation Time': createdAt.toProperHumanReadableDate(),
      'available API keys': apiKeysLength,
    };
  }
}
