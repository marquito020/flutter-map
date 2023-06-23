import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE7E6E6),
  100: Color(0xFFC2C1C1),
  200: Color(0xFF999898),
  300: Color(0xFF706E6E),
  400: Color(0xFF524F4F),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF2E2B2B),
  700: Color(0xFF272424),
  800: Color(0xFF201E1E),
  900: Color(0xFF141313),
});
const int _primaryPrimaryValue = 0xFF333030;

const MaterialColor primaryAccent =
    MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFFF36969),
  200: Color(_primaryAccentValue),
  400: Color(0xFFF60000),
  700: Color(0xFFDC0000),
});
const int _primaryAccentValue = 0xFFEF3939;

const MaterialColor containerprimary =
    MaterialColor(_containerprimaryPrimaryValue, <int, Color>{
  50: Color(0xFFFCFCFC),
  100: Color(0xFFF8F8F8),
  200: Color(0xFFF4F4F4),
  300: Color(0xFFEFEFEF),
  400: Color(0xFFEBEBEB),
  500: Color(_containerprimaryPrimaryValue),
  600: Color(0xFFE5E5E5),
  700: Color(0xFFE2E2E2),
  800: Color(0xFFDEDEDE),
  900: Color(0xFFD8D8D8),
});
const int _containerprimaryPrimaryValue = 0xFFE8E8E8;

const MaterialColor containerprimaryAccent =
    MaterialColor(_containerprimaryAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_containerprimaryAccentValue),
  400: Color(0xFFFFFFFF),
  700: Color(0xFFFFFFFF),
});
const int _containerprimaryAccentValue = 0xFFFFFFFF;
