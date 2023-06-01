import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService {
  final ValueNotifier<List> tableStateNotifier = ValueNotifier([]);
  List<String> propertyNames = ["name", "style", "ibu"];
  List<String> columnNames = ["Escolha", "Uma", "Opção"];
  int selectedIndex = 0;
  int pageSize = 5;

  void carregar(int index) {
    var funcoes = [
      carregarCafes,
      carregarCervejas,
      carregarNacoes,
    ];

    selectedIndex = index;
    funcoes[index]();
  }

  void columnsCervejas() {
    propertyNames = ["name", "style", "ibu"];
    columnNames = ["Nome", "Estilo", "IBU"];
  }

  Future<void> carregarCervejas() async {
    columnsCervejas();
    var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': pageSize.toString()},
    );
    print('carregarCervejas #1 - antes do await');
    var jsonString = await http.read(beersUri);
    print('carregarCervejas #2 - depois do await');
    var beersJson = jsonDecode(jsonString);

    tableStateNotifier.value = beersJson;
  }

  void columnsCafes() {
    propertyNames = ["blend_name", "origin", "variety"];
    columnNames = ["Nome", "Origem", "Variedades"];
  }

  Future<void> carregarCafes() async {
    columnsCafes();
    var coffeeUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': pageSize.toString()},
    );
    print('carregarCafes #1 - antes do await');
    var jsonString = await http.read(coffeeUri);
    print('carregarCafes #2 - depois do await');
    var coffeesJson = jsonDecode(jsonString);

    tableStateNotifier.value = coffeesJson;
  }

  void columnsNacoes() {
    propertyNames = ["nationality", "language", "capital"];
    columnNames = ["Nacionalidade", "Idioma", "Capital"];
  }

  Future<void> carregarNacoes() async {
    columnsNacoes();
    var nationUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': pageSize.toString()},
    );
    print('carregarNacoes #1 - antes do await');
    var jsonString = await http.read(nationUri);
    print('carregarNacoes #2 - depois do await');
    var nationsJson = jsonDecode(jsonString);

    tableStateNotifier.value = nationsJson;
  }
}

final dataService = DataService();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Quantidade dinâmica de dados!"),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text('Número de itens:'),
                    SizedBox(width: 10),
                    DropdownButton<int>(
                      value: dataService.pageSize,
                      items: [
                        DropdownMenuItem<int>(
                          value: 5,
                          child: Text('5'),
                        ),
                        DropdownMenuItem<int>(
                          value: 10,
                          child: Text('10'),
                        ),
                        DropdownMenuItem<int>(
                          value: 15,
                          child: Text('15'),
                        ),
                      ],
                      onChanged: (value) {
                        dataService.pageSize = value!;
                        dataService.carregar(dataService.selectedIndex);
                      },
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: dataService.tableStateNotifier,
                builder: (_, value, __) {
                  return DataTableWidget(
                    jsonObjects: value,
                    columnNames: dataService.columnNames,
                    propertyNames: dataService.propertyNames,
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

class NewNavBar extends HookWidget {
  var itemSelectedCallback;

  NewNavBar({this.itemSelectedCallback}) {
    itemSelectedCallback ??= (_) {};
  }

  @override
  Widget build(BuildContext context) {
    var state = useState(0);
    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;
          print(state.value);
          itemSelectedCallback(index);
        },
        currentIndex: state.value,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
              label: "Cafés", icon: Icon(Icons.coffee_outlined)),
          BottomNavigationBarItem(
              label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nações", icon: Icon(Icons.flag_outlined)),
        ]);
  }
}

class DataTableWidget extends StatelessWidget {
  final List? jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget({
    this.jsonObjects,
    this.columnNames = const ["Nome", "Estilo", "IBU"],
    this.propertyNames = const ["name", "style", "ibu"],
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columnNames
          .map(
            (name) => DataColumn(
              label: Text(
                name,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          )
          .toList(),
      rows: jsonObjects
              ?.map(
                (obj) => DataRow(
                  cells: propertyNames
                      .map(
                        (propName) => DataCell(
                          Text(obj[propName]?.toString() ?? ''),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList() ??
          [],
    );
  }
}
