import 'package:equatable/equatable.dart';

class APIKeyResponse extends Equatable {
  const APIKeyResponse({
    required this.username,
    required this.apiKey,
  });

  factory APIKeyResponse.fromJson(Map<String, dynamic> json) {
    return APIKeyResponse(
      username: json['username'] as String,
      apiKey: json['apiKey'] as String,
    );
  }

  final String username;
  final String apiKey;

  @override
  List<Object?> get props => [username, apiKey];
}
