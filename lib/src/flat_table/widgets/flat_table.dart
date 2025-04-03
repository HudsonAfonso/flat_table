import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../extensions/flex_ext.dart';
import '../models/flat_table_ctrl.dart';
import '../models/list_provider.dart';

typedef CustomCellBuilder = CellBuilder Function(FlatTableCtrl ctrl, TableVicinity vicinity);

class FlatTable extends StatelessWidget {
  const FlatTable(
    this.ctrl, {
    super.key,
    this.builders = const <String, CustomCellBuilder>{},
  });

  final Map<String, CustomCellBuilder> builders;
  final FlatTableCtrl ctrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(trailing: BorderSide(color: theme.dividerColor)),
    );

    final ScrollController verticalController = ScrollController();
    final ScrollController horizontalController = ScrollController();

    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: <Widget>[
          ListenableBuilder(
            listenable: ctrl.loading,
            builder: (BuildContext context, Widget? child) {
              final bool loading = ctrl.loading.value;

              return loading
                  ? LinearProgressIndicator(key: Key('LinearProgressIndicator-${loading.hashCode}'))
                  : SizedBox.shrink(key: Key('SizedBox-${loading.hashCode}'));
            },
          ),
          ListenableBuilder(
            listenable: ctrl,
            builder: (BuildContext context, Widget? child) {
              return Expanded(
                child: RawScrollbar(
                  controller: verticalController,
                  thumbVisibility: true,
                  radius: const Radius.circular(2),
                  thickness: 10,
                  trackVisibility: true,
                  child: RawScrollbar(
                    controller: horizontalController,
                    thumbVisibility: true,
                    radius: const Radius.circular(2),
                    thickness: 10,
                    trackVisibility: true,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 11, bottom: 11),
                      child: TableView.builder(
                        horizontalDetails: ScrollableDetails.horizontal(controller: horizontalController),
                        verticalDetails: ScrollableDetails.vertical(controller: verticalController),
                        pinnedRowCount: 1,
                        columnCount: ctrl.columns.length,
                        rowCount: ctrl.rows.length,
                        // cacheExtent: 0,
                        columnBuilder: (int index) {
                          return TableSpan(
                            extent: FixedTableSpanExtent(ctrl.getColumn(index).columnWidth?.toDouble() ?? 200),
                            foregroundDecoration: ctrl.provider.meta.length != 1 ? decoration : null,
                          );
                        },
                        rowBuilder: (int index) {
                          Color? color = colorScheme.primary.withOpacity(0.1);
                          color = index.isOdd ? color : null;

                          final Brightness brightness = Theme.of(context).brightness;
                          if (ctrl.selected.contains(index)) {
                            color = brightness == Brightness.light
                                ? colorScheme.secondary
                                : colorScheme.secondary.darken(40);
                          }

                          if (index == 0) {
                            color = colorScheme.primary.withOpacity(0.2);
                          }

                          if (index == 0 && ctrl.provider.meta.length == 1 && ctrl.provider.data.isEmpty) {
                            color = Colors.transparent;
                          }

                          return TableSpan(
                            extent: FixedTableSpanExtent(index == 0 ? 40 : 35),
                            recognizerFactories: <Type, GestureRecognizerFactory>{
                              TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                                () => TapGestureRecognizer(),
                                (TapGestureRecognizer t) => t.onTap = () => ctrl.select(index),
                              ),
                            },
                            backgroundDecoration: index == 0 && ctrl.provider.meta.length != 1
                                ? TableSpanDecoration(
                                    border: TableSpanBorder(trailing: BorderSide(color: theme.dividerColor)),
                                    color: color,
                                  ) //decoration
                                : TableSpanDecoration(color: color),
                          );
                        },
                        cellBuilder: (BuildContext context, TableVicinity vicinity) {
                          final SimpleType type = ctrl.getColumn(vicinity.xIndex);
                          final String renderer = type.columnRenderer?.name ?? '';

                          if (vicinity.row == 0) {
                            return HeaderCell(ctrl: ctrl, vicinity: vicinity).cell;
                          }

                          if (builders.containsKey(type.name)) {
                            return builders[type.name]!.call(ctrl, vicinity).cell;
                          }
                          if (builders.containsKey(renderer)) {
                            return builders[type.name]!.call(ctrl, vicinity).cell;
                          }

                          final TableViewCell textCell = TextCell(ctrl: ctrl, vicinity: vicinity).cell;

                          return switch (renderer) {
                            'checkbox' => textCell,
                            'status' => textCell,
                            'bandeira' => textCell,
                            'bool' => textCell,
                            'hidden' => const TableViewCell(child: Icon(Symbols.visibility_off, weight: 300)),
                            'mono' || _ => textCell,
                          };
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

abstract class CellBuilder extends Widget {
  const CellBuilder({super.key});

  TableViewCell get cell;

  FlatTableCtrl get ctrl;

  TableVicinity get vicinity;
}

class HeaderCell extends StatefulWidget implements CellBuilder {
  const HeaderCell({
    required this.ctrl,
    required this.vicinity,
    super.key,
  });

  @override
  final FlatTableCtrl ctrl;

  @override
  final TableVicinity vicinity;

  @override
  TableViewCell get cell => TableViewCell(child: this);

  @override
  State<HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<HeaderCell> with AutomaticKeepAliveClientMixin<HeaderCell> {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final SimpleType type = widget.ctrl.getColumn(widget.vicinity.xIndex);
    final String label = type.columnLabel;
    // final String label = type.name;

    return InkWell(
      onTap: () => widget.ctrl.sortBy(type.index),
      canRequestFocus: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label.toString(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontFeatures: <FontFeature>[const FontFeature.proportionalFigures()],
                ),
                textAlign:
                    type.columnTextAlign == 'right' || (type.currency ?? false) ? TextAlign.right : TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (type.index == widget.ctrl.sortColumnIndex)
              SizedBox(
                width: 15,
                child: Icon(
                  widget.ctrl.sortDirection == SortDirection.ascending
                      ? Symbols.arrow_drop_down
                      : Symbols.arrow_drop_up,
                  weight: 300,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TextCell extends StatefulWidget implements CellBuilder {
  const TextCell({
    required this.ctrl,
    required this.vicinity,
    super.key,
  });

  @override
  final FlatTableCtrl ctrl;
  @override
  final TableVicinity vicinity;

  @override
  TableViewCell get cell => TableViewCell(child: this);

  @override
  State<TextCell> createState() => _TextCellState();
}

class _TextCellState extends State<TextCell> with AutomaticKeepAliveClientMixin<TextCell> {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final SimpleType type = widget.ctrl.getColumn(widget.vicinity.xIndex);
    final NumberFormat nf = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: type.decimalDigits,
    );

    final int yIndex = widget.vicinity.yIndex;

    final List<dynamic> row = widget.ctrl.getRow(yIndex - 0);
    dynamic label = row.length <= widget.vicinity.xIndex ? '' : row[widget.vicinity.xIndex] ?? '';
    if (widget.ctrl.formatters?.containsKey(widget.ctrl.provider.meta[type.index].name) ?? false) {
      label =
          widget.ctrl.formatters![widget.ctrl.provider.meta[type.index].name]!.call(row.elementAtOrNull(type.index));
    }

    if (yIndex != 0 && ((type.currency ?? false) || type.decimalDigits != null)) {
      if (label != null && label != '') {
        label = nf.format(double.parse(label.toString()));
      }
    }
    if (type.columnRenderer == ColumnRenderer.checkbox) {
      // return Checkbox(value: false, onChanged: (bool? value) {});
      return TableViewCell(child: Checkbox(value: false, onChanged: (bool? value) {})); // ignore: no-empty-block
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Color textColor = colorScheme.onSurface;
    if (widget.ctrl.selected.contains(yIndex)) {
      textColor = colorScheme.secondary.withOpacity(0.2).onColor == Colors.black // --
          ? colorScheme.onSurface
          : colorScheme.surface;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                // fontSize: 13,
                color: textColor,
                letterSpacing: type.currency ?? false ? 0.1 : null,
                fontFeatures: <FontFeature>[const FontFeature.proportionalFigures()],
              ),
              textAlign: type.columnTextAlign == 'right' ||
                      ((type.currency ?? false) || type.decimalDigits != null) ||
                      type.builtInType == 'int' ||
                      type.builtInType == 'double'
                  ? TextAlign.right
                  : TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
