import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nida/nida.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nida Plugin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Nida nida = Nida();
  String nin = '';
  String firstName = '';
  String middleName = '';
  String surname = '';
  String sex = '';
  String dateOfBirth = '';
  String nationality = '';
  bool loading = false;
  String errorText = '';
  Future<void> fetchNida(String nin) async {
    setState(() {
      loading = true;
      errorText = '';
    });
    try {
      Map<String, dynamic> userData = await nida.userData(nin);

      Map<String, dynamic> result = userData['result'];
      if (result != null) {
        setState(() {
          loading = false;
          nin = result['NIN'];
          firstName = result['FIRSTNAME'];
          middleName = result['MIDDLENAME'];
          surname = result['SURNAME'];
          sex = result['SEX'];
          dateOfBirth = result['DATEOFBIRTH'];
          nationality = result['NATIONALITY'];
        });
      }
      debugPrint('succesful');
    } catch (e) {
      debugPrint('failed');
      setState(() {
        loading = false;
        errorText = "Failed to fetch data";
      });
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  TextEditingController nideinputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "NIDA",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nideinputController,
                          validator: (value) {
                            if (value == "" || value!.length != 20) {
                              return 'Enter valid National ID';
                            }
                          },
                          decoration: const InputDecoration(
                              label: Text('Enter National ID (20)'),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.green, width: 2))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                            width: double.infinity,
                            child: OutlinedButton(
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.resolveWith(
                                        (states) => const EdgeInsets.all(10)),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.green)),
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  clearUserData();
                                  if (_formKey.currentState!.validate() &&
                                      !loading) {
                                    String nationalID =
                                        nideinputController.text;
                                    debugPrint('Please wait..........');
                                    await fetchNida(nationalID);
                                  }
                                },
                                child: loading
                                    ? spinkit
                                    : const Text(
                                        "SEARCH",
                                        style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ))),
                        const SizedBox(
                          height: 14,
                        ),
                        Text(
                          '$errorText',
                          style: const TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Citizen Details'),
                  const Divider(),
                  CitizenInfoTile(
                      title: 'National ID',
                      description: nideinputController.text),
                  CitizenInfoTile(title: 'First Name', description: firstName),
                  CitizenInfoTile(
                      title: 'Middle Name', description: middleName),
                  CitizenInfoTile(title: 'Surname', description: surname),
                  CitizenInfoTile(title: 'Sex', description: sex),
                  CitizenInfoTile(
                      title: 'Date of Birth', description: dateOfBirth),
                  CitizenInfoTile(
                      title: 'Nationality', description: nationality),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clearUserData() {
    setState(() {
      nin = '';
      firstName = '';
      middleName = '';
      surname = '';
      sex = '';
      dateOfBirth = '';
      nationality = '';
    });
  }

  final spinkit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red,
        ),
      );
    },
  );
}

class CitizenInfoTile extends StatelessWidget {
  const CitizenInfoTile({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(title),
        trailing: Text(description),
      ),
    );
  }
}
