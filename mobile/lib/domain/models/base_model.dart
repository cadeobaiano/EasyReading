abstract class BaseModel {
  String get id;
  Map<String, dynamic> toJson();
  
  BaseModel fromJson(Map<String, dynamic> json);
}
