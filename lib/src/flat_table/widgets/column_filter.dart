import 'package:flutter/material.dart' hide MenuAnchor, MenuController, MenuItemButton;
import 'package:material_symbols_icons/symbols.dart';

import '../models/flat_table_ctrl.dart';
import '../models/list_provider.dart';
import 'menu_anchor.dart';

class ColumnFilter extends StatelessWidget {
  const ColumnFilter(
    this.ctrl,
    this.tableSize, {
    super.key,
  });

  final FlatTableCtrl ctrl;
  final ValueNotifier<Size> tableSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<Size>(
        valueListenable: tableSize,
        builder: (BuildContext context, Size size, Widget? child) {
          return MenuAnchor(
            menuChildren: <Widget>[
              ValueListenableBuilder<String>(
                valueListenable: ctrl.textFilter,
                builder: (_, String textFilter, __) {
                  if (textFilter == '') return const SizedBox.shrink();

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: size.width / 2),
                    child: MenuItemButton(
                      onPressed: () {}, // ignore: no-empty-block
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text('Usar: "$textFilter"', style: const TextStyle(height: 1), maxLines: 2),
                      ),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: ctrl.textFilter,
                builder: (_, String textFilter, __) {
                  if (textFilter == '') return const SizedBox.shrink();

                  return const Divider();
                },
              ),
              MenuItemButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    'Propriedades',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(),
              ...ctrl.columns.map<MenuItemButton>((SimpleType type) {
                return MenuItemButton(
                  onPressed: () {}, // ignore: no-empty-block
                  child: Padding(padding: const EdgeInsets.only(right: 20), child: Text(type.columnLabel)),
                );
              }),
            ],
            style: MenuStyle(maximumSize: WidgetStateProperty.all(Size(size.width, size.height))),
            alignmentOffset: const Offset(0, 3),
            builder: (BuildContext context, MenuController controller, Widget? child) {
              final TextEditingController controller = TextEditingController();

              return TextFormField(
                controller: controller..text = ctrl.textFilter.value,
                decoration: InputDecoration(
                  hintText: 'Realize uma pesquisa por termo',
                  isDense: true,
                  contentPadding: const EdgeInsets.all(8),
                  prefixIcon: const Icon(Symbols.search, weight: 300),
                  suffixIcon: ValueListenableBuilder<String>(
                    valueListenable: ctrl.textFilter,
                    builder: (_, String textFilter, __) {
                      return Visibility(
                        visible: textFilter.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            ctrl.textFilter.value = '';
                            controller.clear();
                            ctrl.invalidateState();
                          },
                          icon: const Icon(Symbols.clear, weight: 300),
                        ),
                      );
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (String value) {
                  ctrl.textFilter.value = value;
                },
                onEditingComplete: () {
                  ctrl.invalidateState();
                },
                onSaved: (String? newValue) {
                  ctrl.invalidateState();
                },
              );
            },
          );
        },
      ),
    );
  }
}
