 import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  bool welcomeScreenSeen = prefs.getBool('welcomeScreenSeen') ?? false;
  CounterStorage storage = CounterStorage(); // Initialize CounterStorage
  await storage.createFolder(); // Ensure folder creation

  double startingAmount = prefs.getDouble('startingAmount') ?? 0.0;
  String currency = prefs.getString('_selectedCurrency') ?? '€';

  runApp(MaterialApp(
    title: 'Money Pal',
    theme: ThemeData.light(), 
    home: welcomeScreenSeen ? MyApp(storage: storage, startingAmount: startingAmount,  currency: currency,) : WelcomeScreen(),
  ));
}


class CounterStorage {
  void setState(Null Function() param0) {}


  Future<void> deleteTransaction(int number) async {
    String folderPath = await createFolder();
    print('Now the bitch is in the Storage. TraNum: $number');
    File file = File('$folderPath/Tra$number.txt');
    if (await file.exists()) {
      print('in the if');
      await file.delete();
    }
  }
  Future<String> createFolder() async {
    // Get the documents directory using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Create a new folder named "money_pal" within the documents directory
    Directory folder = Directory('${documentsDirectory.path}/money_pal');
    if (!(await folder.exists())) {
      await folder.create(recursive: true);
    }

    // Return the path of the created folder
    return folder.path;
  }

  int fileNum = 0;

Future<File> get _fileTracker async {
  try {
    String folderPath = await createFolder();
    File trackerFile = File('$folderPath/tracker.txt'); 
    
    // Read the file
    String contents = await trackerFile.readAsString();

    // Parse the contents to get the current fileNum value
    int currentFileNum = int.parse(contents);

    // Replace the existing value with the current fileNum
    fileNum = currentFileNum;

    // Write the updated fileNum back to the file
    await trackerFile.writeAsString(fileNum.toString());

    return trackerFile;
  } catch (e) {
    // If encountering an error, return a new file with the current fileNum
    return _createTrackerFile();
  }
}

  Future<List<String>> readTra(int number) async {
    try {
      String folderPath = await createFolder();
      File file = File('$folderPath/Tra$number.txt');
      List<String> lines = await file.readAsLines();
      return lines;
    } catch (e) {
      print("Error reading file: $e");
      return [];
    }
  }


Future<File> _createTrackerFile() async {
  String folderPath = await createFolder();
  File trackerFile = File('$folderPath/tracker.txt');
  await trackerFile.writeAsString(fileNum.toString());
  return trackerFile;
}


  Future<File> get _localFile async {
    String folderPath = await createFolder();
    int number = await readCounter();
    
    return File('$folderPath/Tra$number.txt');
  }

  Future<File> get _totalFile async {
    String folderPath = await createFolder();

    return File('$folderPath/Total.txt');
  }

  Future<int> readCounter() async {
    try {
      final fileTracker = await _fileTracker;
      final contents = await fileTracker.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }
  Future<double> readTotal() async {
    try {
      final totalFile = await _totalFile;
      final contents = await totalFile.readAsString();

      print(contents);
      return double.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(double newCount, String category, DateTime date, int number) async {
    final file = await _localFile;
    writeFileNum();
    return file.writeAsString('$newCount\n$category\n$date\n$number');
  }

  Future<File> writeTotal(double count) async {
    final file = await _totalFile;

    return file.writeAsString('$count');
  }

  Future<File> writeFileNum() async {
    final fileTrack = await _fileTracker;
    fileNum++;
    // Write the file
    return fileTrack.writeAsString(fileNum.toString());
  }
  

}

class Expense {
  final int number;
  final String category;
  final double amount;
  final DateTime date;

  Expense(this.number, this.category, this.amount, this.date);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.storage, required this.startingAmount, required this.currency}) : super(key: key);
  final double startingAmount;
  final String currency;
  final CounterStorage storage;
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double totalCount = 0;
  int number = 0;

  bool isDarkModeEnabled = false; // Track dark mode state

  List<Expense> transactions = [];

  Map<String, double> dataMap = {};

  
  int currentPageIndex = 0;
  List<NeatCleanCalendarEvent> calendarEvents = [];

  List<DropdownMenuItem<String>> dropdownMenuEntries = [
    const DropdownMenuItem(value: 'Namirnice', child: Text('Namirnice')),
    const DropdownMenuItem(value: 'Vozilo', child: Text('Vozilo')),
    const DropdownMenuItem(value: 'Struja', child: Text('Struja')),
    const DropdownMenuItem(value: 'Internet', child: Text('Internet')),
    const DropdownMenuItem(value: 'Posao', child: Text('Posao')),
  ];
  

  bool isExpense = true;


  @override
  void initState() {
    super.initState();
    dataMap = {
      'Namirnice': 0,
      'Vozilo': 0,
      'Struja': 0,
      'Internet': 0,
      'Posao': 0,
    };
    dropdownMenuEntries = dataMap.keys.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    _checkIfWelcomeScreenSeen(); // Check if the welcome screen has been seen

    totalCount = widget.startingAmount;

    

    loadData();
  }

  void updateCount(double newCount, String category, DateTime date, bool isExpense) async {  
  setState(() {
    final signedAmount = isExpense ? -newCount : newCount;
    totalCount += signedAmount;
    widget.storage.writeTotal(totalCount);
    widget.storage.writeCounter(signedAmount, category, date, number);
    transactions.add(Expense(number, category, signedAmount, date));
    number++;
    // Update dataMap for pie chart
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

    // Assuming calendarEvents is correctly managed elsewhere for UI updates
    calendarEvents.add(NeatCleanCalendarEvent(
      '$category - ${newCount.toString()}${widget.currency}',
      startTime: DateTime(date.year, date.month, date.day),
      endTime: DateTime(date.year, date.month, date.day),
      isAllDay: true, // Indicate all-day event
      color: _getColorForCategory(category), // Assign color based on category
    ));
  });
}

void deleteTransaction(int number) async {
  print('The number is $number');
  int index = transactions.indexWhere((transaction) => transaction.number == number);
  if (index != -1) {
    Expense transactionToDelete = transactions[index];
    print('This bitch right here ${transactionToDelete.amount}');

    // Adjust the totalCount and update the total amount file
    totalCount -= transactionToDelete.amount;
    await widget.storage.writeTotal(totalCount);
  print('the bitch is in deleteTransaction $number');
    // Remove the transaction from the local storage
    await widget.storage.deleteTransaction(number);

    // Remove the transaction from the list
    transactions.removeAt(index);

    // Recalculate the dataMap amounts without removing categories
    recalculateDataMapAfterDeletion();

    // Rebuild calendar events
    rebuildCalendarEvents();

    // Update UI
    setState(() {});
  }
}


void recalculateDataMapAfterDeletion() {
  // Reset amounts to 0 for all categories
  Map<String, double> tempDataMap = Map.fromIterable(dataMap.keys, key: (k) => k, value: (v) => 0.0);

  // Recalculate amounts based on remaining transactions
  for (var transaction in transactions) {
    tempDataMap[transaction.category] = (tempDataMap[transaction.category] ?? 0) + transaction.amount;
  }

  // Update the dataMap
  dataMap = tempDataMap;
}


void rebuildCalendarEvents() {
  List<NeatCleanCalendarEvent> updatedEvents = [];

  for (var transaction in transactions) {
    updatedEvents.add(NeatCleanCalendarEvent(
      '${transaction.category} - ${transaction.amount.toString()}${widget.currency}',
      startTime: transaction.date,
      endTime: transaction.date, // Adjust as necessary
      isAllDay: true,
      color: _getColorForCategory(transaction.category),
    ));
  }

  setState(() {
    calendarEvents = updatedEvents;
  });
}

  //dodavanje kategorija
  void addCategory(String newCategory) {
    setState(() {
      dataMap[newCategory] = 0;
      // Update dropdown menu entries with the new category
      dropdownMenuEntries.add(DropdownMenuItem(value: newCategory, child: Text(newCategory)));
    });
  }

  Future<void> _checkIfWelcomeScreenSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool welcomeScreenSeen = prefs.getBool('welcomeScreenSeen') ?? false;
    if (!welcomeScreenSeen) {
      await prefs.setBool('welcomeScreenSeen', true);
    }
  }

  Future<void> loadData() async {
    int fileNum = await widget.storage.readCounter();
    // Initialize variables outside the loop to ensure they are not late-initialized
    double amount;
    String category;
    DateTime date;

    // Temporary storage to update the pie chart dataMap correctly
   Map<String, double> tempDataMap = {
    'Namirnice': 0,
    'Vozilo': 0,
    'Struja': 0,
    'Internet': 0,
    'Posao': 0,
  };

  for(int i = 0; i < fileNum; i++) {
    final List<String> lines = await widget.storage.readTra(i);
    if (lines.isNotEmpty && lines.length >= 3) {
      // Parse each transaction line by line
      amount = double.parse(lines[0]);
      category = lines[1];
      date = DateTime.parse(lines[2]);
      number = int.parse(lines[3]);

      // Add transaction to the transactions list
      transactions.add(Expense(number, category, amount, date));
      
      // Only consider negative amounts for expenses in dataMap
      if (amount < 0) {
        tempDataMap[category] = (tempDataMap[category] ?? 0) + amount; // Deduct the amount for expenses
      }

      // Add event to the calendar for each transaction
      calendarEvents.add(NeatCleanCalendarEvent(
        '$category - ${amount}€',
        startTime: DateTime(date.year, date.month, date.day),
        endTime: DateTime(date.year, date.month, date.day),
        isAllDay: true,
        color: _getColorForCategory(category),
      ));
    }
  }
  
  

  setState(() {
    // Update the main dataMap for the pie chart with the aggregated data from tempDataMap
    dataMap.clear();
    dataMap.addAll(tempDataMap);

    // This ensures the UI updates with the correct values for both the transactions list and the pie chart
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

  Widget _buildPieChart() {
  if (dataMap.isNotEmpty) {
    return MyPieChart(dataMap: dataMap);
  } else {
    // This text is shown while dataMap is empty, consider replacing it with a loading indicator if loadData is asynchronous
    return Text('Loading chart data...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,));
  }
}

  @override
  Widget build(BuildContext context) {
    if(totalCount == 0)
    {
      widget.storage.readTotal().then((double temp) {
        setState(() {
          totalCount = temp;
        });
      });  
    }
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
                  'Trenutno stanje\n$totalCount${widget.currency}',
                  style: const TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),

              Expanded(
                child: ListView.builder(
    itemCount: transactions.length,
    itemBuilder: (context, index) {
      final transaction = transactions[index];
      return Card(
        elevation: 15,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(15),
        child: ListTile(
    title: Text(transaction.category),
    // Update subtitle to display amount and date
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${transaction.amount}${widget.currency}'),
        // Format the date as you like, here is a simple example
        Text(DateFormat('dd-MM-yyyy').format(transaction.date)),
      ],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => deleteTransaction(transactions[index].number),
        ),
    ],
  ),
)
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

        // Chart page
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffbf1c42), Colors.purple, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
            child: Center(
    // Check if dataMap is not empty to display the PieChart
    child: Center(
    child: _buildPieChart(), // Call the method here
  ),
),
),
        
        
      ][currentPageIndex],
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          child: const Icon(Icons.add),
           onPressed: () {
            Navigator.push(
              context,
                MaterialPageRoute(
                builder: (context) => AddMoney(
                updateCount: updateCount,
                dropdownMenuEntries: dataMap.keys.toList(),
              ),
            ),
          );
        },
      )],
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



class StartAmountScreen extends StatefulWidget {
  @override
  _StartAmountScreenState createState() => _StartAmountScreenState();
}

class _StartAmountScreenState extends State<StartAmountScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCurrency = '€'; // Default currency

  @override
  Widget build(BuildContext context) {
    List<String> currencies = ['€', '\$', '£', '¥', '₹', '₽']; // Add more currencies if needed

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Adjust the height as needed
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfffc2759), Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Start Amount',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Starting Amount',
                border: OutlineInputBorder(), // Add border to text field
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              items: currencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double startingAmount = double.parse(_controller.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(startingAmount: startingAmount, currency: _selectedCurrency, storage: CounterStorage()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16), // Adjust button padding
                primary: Color.fromARGB(255, 214, 122, 179),
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class WelcomeScreen extends StatelessWidget {
  Future<void> _checkIfWelcomeScreenSeen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool welcomeScreenSeen = prefs.getBool('welcomeScreenSeen') ?? false;
    if (welcomeScreenSeen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartAmountScreen()),
      );
    } else {
      await prefs.setBool('welcomeScreenSeen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkIfWelcomeScreenSeen(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Adjust the height as needed
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfffc2759), Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Dobrodošli!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          elevation: 0,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/card.png', // Replace with your image path
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Money Pal - Upravljaj svojim financijama s lakoćom!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color.fromARGB(255, 168, 94, 156),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StartAmountScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                primary: Color.fromARGB(255, 214, 122, 179),
                onPrimary: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Dalje',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
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
  final Function(double, String, DateTime, bool) updateCount;
  final List<String> dropdownMenuEntries;

  const AddMoney({Key? key, required this.updateCount, required this.dropdownMenuEntries}) : super(key: key);

  @override
  _AddMoneyState createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  TextEditingController controller = TextEditingController();
  String selectedCategory = 'Namirnice';
  DateTime selectedDate = DateTime.now();
  bool isExpense = true;

  void _showAddCategoryDialog() {
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nova kategorija'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: "Ime kategorije"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Dodaj'),
              onPressed: () {
                String newCategory = categoryController.text;
                if (newCategory.isNotEmpty) {
                  setState(() {
                    widget.dropdownMenuEntries.add(newCategory); // Assuming you have a method to update the categories list
                    selectedCategory = newCategory; // Optionally set the new category as the selected one
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova transakcija'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Količina'),
            ),
            SizedBox(height: 50),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              items: widget.dropdownMenuEntries.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Datum: ${selectedDate.day}. ${selectedDate.month}. ${selectedDate.year}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ListTile(
              title: const Text('Kategorija:'),
              trailing: Switch(
                value: isExpense,
                onChanged: (value) {
                  setState(() {
                    isExpense = value;
                  });
                },
              ),
              subtitle: isExpense ? const Text('Trošak') : const Text('Prihod'),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddCategoryDialog();
              },
              child: Text('Add New Category'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios_rounded),
        onPressed: () {
          if (controller.text.isNotEmpty) {
            final double newCount = double.tryParse(controller.text) ?? 0;
            if (newCount != 0) {
              widget.updateCount(newCount, selectedCategory, selectedDate, isExpense);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a valid number')),
              );
            }
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


class AddCategory extends StatelessWidget {
  final Function(String) addCategory;

  const AddCategory({Key? key, required this.addCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String newCategory = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova kategorija'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                newCategory = value;
              },
              decoration: const InputDecoration(
                labelText: 'Upiši ime nove kategorije',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  addCategory(newCategory);
                  Navigator.pop(context);
                }
              },
              child: const Text('Dodaj'),
            ),
          ],
        ),
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