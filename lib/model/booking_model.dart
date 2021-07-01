import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel{
  String docId;
  String barberId;
  String barberName;
  String cityBook;
  String customerName;
  String customerId;
  String customerPhone;
  String salonAddress;
  String salonId;
  String salonName;
  String time;
  String barberRating;
  bool done;
  int slot;
  int timeStamp;

  DocumentReference reference;

  BookingModel(
      {this.docId,
      this.barberId,
      this.barberName,
      this.cityBook,
      this.customerName,
      this.customerPhone,
      this.customerId,
      this.salonAddress,
      this.salonId,
      this.salonName,
      this.time,
      this.done,
      this.slot,
      this.timeStamp,
      this.barberRating});

  BookingModel.fromJson(Map<String, dynamic> json){
    docId = json["docId"];
    barberId = json["barberId"];
    cityBook = json["cityBook"];
    barberName = json["barberName"];
    customerName = json["customerName"];
    customerPhone = json["customerPhone"];
    customerId = json["customerId"];
    salonAddress = json["salonAddress"];
    salonId = json["salonId"];
    salonName = json["salonName"];
    done = json["done"];
    time = json["time"];
    barberRating = json["barberRating"];
    slot = int.parse(json["slot"] == null ? "-1" : json["slot"].toString());
    timeStamp = int.parse(json["timeStamp"] == null ? "0" : json["timeStamp"].toString());
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["docId"] = this.docId;
    map["barberId"] = this.barberId;
    map["cityBook"] = this.cityBook;
    map["barberName"] = this.barberName;
    map["customerName"] = this.customerName;
    map["customerPhone"] = this.customerPhone;
    map["customerId"] = this.customerId;
    map["salonAddress"] = this.salonAddress;
    map["salonId"] = this.salonId;
    map["salonName"] = this.salonName;
    map["done"] = this.done;
    map["time"] = this.time;
    map["slot"] = this.slot;
    map["barberRating"] = this.barberRating;
    map["timeStamp"] = this.timeStamp;
    return map;
  }
}