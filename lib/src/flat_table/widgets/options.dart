import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../extensions/intersperse.dart';
import '../models/flat_table_ctrl.dart';
import '../models/list_provider.dart';

class Options extends StatelessWidget {
  const Options({
    required this.ctrl,
    super.key,
  });

  final FlatTableCtrl ctrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Icon(
            Symbols.check,
            color: theme.brightness == Brightness.light ? colorScheme.onSurface : colorScheme.surface,
          );
        }

        return const Icon(Symbols.close);
      },
    );

    final ScrollController verticalController = ScrollController();
    final List<SimpleType> columns = List<SimpleType>.from(ctrl.provider.meta.map((SimpleType e) => e.copyWith()));

    return AlertDialog(
      title: const Text('Preferences'),
      content: RawScrollbar(
        controller: verticalController,
        thumbVisibility: true,
        radius: const Radius.circular(2),
        thickness: 10,
        trackVisibility: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: verticalController,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 820, maxWidth: 820),
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Gap(16),
                              Text('View as', style: textTheme.bodyLarge),
                              const Gap(4),
                              const RadioListTile<int>(
                                value: 50,
                                groupValue: 51,
                                onChanged: null,
                                title: Text('Cards'),
                                dense: true,
                                contentPadding: EdgeInsets.only(left: 4, right: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Divider(),
                              const RadioListTile<int>(
                                value: 100,
                                groupValue: 100,
                                onChanged: null,
                                title: Text('Table'),
                                dense: true,
                                contentPadding: EdgeInsets.only(left: 4, right: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Gap(16),
                              Text('Stick first column(s)', style: textTheme.bodyLarge),
                              Text(
                                'Keep the first column(s) visible while horizontally scrolling the table content.',
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                              ),
                              const Gap(4),
                              const RadioListTile<int>(
                                value: 50,
                                groupValue: 50,
                                onChanged: null,
                                title: Text('None'),
                                dense: true,
                                contentPadding: EdgeInsets.only(left: 4, right: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Divider(),
                              const RadioListTile<int>(
                                value: 100,
                                groupValue: 50,
                                onChanged: null,
                                title: Text('First column'),
                                dense: true,
                                contentPadding: EdgeInsets.only(left: 4, right: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Divider(),
                              const RadioListTile<int>(
                                value: 200,
                                groupValue: 50,
                                onChanged: null,
                                title: Text('First two columns'),
                                dense: true,
                                contentPadding: EdgeInsets.only(left: 4, right: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              Container(
                                color: Colors.white10,
                                width: 1,
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 36, thickness: 2, endIndent: 0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Select visible columns', style: textTheme.bodyLarge),
                            const Gap(4),
                            ...columns.map<Widget>((SimpleType type) {
                              return ListenableBuilder(
                                listenable: type,
                                builder: (BuildContext context, Widget? child) {
                                  return ListTile(
                                    title: Text(type.columnLabel),
                                    trailing: SizedBox(
                                      width: 40,
                                      child: AbsorbPointer(
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Switch(
                                            value: type.visible,
                                            onChanged: (bool value) {}, // ignore: no-empty-block
                                            thumbIcon: thumbIcon,
                                          ),
                                        ),
                                      ),
                                    ),
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    onTap: () => type.changeVisibility(!type.visible),
                                  );
                                },
                              );
                            }).intersperse(const Divider(height: 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            ctrl.provider.meta = columns;
            ctrl.invalidateState();
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
      insetPadding: const EdgeInsets.all(10),
    );
  }
}
