import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/utilitarios.dart' as util;

class Metereologia extends StatefulWidget {
  @override
  _MetereologiaState createState() => new _MetereologiaState();
}

// Photo by Jonathan Bowers on Unsplash
// Photo by Andy Grizzell on Unsplash
class _MetereologiaState extends State<Metereologia> {

  String _cidadePesquisada;
  String _tempo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Metereologia"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
            icon: new Icon((Icons.menu)),
            onPressed: () {
              _vaiParaProximaTela(context);
            }, //muda a tela,
          )
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'imagens/chuva.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 13.9, 20.9, 0.0),
            child: new Text(
              '${_cidadePesquisada == null ? util.cidadeInicial : _cidadePesquisada}',
              style: _retorneCidadeEstilizada(),
            ),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset(_retornaImagem(_tempo)),
          ),

          // Abaixo ficara o Container com os dados metereologicos
          new Container(
            margin: const EdgeInsets.fromLTRB(120.0, 350.0, 30.0, 0.0),
            child: atualizaTempWidget(_cidadePesquisada),
          ),
        ],
      ),
    );
  }



  Future<Map> obtemMetereogia(String cidade) async {
    String urlAPI =
        'http://api.openweathermap.org/data/2.5/weather?q=${cidade}&appid=${util
        .idDoOpenWeather}&units=metric';

    http.Response response = await http.get(urlAPI);

    return json.decode(response.body);
  }

  Widget atualizaTempWidget(String cidade) {
    return new FutureBuilder(
        future: obtemMetereogia(cidade == null ? util.cidadeInicial : cidade),
        builder: (BuildContext contexto, AsyncSnapshot<Map> momento) {
          // Aqui é onde se obtem todas as informações pelo JSON
          if (momento.hasData) {
            Map conteudo = momento.data;
            _tempo = conteudo['weather'][0]['main'].toString();

            return new Container(
              child: new Column(
                children: <Widget>[

                  new ListTile(
                    title: new Text(
                      conteudo['main']['temp'].toString() + " C",
                      style: _estiloTemperatura(),
                    ),
                    subtitle: new Text(
                      "Humidade: ${conteudo['main']['humidity'].toString()} %\n"
                          "Min: ${conteudo['main']['temp_min'].toString()} C\n"
                          "Máx: ${conteudo['main']['temp_max'].toString()} C",
                      style: _estiloDadosExtras(),

                    ),

                  )
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }

  void obtemCoisas() async {
    Map dados = await obtemMetereogia(util.cidadeInicial);
    print(dados.toString());
  }

  Future _vaiParaProximaTela(BuildContext contexto) async {

    Map resultado = await Navigator.of(contexto).push(
        new MaterialPageRoute<Map>(
            builder: (BuildContext contexto){
              return new AlteraCidade();
            }
        )
    );

    if(resultado != null && resultado.containsKey('cidade')){
      //print(resultado['cidade']);
      _cidadePesquisada = resultado['cidade'];

    }

  }

  String _retornaImagem(String tempo) {
    String imagem = 'imagens/sun.png';
    switch(tempo){
      case 'Clear':
        return 'imagens/sun.png';
      case 'Clouds':
        return 'imagens/cloudy.png';
      case 'Rain':
        return 'imagens/rain.png';
      default:
        break;

    }
    return imagem;
  }
}

class AlteraCidade extends StatelessWidget {
  var _campoCidadeControleler = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('Altera a Cidade'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Image.asset(
            'imagens/noite.png',
            width: 490.0,
            height: 1200.0,
            fit: BoxFit.fill,
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(

                  decoration: new InputDecoration(
                    hintText: 'Escreva a cidade',
                    hintStyle: new TextStyle(
                      color: Colors.white70,
                    ),
                    fillColor: Colors.white,
                  ),
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  controller: _campoCidadeControleler,
                  keyboardType: TextInputType.text,


                ),
              ),
              new ListTile(
                title: new FlatButton(
                    onPressed: (){
                      Navigator.pop(context, {
                        'cidade':_campoCidadeControleler.text
                      });
                    },
                    textColor: Colors.white,
                    color: Colors.redAccent,

                    child: new Text('Obtem Metereologia')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle _retorneCidadeEstilizada() {
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle _estiloDadosExtras() {
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontSize: 17.0,
  );
}


TextStyle _estiloTemperatura() {
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9,
  );
}
