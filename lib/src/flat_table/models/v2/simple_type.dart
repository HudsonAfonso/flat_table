import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../extensions/flex_ext.dart';

typedef FormatterFunc = String Function(Object? obj);
typedef BuilderFunc = Widget Function(BuildContext context, bool selected, String text);

sealed class SimpleType {
  final int index;
  final String name;
  final String label;
  double? width;
  late String textAlign;

  FormatterFunc? _formatterFunc;
  BuilderFunc? _builderFunc;

  SimpleType({
    required this.index,
    required this.name,
    required this.label,
    this.width,
    this.textAlign = 'left',
    FormatterFunc? formatter,
    BuilderFunc? builder,
  }) {
    _formatterFunc = formatter;
    _builderFunc = builder;
  }

  Widget _builder(BuildContext context, bool selected, Widget child) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color textColor = colorScheme.onSurface;
    // if (ctrl.selected.contains(vicinity.yIndex)) {
    if (selected) {
      textColor = colorScheme.secondary.withOpacity(0.2).onColor == Colors.black // --
          ? colorScheme.onSurface
          : colorScheme.surface;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: textColor),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  String formatted(Object? obj);

  Widget basicBuild(BuildContext context, bool selected, String text) {
    final Widget w = _builderFunc?.call(context, selected, text) ??
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFeatures: <FontFeature>[const FontFeature.proportionalFigures()],
          ),
          textAlign: TextAlign.values.byName(textAlign),
          overflow: TextOverflow.ellipsis,
        );

    return _builder(context, selected, w);
  }

  set formatter(FormatterFunc? func) => _formatterFunc = func;

  set builder(BuilderFunc? func) => _builderFunc = func;
}

class StringType extends SimpleType {
  static Type builtInType = String;

  StringType({
    required super.index,
    required super.name,
    required super.label,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? obj.toString();
}

class BoolType extends SimpleType {
  static Type builtInType = bool;

  BoolType({
    required super.index,
    required super.name,
    required super.label,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? (obj == true ? 'Sim' : 'Não');
}

class CurrencyType extends SimpleType {
  static Type builtInType = Decimal;
  final int? decimalDigits;

  CurrencyType({
    required super.index,
    required super.name,
    required super.label,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
    this.decimalDigits,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? _formatted(obj);

  String _formatted(Object? obj) {
    final NumberFormat nf = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: decimalDigits,
    );

    return nf.format(obj).trim();
  }
}

class DateTimeType extends SimpleType {
  static Type builtInType = DateTime;
  final String? pattern;

  DateTimeType({
    required super.index,
    required super.name,
    required super.label,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
    this.pattern,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? _formatted(obj);

  String _formatted(Object? obj) {
    return DateFormat(pattern ?? 'dd/MM/yyyy H:mm').format(obj as DateTime);
  }
}

class DoubleType extends SimpleType {
  static Type builtInType = double;
  final int? decimalDigits;

  DoubleType({
    required super.index,
    required super.name,
    required super.label,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
    this.decimalDigits,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? _formatted(obj);

  String _formatted(Object? obj) {
    final NumberFormat nf = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: decimalDigits,
    );

    return nf.format(obj).trim();
  }
}

class IntType extends SimpleType {
  static Type builtInType = int;

  IntType({
    required super.index,
    required super.name,
    required super.label,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? obj.toString();
}

class EnumType extends SimpleType {
  static Type builtInType = Enum;
  final Map<String, String> values;

  EnumType({
    required super.index,
    required super.name,
    required super.label,
    required this.values,
    super.width,
    super.textAlign,
    super.formatter,
    super.builder,
  });

  @override
  String formatted(Object? obj) => _formatterFunc?.call(obj) ?? values[obj] ?? obj.toString();
}

class CellData {
  final Object? raw;
  final SimpleType simpleType;

  String? _formatted;

  CellData({
    required this.simpleType,
    required this.raw,
  });

  String get formatted {
    return _formatted ?? (_formatted = simpleType.formatted(raw));
  }

  Widget cell(BuildContext context, bool selected) {
    return simpleType.basicBuild(context, selected, formatted);
  }
}
