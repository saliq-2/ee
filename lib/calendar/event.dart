import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title; // Title of the event
  final String? description; // Description of the event (nullable)
  final DateTime date; // Date of the event
  final String id; // Unique identifier for the event


  Event({
    required this.title,
    this.description,
    required this.date,
    required this.id,
  }); //Constructor for the Event class. It initializes the properties based on the provided parameters.

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    // Factory constructor to create an Event object from a Firestore DocumentSnapshot
    final data = snapshot.data()!; // Extracting the data map from the Firestore DocumentSnapshot.
    return Event( //Creating and returning an Event instance using the extracted data.
      date: data['date'].toDate(), // Convert Firestore Timestamp to DateTime
      title: data['title'], // Get the title
      description: data['description'], // Get the description
      id: snapshot.id, // Get the unique document ID
    );
  }

  Map<String, Object?> toFirestore() {
    // Convert the Event object to a format suitable for Firestore
    return {
      "date": Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      "title": title, // Store the title
      "description": description, // Store the description
    };
  }
}
