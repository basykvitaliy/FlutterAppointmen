import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_salon/model/barber_model.dart';
import 'package:flutter_salon/model/city_model.dart';
import 'package:flutter_salon/model/salon_model.dart';
import 'package:flutter_salon/repositories/AllSalonRepository.dart';
import 'package:flutter_salon/screens/done_service_scree.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:flutter_salon/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {

    var currentStaffStep = watch(staffStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var dateWatch = watch(selectedDate).state;
    var selectTimeWatch = watch(selectedTime).state;

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(currentStaffStep == 1
        ? "Select city"
        : currentStaffStep == 2
        ? "Select salon"
        : currentStaffStep == 3
        ? "Your appointmen"
        : "Staff home"),
      ),
      body: Column(
        children: [
          //area
          Expanded(
            child: currentStaffStep == 1 ? displaycity()
                : currentStaffStep == 2 ? displaySalon(cityWatch.name)
                : currentStaffStep == 3 ? displayAppointmen(context)
                : Container(),
            flex: 10,),

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
                          onPressed: currentStaffStep == 1
                              ? null
                              : () => context.read(staffStep).state--,
                        )),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(

                        child: ElevatedButton(
                          child: Text("Next"),
                          onPressed: (currentStaffStep == 1
                              && context.read(selectedCity).state.name == null)
                              || (currentStaffStep == 2 && context.read(selectedSalon).state.docId == null)
                              ? null
                              : currentStaffStep == 3
                              ? null
                              : () => context.read(staffStep).state++,
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

  displaycity() {
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
              return GridView.builder(
                itemCount: cities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2
                  ),
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: () => context.read(selectedCity).state = cities[index],
                      child: Card(
                         shape: context.read(selectedCity).state.name == cities[index].name
                             ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(width: 1, color: Colors.blue))
                             : null,
                        child: Center(
                          child: Text("${cities[index].name}"),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displaySalon(String name) {
    return FutureBuilder(
        future: getSalonList(name),
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

  displayBarber(SalonModel salonModel) {
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

  displayAppointmen(BuildContext context) {
    return FutureBuilder(
      future: checkStaffOfThisSalon(context),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else{
            var result = snapshot.data as bool;
            if(result) return displaySlot(context);
            else
              return Text("You are not a staff of this  salon");
          }
        });
  }

  displaySlot(BuildContext context) {
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
                  future: getBookingSlotOfBarber(context, DateFormat("dd_MM_yyyy").format(context.read(selectedDate).state)),
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
                            onTap: !listTimeSlot.contains(index) ? null : (){
                              return processDoneServices(context, index);
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

  processDoneServices(BuildContext context, int index) {
    context.read(selectedTimeSlot).state = index;
    Navigator.push(context, MaterialPageRoute(builder: (_) => DoneService()));
  }
}
