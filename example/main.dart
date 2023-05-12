// Copyright (c) 2023, Devon Carew. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vtable/vtable.dart';

void main() {
  runApp(
    ExampleApp(
      items: generateRowData(planets.length * 10),
    ),
  );
}

class ExampleApp extends StatefulWidget {
  final List<SampleRowData> items;

  const ExampleApp({
    required this.items,
    super.key,
  });

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTable Example App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('VTable Example App'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: createTable(),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  VTable<SampleRowData> createTable() {
    const disabledStyle =
        TextStyle(fontStyle: FontStyle.italic, color: Colors.grey);

    return VTable<SampleRowData>(
      items: widget.items,
      tableDescription: '${widget.items.length} items',
      startsSorted: true,
      includeCopyToClipboardAction: true,
      columns: [
        VTableColumn(
          label: 'ID',
          width: 180,
          grow: 1,
          transformFunction: (row) => row.id,
        ),
        VTableColumn(
          label: 'Planet',
          width: 100,
          grow: 1,
          transformFunction: (row) => row.planet.name,
          styleFunction: (row) => row.planet == moon ? disabledStyle : null,
        ),
        VTableColumn(
          label: 'Gravity (m/s²)',
          width: 120,
          grow: 1,
          transformFunction: (row) => row.planet.gravity.toStringAsFixed(1),
          alignment: Alignment.centerRight,
          compareFunction: (a, b) =>
              a.planet.gravity.compareTo(b.planet.gravity),
          validators: [SampleRowData.validateGravity],
        ),
        VTableColumn(
          label: 'Orbit distance (AU)',
          width: 120,
          grow: 1,
          transformFunction: (row) =>
              (row.planet.orbit / earth.orbit).toStringAsFixed(1),
          alignment: Alignment.centerRight,
          compareFunction: (a, b) => a.planet.orbit.compareTo(b.planet.orbit),
        ),
        VTableColumn(
          label: 'Orbital period (years)',
          width: 140,
          grow: 1,
          transformFunction: (row) =>
              (row.planet.period / earth.period).toStringAsFixed(1),
          alignment: Alignment.centerRight,
          compareFunction: (a, b) => a.planet.period.compareTo(b.planet.period),
        ),
        VTableColumn(
          label: 'Moons',
          width: 100,
          grow: 1,
          transformFunction: (row) => row.planet.moons.toString(),
          alignment: Alignment.centerRight,
          compareFunction: (a, b) => a.planet.moons - b.planet.moons,
        ),
        VTableColumn(
          label: 'Temperature (C)',
          width: 120,
          transformFunction: (row) => row.planet.temp.toString(),
          alignment: Alignment.centerRight,
          compareFunction: (a, b) => a.planet.temp - b.planet.temp,
        ),
        VTableColumn(
          label: 'Temperature',
          width: 120,
          alignment: Alignment.center,
          transformFunction: (row) => row.planet.temp.toString(),
          compareFunction: (a, b) => a.planet.temp - b.planet.temp,
          renderFunction: (context, data, _) {
            Color color;
            if (data.planet.temp < 0) {
              color = Colors.blue
                  .withAlpha((data.planet.temp / Planet.coldest * 255).round());
            } else {
              color = Colors.red
                  .withAlpha((data.planet.temp / Planet.hotest * 255).round());
            }
            return Chip(
              label: const SizedBox(width: 48),
              backgroundColor: color,
            );
          },
        ),
      ],
    );
  }
}

List<SampleRowData> generateRowData(int rows) {
  final words = loremIpsum
      .toLowerCase()
      .replaceAll(',', '')
      .replaceAll('.', '')
      .split(' ');
  final random = math.Random();

  return List.generate(rows, (index) {
    final word1 = words[random.nextInt(words.length)];
    final word2 = words[random.nextInt(words.length)];
    final val = random.nextInt(10000);
    final id = '$word1-$word2-${val.toString().padLeft(4, '0')}';

    return SampleRowData(
      id: id,
      planet: planets[random.nextInt(planets.length)],
    );
  });
}

const String loremIpsum =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua.';

const Planet earth = Planet('Earth', 9.8, 149.6, 365.2, 15, 1);
const Planet moon = Planet('Moon', 1.6, 0.384, 27.3, -20, 0);

const List<Planet> planets = <Planet>[
  Planet('Mercury', 3.7, 57.9, 88, 167, 0),
  Planet('Venus', 8.9, 108.2, 224.7, 464, 0),
  earth,
  moon,
  Planet('Mars', 3.7, 228, 687, -65, 2),
  Planet('Jupiter', 23.1, 778.5, 4331, -110, 92),
  Planet('Saturn', 9, 1432, 10747, -140, 83),
  Planet('Uranus', 8.7, 2867, 30589, -195, 27),
  Planet('Neptune', 11, 4515, 59800, -200, 14),
  Planet('Pluto', 0.7, 5906.4, 90560, -225, 5),
];

class Planet {
  final String name;
  final double gravity;
  final double orbit;
  final double period;
  final int temp;
  final int moons;

  const Planet(
    this.name,
    this.gravity,
    this.orbit,
    this.period,
    this.temp,
    this.moons,
  );

  static int get coldest =>
      planets.fold(0, (previous, next) => math.min(previous, next.temp));

  static int get hotest =>
      planets.fold(0, (previous, next) => math.max(previous, next.temp));

  @override
  String toString() => name;
}

class SampleRowData {
  final String id;
  final Planet planet;

  SampleRowData({required this.id, required this.planet});

  static ValidationResult? validateGravity(SampleRowData row) {
    if (row.planet.gravity > 20.0) {
      return ValidationResult.error('too heavy!');
    }
    if (row.planet.gravity > 10.0) {
      return ValidationResult.warning('pretty heavy');
    }
    return null;
  }

  @override
  String toString() => '$id (${planet.name})';
}
