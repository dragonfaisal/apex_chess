import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';

void main() {
  final report = buildDefaultOnlineReviewStagingReadinessReport();
  io.stdout.write(renderOnlineReviewStagingReadinessReportMarkdown(report));
  io.exitCode = onlineReviewStagingReadinessReportExitCode(report);
}
