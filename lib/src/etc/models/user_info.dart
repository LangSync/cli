import 'package:equatable/equatable.dart';
import 'package:langsync/src/etc/extensions.dart';
import 'package:langsync/src/etc/models/Localization_doc.dart';

class UserInfo extends Equatable {
  const UserInfo({
    required this.userId,
    required this.createdAt,
    required this.apiKeysLength,
    required this.localizationDocs,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return UserInfo(
      userId: userJson['userId'] as String,
      createdAt: DateTime.parse(userJson['createdAt'] as String),
      apiKeysLength: userJson['apiKeysLength'] is int
          ? userJson['apiKeysLength'] as int
          : int.parse(userJson['apiKeysLength'] as String),
      localizationDocs: (userJson['localizationDocs'] as List<dynamic>)
          .map(
            (dynamic e) => LocalizationDoc.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String userId;
  final DateTime createdAt;
  final int apiKeysLength;
  final List<LocalizationDoc> localizationDocs;

  @override
  List<Object?> get props => [
        userId,
        createdAt,
        apiKeysLength,
        localizationDocs,
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'User ID': userId,
      'User Account Creation Date':
          '${createdAt.toProperHumanReadableDate()} - ${createdAt.toIso8601String()}',
      'Available API keys': apiKeysLength,
      'Processed Localizations': localizationDocs.length,
      'Most Recent Localization ID': localizationDocs.isNotEmpty
          ? localizationDocs.last.partitionId
          : 'You have no processed localizations.',
      'Most Recent Localization Date': localizationDocs.isNotEmpty
          ? '${localizationDocs.last.createdAt.toProperHumanReadableDate()} - ${localizationDocs.last.createdAt.toIso8601String()}'
          : 'You have no processed localizations.',
    };
  }
}
