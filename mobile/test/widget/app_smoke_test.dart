import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/app.dart';

void main() {
  testWidgets('app builds without throwing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ResilientBuildApp()),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
