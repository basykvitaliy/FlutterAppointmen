
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_salon/model/ImageModel.dart';

final CollectionReference bannerCol = FirebaseFirestore.instance.collection("Banner");

Stream<List<ImageModel>> get getBannerList{
  return bannerCol.snapshots().map((imagemodel){
    return imagemodel.docs.map((e) => ImageModel.fromJson(e.data())).toList();
  });
}

Future bannerList()async{
  List<ImageModel> items = [];
  await bannerCol.get().then((value){
    value.docs.forEach((element) {
      items.add(ImageModel.fromJson(element.data()));
    });
  } );
  return items;
}