import 'package:flutter/material.dart';
void main() {
  runApp(const MaterialApp(
    title: 'Money Pal',
    home: MyApp(),
  ));
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.red,
        title: const Text(
          'MoneyPal',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Text(
              'Trenutno stanje\n$count€',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            color: Colors.red,
            width: 1500,
            height: 110,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            transformAlignment: Alignment.centerLeft,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMoney()),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Monthly View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ]
      ),
    );
  }
}

class AddMoney extends StatelessWidget {
  const AddMoney({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.red,
        title: const Text(
          'Add amount',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
              Navigator.pop(context);;
          },
        ),
    );
  }
}

class Monthly extends StatelessWidget {
  const Monthly({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.red,
        title: const Text(
          'Monthly View',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}