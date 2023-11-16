import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// Define a StatelessWidget named DetailPage
class DetailPage extends StatelessWidget {
  // Declare a final property 'data' of type Map<String, dynamic>
  final Map<String, dynamic> data; // declares a constant (final) property named data that is expected to hold a map with string keys and dynamic values.
  // This property is used to pass and store the detailed information about a person that will be displayed on the detail page.
  //In other words, it's a map where the keys are strings, and the associated values can be of various data types.

  // Constructor for the DetailPage class
  const DetailPage({Key? key, required this.data}) : super(key: key);
  //he constructor DetailPage({Key? key, required this.data}) takes a required parameter named data,
  // which is a map containing the person's information.

  // Build method required by StatelessWidget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title:  Text('Details',style: GoogleFonts.aboreto(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.height*0.03,
        ),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration:  BoxDecoration(
    gradient: LinearGradient(
    colors: [
    Colors.white, // Start color of the gradient
    Colors.grey.shade300, // End color of the gradient
    ],)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            // Nested Column for arranging various sections
            Column(
              children: [
                _buildNameTitle(), // Display the person's name
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  child: _buildContactInfo(), // Display contact information
                ),
                _buildEmailInfo(),
                _buildDepartmentInfo(), // Display department information
                _buildDesignationInfo(), // Display designation information
              ],
            ),
          ],
        ),
      ), // Build the main content of the page
    );
  }

// Function to display customized Name title
  Widget _buildNameTitle() {
    return Column(
      children: [
        Text(
          toCamelCase(data['name']),
          style: GoogleFonts.roboto(
            fontSize: 35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
  // Display contact information
  Widget _buildContactInfo() {
    return ListTile(
      tileColor: Colors.red,
      horizontalTitleGap: 15,
      leading: Text(
        "Phone No:",
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      title: Text(data['phone']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPhoneIcon(), // calling Function
          const SizedBox(
            width: 12,
          ),
          _buildWhatsAppIcon(), //  Whatsapp function
        ],
      ),
    );
  }
  //  Function to build phone title
  Widget _buildPhoneIcon() {
    return IconButton(
      onPressed: () async {
        await FlutterPhoneDirectCaller.callNumber(data['phone']);
      },
      icon: const Icon(Icons.phone),
      color: Colors.black,
    );
  }
  //  Whatsapp function
  Widget _buildWhatsAppIcon() {
    return SizedBox(
      width: 35,
      height: 30,
      child: InkWell(
        child: Image.asset('assets/images/WhatsApp.png'),
        onTap: () async {
          String wno = data['phone'];
          var whatsappUrl = "https://wa.me/$wno";
          await launch(whatsappUrl);
        },
      ),
    );
  }
  //  Function to build Email title
  Widget _buildEmailInfo(){
    return ListTile(
      horizontalTitleGap: 15,
      leading: Text(
        "Email:",
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      title: Text(
        data['email'],
        style: const TextStyle(),
      ),
      trailing: IconButton(
        onPressed: () async {
          String? encodeQueryParameters(
              Map<String, String> params) {
            return params.entries
                .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');
          }

          final Uri emailUri = Uri(
            scheme: 'mailto',
            path: data['email'],
            query: encodeQueryParameters(<String, String>{
              'subject': '!',
            }),
          );
          if (await canLaunchUrl(emailUri)) {
            // print(data['email']);
            launchUrl(emailUri);
          } else {
           // print(data['email']);
           //  ScaffoldMessenger.of(context).showSnackBar(
           //    const SnackBar(content: Text("Could not launch")),
           //
           //  );
          }
        },
        icon: const Icon(Icons.email),
        color: Colors.black,
      ),
    );
  }

  // Function for building department information
  Widget _buildDepartmentInfo() {
    return ListTile(
      leading: Text(
        "Department:",
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      title: Text(data['department']),
    );
  }

  // Function for building Designation information
  Widget _buildDesignationInfo() {
    return ListTile(
      leading: Text(
        "Designation:",
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      title: Text(
        toCamelCase(data['designation']),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 17,
          color: Colors.red,
        ),
      ),
    );
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
