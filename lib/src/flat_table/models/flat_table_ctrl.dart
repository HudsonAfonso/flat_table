import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../extensions/recase_ext.dart';
import 'list_provider.dart';
import 'search.dart';

typedef RefreshAction = Future<ListProvider> Function();
typedef Formatter = String Function(dynamic);
typedef OnSelect = void Function(List<dynamic>);

class FlatTableCtrl with ChangeNotifier {
  FlatTableCtrl({
    required this.name,
    required this.provider,
    this.formatters,
    this.refresh,
    this.onSelect,
    this.sizes = const <String, int>{},
    this.multiSelect = false,
  }) {
    _refresh();
  }

  final bool multiSelect;
  final String name;
  final ListProvider provider;

  Map<String, Formatter>? formatters;
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  OnSelect? onSelect;
  RefreshAction? refresh;
  List<int> selected = <int>[];
  ValueNotifier<bool> showFilter = ValueNotifier<bool>(false);
  Map<String, int> sizes;
  int? sortColumnIndex;
  SortDirection sortDirection = SortDirection.ascending;
  ValueNotifier<String> textFilter = ValueNotifier<String>('');

  List<SimpleType>? _cachedColumns;
  List<int>? _cachedIndices;
  List<List<dynamic>>? _cachedRows;
  bool _disposed = false;

  List<SimpleType> get columns => _cachedColumns ??= provider.meta.where((SimpleType c) => c.visible).toList();

  Function? get refreshAction => refresh != null ? _refresh : null;

  List<List<dynamic>> get rows {
    if (_cachedRows == null) {
      _cachedRows = provider.data.map(
        (dynamic e) {
          return <dynamic>[
            for (int i in _indices)
              (formatters?.containsKey(provider.meta[i].name) ?? false)
                  ? formatters![provider.meta[i].name]!.call(e[i])
                  : e[i],
          ];
        },
      ).toList();

      if (textFilter.value != '') {
        final List<TextSearchItem<List<dynamic>>> searchableItems = _cachedRows!.map(
          (List<dynamic> e) {
            final Iterable<String> terms = e
                .map(
                  (dynamic i) => i.toString().split(' ')..add('all:$i'),
                )
                .expand((List<String> j) => j);

            return TextSearchItem<List<dynamic>>.fromTerms(e, terms);
          },
        ).toList();
        final List<List<dynamic>> result = TextSearch<List<dynamic>>(searchableItems).fastSearch(
          textFilter.value,
          matchThreshold: 0.1,
        );

        // if (result.isNotEmpty)
        _cachedRows = result;
      }

      final RegExp regExp = RegExp('[^a-zA-Z0-9 ]');

      // columns width
      for (SimpleType t in columns) {
        if (_indices.contains(t.index)) {
          final List<int> widths = _cachedRows!
              .map((List<dynamic> row) {
                dynamic value = row.elementAtOrNull(t.index);

                if (sizes.containsKey(t.name)) return sizes[t.name]!;

                if (t.currency ?? false) {
                  final NumberFormat nf = NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: '',
                    decimalDigits: t.decimalDigits,
                  );
                  value = nf.format(double.tryParse(value.toString()) ?? 0);
                  // print(value);
                }

                return value == null
                    ? 0
                    : value.toString().trim().length -
                        (regExp.allMatches(value.toString().trim()).length * 0.4).floor();
              })
              .toSet()
              .toList();
          if (!sizes.containsKey(t.name)) {
            widths.add(t.columnLabel.length - (regExp.allMatches(t.columnLabel).length * 0.4).floor());
          }

          int w = sizes[t.name] ?? widths.reduce(max);
          w = ((8 * 2) + (w * 8.5)).ceil();

          t.columnWidth = w;
        }
      }
    }

    return <List<dynamic>>[
      columns.map((SimpleType e) => e.columnLabel).toList(),
      ..._cachedRows!,
    ];
  }

  List<int> get _indices => _cachedIndices ??= columns.map((SimpleType c) => c.index).toList();

  // static Uint8List encodeCsv(Map<String, dynamic> provider) {
  //   const ListToCsvConverter converter = ListToCsvConverter(fieldDelimiter: ';', delimitAllFields: true);
  //
  //   final String csv = converter.convert(
  //     List<List<dynamic>>.from(provider['data'].map((dynamic x) => List<dynamic>.from(x.map((dynamic x) => x)))),
  //   );
  //
  //   return Uint8List.fromList(csv.codeUnits);
  // }

  static Uint8List encodeXlsx(Map<String, dynamic> provider) {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    final String fontFamily = getFontFamily(FontFamily.Calibri);

    final CellStyle headerStyle = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#000000'),
      fontFamily: fontFamily,
    );
    final CellStyle cellStyle = CellStyle(fontFamily: fontFamily);

    sheet.appendRow(
      provider['meta'].map<TextCellValue>((dynamic e) => TextCellValue(e['column_label'].toString())).toList(),
    );
    sheet.row(sheet.maxRows - 1).forEach((Data? cell) {
      if (cell != null) cell.cellStyle = headerStyle;
    });

    for (int i = 0; i < provider['data'].length; i += 1) {
      final List<dynamic> element = provider['data'][i];
      sheet.appendRow(
        element.map((dynamic e) {
          return switch (e) {
            final String value => TextCellValue(value),
            final int value => IntCellValue(value),
            final bool value => BoolCellValue(value),
            final double value => DoubleCellValue(value),
            final DateTime value => DateTimeCellValue.fromDateTime(value),
            null => null,
            _ => TextCellValue(e.toString()),
          };
        }).toList(),
      );
      sheet.row(sheet.maxRows - 1).indexed.forEach(((int, Data?) e) {
        final Map<String, dynamic> column = provider['meta'][e.$1];
        final Data? cell = e.$2;
        if (cell != null) {
          cell.cellStyle = cellStyle;
          if (cell.value is DoubleCellValue && (column['currency'] ?? false)) {
            if (column['decimal_digits'] == 2) cell.cellStyle = cellStyle.copyWith(numberFormat: NumFormat.standard_2);
            // if (column.decimalDigits == 3) {
            //   cell.cellStyle = cellStyle.copyWith(numberFormat: const CustomNumericNumFormat(formatCode: '0.000'));
            // }
          }
          if (cell.value is DateTimeCellValue) {
            cell.cellStyle = cellStyle.copyWith(numberFormat: NumFormat.defaultDateTime);
          }
        }
      });
    }

    return Uint8List.fromList(excel.encode()!);
  }

  void clearSelection() {
    selected.clear();
    invalidateState();
  }

  SimpleType columnByName(String name) => columns.firstWhere((SimpleType type) => type.name == name);

  SimpleType getColumn(int index) => columns[index];

  List<dynamic> getRow(int index) => rows.length > index ? rows[index] : <dynamic>[];

  void invalidateState() {
    sortColumnIndex = null;
    _cachedColumns = null;
    _cachedRows = null;
    _cachedIndices = null;
    rows;

    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> save() async {
    loading.value = true;

    final Uint8List bytes = await compute<Map<String, dynamic>, Uint8List>(encodeXlsx, toVisibleJson());
    final String path = await FileSaver.instance.saveFile(
      bytes: Uint8List.fromList(bytes),
      name: name.toLowerCase().snakeCase,
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    if (kDebugMode) {
      Process.run('open', <String>[path]);
    }

    // TODO: chamar callback
    // Asuka.showSnackBar(SnackBar(content: Text('Arquivo salvo em $path'), behavior: SnackBarBehavior.floating));

    loading.value = false;
  }

  void select(int index) {
    if (multiSelect) {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    } else {
      selected.clear();
      selected.add(index);
    }
    notifyListeners();
    onSelect?.call(getRow(index));
  }

  void sortBy(int columnIndex) {
    sortDirection = sortColumnIndex == columnIndex ? sortDirection.reverse() : SortDirection.ascending;

    _cachedRows = _cachedRows!.sorted(
      (List<dynamic> a, List<dynamic> b) => _compareData(a[columnIndex], b[columnIndex]),
    );
    sortColumnIndex = columnIndex;
    selected.clear();

    notifyListeners();
  }

  Map<String, dynamic> toVisibleJson() => <String, dynamic>{
        'meta': List<dynamic>.from(columns.map((SimpleType x) => x.toJson())),
        'data': List<dynamic>.from(
          rows.sublist(1).map((List<dynamic> x) => List<dynamic>.from(x.map((dynamic x) => x))),
        ),
      };

  int _compare(Object? valueA, Object? valueB) {
    final bool aEmpty = valueA.empty();
    final bool bEmpty = valueB.empty();

    if (aEmpty && bEmpty) return 0;
    if (aEmpty) return -1;
    if (bEmpty) return 1;

    if (valueA.runtimeType == bool) {
      valueA = valueA == true ? 1 : 0;
    }
    if (valueB.runtimeType == bool) {
      valueB = valueB == true ? 1 : 0;
    }

    if (valueA.runtimeType == String && double.tryParse(valueA as String) != null) {
      valueA = valueA.padLeft(16, '0');
    }
    if (valueB.runtimeType == String && double.tryParse(valueB as String) != null) {
      valueB = valueB.padLeft(16, '0');
    }

    return (valueA as Comparable<Object>).compareTo(valueB as Comparable<Object>);
  }

  int _compareData(Object? a, Object? b) => _compare(a, b) * _compareFactor(sortDirection);

  int _compareFactor(SortDirection direction) => direction == SortDirection.ascending ? 1 : -1;

  Future<void> _refresh() async {
    if (refresh != null) {
      loading.value = true;

      final ListProvider? p = await refresh?.call();
      if (p != null) {
        provider.meta = p.meta;
        provider.data = p.data;

        selected.clear();
        invalidateState();
      }
      loading.value = false;
      if (!_disposed) {
        loading.value = false;
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();

    loading.dispose();
    showFilter.dispose();
    textFilter.dispose();
  }
}

enum SortDirection {
  ascending,
  descending,
}

extension SortDirectionExtension on SortDirection {
  SortDirection reverse() => this == SortDirection.ascending ? SortDirection.descending : SortDirection.ascending;
}
