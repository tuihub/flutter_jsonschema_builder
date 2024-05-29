import 'package:flutter/material.dart';

class JsonFormSchemaUiConfig {
  const JsonFormSchemaUiConfig({
    this.fieldTitle,
    this.error,
    this.title,
    this.titleAlign,
    this.subtitle,
    this.description,
    this.label,
    this.addItemBuilder,
    this.removeItemBuilder,
    this.submitButtonBuilder,
    this.addFileButtonBuilder,
  });

  final TextStyle? fieldTitle;
  final TextStyle? error;
  final TextStyle? title;
  final TextAlign? titleAlign;
  final TextStyle? subtitle;
  final TextStyle? description;
  final TextStyle? label;

  final Widget Function(VoidCallback onPressed, String key)? addItemBuilder;
  final Widget Function(VoidCallback onPressed, String key)? removeItemBuilder;

  /// render a custom submit button
  /// @param [VoidCallback] submit function
  final Widget Function(VoidCallback onSubmit)? submitButtonBuilder;

  /// render a custom button
  /// if it returns null or it is null, it will build default button
  final Widget? Function(VoidCallback? onPressed, String key)?
      addFileButtonBuilder;
}
