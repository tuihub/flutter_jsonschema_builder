import 'package:flutter_jsonschema_builder/src/helpers/is_url.dart';
import 'package:flutter_jsonschema_builder/src/models/property_schema.dart';
import 'package:flutter_jsonschema_builder/src/utils/localized_texts.dart';

String? inputValidationJsonSchema({
  required LocalizedTexts localizedTexts,
  required String newValue,
  required SchemaProperty property,
}) {
  if (newValue.isEmpty) {
    return localizedTexts.required();
  }

  if (newValue.length < (property.minLength?.toInt() ?? 0)) {
    return localizedTexts.minLength(minLength: property.minLength!);
  }

  if (property.format == PropertyFormat.uri) {
    if (!isURL(newValue)) {
      return localizedTexts.shouldBeUri();
    }
  }
  return null;
}
