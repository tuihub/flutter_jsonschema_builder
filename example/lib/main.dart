import 'dart:developer';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/flutter_jsonschema_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final jsonSchema = '''
{
  "title": "Texto",
  "type": "object",
  "properties": {
    
    "files": {
      "type": "array",
      "title": "Multiple files",
      "items": {
        "type": "string",
        "format": "data-url"
      }
    },
    "texts": {
      "type": "array",
      "title": "Text Fields",
      "items": {
        "type": "string"
      }
    },
    "select": {
      "title" : "Select your Cola",
      "type": "string",
      "description": "This is the select-description",
      "enum" : [0,1,2,3,4],
      "enumNames" : ["Vale 0","Vale 1","Vale 2","Vale 3","Vale 4"],
      "default" : 3
    },
    "profession" :  {
      "type":"string",
      "default" : "investor",
      "oneOf":[
          {
            "enum":[
                "trader"
            ],
            "type":"string",
            "title":"Trader"
          },
          {
            "enum":[
                "investor"
            ],
            "type":"string",
            "title":"Inversionista"
          },      
          {
            "enum":[
                "manager_officier"
            ],
            "type":"string",
            "title":"Gerente / Director(a)"
          }
      ],
      "title":"Ocupación o profesión"
    }

  }
}
  ''';

  final jsonData = '''
{
  "files": [
    "https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg"
  ],
  "texts": [
    "Hello",
    "World"
  ],
  "select": 0,
  "profession": "trader"
}
  ''';

  final uiSchema = '''

{
 "gender": {
						"ui:widget": "radio"
					}
}

        ''';

  Future<List<XFile>?> defaultCustomFileHandler() async {
    await Future.delayed(const Duration(seconds: 3));

    final file1 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');
    final file2 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');
    final file3 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');

    return [file1, file2, file3];
  }

  final _formController = JsonFormController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20),
              child: Material(
                child: JsonForm(
                  controller: _formController,
                  jsonSchema: jsonSchema,
                  jsonData: jsonData,
                  uiSchema: uiSchema,
                  onFormDataSaved: (data) {
                    inspect(data);
                  },
                  fileHandler: () => {
                    'files': defaultCustomFileHandler,
                    'file': () async {
                      return [
                        XFile(
                            'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg')
                      ];
                    },
                    '*': defaultCustomFileHandler
                  },
                  customPickerHandler: () => {
                    '*': (data) async {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return Scaffold(
                              body: Container(
                                margin: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Text('My Custom Picker'),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: data.keys.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(data.values
                                              .toList()[index]
                                              .toString()),
                                          onTap: () => Navigator.pop(context,
                                              data.keys.toList()[index]),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  },
                  jsonFormSchemaUiConfig: JsonFormSchemaUiConfig(
                    expandGenesis: true,
                    title: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    fieldTitle:
                        const TextStyle(color: Colors.pink, fontSize: 12),
                    submitButtonBuilder: (onSubmit) => TextButton.icon(
                      onPressed: onSubmit,
                      icon: const Icon(Icons.heart_broken),
                      label: const Text('Enviar'),
                    ),
                    addItemBuilder: (onPressed, key) => TextButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.plus_one),
                      label: const Text('Add Item'),
                    ),
                    addFileButtonBuilder: (onPressed, key) {
                      if (['file', 'file3'].contains(key)) {
                        return OutlinedButton(
                          onPressed: onPressed,
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all(
                                const Size(double.infinity, 40)),
                            backgroundColor: WidgetStateProperty.all(
                              const Color(0xffcee5ff),
                            ),
                            side: WidgetStateProperty.all(
                                const BorderSide(color: Color(0xffafd5ff))),
                            textStyle: WidgetStateProperty.all(
                                const TextStyle(color: Color(0xff057afb))),
                          ),
                          child: Text('+ Agregar archivo $key'),
                        );
                      }

                      return null;
                    },
                  ),
                  customValidatorHandler: () => {
                    'files': (value) {
                      return null;
                    }
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _formController.submit,
              child: const Text('Controller Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
