import 'package:flutter/material.dart';

mixin Option<T> {
  T get id;

  String get label;

  ValueNotifier<bool> get selected;
}
