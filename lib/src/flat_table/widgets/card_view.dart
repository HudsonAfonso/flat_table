import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
  });

  final Map<String, CustomCellBuilder0> builders;
  final FlatTableCtrl ctrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

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
                  child: Padding(
                    padding: const EdgeInsets.only(right: 11, bottom: 11),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ResponsiveGridList(
                          minItemWidth: 290,
                          horizontalGridMargin: 0,
                          // verticalGridMargin: 16,

                          listViewBuilderOptions: ListViewBuilderOptions(
                            controller: verticalController,
                            shrinkWrap: true,
                          ),
                          children: ctrl.rows
                              .sublist(1)
                              .map(
                                (List<dynamic> row) => Card(
                                  color: colorScheme.surfaceVariant.lighten(5),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: colorScheme.surfaceVariant),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: ctrl.columns
                                          .map<Widget>(
                                            (SimpleType t) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    t.columnLabel,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  Text(
                                                    row.elementAtOrNull(t.index).toString(),
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      height: 1,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                          .intersperse(const Gap(smallSpacing))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
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
