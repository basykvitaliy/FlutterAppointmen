import 'package:cloud_firestore/cloud_firestore.dart';

class SalonModel{
  String name;
  String address;
  String docId;
  DocumentReference reference;

  SalonModel({this.name, this.address});

  SalonModel.fromJson(Map<String, dynamic> json){
    name = json["name"];
    address = json["address"];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["name"] = this.name;
    map["address"] = this.address;
    return map;
  }
}