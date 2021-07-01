class UserModel{
  String name;
  String address;
  bool isStaff;

  UserModel({this.isStaff, this.name, this.address});

  UserModel.fromJson(Map<String, dynamic> map){
    name = map["name"];
    address = map["address"];
    isStaff = map["isStaff"] == null ? false : map["isStaff"] as bool;
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["name"] = this.name;
    map["address"] = this.address;
    map["isStaff"] = this.isStaff;
    return map;
  }
}