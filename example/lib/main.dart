import 'package:flat_table/flat_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'flex_ext.dart';

void main() => runApp(const AppWidget());

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // const Color colorSchemeSeed = Color(0xFF333333);
    const Color colorSchemeSeed = Colors.blueGrey;

    return MaterialApp(
      home: const MyHomePage(title: 'Demo'),
      title: 'Demo',
      theme: _themeFor(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: colorSchemeSeed),
      ),
      darkTheme: _themeFor(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: colorSchemeSeed),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _themeFor({required ThemeData theme}) {
    final TextTheme textTheme = GoogleFonts.ibmPlexSansCondensedTextTheme(theme.textTheme);
    final TextStyle labelMedium = textTheme.labelMedium!.copyWith(color: theme.colorScheme.onSurface);

    final IconThemeData iconTheme = theme.iconTheme.copyWith(weight: 300);

    return theme.copyWith(
      textTheme: textTheme,
      appBarTheme: theme.appBarTheme.copyWith(
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: iconTheme,
        actionsIconTheme: iconTheme,
      ),
      snackBarTheme: theme.snackBarTheme.copyWith(behavior: SnackBarBehavior.floating),
      iconTheme: iconTheme,
      navigationRailTheme: theme.navigationRailTheme.copyWith(
        selectedIconTheme: iconTheme,
        unselectedIconTheme: iconTheme,
        selectedLabelTextStyle: labelMedium,
        unselectedLabelTextStyle: labelMedium,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: const OutlineInputBorder(),
        filled: true,
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // alignLabelWithHint: true,
      ),
      bannerTheme: theme.bannerTheme.copyWith(
        backgroundColor: theme.colorScheme.surface.getShadeColor(lightenn: theme.brightness == Brightness.dark),
        padding: const EdgeInsets.all(16),
      ),
      cardTheme: theme.cardTheme.copyWith(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FlatTableView(
        ctrl: FlatTableCtrl(
          name: 'Demo',
          provider: ListProvider(
            meta: <SimpleType>[
              SimpleType(index: 0, builtInType: 'string', columnLabel: 'Weapon', name: 'Weapon'),
              SimpleType(index: 1, builtInType: 'string', columnLabel: 'Type', name: 'Type'),
              SimpleType(index: 2, builtInType: 'bool', columnLabel: 'Support Drop', name: 'Support Drop'),
              SimpleType(index: 3, builtInType: 'int', columnLabel: 'Magazine Capacity', name: 'Magazine Capacity'),
              SimpleType(index: 4, builtInType: 'bool', columnLabel: 'Rounds Reload', name: 'Rounds Reload'),
              SimpleType(index: 5, builtInType: 'int', columnLabel: 'Reserve Magzines', name: 'Reserve Magzines'),
              SimpleType(index: 6, builtInType: 'int', columnLabel: 'Damage', name: 'Damage'),
              SimpleType(index: 7, builtInType: 'double', columnLabel: 'Max Fire Rate', name: 'Max Fire Rate'),
              SimpleType(index: 8, builtInType: 'double', columnLabel: 'DPS', name: 'DPS', decimalDigits: 2),
              SimpleType(index: 9, builtInType: 'string', columnLabel: 'Fire Mode', name: 'Fire Mode'),
              SimpleType(index: 10, builtInType: 'int', columnLabel: 'Recoil', name: 'Recoil'),
              SimpleType(
                index: 11,
                builtInType: 'double',
                columnLabel: 'Recoil/s',
                name: 'Recoil/s',
                decimalDigits: 2,
              ),
              SimpleType(index: 12, builtInType: 'int', columnLabel: 'Armor Penetration', name: 'Armor Penetration'),
              SimpleType(index: 13, builtInType: 'string', columnLabel: 'Unique Traits', name: 'Unique Traits'),
              SimpleType(
                index: 14,
                builtInType: 'string',
                columnLabel: 'War Bond/Unlock Level',
                name: 'War Bond/Unlock Level',
              ),
              SimpleType(index: 15, builtInType: 'int', columnLabel: 'Unlock Cost', name: 'Unlock Cost'),
            ],
            data: <List<dynamic>>[
              <dynamic>[
                'AR-23 Liberator',
                'Rifle',
                false,
                45,
                false,
                7,
                55,
                640,
                586.67,
                'Auto',
                15,
                160,
                1,
                null,
                'Starter',
                null,
              ],
              <dynamic>[
                'MP-98 Knight',
                'SMG',
                false,
                50,
                false,
                7,
                50,
                1380,
                1150,
                'Auto',
                20,
                460,
                1,
                'One Handed',
                'Starter (DLC)',
                'N/A',
              ],
              <dynamic>[
                'P-2 Peacemaker',
                'Pistol',
                false,
                15,
                false,
                5,
                60,
                900,
                900,
                'Semi',
                23,
                345,
                1,
                'One Handed',
                'Starter',
                'N/A',
              ],
              <dynamic>[
                'SG-8 Punisher',
                'Shotgun',
                false,
                16,
                true,
                60,
                405,
                80,
                540,
                'Pump',
                110,
                146.67,
                1,
                'Dual Magazine',
                'Helldivers Mobilize!',
                '4',
              ],
              <dynamic>[
                'P-19 Redeemer',
                'Pistol',
                false,
                31,
                false,
                4,
                60,
                1100,
                1100,
                'Auto',
                11,
                201.67,
                1,
                'One Handed',
                'Helldivers Mobilize!',
                '5',
              ],
              <dynamic>[
                'R-63 Diligence',
                'DMR',
                false,
                20,
                false,
                8,
                112,
                350,
                653.33,
                'Semi',
                35,
                204.17,
                1,
                'Magnified Optics',
                'Helldivers Mobilize!',
                '8',
              ],
              <dynamic>[
                'SMG-37 Defender',
                'SMG',
                false,
                45,
                false,
                7,
                70,
                520,
                606.67,
                'Auto',
                10,
                86.67,
                1,
                'One Handed',
                'Helldivers Mobilize!',
                '15',
              ],
              <dynamic>[
                'SG-225 Breaker',
                'Shotgun',
                false,
                13,
                false,
                7,
                330,
                300,
                1650,
                'Auto',
                55,
                275,
                1,
                'N/A',
                'Helldivers Mobilize!',
                '20',
              ],
              <dynamic>[
                'LAS-5 Scythe',
                'Laser',
                false,
                null,
                false,
                null,
                null,
                null,
                300,
                'Beam',
                null,
                null,
                1,
                'Heat Sinks',
                'Helldivers Mobilize!',
                '30',
              ],
              <dynamic>[
                'AR-23P Liberator Penetrator',
                'Rifle',
                false,
                30,
                false,
                null,
                45,
                640,
                480,
                'Auto',
                19,
                202.67,
                2,
                'N/A',
                'Helldivers Mobilize!',
                '40',
              ],
              <dynamic>[
                'R-63CS Diligence Counter Sniper',
                'DMR',
                false,
                15,
                false,
                null,
                128,
                350,
                746.67,
                'Semi',
                53,
                309.17,
                1,
                'Magnified Optics',
                'Helldivers Mobilize!',
                '40',
              ],
              <dynamic>[
                'SG-8S Slugger',
                'Shotgun',
                false,
                16,
                true,
                60,
                280,
                80,
                373.33,
                'Pump',
                110,
                146.67,
                1,
                'Dual Magazine',
                'Helldivers Mobilize!',
                '60',
              ],
              <dynamic>[
                'SG-225SP Breaker Spray&Pray',
                'Shotgun',
                false,
                26,
                false,
                null,
                144,
                330,
                792,
                'Auto',
                45,
                247,
                1,
                'N/A',
                'Helldivers Mobilize!',
                '60',
              ],
              <dynamic>[
                'PLAS-1 Scorcher',
                'Energy',
                false,
                15,
                false,
                null,
                100,
                250,
                416.67,
                '',
                20,
                83.33,
                1,
                'Explosive',
                'Helldivers Mobilize!',
                '75',
              ],
              <dynamic>[
                'P-4 Senator',
                'Pistol',
                false,
                6,
                true,
                40,
                150,
                200,
                500,
                '',
                43,
                143.33,
                1,
                'One Handed',
                'Steeled Veterans',
                '15',
              ],
              <dynamic>[
                'AR-23E Liberator Explosive',
                'Rifle',
                false,
                30,
                false,
                10,
                55,
                320,
                293.33,
                'Auto',
                28,
                149.33,
                1,
                'Explosive',
                'Steeled Veterans',
                '20',
              ],
              <dynamic>[
                'SG-225IE Breaker Incendiary',
                'Shotgun',
                false,
                25,
                false,
                6,
                180,
                300,
                900,
                'Burst',
                28,
                140,
                1,
                'Incendiary',
                'Steeled Veterans',
                '60',
              ],
              <dynamic>[
                'JAR-5 Dominator',
                'Shotgun',
                false,
                15,
                false,
                null,
                200,
                250,
                833.33,
                'Burst',
                75,
                312.5,
                2,
                'N/A',
                'Steeled Veterans',
                '80',
              ],
              <dynamic>[
                'MG-43 Machine Gun',
                'Machinegun',
                true,
                150,
                false,
                2,
                null,
                900,
                null,
                'Auto',
                null,
                null,
                2,
                'Static Reload',
                '1',
                'N/A',
              ],
              <dynamic>[
                'APW-1 Anti-Materiel Rifle',
                'Anti-Materiel Rifle',
                true,
                7,
                false,
                6,
                null,
                null,
                null,
                'Bolt',
                null,
                null,
                3,
                'Magnified Optics',
                '2',
                '5000',
              ],
              <dynamic>[
                'M-105 Stalwart',
                'Machinegun',
                true,
                250,
                false,
                3,
                null,
                1150,
                null,
                'Auto',
                null,
                null,
                1,
                'N/A',
                '2',
                '3500',
              ],
              <dynamic>[
                'EAT-17 Expendable Anti-Tank',
                'Rocket Launcher',
                true,
                1,
                false,
                0,
                null,
                null,
                null,
                'Single',
                null,
                null,
                3,
                'Single Use',
                '3',
                '3000',
              ],
              <dynamic>[
                'GR-8 Recoilless Rifle',
                'Rocket Launcher',
                true,
                1,
                true,
                5,
                null,
                null,
                null,
                'Single',
                null,
                null,
                3,
                'Partner Reload',
                '5',
                '6000',
              ],
              <dynamic>[
                'FLAM-40 Flamethrower',
                'Flamethrower',
                true,
                100,
                false,
                4,
                null,
                8.3,
                null,
                'Stream',
                null,
                null,
                3,
                'Incendiary',
                '10',
                '6000',
              ],
              <dynamic>[
                'AC-8 Autocannon',
                'Autocannon',
                true,
                10,
                false,
                10,
                null,
                200,
                null,
                'Auto',
                null,
                null,
                3,
                'Partner Reload, 5 round clips',
                '10',
                '7000',
              ],
              <dynamic>[
                'RS-422 Railgun',
                'Railgun',
                true,
                null,
                null,
                null,
                null,
                null,
                null,
                'Charge',
                null,
                null,
                3,
                'N/A',
                '20',
                '9000',
              ],
              <dynamic>[
                'FAF-14 Spear',
                'Missile Launcher',
                true,
                1,
                true,
                null,
                null,
                null,
                null,
                'Single',
                null,
                null,
                3,
                'Partner Reload, Seeking',
                '20',
                '1500',
              ],
              <dynamic>[
                'GL-21 Grenade Launcher',
                'Grenade Launcher',
                true,
                10,
                false,
                2,
                null,
                null,
                null,
                'Auto',
                null,
                null,
                1,
                'Explosive',
                '5',
                '6000',
              ],
              <dynamic>[
                'LAS-98 Laser Cannon',
                'Laser',
                true,
                null,
                false,
                1,
                null,
                null,
                null,
                'Beam',
                null,
                null,
                2,
                'Heat Sinks',
                '5',
                '4000',
              ],
              <dynamic>[
                'ARC-3 Arc Thrower',
                'Energy',
                true,
                null,
                false,
                null,
                null,
                null,
                null,
                'Charge',
                null,
                null,
                3,
                'Multi Target',
                '15',
                '7000',
              ],
              <dynamic>[
                'Break Action Shotgun',
                'Shotgun',
                false,
                2,
                true,
                40,
                null,
                null,
                null,
                'Semi',
                null,
                null,
                1,
                'Random Pickup Only',
                'N/A',
                'N/A',
              ],
              <dynamic>[
                'LAS-16 Sickle',
                'Laser',
                false,
                null,
                false,
                6,
                55,
                750,
                687.5,
                'Auto',
                2,
                25,
                1,
                'Heat Sinks',
                'Cutting Edge',
                '20',
              ],
              <dynamic>[
                'SG-8P Punisher Plasma',
                'Shotgun',
                false,
                8,
                true,
                60,
                100,
                80,
                133.33,
                'Pump',
                110,
                146.67,
                2,
                'Explosive',
                'Cutting Edge',
                '60',
              ],
              <dynamic>[
                'ARC-12 Blitzer',
                'Shotgun',
                false,
                null,
                false,
                null,
                250,
                30,
                125,
                'Single',
                60,
                30,
                3,
                'Multi Target',
                'Cutting Edge',
                '80',
              ],
              <dynamic>[
                'LAS-7 Dagger',
                'Laser',
                false,
                null,
                false,
                null,
                null,
                null,
                150,
                'Beam',
                null,
                null,
                1,
                'Heat Sinks, One Handed',
                'Cutting Edge',
                '60',
              ],
            ],
          ),
          showDetail: true,
        ),
        actions: <Widget>[
          Tooltip(
            message: 'Novo',
            child: IconButton(
              onPressed: () {}, // ignore: no-empty-block
              icon: const Icon(Symbols.add_circle, weight: 300),
            ),
          ),
        ],
        detailBuilder: (BuildContext context, List<dynamic>? row) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Object Page Header with Links, Rating Indicator, and Object Status',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1),
                ),
                Text(
                  row.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        height: 2.5,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
