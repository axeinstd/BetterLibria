import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red, brightness: Brightness.dark),
    useMaterial3: true,
    brightness: Brightness.dark);
final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red, brightness: Brightness.light),
    useMaterial3: true,
    brightness: Brightness.light);