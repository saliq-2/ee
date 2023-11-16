import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';
//The above  section imports necessary packages and libraries that will be used throughout the code.

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//a StatefulWidget named MyHomePage is defined.
// It creates an instance of _MyHomePageState to manage the state of the widget.
//In this part, the state class _MyHomePageState is defined. It includes various properties
// that will hold information about the calendar state,
// selected dates, events, and loading status.
class _MyHomePageState extends State<MyHomePage> {
  late DateTime
      _focusedDay; // Represents the currently focused day in the calendar.
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay; // Represents the selected day in the calendar.
  late CalendarFormat
      _calendarFormat; //Represents the format of the calendar (e.g., month view, week view).
  late Map<DateTime, List<Event>>
      _events; //A map that associates each day with a list of events for that day.
  DateTime? _selectedDate; //Holds the selected date.
  final ScrollController _scrollController =
      ScrollController(); //A controller to manage scrolling in the event list.
  bool _isLoading = true; // Indicates whether data is currently being loaded.

  //Function to perform auto scrolling
  void _scrollToSelectedDateEvents(DateTime selectedDate) {
    int index = _events.keys.toList().indexOf(selectedDate);
    if (index != -1) {
      // Calculate the position of the event in the ListView
      double position =
          index * 74.0; // Assuming each ListTile is 72 pixels high

      // Scroll to the position of the event in the ListView
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }
  // the getHashCode function calculates a unique hash code for a DateTime key.
  //The function takes a DateTime object as its argument, which represents a specific date and time.
  // key.day represents the day of the month (1 to 31).
  // key.month represents the month of the year (1 to 12).
  // key.year represents the year.
  // The hash code calculation uses these components to create a unique hash code for the given date
  //The multiplication by large values like 1000000 and 10000 ensures that the contributions
  // from each component do not overlap.
  //This hash code is unique to this date and can be used for efficient storage and retrieval in data structures
  // that utilize hash codes, such as hash maps.
  @override
  void initState() {
    super.initState();

    // Initialize the _events map using LinkedHashMap with custom equality and hash code functions
    _events = LinkedHashMap(
      equals: isSameDay, // Function to determine if two DateTime objects are the same day
      hashCode: getHashCode, // Hash code function for the DateTime objects
    );

    // Set the initial focused day to the current date and time
    _focusedDay = DateTime.now();

    // Define the range of dates for the calendar (from January 1, 2020, to December 31, 2030)
    _firstDay = DateTime.utc(2020, 1, 1);
    _lastDay = DateTime.utc(2030, 12, 31);

    // Set the initial selected day to the current date and time
    _selectedDay = DateTime.now();

    // Set the initial calendar format to 'month'
    _calendarFormat = CalendarFormat.month;

    // Load events from Firestore for the currently focused month
    _loadFirestoreEvents();
  }

  //The initState method is called when the widget is created. It initializes various properties,
  // including _events, _focusedDay, _firstDay, _lastDay, _selectedDay, and _calendarFormat.
  // It also calls _loadFirestoreEvents to retrieve events from Firestore.
  //loadfireevents function to load data from firestore.

  void _loadFirestoreEvents() {
    setState(() {
      _isLoading = true; // Show progress indicator
    });

    // Calculate the first and last day of the selected month
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // Query Firestore for events within the selected month's range
    FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThanOrEqualTo: lastDay)
        .snapshots()
        .listen((snapshot) {
      // Clear the existing events map
      _events = {};

      // Iterate through each document in the query snapshot
      for (var doc in snapshot.docs) {
        // Convert Firestore document to Event object using a constructor
        final event = Event.fromFirestore(doc);

        // Extract the date portion from the event's date
        final day = DateTime.utc(event.date.year, event.date.month, event.date.day);

        // Create a list for the day's events if it doesn't exist
        if (_events[day] == null) {
          _events[day] = [];
        }

        // Add the event to the corresponding day's list
        _events[day]!.add(event);
      }

      setState(() {
        _isLoading = false; // Hide progress indicator after loading
      });
    });
  }

  //This method fetches events from Firestore based on a date range. It sets
  // _isLoading to true to display a progress indicator, queries Firestore for events,
  // processes the fetched events, and updates the _events map.
  // It then sets _isLoading back to false to hide the progress indicator.

  List<Event> _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }
  //This function returns the list of events associated
  // with a given day from the _events map.


  @override
  Widget build(BuildContext context) {
    //It returns a Scaffold widget, which provides the basic structure for a
    // screen in Flutter, including an app bar and a body.
    return Scaffold(
      appBar: buildAppBar(),

      //the body property is a Column widget containing a list of children widgets.
      body: Column(
        children: [
          // The first child is generated by the buildCalendarCard function, which returns a
          // calendar card containing the TableCalendar widget.
          buildCalendarCard(),
          const Text('*Subject to the appearance of Moon'),
          const SizedBox(height: 20),
          //The third child is generated by the buildEventListView function, which returns an event list,
          // potentially displaying a CircularProgressIndicator when loading events.
          buildEventListView(),
        ],
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      toolbarHeight: MediaQuery.of(context).size.height*0.09,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (rect)=> const LinearGradient(colors: [
          Colors.pink,Colors.indigoAccent,Colors.pink
        ]).createShader(rect),
        child: Text(
          "Calendar",
          style: GoogleFonts.aboreto(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.height*0.03,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            icon:  Icon(
              Icons.calendar_month_outlined,
              color: Colors.pink.shade700,
              size: MediaQuery.of(context).size.height*0.04,
            ),
            onPressed: _showJumpToDateDialog,
          ),
        ),
      ],
      leading: Image.asset(
        'assets/images/cuklo.png',
        fit: BoxFit.contain,
      ),
    );
  }
  // this function returns the customized app bar

  Widget buildCalendarCard() {
    return Card(
      clipBehavior: Clip.antiAlias, // Clip the widget's content using anti-aliasing
      child: TableCalendar(

        // Customize the appearance of the days of the week header
        daysOfWeekHeight:MediaQuery.of(context).size.height*0.07, // Set the height of the days of the week header
        daysOfWeekStyle:  DaysOfWeekStyle(
          weekendStyle: GoogleFonts.alice(
              fontSize:MediaQuery.of(context).size.height*0.02,
                  color:  const Color(0xFF6A6A6A),
              fontWeight: FontWeight.bold
          ),
          weekdayStyle: GoogleFonts.alice(
            fontSize: MediaQuery.of(context).size.height*0.02,
        color: const Color(0xFF4F4F4F)
          )
        ),
        rowHeight: MediaQuery.of(context).size.height*0.06,

        // Customize the appearance of the calendar header
        headerStyle:  HeaderStyle(
          titleTextFormatter: (day,locale)=> DateFormat('MMM  y').format(day),
          formatButtonVisible: true, // Show a button to change the calendar format
          titleCentered: true, // Center the header title
         // Use an icon for the left chevron
          // Use an icon for the right chevron
          headerPadding: const EdgeInsets.only(
              bottom:
              10,top: 10),
          titleTextStyle: GoogleFonts.alice(
            fontWeight: FontWeight.w500,
                fontSize: MediaQuery.of(context).size.height*0.04,
          )
        ),

        // Customize the appearance of the calendar cells
        calendarStyle:  const CalendarStyle(
          todayDecoration:
          BoxDecoration(

            color: Colors.pinkAccent,
             // Set the background color for today's date
            shape: BoxShape.circle, // Display today's date as a circle
          ),
          rowDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.1, color: Colors.black), // Add a border between rows
            ),
          ),
          weekendTextStyle:
          TextStyle(color: Colors.red,), // Style for weekends
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle, // Display selected dates as circles
            gradient: LinearGradient(colors: [
              Colors.orange,Colors.red
            ]
            ,begin: Alignment.topCenter,end: Alignment.bottomCenter),// Set the background color for selected dates
          ),
        ),
        // Use the calendarBuilders property
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            //Customize the cell for days with events

            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    width: 15,
                    height: 7,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),



        // Set the event loader function
        eventLoader: _getEventsForTheDay,

        // ... Other TableCalendar properties
        calendarFormat: _calendarFormat, // Set the initial calendar format
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format; // Update the calendar format when changed
          });
        },
        focusedDay: _focusedDay, // Set the initially focused day
        firstDay: _firstDay, // Set the first day of the calendar
        lastDay: _lastDay, // Set the last day of the calendar
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay; // Update the focused day when the page changes
          });

          _loadFirestoreEvents(); // Load events when the page changes
        },
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay), // Predicate for selecting a day
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay; // Update the selected day
            _focusedDay = focusedDay; // Update the focused day
            _selectedDate = selectedDay; // Update the selected date
          });
          _scrollToSelectedDateEvents(selectedDay); // Scroll to the event associated with the selected date
        },
      ),
    );
  }

  Widget buildEventListView() {
    //It returns an Expanded widget, which takes up the remaining available space in the column.
    return Expanded(
      // The content of the Expanded widget is determined by a ternary operator.
      // If _isLoading is true, a Center widget containing a CircularProgressIndicator is shown to indicate that data is being loaded.
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
      // Otherwise, a ListView.builder widget is used to display a list of events.
      // Inside the ListView.builder, the controller property is set to _scrollController, which is used to control scrolling behavior.
      // The itemCount property is set to _events.length, which determines the number of items in the list.
      // The itemBuilder property is set to _buildDayEvents, which is a callback function used to build each item in the list.
      // The _buildDayEvents function is responsible for creating a column of event tiles for a particular day.
          : ListView.builder(
              controller: _scrollController,
              itemCount: _events.length,
              itemBuilder: _buildDayEvents,
            ),
    );
  }


  Widget _buildDayEvents(BuildContext context, int index) {
    // Get the DateTime (day) for the specified index from the _events map keys
    DateTime day = _events.keys.elementAt(index);

    // Get the list of events for the specific day from the _events map
    // If there are no events for the day, an empty list is used (fallback to [])
    List<Event> eventsForTheDay = _events[day] ?? [];

    // Return a Column widget containing a list of event tiles for the day
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the column
      mainAxisAlignment: MainAxisAlignment.start, // Align children along the start of the column
      children: eventsForTheDay.map((event) {
        // Map each event to a buildEventTile widget and convert the result to a list
        return buildEventTile(event, day);
      }).toList(),
    );
  }
  //In this _buildDayEvents function:
  // BuildContext context and int index are the parameters of the function, where context is
  // a reference to the build context and index is the index of the day being built.




  Widget buildEventTile(Event event, DateTime day) {
    // Return an InkWell widget, which adds ink splash effect when tapped
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ListTile(
          // Customize ListTile properties and styling
          tileColor: isSameDay(day, _selectedDate) ? Colors.grey.shade300 : null, // Set tile color if it's the selected day
          leading:  Icon(
            Icons.event,
            color: Colors.black,
            size: MediaQuery.of(context).size.height*0.03,
          ), // Icon shown at the start of the ListTile
          title: Text(
            toCamelCase(event.title),
            style: GoogleFonts.aleo(

              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.height*0.02,
              color: Colors.red.shade500
            ),
          ), // Display event title
          subtitle: Text(
            DateFormat('MMM d, y').format(day),

            style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          ), // Display date using a specific format
        ),
      ),
      onTap: () {
        _showEventDialog(event, day); // Call the _showEventDialog function when tapped
      },
    );
  }
  //In this buildEventTile function:
// Widget buildEventTile(Event event, DateTime day) defines the function with two parameters: event (an instance of the Event class) and
// day (the DateTime of the day the event belongs to).



  void _showEventDialog(Event event, DateTime day) {
    showDialog(
      context: context,
      builder: (context) {
        // Format the event date using the yMMMMd format (e.g., September 1, 2023)
        String formattedDate = DateFormat('MMM d y').format(day);

        // Return a Dialog widget
        return Dialog(
          alignment: const Alignment(0, -0.7), // Align the dialog slightly above the center
          clipBehavior: Clip.antiAlias, // Apply anti-aliasing to the dialog's clip path
          insetAnimationCurve: Curves.decelerate, // Set the curve for the dialog animation
          insetAnimationDuration: const Duration(microseconds: 500), // Set the duration for the animation
          elevation: 50, // Set the elevation of the dialog
          shadowColor: Colors.black, // Set the shadow color of the dialog
          backgroundColor: Colors.grey.shade300, // Set the background color of the dialog
          child: Padding(
            padding: const EdgeInsets.all(10.0), // Apply padding around the content
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5, // Set the height of the dialog
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    height: 170, // Set the height of this container
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Display "On this day" ListTile
                          const ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.orange,
                            ),
                            title: Text(
                              'On this day',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            minLeadingWidth: 1,
                            horizontalTitleGap: 4,
                          ),
                          ListTile(
                            // Display event title and formatted date
                            contentPadding: const EdgeInsets.all(20),
                            title: Text(
                              toCamelCase(event.title),
                              style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: GoogleFonts.openSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            //tileColor: Colors.grey.shade200,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ), // Add a small gap
                  SingleChildScrollView(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: Text(
                        "Description:\n",
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        event.description ?? '',
                        style: GoogleFonts.alice(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  //In this _showEventDialog function:
// void _showEventDialog(Event event, DateTime day) defines the function with two parameters: event (an instance of the Event class) and
// day (the DateTime of the day the event belongs to).



  void _showJumpToDateDialog() async {
    // Show a date picker dialog to select a specific date
    DateTime? selectedDate = await showDatePicker(
      context: context, // The build context
      initialDate: _focusedDay, // Set the initially displayed date
      firstDate: _firstDay, // Set the minimum selectable date
      lastDate: _lastDay, // Set the maximum selectable date
    );

    // If a date was selected, update the calendar and load events
    if (selectedDate != null) {
      setState(() {
        _focusedDay = selectedDate; // Update the focused day
        _selectedDay = selectedDate; // Update the selected day
      });

      // Scroll to the event associated with the selected date
      _scrollToSelectedDateEvents(selectedDate);

      // Load events for the selected date from firestore
      _loadFirestoreEvents();
    }
  }
  String toCamelCase(String input) {
    if (input.isEmpty) {
      return input; // Return an empty string if the input is empty
    }

    // Split the input string into words based on space
    final words = input.split(' ');

    // Capitalize the first letter of each word and make the rest lowercase
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return ''; // Return an empty string if the word is empty
      }
      // Capitalize the first letter and concatenate with the rest of the word in lowercase
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });

    // Join the words back together to form the camel case string
    return capitalizedWords.join(' ');
  }

}
