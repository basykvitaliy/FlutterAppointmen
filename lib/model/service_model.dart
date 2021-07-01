class ServiceModel{
  String name;
  String docId;
  double price;

  ServiceModel({this.name, this.price});

  ServiceModel.fromJson(Map<String, dynamic> map){
    name = map["name"];
    price = map["price"] == null ? 0 : double.parse(map["price"].toString());
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["name"] = this.name;
    map["price"] = this.price;
    return map;
  }
}