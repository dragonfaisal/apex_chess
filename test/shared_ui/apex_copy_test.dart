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
      ApexCopy.synced,
      ApexCopy.searchPlayer,
      ApexCopy.searchOpponentOpening,
    ];

    for (final value in publicCopy) {
      expect(value, isNot(contains('Quantum')));
      expect(value, isNot(contains('Grandmaster')));
      expect(value, isNot(contains('Intel')));
      expect(value, isNot(contains('Radar')));
      expect(value.split(RegExp(r'\s+')).length, lessThanOrEqualTo(4));
    }
  });
}
