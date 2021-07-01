
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_salon/model/barber_model.dart';
import 'package:flutter_salon/model/booking_model.dart';
import 'package:flutter_salon/model/city_model.dart';
import 'package:flutter_salon/model/salon_model.dart';
import 'package:flutter_salon/model/service_model.dart';
import 'package:flutter_salon/model/user_model.dart';

final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref) => "");
final forceReload = StateProvider((ref) => false);
final userInformation = StateProvider((ref) => UserModel());


final currentStep = StateProvider((ref) => 1);
final selectedCity = StateProvider((ref) => CityModel());
final selectedSalon = StateProvider((ref) => SalonModel());
final selectedBarber = StateProvider((ref) => BarberModel());
final selectedDate = StateProvider((ref) => DateTime.now());
final selectedTimeSlot = StateProvider((ref) => -1);
final selectedTime = StateProvider((ref) => "");


final deleteFlagRefresh = StateProvider((ref) => false);


final staffStep = StateProvider((ref) => 1);
final selectedBooking = StateProvider((ref) => BookingModel());
final selectedServices = StateProvider((ref) => List<ServiceModel>.empty(growable: true));