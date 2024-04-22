import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension EmptyExtension on Object? {
  bool empty() => this == null || this == '';
}

class ListProvider with ChangeNotifier {
  ListProvider({
    required this.name,
    List<SimpleType>? meta,
    List<List<dynamic>>? data,
  }) {
    this.meta = meta ?? <SimpleType>[SimpleType(index: 0, builtInType: '', columnLabel: '', name: '')];
    this.data = data ?? <List<dynamic>>[];
  }

  factory ListProvider.fromJson(Map<String, dynamic> json) => ListProvider(
        name: json['name'],
        meta: SimpleType.fromJsonList(json['meta']),
        data: List<List<dynamic>>.from(
          json['data'].map((dynamic x) => List<dynamic>.from(x.map((dynamic x) => x))),
        ),
      );

  final String name;

  late List<List<dynamic>> data;
  late List<SimpleType> meta;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'meta': List<dynamic>.from(meta.map((SimpleType x) => x.toJson())),
        'data': List<dynamic>.from(data.map((List<dynamic> x) => List<dynamic>.from(x.map((dynamic x) => x)))),
      };
}

class SimpleType with ChangeNotifier {
  SimpleType({
    required this.index,
    required this.builtInType,
    required this.columnLabel,
    required this.name,
    this.ovs,
    this.columnRenderer,
    this.columnWidth,
    this.columnTextAlign,
    this.currency,
    this.decimalDigits,
    this.visible = true,
  });

  factory SimpleType.fromJson(int index, Map<String, dynamic> json) => SimpleType(
        index: index,
        builtInType: json['built_in_type'],
        columnLabel: json['column_label'],
        name: json['name'],
        ovs: json['ovs'] == null ? null : ListProvider.fromJson(json['ovs']),
        columnRenderer: json['column_renderer'] == null ? null : ColumnRenderer.values.byName(json['column_renderer']),
        columnWidth: json['column_width'],
        columnTextAlign: json['column_text_align'],
        currency: json['currency'],
        decimalDigits: json['decimal_digits'],
        visible: json['visible'] ?? true,
      );

  final String builtInType;
  final String columnLabel;
  final ColumnRenderer? columnRenderer;
  final String? columnTextAlign;
  final bool? currency;
  final int? decimalDigits;
  final int index;
  final String name;
  final ListProvider? ovs;

  int? columnWidth;

  bool visible = true;

  static List<SimpleType> fromJsonList(List<dynamic> jsonList) =>
      List<SimpleType>.from(jsonList.indexed.map(((int, dynamic) e) => SimpleType.fromJson(e.$1, e.$2)));

  void changeVisibility(bool visible) {
    this.visible = visible;
    notifyListeners();
  }

  SimpleType copyWith({
    int? index,
    String? builtInType,
    String? columnLabel,
    String? name,
    ListProvider? ovs,
    ColumnRenderer? columnRenderer,
    int? columnWidth,
    String? columnTextAlign,
    bool? currency,
    int? decimalDigits,
    bool? visible,
  }) =>
      SimpleType(
        index: index ?? this.index,
        builtInType: builtInType ?? this.builtInType,
        columnLabel: columnLabel ?? this.columnLabel,
        name: name ?? this.name,
        ovs: ovs ?? this.ovs,
        columnRenderer: columnRenderer ?? this.columnRenderer,
        columnWidth: columnWidth ?? this.columnWidth,
        columnTextAlign: columnTextAlign ?? this.columnTextAlign,
        currency: currency ?? this.currency,
        decimalDigits: decimalDigits ?? this.decimalDigits,
        visible: visible ?? this.visible,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'built_in_type': builtInType,
        'column_label': columnLabel,
        'name': name,
        'ovs': ovs?.toJson(),
        'column_renderer': columnRenderer?.name,
        'column_width': columnWidth,
        'column_text_align': columnTextAlign,
        'currency': currency,
        'decimal_digits': decimalDigits,
        'visible': visible,
      };
}

enum ColumnRenderer {
  checkbox,
  mono,
  bool,
  hidden,
  bandeira,
  status;
}
