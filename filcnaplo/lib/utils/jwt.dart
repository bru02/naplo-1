import 'dart:convert';

import 'package:filcnaplo/models/user.dart';

class JwtUtils {
  static Map? decodeJwt(String jwt) {
    var parts = jwt.split(".");
    if (parts.length != 3) return null;

    if (parts[1].length % 4 == 2) {
      parts[1] += "==";
    } else if (parts[1].length % 4 == 3) {
      parts[1] += "=";
    }

    try {
      var payload = utf8.decode(base64Url.decode(parts[1]));
      return jsonDecode(payload);
    } catch (error) {
      print("ERROR: JwtUtils.decodeJwt: $error");
    }
  }

  static String? getNameFromJWT(String jwt) {
    var jwtData = decodeJwt(jwt);
    return jwtData?["name"];
  }

  static Role? getRoleFromJWT(String jwt) {
    var jwtData = decodeJwt(jwt);

    switch (jwtData?["role"]) {
      case "Tanulo":
        return Role.student;
      case "Gondviselo":
        return Role.parent;
    }
  }
}
