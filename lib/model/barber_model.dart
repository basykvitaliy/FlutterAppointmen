import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel{
  String name;
  String docId;
  int ratingTimes;
  double rating;

  DocumentReference reference;

  BarberModel();

  BarberModel.fromJson(Map<String, dynamic> json){
    name = json["name"];
    docId = json["docId"];
    rating = double.parse(json["rating"] == null ? "0" : json["rating"].toString()) ;
    ratingTimes = int.parse(json["ratingTimes"] == null ? "0" : json["ratingTimes"].toString());
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["name"] = this.name;
    map["docId"] = this.docId;
    map["rating"] = this.rating;
    map["ratingTimes"] = this.ratingTimes;
    return map;
  }
}