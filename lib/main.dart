import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cuk/splash_screen/splash_screen.dart';
import 'package:ecalendar/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    name: 'ecalendar',
    options: DefaultFirebaseConfig.platformOptions,

  );

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? mTokens=" ";
  final _firebaseMessaging=FirebaseMessaging.instance;

  @override
  void initState(){
    super.initState();
    initNotifications();
    getToken();
  }
  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      // print('user granted permission ');
    }
   // FirebaseMessaging.onBackgroundMessage((handleBackgroundMessage));
  }
  Future<void > handleBackgroundMessage(RemoteMessage message) async{
    // print('Title ${message.notification?.title}');
    // print('Title ${message.notification?.body}');
    // print('Payload: ${message.data}');
  }

  void getToken() async {
    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      bool tokenExists = await checkIfTokenExists(token);

      if (!tokenExists) {
        saveTokenToFirestore(token);
      } else {
        // print('Token already exists in Firestore.');
      }
    }
  }

  Future<bool> checkIfTokenExists(String token) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('DeviceTokens')
        .where('token', isEqualTo: token)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> saveTokenToFirestore(String token) async {
    await FirebaseFirestore.instance
        .collection('DeviceTokens')
        .add({'token': token});
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CUK-Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const SplashScreen(),
    );
  }
}




