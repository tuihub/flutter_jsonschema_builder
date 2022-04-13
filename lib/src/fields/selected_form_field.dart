import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_form/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_form/src/builder/widget_builder.dart';
import 'package:flutter_jsonschema_form/src/fields/fields.dart';
import 'package:flutter_jsonschema_form/src/models/object_schema.dart';
import 'package:flutter_jsonschema_form/src/models/one_of_model.dart';
import 'package:flutter_jsonschema_form/src/models/property_schema.dart';
import 'package:flutter_jsonschema_form/src/models/schema.dart';

class SelectedFormField extends PropertyFieldWidget<dynamic> {
  const SelectedFormField(
      {Key? key,
      required SchemaProperty property,
      required final ValueSetter<dynamic> onSaved,
      ValueChanged<dynamic>? onChanged})
      : super(
            key: key,
            property: property,
            onSaved: onSaved,
            onChanged: onChanged);

  @override
  _SelectedFormFieldState createState() => _SelectedFormFieldState();
}

class _SelectedFormFieldState extends State<SelectedFormField> {
  final listOfModel = <OneOfModel>[];
  Map<String, dynamic> indexedData = {};
  OneOfModel? valueSelected;
  List<DropdownMenuItem<OneOfModel>> w = <DropdownMenuItem<OneOfModel>>[];
  late OneOfModel customObject;

  final pageController = PageController(initialPage: 1, viewportFraction: 0.77);

  @override
  void initState() {
    // fill enum property
    if (widget.property.enumm == null) {
      switch (widget.property.type) {
        case SchemaType.boolean:
          widget.property.enumm = [true, false];
          break;
        default:
          widget.property.enumm =
              widget.property.enumNames?.map((e) => e.toString()).toList() ??
                  [];
      }
    }

    if (widget.property.oneOf is List) {
      for (int i = 0; i < (widget.property.oneOf?.length ?? 0); i++) {
        if (widget.property.id == 'profession') {
          final titleList = [];
          final enumString = widget.property.oneOf![i]['enum'].first;
          titleList.add(widget.property.oneOf![i]['title']);
          customObject = OneOfModel(
              oneOfModelEnum: titleList,
              title: enumString,
              type: widget.property.oneOf![i]['type']);
        } else {
          customObject = OneOfModel(
              oneOfModelEnum: widget.property.oneOf![i]['enum'],
              title: widget.property.oneOf![i]['title'],
              type: widget.property.oneOf![i]['type']);
        }
        listOfModel.add(customObject);
      }
    }

    widget.triggetDefaultValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.property.oneOf != null, 'oneOf is required');
    assert(
      () {
        return true;
      }(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.property.title} ${widget.property.required ? "*" : ""}',
            style:
                WidgetBuilderInherited.of(context).jsonFormSchemaStyle.label),
        DropdownButtonFormField<OneOfModel>(
          key: Key(widget.property.idKey),
          value: valueSelected,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          hint: const Text('Seleccione'),
          isExpanded: true,
          validator: (value) {
            if (widget.property.required && value == null) {
              return 'required';
            }
          },
          items: (listOfModel != [] || listOfModel.isNotEmpty)
              ? listOfModel
                  .map((item) {
                    return DropdownMenuItem<OneOfModel>(
                      value: item,
                      child: Text(
                        item.title ?? '',
                      ),
                    );
                  })
                  .toSet()
                  .toList()
              : [],
          onChanged: widget.property.readOnly
              ? null
              : (OneOfModel? value) {
                  valueSelected = value;
                  if (widget.onChanged != null) {
                    widget.onChanged!(value?.oneOfModelEnum?.first);
                  }
                },
          onSaved: widget.onSaved,
          decoration: InputDecoration(
              errorStyle:
                  WidgetBuilderInherited.of(context).jsonFormSchemaStyle.error),
        ),
      ],
    );
  }
}
