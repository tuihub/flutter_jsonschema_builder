import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/flutter_jsonschema_builder.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/models/models.dart';

class JsonFormSchemaUiConfig {
  const JsonFormSchemaUiConfig({
    this.fieldTitle,
    this.error,
    this.title,
    this.titleAlign,
    this.subtitle,
    this.description,
    this.label,
    this.expandGenesis = false,
    this.addItemBuilder,
    this.removeItemBuilder,
    this.submitButtonBuilder,
    this.addFileButtonBuilder,
    this.formSectionBuilder,
    this.fieldWrapperBuilder,
    this.headerTitleBuilder,
    LocalizedTexts? localizedTexts,
    bool? debugMode,
    LabelPosition? labelPosition,
  })  : localizedTexts = localizedTexts ?? const LocalizedTexts(),
        debugMode = debugMode ?? false,
        labelPosition = labelPosition ?? LabelPosition.fieldInputDecoration;

  final TextStyle? fieldTitle;
  final TextStyle? error;
  final TextStyle? title;
  final TextAlign? titleAlign;
  final TextStyle? subtitle;
  final TextStyle? description;
  final TextStyle? label;
  final LocalizedTexts localizedTexts;
  final bool debugMode;
  final LabelPosition labelPosition;
  final bool expandGenesis;

  final Widget Function(VoidCallback onPressed, String key)? addItemBuilder;
  final Widget Function(VoidCallback onPressed, String key)? removeItemBuilder;

  /// render a custom submit button
  /// @param [VoidCallback] submit function
  final Widget Function(VoidCallback onSubmit)? submitButtonBuilder;

  /// render a custom button
  /// if it returns null or it is null, it will build default button
  final Widget? Function(VoidCallback? onPressed, String key)?
      addFileButtonBuilder;

  final Widget Function(Widget child)? formSectionBuilder;
  final Widget? Function(FieldWrapperParams params)? fieldWrapperBuilder;

  final Widget Function(String title, String description)? headerTitleBuilder;

  String labelText(SchemaProperty property) =>
      '${property.titleOrId} ${property.requiredNotNull ? "*" : ""}';

  String? fieldLabelText(SchemaProperty property) =>
      labelPosition == LabelPosition.fieldInputDecoration
          ? labelText(property)
          : null;

  Widget? removeItemWidget(BuildContext context, Schema property) {
    final removeItem = RemoveItemInherited.getRemoveItem(context, property);
    if (removeItem == null) return null;

    return removeItemBuilder != null
        ? removeItemBuilder!(removeItem.value, removeItem.key)
        : TextButton.icon(
            onPressed: removeItem.value,
            icon: const Icon(Icons.remove),
            label: Text(localizedTexts.removeItem()),
          );
  }

  Widget addItemWidget(void Function() addItem, SchemaArray schemaArray) {
    return addItemBuilder != null
        ? addItemBuilder!(addItem, schemaArray.idKey)
        : TextButton.icon(
            onPressed: addItem,
            icon: const Icon(Icons.add),
            label: Text(localizedTexts.addItem()),
          );
  }
}

enum LabelPosition {
  top,
  left,
  right,
  fieldInputDecoration,
}

class FieldWrapperParams {
  const FieldWrapperParams({
    required this.property,
    required this.input,
    required this.removeItem,
  });

  final SchemaProperty property;
  final Widget input;
  final Widget? removeItem;
}
