import 'dart:convert';
import 'dart:math';

import 'package:langsync/src/etc/models/config.dart';
import 'package:langsync/src/etc/utils.dart';
import 'package:mason_logger/mason_logger.dart';

final randomframesToUse = utils.randomLoadingFrames();

extension IterableExtension<T> on String {
  String hiddenBy(String hideChar) {
    if (contains('-')) {
      final ran = Random();

      Iterable<String> splitted = split('-');

      splitted = splitted.map((curr) {
        if (curr.length <= 2) {
          return curr;
        } else {
          return hideChar * ran.nextInt(25);
        }
      });

      return splitted.join('-');
    } else {
      return List.generate(length, (index) => hideChar).join();
    }
  }
}

extension DateExte on DateTime {
  String toProperHumanReadableDate() {
    final now = DateTime.now();

    final diff = now.difference(this);

    if (diff.inDays >= 365) {
      return '${diff.inDays ~/ 365} years ago';
    } else if (diff.inDays >= 30) {
      return '${diff.inDays ~/ 30} months ago';
    } else if (diff.inDays >= 7) {
      return '${diff.inDays ~/ 7} weeks ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} seconds ago';
    } else {
      return 'just now';
    }
  }
}

extension LoggerExt on Logger {
  void docsInfo({
    required String path,
  }) {
    info('\n');
    info(
      "For more info, check our docs at: https://docs.langsync.app/${path.startsWith('/') ? path.substring(1) : path}",
    );
  }

  void customErr({
    required Progress progress,
    required String update,
    required Object error,
  }) {
    info('\n');

    if (utils.isDebugMode) {
      progress.fail(error.toString());
    } else {
      progress.fail(update);
    }
  }

  Progress customProgress(String message) {
    return progress(
      message,
      options: ProgressOptions(
        animation: ProgressAnimation(
          frames: randomframesToUse,
        ),
      ),
    );
  }
}

extension MapExtension on Map<dynamic, dynamic> {
  LangSyncConfig toConfigModeled() {
    return LangSyncConfig.fromMap(this);
  }
}

extension JsonMapExtension on Map<String, dynamic> {
  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(this);
  }
}

extension DateExt on DateTime {
  String toHumanReadable() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }
}
