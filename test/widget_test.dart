import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/widgets/empty_state.dart';
import 'package:shopease/widgets/error_widget.dart';

void main() {
  testWidgets('EmptyState shows its title, message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.favorite_border,
            title: 'Nothing here',
            message: 'Add something first',
            actionLabel: 'Go',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add something first'), findsOneWidget);

    await tester.tap(find.text('Go'));
    expect(tapped, isTrue);
  });

  testWidgets('ErrorState shows the message and retry works', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(message: 'No internet', onRetry: () => retried++),
        ),
      ),
    );

    expect(find.text('No internet'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });
}
