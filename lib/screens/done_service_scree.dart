import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_salon/model/booking_model.dart';
import 'package:flutter_salon/model/service_model.dart';
import 'package:flutter_salon/repositories/AllSalonRepository.dart';
import 'package:flutter_salon/repositories/ServicesRepository.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:intl/intl.dart';
class DoneService extends ConsumerWidget {

  GlobalKey<ScaffoldState> keys = GlobalKey();
  @override
  Widget build(BuildContext context, watch) {
    
    return SafeArea(child: Scaffold(
      key: keys,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Done Services"),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: getDetailBooking(context, context.read(selectedTimeSlot).state),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }else{
                  var bookingModel = snapshot.data as BookingModel;
                  return Card(
                    elevation: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                child: Icon(Icons.account_box_rounded),
                              ),
                               SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${bookingModel.customerPhone}"),
                                  Divider(thickness: 1,),
                                  Row(
                                    children: [
                                      Consumer(builder: (context, watch, _){
                                        var servicesSelected = watch(selectedServices).state;
                                        var totelPrice = servicesSelected.map((e) => e.price).fold(0, (value, element) => value + element);
                                        return Text("Price: \$$totelPrice");
                                      })
                                    ],
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
              }),
          Expanded(
              child: FutureBuilder(
                future: getServices(context),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                  );
                  }else{
                    var services = snapshot.data as List<ServiceModel>;
                    return Consumer(builder: (context, watch, _){
                      var servicesWatch = watch(selectedServices).state;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ChipsChoice<ServiceModel>.multiple(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              wrapped: true,
                              value: servicesWatch,
                              onChanged: (val) => context.read(selectedServices).state = val,
                              choiceStyle: C2ChoiceStyle(elevation: 9),
                              choiceItems: C2Choice.listFrom<ServiceModel, ServiceModel>(
                                  source: services,
                                  value: (index, value) => value,
                                  label: (index, value) => "${value.name} (\$${value.price})"),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                child: Text("FINISH"),
                                onPressed: servicesWatch.length > 0 ? () => finishService(context) : null
                              )
                            ),
                          ],
                        ),
                      );
                    });
                  }
                },
              ),),
        ],
      ),
    ));
  }

  finishService(BuildContext context) {
    var batch = FirebaseFirestore.instance.batch();
    var barberBook = context.read(selectedBooking).state;

    var userBook = FirebaseFirestore.instance
        .collection("User")
        .doc(barberBook.customerPhone)
        .collection("Booking_${barberBook.customerId}")
        .doc("${barberBook.barberId}_${DateFormat("dd_MM_yyyy").format(DateTime.fromMillisecondsSinceEpoch(barberBook.timeStamp))}");
    Map<String, bool> updateDone = Map();
        updateDone["done"] = true;

        batch.update(userBook, updateDone);
        batch.update(barberBook.reference, updateDone);
        batch.commit().then((value) {
          ScaffoldMessenger.of(keys.currentContext)
              .showSnackBar(SnackBar(content: Text("Success"))).closed
              .then((value) => Navigator.pop(context));
        });
  }
}
