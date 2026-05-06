import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApexCopy keeps public labels short and avoids old hype labels', () {
    const publicCopy = [
      ApexCopy.importTitle,
      ApexCopy.archivesTitle,
      ApexCopy.dashboardTitle,
      ApexCopy.academyTitle,
      ApexCopy.scannerTitle,
      ApexCopy.depthFastLabel,
      ApexCopy.depthDeepLabel,
      ApexCopy.depthOfflineLabel,
      ApexCopy.noConnection,
      ApexCopy.chooseExactPlayer,
      ApexCopy.noExactPlayerFound,
      ApexCopy.chessComUnavailable,
      ApexCopy.lichessUnavailable,
      ApexCopy.profileUnavailable,
      ApexCopy.synced,
      ApexCopy.searchOlderGames,
      ApexCopy.searchingOlderGames,
      ApexCopy.searchPlayer,
      ApexCopy.searchOpponentOpening,
      ApexCopy.dashboardPlayerSearchTitle,
      ApexCopy.dashboardPlayerSearchSubtitle,
      ApexCopy.dashboardPublicAccountStats,
    ];

    for (final value in publicCopy) {
      expect(value, isNot(contains('Quantum')));
      expect(value, isNot(contains('Grandmaster')));
      expect(value, isNot(contains('Intel')));
      expect(value, isNot(contains('Radar')));
      expect(value.split(RegExp(r'\s+')).length, lessThanOrEqualTo(4));
    }
  });

  test('Stats search copy stays honest about public profile scope', () {
    expect(ApexCopy.dashboardPlayerSearchTitle, 'PLAYER SEARCH');
    expect(ApexCopy.dashboardPlayerSearchSubtitle, 'Public profile');
    expect(ApexCopy.dashboardPublicAccountStats, 'Public account stats');
    expect(
      [
        ApexCopy.dashboardPlayerSearchTitle,
        ApexCopy.dashboardPlayerSearchSubtitle,
        ApexCopy.dashboardPublicAccountStats,
        ApexCopy.dashboardPublicSections,
      ].join(' '),
      isNot(contains('analytics')),
    );
  });
}
