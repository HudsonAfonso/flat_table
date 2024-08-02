import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../../flat_table.dart';
import '../extensions/flex_ext.dart';
import '../extensions/intersperse.dart';
import 'constants.dart';

typedef CustomCellBuilder0 = CellBuilder Function(FlatTableCtrl ctrl, TableVicinity vicinity);

class CardView extends StatelessWidget {
  const CardView(
    this.ctrl, {
    super.key,
    this.builders = const <String, CustomCellBuilder0>{},
    this.cardBuilder,
  });

  final Map<String, CustomCellBuilder0> builders;
  final FlatTableCtrl ctrl;
  final CardBuilder? cardBuilder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final TextStyle? labelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w900,
      height: 1.3,
    );
    final TextStyle? dataStyle = theme.textTheme.bodySmall?.copyWith(
      height: 1,
    );

    final ScrollController verticalController = ScrollController();

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
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ResponsiveGridList(
                        minItemWidth: 300,
                        horizontalGridMargin: 0,
                        // verticalGridMargin: 16,

                        listViewBuilderOptions: ListViewBuilderOptions(
                          controller: verticalController,
                          shrinkWrap: true,
                        ),
                        children: ctrl.rows.sublist(1).asMap().entries.map(
                          (MapEntry<int, List<dynamic>> entry) {
                            final List<dynamic> row = entry.value;

                            if (cardBuilder != null) return cardBuilder!.call(context, entry.key, ctrl.columns, row);

                            return Card(
                              color: theme.brightness == Brightness.dark
                                  ? colorScheme.surfaceContainerHighest.lighten(5)
                                  : colorScheme.surfaceContainerHighest.darken(5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: ctrl.columns
                                      .slices(2)
                                      .map<Widget>(
                                        (List<SimpleType> l) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(l.first.columnLabel, style: labelStyle),
                                                    Text(
                                                      row.elementAtOrNull(l.first.index).toString(),
                                                      style: dataStyle,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (l.length > 1)
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Text(l.last.columnLabel, style: labelStyle),
                                                      Text(
                                                        row.elementAtOrNull(l.last.index).toString(),
                                                        style: dataStyle,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      )
                                      .intersperse(
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: smallSpacing * 0.7),
                                          child: Divider(height: 1),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            );
                          },
                        ).toList(),
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
