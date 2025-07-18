import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wallet_card/helpers/color.dart';

void main() {
  group('Helpers', () {
    test('parses color from rgb string', () {
      const expected = Color.fromRGBO(200, 200, 200, 1);
      final parsedColor = color(color: 'rgb(200,200,200)');

      expect(parsedColor, expected);
    });

    test('falls back to black on error', () {
      const expected = black;
      final parsedColor = color(color: 'rgb(2000,200,200)');
      expect(parsedColor, expected);
    });

    test('black color on null', () {
      const expected = black;
      final parsedColor = color(color: null);
      expect(parsedColor, expected);
    });

    test('custom red color on null', () {
      const fallback = Color.fromRGBO(255, 0, 0, 1);
      final parsedColor = color(color: null, defaultColor: fallback);
      expect(parsedColor, fallback);
    });

    test('fromColor to stringified red', () {
      const expected = 'rgb(255,0,0)';
      final parsedColor = fromColor(const Color.fromRGBO(255, 0, 0, 1));
      expect(parsedColor, expected);
    });
  });
}
