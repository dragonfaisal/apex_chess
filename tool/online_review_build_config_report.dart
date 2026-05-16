import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';

void main() {
  final report = buildOnlineReviewBuildConfigReport();
  io.stdout.write(renderOnlineReviewBuildConfigReportMarkdown(report));
  io.exitCode = onlineReviewBuildConfigReportExitCode(report);
}
