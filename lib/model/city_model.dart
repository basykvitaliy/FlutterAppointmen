class CityModel{
  String name;

  CityModel({this.name});

  CityModel.fromJson(Map<String, dynamic> json){
    name = json["name"];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["name"] = this.name;
    return map;
  }
}