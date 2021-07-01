class ImageModel{
  String image;

  ImageModel({this.image});

  ImageModel.fromJson(Map<String, dynamic> json){
    image = json["image"];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> map = Map<String, dynamic>();
    map["image"] = this.image;
    return map;
  }
}