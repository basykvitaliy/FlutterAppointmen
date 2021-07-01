import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_salon/utils/constant.dart';
import 'package:flutter_salon/utils/utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'MainScreen.dart';

class AuthScreen extends ConsumerWidget {


  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context, watch) {
    return Scaffold(
      key: _globalKey,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://media.istockphoto.com/vectors/blue-abstract-background-vector-id483589997"),
              fit: BoxFit.cover,
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: MediaQuery.of(context).size.width,

              child: FutureBuilder(
                future: checkLoginState(context, false, _globalKey),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }else{
                    var userState= snapshot.data as LOGIN_STATE;
                    if(userState == LOGIN_STATE.LOGGED){
                      return Container();
                    }else{
                      return ElevatedButton.icon(
                        onPressed: () => processLogin(context),
                        icon: Icon(Icons.phone, color: Colors.white),
                        label: Text("Login with phone", style: TextStyle(color: Colors.white),),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue,)
                        ),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  processLogin(BuildContext context, ){
    var user = FirebaseAuth.instance.currentUser;
    if(user == null){
      FirebaseAuthUi.instance().launchAuth([AuthProvider.phone()]).then((value)async{
        context.read(userLogged).state = user;
        await checkLoginState(context, true, _globalKey);
      }).catchError((e){
        if(e is PlatformException)
          if(e.code == FirebaseAuthUi.kUserCancelledError)
            ScaffoldMessenger.of(_globalKey.currentContext).showSnackBar(SnackBar(content: Text("${e.message}")));
          else
            ScaffoldMessenger.of(_globalKey.currentContext).showSnackBar(SnackBar(content: Text("Error!!!")));
      });
    }else{

    }
  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin, GlobalKey<ScaffoldState> _globalKey) async{
    var user = FirebaseAuth.instance.currentUser;
    if(!context.read(forceReload).state){
      await Future.delayed(Duration(seconds:fromLogin == true ? 0 : 1)).then((value){
        user.getIdToken().then((token)async{
          context.read(userToken).state = token;


          //Cher user in FireStore
          CollectionReference reference = FirebaseFirestore.instance.collection("User");
          DocumentSnapshot snapshot = await reference.doc(FirebaseAuth.instance.currentUser.phoneNumber).get();

          //Force reload state
          context.read(forceReload).state = true;
          if(snapshot.exists){
            Navigator.push(context, MaterialPageRoute(builder: (_) => MainScreen()));
          }else{
            var nameController = TextEditingController();
            var addressController = TextEditingController();
            Alert(
                context: context,
                title: "Update profile",
                content: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.account_circle),
                          labelText: "Name"
                      ),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.home),
                          labelText: "Address"
                      ),
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(child: Text("Cancel"), onPressed:() => Navigator.pop(context)),
                  DialogButton(child: Text("Update"), onPressed:() {
                    reference.doc(FirebaseAuth.instance.currentUser.phoneNumber).set({
                      "name": nameController.text,
                      "address": addressController.text,
                    }).then((value) async{
                      Navigator.pop(context);
                      ScaffoldMessenger.of(_globalKey.currentContext).showSnackBar(SnackBar(content: Text("Update profile success!!")));
                      await Future.delayed(Duration(seconds: 1), (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MainScreen()));
                      });
                    }).catchError((e){
                      ScaffoldMessenger.of(_globalKey.currentContext).showSnackBar(SnackBar(content: Text("Error!!${e}")));
                    });
                  }),
                ]
            ).show();
          }
        });
      });
    }
    return user != null ? LOGIN_STATE.LOGGED : LOGIN_STATE.NOT_LOGIN;
  }
}