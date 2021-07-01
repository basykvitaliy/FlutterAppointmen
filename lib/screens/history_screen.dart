
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_salon/model/booking_model.dart';
import 'package:flutter_salon/repositories/UserRepository.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:flutter_salon/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HistoryScreen extends ConsumerWidget {

  GlobalKey<ScaffoldState> _keys = GlobalKey();

  @override
  Widget build(BuildContext context, watch) {

    var watchRefresh = watch(deleteFlagRefresh).state;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("History"),
          ),
          key: _keys,
          resizeToAvoidBottomInset: true,
          body: Center(
            child: displayUserHistory(),
          ),
        ));
  }
  displayUserHistory() {
    return FutureBuilder(
        future: getUserHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var userBooking = snapshot.data as List<BookingModel>;
            if (userBooking == null || userBooking.length == 0) {
              return Center(
                child: Text(
                  "Cannot load city list",
                  style: GoogleFonts.robotoMono(),
                ),
              );
            } else {
              return FutureBuilder(
                future: syncTime(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }else{
                      var syncTime = snapshot.data as DateTime;
                      return ListView.builder(
                          itemCount: userBooking.length,
                          itemBuilder: (context, index) {
                            var isExpired = DateTime.fromMillisecondsSinceEpoch(userBooking[index].timeStamp).isBefore(syncTime);
                            return Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text("Date: "),
                                                  Text(DateFormat("dd/MM/yyyy").format(
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                        userBooking[index].timeStamp
                                                    ),
                                                  )),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("Time: "),
                                                  Text(TIME_SLOT.elementAt(userBooking[index].slot)
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Divider(thickness: 1,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("${userBooking[index].salonName}"),
                                                  Text("${userBooking[index].barberName}"),
                                                ],
                                              )
                                            ],
                                          ),
                                          Divider(thickness: 1,),
                                          Text("${userBooking[index].salonAddress}"),
                                        ],
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap:isExpired ?  null : (){
                                      Alert(
                                          context: context,
                                          type: AlertType.warning,
                                          title: "Delete booking",
                                          desc: "Please delete also in your Caloendar too",
                                          buttons: [
                                            DialogButton(
                                                child: Text("Cancel"),
                                                onPressed: () => Navigator.pop(context)
                                            ),
                                            DialogButton(
                                                child: Text("Delete"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  cancelBooking(context, userBooking[index]);
                                                }
                                            ),
                                          ]
                                      ).show();
                                  },
                                    child: Container(
                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20)
                                          )
                                      ),
                                      child: Center(
                                        child: Text(userBooking[index].done ? "Finish" : isExpired ? "Expired" : "Cansel",
                                          style: TextStyle(color:isExpired ? Colors.grey : Colors.white),),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    }
                  });
            }
          }
        });
  }

  void cancelBooking(BuildContext context, BookingModel bookingModel) {
    var batch = FirebaseFirestore.instance.batch();
    var barberBooking = FirebaseFirestore.instance
        .collection("AllSalon")
        .doc(bookingModel.cityBook)
        .collection("Branch")
        .doc(bookingModel.salonId)
        .collection("Barber")
        .doc(bookingModel.barberId)
        .collection(DateFormat("dd_MM_yyyy").format(
          DateTime.fromMillisecondsSinceEpoch(bookingModel.timeStamp),))
    .doc(bookingModel.slot.toString());
    var userBooking = bookingModel.reference;

    //delete
    batch.delete(userBooking);
    batch.delete(barberBooking);
    batch.commit().then((value){

      context.read(deleteFlagRefresh).state = !context.read(deleteFlagRefresh).state;
    });
  }

}
