import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:path_provider/path_provider.dart';


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
  List<NeatCleanCalendarEvent> calendarEvents = [];
  


  Map<String, double> dataMap = {
    'Namirnice': 0,
    'Vozilo': 0,
    'Struja': 0,
    'Internet': 0,
    'Posao': 0,
  };

bool isExpense = true;

  void updateCount(double newCount, String category, DateTime date) {
    setState(() {
      // Determine the sign of the amount based on the slider position
    final signedAmount = isExpense ? -newCount : newCount;
    
    // Update the total count
    count += signedAmount;

    // Update expenses list
    expenses.add(Expense(category, signedAmount, date));

    // Update dataMap
    // Update dataMap
if (dataMap.containsKey(category)) {
  if (signedAmount < 0) {
    // Only update dataMap for expenses (negative amounts)
    if (dataMap[category] != null) {
      dataMap[category] = dataMap[category]! - signedAmount; // Negate the amount
    } else {
      dataMap[category] = -signedAmount; // Set as expense
    }
  }
} else {
  dataMap[category] = signedAmount;
}
      calendarEvents.add(NeatCleanCalendarEvent(
          '$category - ${-newCount}€',
          startTime: DateTime(date.year, date.month, date.day),
          endTime: DateTime(date.year, date.month, date.day),
          isAllDay: true, // Set the end time
          color: _getColorForCategory(category), // Color code by category
        ));
    });
    
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Namirnice':
        return Colors.green;
      case 'Vozilo':
        return Colors.blue;
      case 'Struja':
        return Colors.orange;
      case 'Internet':
        return Colors.yellow;
      case 'Posao':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          currentPageIndex == 0
        ? 'Home'
        : (currentPageIndex == 1 ? 'Calendar View' : 'Chart'),
          style: const TextStyle(color: Colors.white),
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
                    return Card(
                      elevation: 15,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                        title: Text(
                          expense.category,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          '${expense.amount}€',
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: Text(
                          '${expense.date.day}. ${expense.date.month}. ${expense.date.year}.',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),

        /// Calendar page
        Container(
          /*decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffbf1c42), Colors.purple, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),*/
          child: Calendar(

            startOnMonday: true,
            weekDays: const ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sri', 'Ned'],
            eventsList: calendarEvents, // Use the calendar events list here
            isExpandable: true,
            eventDoneColor: Colors.green,
            selectedColor: Colors.pink,
            selectedTodayColor: Colors.red,
            todayColor: Colors.blue,
            eventColor: null,
            locale: 'hr_HR',
            todayButtonText: 'Danas',
            allDayEventText: '',
          
            isExpanded: true,
            expandableDateFormat: 'EEEE, dd. MMMM yyyy',
            datePickerType: DatePickerType.date,
            dayOfWeekStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 10
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
          child: Center(
            child: MyPieChart(dataMap: dataMap),
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
            selectedIcon: Icon(Icons.pie_chart),
            icon: Icon(Icons.pie_chart_outline),
            label: 'Chart',
          ),
        ],
      ),
    );
  }
}


class MyPieChart extends StatelessWidget {
  final Map<String, double> dataMap;

  const MyPieChart({super.key, required this.dataMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
      height: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: _getColorList(),
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: const LegendOptions(
            showLegendsInRow: true,
            legendPosition: LegendPosition.bottom,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: false,
            showChartValuesInPercentage: true,
            showChartValues: true,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
        ),
      ),
    );
  }

  List<Color> _getColorList() {
    return List.generate(
      dataMap.length,
      (index) => Colors.primaries[index % Colors.primaries.length],
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
  bool isExpense = true;

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2201),
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
          ListTile(
            title: const Text('Izaberi tip:'),
            trailing: Switch(
              value: isExpense,
              onChanged: (value) {
                setState(() {
                  isExpense = value;
                });
              },
            ),
            subtitle: isExpense ? const Text('Prihod') : const Text('Trošak'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios_rounded),
        onPressed: () {
          Navigator.pop(context);
          if (controller.text.isNotEmpty) {
            final newCount = double.parse(controller.text);
            // Determine the sign of the amount based on the selected option
            final signedAmount = isExpense ? -newCount : newCount;
            widget.updateCount(signedAmount, selectedCategory, selectedDate!);
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

class MonthlyView extends StatelessWidget {
  final List<NeatCleanCalendarEvent> calendarEvents;

  const MonthlyView({super.key, required this.calendarEvents});

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
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Kalendar',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Calendar(
          startOnMonday: true,
          weekDays: const ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sri', 'Ned'],
          eventsList: calendarEvents, // Use the calendar events list here
          isExpandable: true,
          eventDoneColor: Colors.green,
          selectedColor: Colors.pink,
          selectedTodayColor: Colors.red,
          todayColor: Colors.blue,
          eventColor: null,
          locale: 'hr_HR',
          todayButtonText: 'Danas',
          allDayEventText: '',
          
          isExpanded: true,
          expandableDateFormat: 'EEEE, dd. MMMM yyyy',
          datePickerType: DatePickerType.date,
          dayOfWeekStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 10),
        ),
      ),
    );
  }
}

class CounterStorage extends _AddMoneyState {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
  

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$selectedDate.txt');
  }
  
  
  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

