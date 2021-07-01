import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_salon/model/booking_model.dart';
import 'package:flutter_salon/model/user_model.dart';

Future<UserModel> getUsers(String phone)async{
  CollectionReference user = FirebaseFirestore.instance.collection("User");
  DocumentSnapshot snapshot = await user.doc(phone).get();
  if(snapshot.exists){
    var userModel = UserModel.fromJson(snapshot.data());
    return userModel;
  }else{
    UserModel();
  }
}

Future<List<BookingModel>> getUserHistory()async{
  var listBooking = List<BookingModel>.empty(growable: true);
  var userRef = FirebaseFirestore.instance.collection("User")
      .doc(FirebaseAuth.instance.currentUser.phoneNumber)
      .collection("Booking ${FirebaseAuth.instance.currentUser.uid}");

  var snapshot = await userRef.orderBy("timeStamp", descending: true).get();
  snapshot.docs.forEach((element) {
    var booking = BookingModel.fromJson(element.data());
    booking.docId = element.id;
    booking.reference = element.reference;
    listBooking.add(booking);
  });
return listBooking;
}