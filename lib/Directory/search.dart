import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_page.dart';

class DirectoryInSearch extends StatefulWidget {
  const DirectoryInSearch({Key? key}) : super(key: key);

  @override
  State<DirectoryInSearch> createState() => _DirectoryInSearchState();
}

class _DirectoryInSearchState extends State<DirectoryInSearch> {
  List<dynamic> allItems = [];
  String query = '';
  bool _isLoading = true;
  String selectedOption = 'Directory';
  List<String> _departments = [];
  @override
  void initState() {
    super.initState();
    _loadAllItemsFromFirebase();
    _fetchDepartments();
  }

//This Below  function fetches all items from the 'Directory' collection in Firestore and listens for real-time changes using snapshots.
  void _loadAllItemsFromFirebase() async {
    try {
      // Access the 'Directory' collection in Firestore
      var collectionReference = FirebaseFirestore.instance.collection('Directory');

      // Fetch the documents from the collection
      var querySnapshot = await collectionReference.get();

      // Extract the document data from the query snapshot
      var items = querySnapshot.docs
          .map((doc) => doc.data())
          .toList(); // Map each document snapshot to its data and convert it to a list

      // Sort the items based on the 'name' field in ascending order
      items.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        // Update the widget state with the fetched items and loading status
        setState(() {
          allItems = items; // Update the list of all items
          _isLoading = false; // Set loading status to false
        });
      }
    } catch (e) {
      print('Exception: $e');
      // Handle the exception as needed
    }
  }


  void _loadDataFromSelectedOption() {
    setState(() {
      _isLoading = true; // Set loading status to true
    });

    // Check if the selected option is 'Directory'
    if (selectedOption == 'Directory') {
      _loadAllItemsFromFirebase(); // Load all items from the 'Directory' collection
    } else {
      // Load data from the selected option's collection
      FirebaseFirestore.instance
          .collection(
              selectedOption) // Access the collection based on selected option
          .snapshots() // Listen to real-time changes using snapshots
          .listen((querySnapshot) {
        //This callback is executed when there are changes in the collection.
        // Extract the document data from the query snapshot
        var items = querySnapshot.docs.map((doc) => doc.data()).toList();

        // Sort the items based on the 'name' field in ascending order
        items.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));

        // Update the widget state with the fetched items and loading status
        setState(() {
          allItems = items; // Update the list of all items
          _isLoading = false; // Set loading status to false
        });
      });
    }
  }

  Stream<List<dynamic>> _performSearch(String query, String selectedOption) {
    print('query: $query');
    String query1=' $query';
    CollectionReference collectionReference;

    if (selectedOption == 'Directory') {
      collectionReference = FirebaseFirestore.instance.collection('Directory');
    } else {
      collectionReference =
          FirebaseFirestore.instance.collection(selectedOption);
    }

    return collectionReference
        .where('name', isGreaterThanOrEqualTo: query1) // Use isGreaterThanOrEqualTo for partial search
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.09,
        centerTitle: true,
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => const LinearGradient(
                  colors: [Colors.pink, Colors.indigoAccent, Colors.pink])
              .createShader(rect),
          child: Text(
            "Directory", // Title text for the app bar
            style: GoogleFonts.aboreto(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.height*0.03,
            ),
          ),
        ),
        backgroundColor: Colors.white, // Background color of the app bar
      ),
      body: Container(
        decoration:  BoxDecoration(

          gradient: LinearGradient(
            colors: [
              Colors.white, // Start color of the gradient
              Colors.grey.shade300, // End color of the gradient
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
                'assets/images/cuk.png',width: MediaQuery.of(context).size.width*1,scale: MediaQuery.of(context).size.aspectRatio*0.8,), // Display the university image
            _buildSearchField(), // Display the search field
            _buildDropdown(),// Display the dropdown for selecting options
            const SizedBox(height: 25,),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator if loading
                  : _buildSearchResults(), // Display the search results
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(15.0), // Padding around the search field
      child: SizedBox(
        width: MediaQuery.of(context).size.width*0.8,
        height: 50,
        child: TextField(

          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search,color: Colors.black,),
            label: const Text("Want to Find Someone"),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15), // Rounded border for the input field
            ),
            focusedBorder:  OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
                borderRadius:
                BorderRadius.circular(15),
            ),
           // hintText: "Search Here", // Placeholder text inside the input field
          ),
          onChanged: (newQuery) {
            //This line sets up a callback that triggers when the input value changes.
            setState(() {
              //This is a Flutter method that marks the widget as needing to be rebuilt due to a state change.
              query = toCamelCase(
                  newQuery); // Update the query and trigger a re-render
            });
          },
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: MediaQuery.of(context).size.height*0.04, // Set the height of the container
      width:MediaQuery.of(context).size.width*0.6, // Set the width of the container
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.grey), // Add a border around the container
        borderRadius:
            BorderRadius.circular(10.0), // Add rounded corners to the container
        color: Colors.grey[200], // Set the background color of the container
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 10), // Add horizontal padding inside the container
      child: InkWell(
        onTap:
            _showOptionsDialog, // Set the callback function when the container is tapped
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Align children to the space between
          children: [
            Text(selectedOption), // Display the selected option text
            const Icon(Icons.arrow_drop_down_circle), // Display a dropdown icon
          ],
        ),
      ),
    );
  }

  Future<void> _fetchDepartments() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('departments').get();
    setState(() {
      _departments =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  void _showOptionsDialog() {
    // Move "Directory" to the beginning of the list or sort the list
    List<String> modifiedDepartments = List.from(_departments);
    modifiedDepartments.remove("Directory");
    modifiedDepartments.insert(0, "Directory");
    modifiedDepartments.sort();

    // Show a dialog using the showDialog function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: Column(
              children: [
                Card(
                  color:
                      Colors.blue, // Set the color for the "Directory" header
                  child: ListTile(
                    title: const Text("Directory",
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() {
                        selectedOption = 'Directory';
                        _isLoading = true;
                        _loadDataFromSelectedOption();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: modifiedDepartments.length,
                    itemBuilder: (context, index) {
                      final value = modifiedDepartments[index];
                      // Skip the "Directory" option in the regular list
                      if (value == "Directory") {
                        return Container(); // Empty container, as the header is fixed at the top
                      }

                      return Card(
                        color: Colors.grey.shade200,
                        child: ListTile(
                          title: Text(value),
                          onTap: () {
                            setState(() {
                              selectedOption = value;
                              _isLoading = true;
                              _loadDataFromSelectedOption();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<dynamic>>(
      //Using a StreamBuilder to listen to the stream of search results.
      // Listen to the stream returned by _performSearch function
      stream: _performSearch(query,
          selectedOption), //Listening to the search results stream based on the query and selected option.
      builder: (context, snapshot) {
        // Builder function called when the stream emits new data
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator if data is being fetched
          return const Center(child: CircularProgressIndicator());
        }

        final searchResults = snapshot.data; // Get the data from the stream

        if (searchResults == null || searchResults.isEmpty) {
          // If there are no search results, display a message
          return const Center(child: Text("No data found"));
        }

        // Build a ListView to display the search results
        return ListView.builder(

          itemCount: searchResults.length, // Number of search results
          itemBuilder: (context, index) {
            //Building each individual item in the list.
            final itemData = searchResults[index]; // Get data for the item
            final itemName = itemData['name'].toString(); // Get item's name
            final isMatched = query.isEmpty ||
                itemName.contains(
                    query); //Checking if the query matches the item's name.

            return isMatched // If matched, wrap the item in a GestureDetector for tapping.
                ? GestureDetector(
                    onTap: () {
                      // Navigate to a detail page when an item is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(data: itemData),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ListTile(
                        minLeadingWidth: MediaQuery.of(context).size.width*.18,
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade700,
                            radius: 15,
                            child: Text('${index + 1}',style: GoogleFonts.aleo(color: Colors.white),)), // Display serial number
                        title: Text(
                          toCamelCase(itemData['name']), // Display item's name
                          style:
                              GoogleFonts.roboto(fontWeight: FontWeight.w600,fontSize: MediaQuery.of(context).size.height*0.022),
                        ),
                        subtitle: Text(
                            "Dept: ${toCamelCase(itemData['department'])}",style:  GoogleFonts.albertSans(color:Colors.red.shade700,fontWeight: FontWeight.w600,fontSize: MediaQuery.of(context).size.height*0.020)
                        ), // Display department
                        trailing:
                            const Icon(Icons.perm_identity_sharp,color: Colors.black,), // Display an icon
                      ),
                    ),
                  )
                : Container(); // If not matched, return an empty container
          },
        );
      },
    );
  }
}
