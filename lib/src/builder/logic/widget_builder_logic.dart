import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/widget_builder.dart';
import 'package:flutter_jsonschema_builder/src/models/json_form_schema_style.dart';
import 'package:flutter_jsonschema_builder/src/models/schema.dart';

class WidgetBuilderInherited extends InheritedWidget {
  WidgetBuilderInherited({
    super.key,
    required this.mainSchema,
    required super.child,
    this.fileHandler,
    this.customPickerHandler,
    this.customValidatorHandler,
  });

  final Schema mainSchema;
  final Map data = {};

  final FileHandler? fileHandler;
  final CustomPickerHandler? customPickerHandler;
  final CustomValidatorHandler? customValidatorHandler;
  late final JsonFormSchemaUiConfig uiConfig;

  void setJsonFormSchemaStyle(
    BuildContext context,
    JsonFormSchemaUiConfig? uiConfig,
  ) {
    final textTheme = Theme.of(context).textTheme;

    this.uiConfig = JsonFormSchemaUiConfig(
      title: uiConfig?.title ?? textTheme.titleLarge,
      titleAlign: uiConfig?.titleAlign ?? TextAlign.center,
      subtitle: uiConfig?.subtitle ??
          textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      description: uiConfig?.description ?? textTheme.bodyMedium,
      error: uiConfig?.error ??
          TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: textTheme.bodySmall!.fontSize,
          ),
      fieldTitle: uiConfig?.fieldTitle ?? textTheme.bodyMedium,
      label: uiConfig?.label,
      //builders
      addItemBuilder: uiConfig?.addItemBuilder,
      removeItemBuilder: uiConfig?.removeItemBuilder,
      submitButtonBuilder: uiConfig?.submitButtonBuilder,
      addFileButtonBuilder: uiConfig?.addFileButtonBuilder,
    );
  }

  /// update [data] with key,values from jsonSchema
  void updateObjectData(dynamic object, String path, dynamic value) {
    log('updateObjectData $object path $path value $value');

    final stack = path.split('.');

    while (stack.length > 1) {
      final _key = stack[0];
      final isNextKeyInteger = int.tryParse(stack[1]) != null;
      final newContent = isNextKeyInteger ? [] : {};
      final _keyNumeric = int.tryParse(_key);

      log('$_key - next Key is int? $isNextKeyInteger');

      _addNewContent(object, _keyNumeric, newContent);

      final tempObject = object[_keyNumeric ?? _key];
      if (tempObject != null) {
        object = tempObject;
      } else {
        object[_key] = newContent;
        object = newContent;
      }

      stack.removeAt(0);
    }

    final _key = stack[0];
    final _keyNumeric = int.tryParse(_key);
    _addNewContent(object, _keyNumeric, value);

    object[_keyNumeric ?? _key] = value;
    stack.removeAt(0);
  }

  /// add a new value into a schema,
  void _addNewContent(dynamic object, int? _keyNumeric, dynamic value) {
    if (object is List && _keyNumeric != null) {
      if (object.length - 1 < _keyNumeric) {
        object.add(value);
      }
    }
  }

  /// remove object from [data] with key from jsonSchema
  void removeObjectData(dynamic object, String path) {
    final stack = path.split('.');

    while (stack.length > 1) {
      final _key = stack[0];
      final _keyNumeric = int.tryParse(_key);

      final tempObject = object[_keyNumeric ?? _key];
      if (tempObject != null) {
        object = tempObject;
      }

      stack.removeAt(0);
    }

    final _key = stack[0];
    final _keyNumeric = int.tryParse(_key);

    if (object is List && _keyNumeric != null) {
      object.removeAt(_keyNumeric);
    } else {
      object.remove(_key);
    }
  }

  /// get object from [data] with key from jsonSchema
  dynamic getObjectData(dynamic object, String path) {
    final stack = path.split('.');

    while (stack.length > 1) {
      final _key = stack[0];
      final _keyNumeric = int.tryParse(_key);

      final tempObject = object[_keyNumeric ?? _key];
      if (tempObject != null) {
        object = tempObject;
      }

      stack.removeAt(0);
    }

    final _key = stack[0];
    final _keyNumeric = int.tryParse(_key);

    try {
      return object[_keyNumeric ?? _key];
    } catch (e) {
      return null;
    }
  }

  void notifyChanges() {
    // if (onChanged != null) onChanged!(data);
  }

  @override
  bool updateShouldNotify(covariant WidgetBuilderInherited oldWidget) =>
      mainSchema != oldWidget.mainSchema;

  static WidgetBuilderInherited of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<WidgetBuilderInherited>();

    assert(result != null, 'No WidgetBuilderInherited found in context');
    return result!;
  }
}

// ignore: must_be_immutable
class RemoveItemInherited extends InheritedWidget {
  RemoveItemInherited({
    super.key,
    required super.child,
    required this.removeItem,
    required this.schema,
  });

  final MapEntry<String, void Function()> removeItem;
  final Schema schema;
  BuildContext? _context;

  static MapEntry<String, void Function()>? getRemoveItem(
    BuildContext context,
    Schema schema,
  ) {
    final removeItemInherited = RemoveItemInherited.maybeOf(context);

    if (removeItemInherited == null ||
        removeItemInherited._context != null &&
            removeItemInherited._context!.mounted &&
            removeItemInherited._context != context ||
        removeItemInherited.schema != schema) {
      return null;
    }

    removeItemInherited._context = context;
    return removeItemInherited.removeItem;
  }

  static RemoveItemInherited? maybeOf(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<RemoveItemInherited>();
    return result;
  }

  @override
  bool updateShouldNotify(covariant RemoveItemInherited oldWidget) =>
      removeItem != oldWidget.removeItem || schema != oldWidget.schema;
}
