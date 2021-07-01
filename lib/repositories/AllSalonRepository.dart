import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_salon/model/barber_model.dart';
import 'package:flutter_salon/model/booking_model.dart';
import 'package:flutter_salon/model/city_model.dart';
import 'package:flutter_salon/model/salon_model.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final CollectionReference allSalonCol = FirebaseFirestore.instance.collection("AllSalon");




Stream<List<CityModel>> get getAllSalonList{
  return allSalonCol.snapshots().map((salonModel){
    return salonModel.docs.map((e) => CityModel.fromJson(e.data())).toList();
  });
}

Future allSalonList()async{
  List<CityModel> items = [];
  await allSalonCol.get().then((value){
    value.docs.forEach((element) {
      items.add(CityModel.fromJson(element.data()));
    });
  } );
  return items;
}


Future<List<SalonModel>> getSalonList(String cityName)async{
  var salons = List<SalonModel>.empty(growable: true);
  var salonRef = allSalonCol.doc(cityName.replaceAll(" ", "")).collection("Branch");
  await salonRef.get().then((value){
    value.docs.forEach((element) {
      var salon = SalonModel.fromJson(element.data());
      salon.docId = element.id;
      salon.reference = element.reference;
      salons.add(salon);
    });
  } );
  return salons;
}

Future<List<BarberModel>> getBarberList(SalonModel salonModel)async{
  var barbers = List<BarberModel>.empty(growable: true);
  var barberRef = salonModel.reference.collection("Barber");
  await barberRef.get().then((value){
    value.docs.forEach((element) {
      var barber = BarberModel.fromJson(element.data());
      barber.docId = element.id;
      barber.reference = element.reference;
        barbers.add(barber);
    });
  } );
  return barbers;
}

Future<List<int>> getTimeOfSlotBarber(BarberModel barberModel, String date)async{
  List<int> result = List<int>.empty(growable: true);
  var bookingRef = barberModel.reference.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<List<int>> getBookingSlotOfBarber(BuildContext context, String date)async{
  var barberDocument = allSalonCol
      .doc(context.read(selectedCity).state.name)
      .collection("Branch")
      .doc(context.read(selectedSalon).state.docId)
      .collection("Barber")
      .doc(FirebaseAuth.instance.currentUser.uid);

  List<int> result = List<int>.empty(growable: true);
  var bookingRef = barberDocument.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<bool> checkStaffOfThisSalon(BuildContext context)async{
  DocumentSnapshot barberSnapshot = await allSalonCol
      .doc(context.read(selectedCity).state.name)
      .collection("Branch")
      .doc(context.read(selectedSalon).state.docId)
      .collection("Barber")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .get();
  return barberSnapshot.exists;

}

Future<BookingModel> getDetailBooking(BuildContext context, int timeSlot)async{
  var userRef = allSalonCol
      .doc(context.read(selectedCity).state.name)
      .collection("Branch")
      .doc(context.read(selectedSalon).state.docId)
      .collection("Barber")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection(DateFormat("dd_MM_yyyy").format(context.read(selectedDate).state));
  DocumentSnapshot snapshot = await userRef.doc(timeSlot.toString()).get();
  if(snapshot.exists){
    var bookingModel = BookingModel.fromJson(json.decode(json.encode(snapshot.data())));
    bookingModel.docId = snapshot.id;
    bookingModel.reference = snapshot.reference;
    context.read(selectedBooking).state = bookingModel;
    return bookingModel;
  }else{
    return BookingModel();
  }
}