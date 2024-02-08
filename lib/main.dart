import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Money Pal',
    home: MyApp(),
  ));
}

class Expense {
  final String category;
  final double amount;
  final DateTime date;

  Expense(this.category, this.amount, this.date);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double count = 0;
  List<Expense> expenses = [];
  int currentPageIndex = 0;

  void updateCount(double newCount, String category, DateTime date) {
    setState(() {
      count += newCount;
      expenses.add(Expense(category, newCount, date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffff023d), Color(0xFFD500F9), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'MoneyPal',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffbf1c42), Colors.purple, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        
          /// Home page
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffff023d),
                      Color(0xFFD500F9),
                      Color(0xFF1A237E)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                width: 1500,
                height: 110,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                transformAlignment: Alignment.centerLeft,
                child: Text(
                  'Trenutno stanje\n$count€',
                  style: const TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(
                        expense.category,
                        style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                      subtitle: Text(
                        '${expense.amount}€',
                        style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                      trailing: Text(
                        '${expense.date.day}. ${expense.date.month}. ${expense.date.year}.',
                        style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        /// Calendar page
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffbf1c42), Colors.purple, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        /// Settings page
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffbf1c42), Colors.purple, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ][currentPageIndex],

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMoney(updateCount: updateCount),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.deepPurple[85],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar View',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}


class ExpenseWidget extends StatelessWidget {
  final Expense expense;

  const ExpenseWidget({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategorija: ${expense.category}'),
          Text('Iznos: ${expense.amount}'),
          Text('Datum: ${expense.date}'),
        ],
      ),
    );
  }
}

class AddMoney extends StatefulWidget {
  final Function(double, String, DateTime) updateCount;

  const AddMoney({super.key, required this.updateCount});

  @override
  State<AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  TextEditingController controller = TextEditingController();
  String selectedCategory = '';
  DateTime? selectedDate;

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffff023d), Color(0xFFD500F9), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Dodaj iznos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          MyCustomForm(controller: controller),
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Izaberite datum:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Colors.grey, 
                    ),
                    child: Text(
                      selectedDate != null
                          ? "${selectedDate!.day}. ${selectedDate!.month}. ${selectedDate!.year}"
                          : 'Izaberite datum',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color:Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownMenu(
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value.data ?? '';
                    });
                  }
                },
                dropdownMenuEntries: const <DropdownMenuEntry<Text>>[
                  DropdownMenuEntry(value: Text('Namirnice'), label: 'Namirnice'),
                  DropdownMenuEntry(value: Text('Vozilo'), label: 'Vozilo'),
                  DropdownMenuEntry(value: Text('Struja'), label: 'Struja'),
                  DropdownMenuEntry(value: Text('Internet'), label: 'Internet'),
                  DropdownMenuEntry(value: Text('Posao'), label: 'Posao'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios_rounded),
        onPressed: () {
          Navigator.pop(context);
          if (controller.text.isNotEmpty) {
            final newCount = double.parse(controller.text);
            widget.updateCount(newCount, selectedCategory, selectedDate!);
          }
        },
      ),
    );
  }
}

class MyCustomForm extends StatelessWidget {
  final TextEditingController controller;

  const MyCustomForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Iznos',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Molimo unesite iznos.';
          }
          return null;
        },
      ),
    );
  }
}

class Monthly extends StatelessWidget {
  const Monthly({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfffc2759), Colors.purple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Monthly View',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}