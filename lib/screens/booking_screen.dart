import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_salon/model/barber_model.dart';
import 'package:flutter_salon/model/booking_model.dart';
import 'package:flutter_salon/model/city_model.dart';
import 'package:flutter_salon/model/salon_model.dart';
import 'package:flutter_salon/repositories/AllSalonRepository.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:flutter_salon/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerWidget {

  GlobalKey<ScaffoldState> _keys = GlobalKey();

  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var barberWatch = watch(selectedBarber).state;
    var dateWatch = watch(selectedDate).state;
    var timeWatch = watch(selectedTime).state;
    var timeSlotWatch = watch(selectedTimeSlot).state;


    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Booking"),
          ),
          key: _keys,
          resizeToAvoidBottomInset: true,
            body: Column(
        children: [
          //step
          NumberStepper(
            activeStep: step - 1,
            direction: Axis.horizontal,
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            numbers: [1, 2, 3, 4, 5],
            stepColor: Colors.grey,
            activeStepColor: Colors.blueAccent,
            numberStyle: TextStyle(color: Colors.white),
          ),
          //screen
          Expanded(
            flex: 10,
            child: step == 1
                ? displaycityList()
                : step == 2 ? displaySalonList(cityWatch.name)
                : step == 3 ? displayBarberList(salonWatch)
                : step == 4 ? displayTime(context, barberWatch)
                : step == 5 ? displayConfirm(context)
                : Container(),
          ),
          //button
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      child: Text("Previous"),
                      onPressed: step == 1
                          ? null
                          : () => context.read(currentStep).state--,
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(

                        child: ElevatedButton(
                      child: Text("Next"),
                      onPressed: (step == 1
                          && context.read(selectedCity).state.name == null)
                          || (step == 2 && context.read(selectedSalon).state.docId == null)
                          || (step == 3 && context.read(selectedBarber).state.docId == null)
                          || (step == 4 && context.read(selectedTimeSlot).state == -1)
                          ? null
                          : step == 5
                              ? null
                              : () => context.read(currentStep).state++,
                    ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  displaycityList() {
    return FutureBuilder(
        future: allSalonList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var cities = snapshot.data as List<CityModel>;
            if (cities == null || cities.length == 0) {
              return Center(
                child: Text(
                  "Cannot load city list",
                  style: GoogleFonts.robotoMono(),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        context.read(selectedCity).state = cities[index];
                      },
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.home_work),
                          title: Text("${cities[index].name}"),
                          trailing: context.read(selectedCity).state.name ==
                                  cities[index].name
                              ? Icon(Icons.check)
                              : null,
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displaySalonList(String cityName) {
    return FutureBuilder(
        future: getSalonList(cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var salons = snapshot.data as List<SalonModel>;
            if (salons == null || salons.length == 0) {
              return Center(
                child: Text(
                  "Cannot load salon list",
                  style: GoogleFonts.robotoMono(),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: salons.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        context.read(selectedSalon).state = salons[index];
                      },
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.home_outlined),
                          title: Text("${salons[index].name}"),
                          subtitle: Text("${salons[index].address}"),
                          trailing: context.read(selectedSalon).state.docId ==
                                  salons[index].docId
                              ? Icon(Icons.check)
                              : null,
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displayBarberList(SalonModel salonModel) {
    return FutureBuilder(
        future: getBarberList(salonModel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var barbers = snapshot.data as List<BarberModel>;
            if (barbers == null || barbers.length == 0) {
              return Center(
                child: Text(
                  "Barber list are empty",
                  style: GoogleFonts.robotoMono(),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: barbers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        context.read(selectedBarber).state = barbers[index];
                      },
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text("${barbers[index].name}"),
                          subtitle: RatingBar.builder(
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            ignoreGestures: true,
                            itemSize: 16,
                            itemCount: 5,
                            direction: Axis.horizontal,
                            initialRating: barbers[index].rating,
                            allowHalfRating: true,
                          ),
                          trailing: context.read(selectedBarber).state.docId ==
                                  barbers[index].docId
                              ? Icon(Icons.check)
                              : null,
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displayTime(BuildContext context, BarberModel barberModel) {
    var now = context.read(selectedDate).state;
    return Column(
      children: [
        Container(
          color: Colors.blue,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: (){
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: now,
                          maxTime: now.add(
                            Duration(days: 31),
                          ),
                          onConfirm: (date) =>
                          context.read(selectedDate).state = date);
                    },
                    child: Column(
                      children: [
                        Text(
                          "${DateFormat.MMMM().format(now)}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text("${now.day}",
                            style: TextStyle(color: Colors.white, fontSize: 26)),
                        Text(
                          "${DateFormat.EEEE().format(now)}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: FutureBuilder(
              future: getMaxAvailableTimeSlot(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }else{
                  var maxTimeSlot = snapshot.data as int;
                  return FutureBuilder(
                    future: getTimeOfSlotBarber(barberModel, DateFormat("dd_MM_yyyy").format(context.read(selectedDate).state)),
                    builder:(context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }else{
                        var listTimeSlot = snapshot.data as List<int>;
                        return GridView.builder(
                            itemCount: TIME_SLOT.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                            itemBuilder: (context, index) =>GestureDetector(
                              onTap: listTimeSlot.contains(index) ? null : (){
                                context.read(selectedTime).state = TIME_SLOT.elementAt(index);
                                context.read(selectedTimeSlot).state = index;
                              },
                              child: Card(
                                color: listTimeSlot.contains(index) ? Colors.grey
                                    : context.read(selectedTime).state == TIME_SLOT.elementAt(index)
                                    ? Colors.lightGreen : Colors.white,
                                child: GridTile(
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("${TIME_SLOT.elementAt(index)}"),
                                        Text(listTimeSlot.contains(index) ? "Занято" :"Свободно"),
                                      ],
                                    ),
                                  ),
                                  header: context.read(selectedTime).state == TIME_SLOT.elementAt(index) ? Icon(Icons.check) : null,
                                ),
                              ),
                            ));
                      }
                    },

                  );
                }
              },
            ),
        ),
      ],
    );
  }

  confirmBooking(BuildContext context) {

    var hour = context.read(selectedTime).state.length <= 10
        ? int.parse(context.read(selectedTime).state.split(":")[0].substring(0,1))
        : int.parse(context.read(selectedTime).state.split(":")[0].substring(0,2));

    var minutes = context.read(selectedTime).state.length <= 10
        ? int.parse(context.read(selectedTime).state.split(":")[1].substring(0,1))
        : int.parse(context.read(selectedTime).state.split(":")[1].substring(0,2));

    var timeStamp = DateTime(
      context.read(selectedDate).state.year,
      context.read(selectedDate).state.month,
      context.read(selectedDate).state.day,
      hour,
      minutes
    ).millisecondsSinceEpoch;

    //create booking model
    var bookingModel = BookingModel(
        barberId: context.read(selectedBarber).state.docId,
    barberName: context.read(selectedBarber).state.name,
    cityBook: context.read(selectedCity).state.name,
    //customerName: context.read(userInformation).state.name,
    customerPhone: FirebaseAuth.instance.currentUser.phoneNumber,
    customerId: FirebaseAuth.instance.currentUser.uid,
    done: false,
    salonAddress: context.read(selectedSalon).state.address,
    salonId: context.read(selectedSalon).state.docId,
    salonName: context.read(selectedSalon).state.name,
    slot: context.read(selectedTimeSlot).state,
    timeStamp: timeStamp,
    time: "${context.read(selectedTime).state} - ${DateFormat("dd/MM/yyyy").format(context.read(selectedDate).state)}",
    );

    var batch = FirebaseFirestore.instance.batch();

    DocumentReference barberBooking = context.read(selectedBarber)
        .state
        .reference
        .collection("${DateFormat("dd_MM_yyyy").format(context.read(selectedDate).state)}")
        .doc(context.read(selectedTimeSlot).state.toString());

    DocumentReference userBooking = FirebaseFirestore.instance.collection("User")
        .doc(FirebaseAuth.instance.currentUser.phoneNumber)
    .collection("Booking ${FirebaseAuth.instance.currentUser.uid}")
        .doc("${context.read(selectedBarber).state.docId}_${DateFormat("dd_MM_yyyy").format(context.read(selectedDate).state)}");

    batch.set(barberBooking, bookingModel.toJson());
    batch.set(userBooking, bookingModel.toJson());
    batch.commit().then((value) {
//reset value
      context.read(selectedDate).state = DateTime.now();
      context.read(selectedBarber).state = BarberModel();
      context.read(selectedCity).state = CityModel();
      context.read(selectedSalon).state = SalonModel();
      context.read(currentStep).state = 1;
      context.read(selectedTime).state = "";
      context.read(selectedTimeSlot).state = -1;

      //create  event

      final event = Event(
          title: "Barber appointment",
          description: "Barber appointment ${context.read(selectedTime).state} -"
              "${DateFormat("dd/MM/yyyy").format(context.read(selectedDate).state)}",
          location: "${context.read(selectedSalon).state.address}",
          startDate: DateTime(
              context.read(selectedDate).state.year,
              context.read(selectedDate).state.month,
              context.read(selectedDate).state.day,
              hour,
              minutes),
          endDate: DateTime(
              context.read(selectedDate).state.year,
              context.read(selectedDate).state.month,
              context.read(selectedDate).state.day,
              hour,
              minutes + 60),
          iosParams: IOSParams(reminder: Duration(hours: 1)),
          androidParams: AndroidParams(emailInvites: [])
      );
      Add2Calendar.addEvent2Cal(event).then((value) {});
    });


  }

  displayConfirm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
              height: MediaQuery.of(context).size.height * 0.2,
              padding: EdgeInsets.all(5),
              child: Icon(Icons.watch, size: 20,),
            ),
        Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text("Спасибо за ваш заказ!".toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      SizedBox(height: 16,),
                      Text("Информация о заказе".toUpperCase()),
                      SizedBox(height: 16,),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 20,),
                            Text("${context.read(selectedTime).state} - ${DateFormat("dd/MM/yyyy").format(context.read(selectedDate).state)}"),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 20,),
                            Text("${context.read(selectedBarber).state.name}"),
                            SizedBox(width: 20,),
                            Icon(Icons.star, color: Colors.amber,),
                            Text("${context.read(selectedBarber).state.rating}"),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey, thickness: 1,),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Icon(Icons.home),
                            SizedBox(width: 20,),
                            Text("${context.read(selectedSalon).state.name}"),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 20,),
                            Text("${context.read(selectedSalon).state.address}"),
                          ],
                        ),
                      ),
                       Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              onPressed: () => confirmBooking(context),
                                child: Text("Сохранить")),
                          ),
                    ],
                  ),
                ),
              ),
            ),),
      ],
    );
  }
}
