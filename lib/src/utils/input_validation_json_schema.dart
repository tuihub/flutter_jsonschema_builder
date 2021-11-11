import 'package:flutter_jsonschema_form/src/helpers/is_url.dart';
import 'package:flutter_jsonschema_form/src/models/property_schema.dart';

String? inputValidationJsonSchema(
    {required String newValue, required SchemaProperty property}) {
  if (newValue.isEmpty) {
    return 'Required';
  }

  if ((newValue.length <= (property.minLength?.toInt() ?? 0)) &&
      property.minLength != null) {
    return 'should NOT be shorter than ${property.minLength} characters';
  }

  if (!(isURL(newValue) && (property.format == PropertyFormat.uri))) {
    return 'you should enter a uri';
  }
}
