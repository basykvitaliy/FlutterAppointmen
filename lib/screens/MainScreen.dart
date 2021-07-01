import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_salon/model/user_model.dart';
import 'package:flutter_salon/repositories/BannerRopsitory.dart';
import 'package:flutter_salon/model/ImageModel.dart';
import 'package:flutter_salon/repositories/LookBool.dart';
import 'package:flutter_salon/repositories/UserRepository.dart';
import 'package:flutter_salon/screens/auth_screen.dart';
import 'package:flutter_salon/screens/booking_screen.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'staff_screen.dart';
import 'history_screen.dart';

class MainScreen extends ConsumerWidget {

  var phone = FirebaseAuth.instance.currentUser.phoneNumber;


  @override
  Widget build(BuildContext context, watch) {

    var staffWatch = watch(userInformation).state;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text("Booking"),
            actions: [
              FutureBuilder(
                  future: getUsers(phone),
                    builder:(context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }else{
                      var userModel = snapshot.data as UserModel;
                      return GestureDetector(
                        onTap: ()async{
                          await FirebaseAuth.instance.signOut();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen()));
                        },
                        child: Container(
                              child: Row(
                                children: [
                                  Text("${userModel.name}"),
                                  SizedBox(width: 15,),
                                  CircleAvatar(
                                    child: Icon(Icons.person, size: 17,),
                                    radius: 17,
                                  ),
                                  Container(
                                    child:
                                    userModel.isStaff
                                        ? IconButton(
                                        icon: Icon(Icons.admin_panel_settings,),
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffScreen()))) : Container(),

                                  ),
                                ],
                              ),
                            ),
                      );
                    }
                    }),
            ],
          ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [

                  Expanded(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen()));
                        },
                        child: Container(
                    child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book_online, size: 50,),
                              Text("Booking", style: GoogleFonts.robotoMono(),)
                            ],
                          ),
                        ),
                    ),
                  ),
                      )),
                  Expanded(
                      child: Container(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart, size: 50,),
                                Text("Card", style: GoogleFonts.robotoMono(),)
                              ],
                            ),
                          ),
                        ),
                      )),
                  Expanded(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen()));
                        },
                        child: Container(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 50,),
                                  Text("History", style: GoogleFonts.robotoMono(),)
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
            //Banner
            FutureBuilder(
              future: bannerList(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }else{
                   var banners = snapshot.data as List<ImageModel>;
                   return CarouselSlider(
                       items: banners.map((e) => Container(
                         child: ClipRRect(
                           borderRadius: BorderRadius.circular(8),
                           child: Image.network(e.image),
                         ),
                       )).toList(),
                     options: CarouselOptions(
                       enlargeCenterPage: true,
                       aspectRatio: 3,
                       autoPlay: true,
                       autoPlayInterval: Duration(seconds: 2)
                     ),
                   );
                  }
                }),
            //Lookbook
            SizedBox(height: 10,),
            Text("LOOKBOOK"),
            FutureBuilder(
                future: lookbookList(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }else{
                    var lookbook = snapshot.data as List<ImageModel>;
                    return Column(
                          children: lookbook.map((e) => Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(e.image),
                            ),
                          )).toList(),
                        );
                  }
                }),
          ],
        ),
      ),
    ));
  }
}
