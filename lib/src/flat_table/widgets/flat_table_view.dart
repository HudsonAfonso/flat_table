import 'dart:async';

import 'package:flutter/material.dart' hide MenuAnchor, MenuController, MenuItemButton;
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../extensions/flex_ext.dart';
import '../models/flat_table_ctrl.dart';
import '../models/option.dart';
import 'card_view.dart';
import 'column_filter.dart';
import 'constants.dart';
import 'flat_table.dart';
import 'maybe_tooltip.dart';
import 'menu_anchor.dart';
import 'options.dart';

typedef Action = void Function();

class FlatTableView extends StatelessWidget {
  const FlatTableView({
    required this.ctrl,
    super.key,
    @Deprecated('Use [actions]') this.novoAction,
    this.actions = const <Widget>[],
    this.filters = const <Widget>[],
    this.showConfig = false,
    this.showHeader = true,
    this.builders = const <String, CustomCellBuilder>{},
  });

  final List<Widget> actions;
  final Map<String, CustomCellBuilder> builders;
  final FlatTableCtrl ctrl;
  final List<Widget> filters;
  final Action? novoAction;
  final bool showConfig;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Size> tableSize = ValueNotifier<Size>(Size.zero);

    final ThemeData theme = Theme.of(context);

    final Function? refreshAction = ctrl.refreshAction;

    return Theme(
      data: theme.copyWith(
        visualDensity: VisualDensity.compact,
        dividerTheme: theme.dividerTheme.copyWith(space: 1, thickness: 1),
        menuTheme: MenuThemeData(style: MenuStyle(padding: MaterialStateProperty.all(EdgeInsets.zero))),
        menuButtonTheme: MenuButtonThemeData(
          style: ButtonStyle(padding: MaterialStateProperty.all(const EdgeInsets.only(left: 10, right: 16))),
        ),
      ),
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          return ContentView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (showHeader)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: IntrinsicHeight(
                          child: Row(
                            children: <Widget>[
                              ColumnFilter(ctrl, tableSize),
                              ListenableBuilder(
                                listenable: ctrl,
                                builder: (BuildContext context, Widget? child) {
                                  final int totalSize = ctrl.provider.data.length;
                                  final int filteredSize = ctrl.rows.length - 1;

                                  String qty = ' ($filteredSize/$totalSize)';
                                  if (filteredSize == totalSize) {
                                    qty = ' ($filteredSize)';
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      qty,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: theme.colorScheme.outline),
                                    ),
                                  );
                                },
                              ),
                              if (refreshAction != null)
                                MaybeTooltip(
                                  condition: constraints.maxWidth > 450,
                                  message: 'Refresh',
                                  child: IconButton(
                                    onPressed: () => refreshAction(),
                                    icon: const Icon(Symbols.refresh, weight: 300),
                                  ),
                                ),
                              if (filters.isNotEmpty)
                                ValueListenableBuilder<bool>(
                                  valueListenable: ctrl.showFilter,
                                  builder: (BuildContext context, bool value, Widget? child) {
                                    return MaybeTooltip(
                                      condition: constraints.maxWidth > 450,
                                      message: 'Filtro',
                                      child: IconButton(
                                        onPressed: () {
                                          ctrl.showFilter.value = !ctrl.showFilter.value;
                                        },
                                        icon: Icon(Symbols.filter_alt, fill: value ? 1 : 0, weight: 300),
                                      ),
                                    );
                                  },
                                ),
                              MaybeTooltip(
                                condition: constraints.maxWidth > 450,
                                message: 'Download resultados (Excel)',
                                child: IconButton(
                                  onPressed: ctrl.save,
                                  icon: const Icon(Symbols.table, weight: 300),
                                ),
                              ),
                              ...actions,
                              if (novoAction != null)
                                MaybeTooltip(
                                  condition: constraints.maxWidth > 450,
                                  message: 'Novo',
                                  child: IconButton(
                                    onPressed: novoAction,
                                    icon: const Icon(Symbols.add_circle, weight: 300),
                                  ),
                                ),
                              if (showConfig)
                                MaybeTooltip(
                                  condition: constraints.maxWidth > 450,
                                  message: 'Configurações',
                                  child: IconButton(
                                    onPressed: () => _settingsDialogBuilder(context, ctrl),
                                    icon: const Icon(Symbols.settings, weight: 300),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (showHeader) const Gap(8),
                ValueListenableBuilder<bool>(
                  valueListenable: ctrl.showFilter,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return value
                        ? Card(
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Wrap(
                                          spacing: smallSpacing,
                                          runSpacing: smallSpacing * 2,
                                          children: <Widget>[
                                            ...filters.map(
                                              (Widget e) => ConstrainedBox(
                                                constraints: const BoxConstraints.tightFor(
                                                  width: (widthConstraint - (smallSpacing * 2)) / 2,
                                                ),
                                                child: e,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: smallSpacing),
                                        child: MaybeTooltip(
                                          condition: constraints.maxWidth > 450,
                                          message: 'Filtrar',
                                          child: SizedBox(
                                            width: 32,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: IconButton.filled(
                                                onPressed: () {
                                                  ctrl.refreshAction!();
                                                  ctrl.showFilter.value = false;
                                                },
                                                icon: const Icon(
                                                  Symbols.filter_alt,
                                                  fill: 1,
                                                  weight: 300,
                                                  opticalSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: ctrl.showFilter,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return value
                        ? Divider(
                            height: 1,
                            thickness: 2,
                            color: Theme.of(context).dividerTheme.color!.lightenOrDarken(context),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                const Gap(4),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, BoxConstraints constraints) {
                      scheduleMicrotask(() {
                        tableSize.value = constraints.biggest;
                      });

                      const bool cardView = false;
                      if (cardView) {
                        return CardView(ctrl, builders: {});
                      }

                      return FlatTable(ctrl, builders: builders);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _settingsDialogBuilder(BuildContext context, FlatTableCtrl ctrl) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Options(ctrl: ctrl);
      },
    );
  }
}

class FilterList<T> extends StatelessWidget {
  const FilterList({
    required this.label,
    required this.options,
    this.single = false,
    super.key,
  });

  final String label;
  final List<Option<T>> options;
  final bool single;

  @override
  Widget build(BuildContext context) {
    final InputDecorationTheme inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return MenuAnchor(
      menuChildren: options
          .map(
            (Option<T> option) => MenuItemButton(
              onPressed: () => _onChanged(option),
              leadingIcon: AbsorbPointer(
                child: ValueListenableBuilder<bool>(
                  valueListenable: option.selected,
                  builder: (_, bool value, __) {
                    return Checkbox(
                      value: value,
                      onChanged: (bool? value) {}, // ignore: no-empty-block
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
              closeOnActivate: false,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(option.label),
              ),
            ),
          )
          .toList(),
      style: MenuStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      alignmentOffset: const Offset(0, 6),
      builder: (BuildContext context, MenuController controller, _) {
        return GestureDetector(
          onTap: controller.isOpen ? controller.close : controller.open,
          child: Card(
            color: inputDecorationTheme.fillColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: inputDecorationTheme.enabledBorder!.borderSide.color),
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(8, 10, 8, 10), child: Text(label)),
                Container(
                  color: Theme.of(context).hintColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: ListenableBuilder(
                      listenable: Listenable.merge(options.map((Option<T> e) => e.selected).toList()),
                      builder: (_, __) {
                        return Text(
                          options.where((Option<T> element) => element.selected.value).length.toString(),
                          style: TextStyle(color: Theme.of(context).colorScheme.surface),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onChanged(Option<T> option) {
    if (single) {
      for (Option<T> e in options) {
        if (e.id != option.id) {
          e.selected.value = false;
        }
      }
    }
    option.selected.value = !option.selected.value;
  }
}

class ContentView extends StatelessWidget {
  const ContentView({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return Padding(
          padding: constraints.maxWidth <= 640
              ? const EdgeInsets.all(12)
              : const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: child,
        );
      },
    );
  }
}
