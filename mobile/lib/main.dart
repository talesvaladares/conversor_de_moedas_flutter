import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getCurrencies() async {
  const request = "https://api.hgbrasil.com/finance/quotations?key=9645ef12";

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

  double _dolar;
  double _euro;

  void _handleRealChange(String text) {
    double real = double.parse(text);
    dolarController.text = (real / _dolar).toStringAsFixed(2);
    euroController.text = (real / _euro).toStringAsFixed(2);
  }

  void _handleDolarChange(String text) {
    double dolar = double.parse(text);
    //quantidade recebida na função vezes o valor do dolar em real
    realController.text = (dolar * this._dolar).toStringAsFixed(2);
    //quantidade recebida na função vezes o valor do dolar em real dividido pelo valor do euro em rais
    euroController.text = (dolar * this._dolar / this._euro).toStringAsFixed(2);
  }

  void _handleEuroChange(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this._euro).toStringAsFixed(2);
    dolarController.text = (euro * this._euro / this._dolar).toStringAsFixed(2);
  }

  void _handleResetFields() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _handleResetFields,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getCurrencies(), //indica qual função devemos esperar
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando...",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          buildTextField("Reais", "R\$", realController,
                              _handleRealChange),
                          Divider(),
                          buildTextField("Dólares", "US\$", dolarController,
                              _handleDolarChange),
                          Divider(),
                          buildTextField(
                              "Euros", "Є", euroController, _handleEuroChange)
                        ],
                      ));
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    controller: controller,
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
