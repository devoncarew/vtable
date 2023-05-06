// Copyright (c) 2023, Devon Carew. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../vtable.dart';
import 'theme.dart';

/// Copies the contents of a [VTable] into the clipboard.
///
/// This widget - when added to the `actions` of a [VTable] - will copy the
/// contents of the table into the clipboard in CSV format.
///
/// [T] is the row type of the target table.
///
/// Note that the parameterized type of the action must be provided in order
/// for the action to locate the table in the widget tree (so, for a
/// `VTable<MyRowType> table, the action should be constructed as
/// `CopyToClipboardAction<MyRowType>`).
class CopyToClipboardAction<T> extends StatelessWidget {
  const CopyToClipboardAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy),
      tooltip: 'Copy table data to clipboard',
      iconSize: defaultIconSize,
      splashRadius: defaultSplashRadius,
      onPressed: () => _copyTableToClipboard(context),
    );
  }

  void _copyTableToClipboard(BuildContext context) {
    final table = context.findAncestorWidgetOfExactType<VTable<T>>()!;

    final buf = StringBuffer();

    // write out the column titles
    buf.writeln(table.columns.map((c) => c.label).join(','));

    // write out each row
    for (final item in table.items) {
      buf.writeln(table.columns.map((column) {
        String val = column.transformFunction != null
            ? column.transformFunction!(item)
            : '$item';
        return val.contains(',') ? '"$val"' : val;
      }).join(','));
    }

    Clipboard.setData(ClipboardData(text: buf.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as CSV to clipboard.')),
    );
  }
}
