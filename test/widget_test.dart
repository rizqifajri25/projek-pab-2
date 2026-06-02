import 'package:flutter_test/flutter_test.dart';
import 'package:projek_pab_2/main.dart';

void main() {
  testWidgets('workspace splash renders', (tester) async {
    await tester.pumpWidget(const PadelFinderWorkspaceApp());
    expect(find.textContaining('PadelFinder source code'), findsOneWidget);
  });
}
