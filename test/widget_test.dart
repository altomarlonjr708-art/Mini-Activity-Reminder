import 'package:actmind/ui/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ActMind themes use Material 3', () {
    expect(AppTheme.light().useMaterial3, isTrue);
    expect(AppTheme.dark().useMaterial3, isTrue);
  });
}
