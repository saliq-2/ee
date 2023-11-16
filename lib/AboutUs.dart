import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => const LinearGradient(
                  colors: [Colors.pink, Colors.indigoAccent, Colors.pink])
              .createShader(rect),
          child: Text(
            'About Us',
            style: GoogleFonts.aboreto(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body:  Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(child: Text( 'Welcome to our app!\n',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.03,fontWeight: FontWeight.bold),)),
              const Text(
                'We created this app to provide a convenient '
                'way to connect to university professionals and to organize and view the events in the University Calendar.'
                '\nMain Features of this app are:',
                style: TextStyle(fontSize: 16),
              ),
              const ListTile(
                minLeadingWidth: 0,
                minVerticalPadding: 12,
                horizontalTitleGap: 12,
                leading: Text(
                  "1.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  'Calendar',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                subtitle: Text(
                  "It provides a realtime update of events in the calendar and "
                  "sends a text message to the users before a day or "
                  "two for a particular event to notify them.",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                minLeadingWidth: 1,
                minVerticalPadding: 12,
                horizontalTitleGap: 12,
                leading: Text(
                  "2.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  'Directory',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                subtitle: Text(
                  "This app has a Directory in which the numbers / emails of all the Teachers, "
                  "staff members  of Central University of Kashmir are stored and "
                  "whenever a user try to find a number of a Person ,"
                  "He/She can enter the name of that person in the search box and "
                  "quickly find that person and can contact them in no time."
                  "You can even call or whatsapp or email them directly from the app which adds to the "
                  "convenience for the user.",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Our Team:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text('1. Er. Afaq Alam Khan  - Mentor'),
              Text('2. Abid Bashir (2024CUKmr 02) - Developer & Designer'),
              Text('3. Saliq Neyaz (2024CUKmr 28) - Developer & Designer'),
              Text('4. Suhaib Aalam (2024CUKmr 32)- Developer & Designer'),
              // Add more team members as needed
            ],
          ),
        ),
      ),
    );
  }
}
