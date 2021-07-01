import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_salon/model/ImageModel.dart';

final CollectionReference lookBookCol = FirebaseFirestore.instance.collection("LookBook");

Stream<List<ImageModel>> get getLookbookList{
  return lookBookCol.snapshots().map((imagemodel){
    return imagemodel.docs.map((e) => ImageModel.fromJson(e.data())).toList();
  });
}

Future lookbookList()async{
  List<ImageModel> items = [];
  await lookBookCol.get().then((value){
    value.docs.forEach((element) {
      items.add(ImageModel.fromJson(element.data()));
    });
  } );
  return items;
}