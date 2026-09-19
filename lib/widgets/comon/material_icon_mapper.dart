import 'package:flutter/material.dart';

/// Maps persisted Material icon codes to const icons.
/// This keeps Flutter web icon tree-shaking compatible.
class MaterialIconMapper {
  MaterialIconMapper._();

  static const Map<int, IconData> _icons = {
    58240: Icons.phone_android,
    57704: Icons.code,
    59636: Icons.web,
    58062: Icons.storage,
    58045: Icons.cloud,
    59576: Icons.settings,
    59591: Icons.build,
    58835: Icons.api,
  };

  static IconData fromCode(int code) => _icons[code] ?? Icons.code;
}
