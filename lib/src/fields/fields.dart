import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/models/property_schema.dart';
import 'package:flutter_jsonschema_builder/src/utils/date_text_input_json_formatter.dart';
import 'package:intl/intl.dart';

export 'checkbox_form_field.dart';
export 'date_form_field.dart';
export 'dropdown_form_field.dart';
export 'file_form_field.dart';
export 'number_form_field.dart';
export 'text_form_field.dart';

abstract class PropertyFieldWidget<T> extends StatefulWidget {
  const PropertyFieldWidget({
    super.key,
    required this.property,
    required this.onSaved,
    required this.onChanged,
    this.customValidator,
  });

  final SchemaProperty property;
  final ValueSetter<T?> onSaved;
  final ValueChanged<T?>? onChanged;
  final String? Function(dynamic)? customValidator;

  /// It calls onChanged
  Future<dynamic> triggerDefaultValue() async {
    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var value = property.defaultValue;
      if (property.initialValue != null) value = property.initialValue;

      try {
        if (property.format == PropertyFormat.date) {
          value = DateFormat(dateFormatString).parse(value);
        } else if (property.format == PropertyFormat.datetime) {
          value = DateFormat(dateTimeFormatString).parse(value);
        }
      } catch (e) {
        value = null;
      }

      if (onChanged != null) onChanged!(value);

      completer.complete(value);
    });

    return completer.future;
  }
}
