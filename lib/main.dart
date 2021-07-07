import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json&key=SUA_CHAVE_API_AQUI";

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        hintColor: Color(0xff00a447),
        primaryColor: Colors.white,
      ),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realUpdated(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarUpdated(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroUpdated(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
            "\$ Conversor de moedas \$",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xff00a447),
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando Dados...",
                    style: TextStyle(
                      color: Color(0xff00a447),
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao Carregar Dados :(",
                      style: TextStyle(
                        color: Color(0xff00a447),
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Color(0xff00a447),
                          ),
                          buildTextField(
                            "Reais",
                            "R\$",
                            realController,
                            _realUpdated,
                          ),
                          Divider(),
                          buildTextField("Dólares", "US\$", dolarController,
                              _dolarUpdated),
                          Divider(),
                          buildTextField(
                            "Euros",
                            "€",
                            euroController,
                            _euroUpdated,
                          ),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
  String label,
  String prefix,
  TextEditingController c,
  Function f,
) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xff00a447),
        ),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
      color: Color(0xff00a447),
      fontSize: 25.0,
    ),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(
      decimal: true,
    ),
  );
}
