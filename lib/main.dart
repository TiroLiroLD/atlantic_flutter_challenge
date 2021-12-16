import 'dart:convert';

import 'package:atlantic_flutter_challenge/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busca CEP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Busca CEP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Api values
  String _addressCep = "";
  String _addressState = "";
  String _addressCity = "";
  String _addressNeighborhood = "";
  String _addressStreet = "";
  String _addressService = "";

  //Form control
  String _inputCep = "";
  bool _isValid = false;
  bool _showSpinner = false;
  bool _showCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  validator: (String? value) => validateCep(value!),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter((9)),
                  ],
                  onChanged: (value) {
                    _inputCep = value;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a search term',
                      suffixIcon: IconButton(
                          onPressed: () async {
                            setState(() => _showSpinner = true);
                            await findCep();
                            setState(() => _showSpinner = false);
                          },
                          icon: Icon(Icons.search))),
                ),
                (_showCard) ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cep: $_addressCep',
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estado: $_addressState',
                                ),
                                Text(
                                  'Cidade: $_addressCity',
                                ),
                              ],
                            ),
                            Text(
                              'Rua: $_addressStreet',
                            ),
                            Text(
                              'Bairro: $_addressNeighborhood',
                            ),
                            Text(
                              'serviço: $_addressService',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ) : Column(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isValid) {
            Response response = await getCep(_inputCep);
            setState(() {
              Map<String, Object?> addressMap = jsonDecode(response.body);
              _addressCep = addressMap["cep"] as String;
              _addressState = addressMap["state"] as String;
              _addressCity = addressMap["city"] as String;
              _addressNeighborhood = addressMap["neighborhood"] as String;
              _addressStreet = addressMap["street"] as String;
              _addressService = addressMap["service"] as String;
            });
          }
          setState(() => _showSpinner = false);
        },
      ),
    );
  }

  validateCep(String value) {
    RegExp exp = RegExp(r"^\d{5}-\d{3}");
    if (exp.hasMatch(value)) {
      _isValid = true;
      return null;
    }
    _isValid = false;
    return ("Insira o CEP no formato 00000-000.");
  }

  findCep() async {
    if (_isValid) {
      Response response = await getCep(_inputCep);
      if (response.statusCode == 200) {
        setState(() {
          Map<String, Object?> addressMap = jsonDecode(response.body);
          _addressCep = addressMap["cep"] as String;
          _addressState = addressMap["state"] as String;
          _addressCity = addressMap["city"] as String;
          _addressNeighborhood = addressMap["neighborhood"] as String;
          _addressStreet = addressMap["street"] as String;
          _addressService = addressMap["service"] as String;
          _showCard = true;
        });
      } else {
        setState(() {
          _showCard = false;
          _addressCep = "";
          _addressState = "";
          _addressCity = "";
          _addressNeighborhood = "";
          _addressStreet = "";
          _addressService = "";
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("CEP $_inputCep não encontrado")));
      }
    }
  }
}
