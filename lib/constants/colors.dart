import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE1E7EC),
  100: Color(0xFFB5C3D0),
  200: Color(0xFF839BB1),
  300: Color(0xFF517392),
  400: Color(0xFF2C557A),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF06315B),
  700: Color(0xFF052A51),
  800: Color(0xFF042347),
  900: Color(0xFF021635),
});
const int _primaryPrimaryValue = 0xFF073763;

const MaterialColor primaryAccent =
    MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFF6D97FF),
  200: Color(_primaryAccentValue),
  400: Color(0xFF074FFF),
  700: Color(0xFF0044EC),
});
const int _primaryAccentValue = 0xFF3A73FF;

const MaterialColor containerprimary =
    MaterialColor(_containerprimaryPrimaryValue, <int, Color>{
  50: Color(0xFFF9FCFE),
  100: Color(0xFFF1F6FB),
  200: Color(0xFFE7F1F9),
  300: Color(0xFFDDEBF7),
  400: Color(0xFFD6E6F5),
  500: Color(_containerprimaryPrimaryValue),
  600: Color(0xFFCADFF1),
  700: Color(0xFFC3DAEF),
  800: Color(0xFFBDD6ED),
  900: Color(0xFFB2CFEA),
});
const int _containerprimaryPrimaryValue = 0xFFCFE2F3;

const MaterialColor containerprimaryAccent =
    MaterialColor(_containerprimaryAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_containerprimaryAccentValue),
  400: Color(0xFFFFFFFF),
  700: Color(0xFFFFFFFF),
});
const int _containerprimaryAccentValue = 0xFFFFFFFF;
