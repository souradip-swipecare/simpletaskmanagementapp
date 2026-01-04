import 'package:taskmanagementsouradip/domains/enums/enums.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String password;
  final String lattitude;
  final String longitude;

  User(this.id, this.email,this.name, this.role, this.password,this.lattitude,this.longitude);
}
