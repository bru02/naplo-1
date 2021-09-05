import 'dart:convert';

import 'package:filcnaplo/models/config.dart';
import 'package:filcnaplo/models/news.dart';
import 'package:filcnaplo/models/release.dart';
import 'package:filcnaplo/models/supporter.dart';
import 'package:filcnaplo_kreta_api/models/school.dart';
import 'package:http/http.dart' as http;

class FilcAPI {
  static const SCHOOL_LIST = "https://filcnaplo.hu/v2/school_list.json";
  static const CONFIG = "https://filcnaplo.hu/v2/config.json";
  static const NEWS = "https://filcnaplo.hu/v2/news.json";
  static const SUPPORTERS = "https://filcnaplo.hu/v2/supporters.json";
  static const REPO = "filc/naplo";
  static const RELEASES = "https://api.github.com/repos/$REPO/releases";

  static Future<List<School>?> getSchools() async {
    try {
      http.Response res = await http.get(Uri.parse(SCHOOL_LIST));

      if (res.statusCode == 200) {
        List<School> schools = (jsonDecode(res.body) as List).cast<Map>().map((json) => School.fromJson(json)).toList();
        schools.add(School(
          city: "Tiszabura",
          instituteCode: "supporttest-reni-tiszabura-teszt01",
          name: "FILC Éles Reni tiszabura-teszt",
        ));
        return schools;
      } else {
        throw "HTTP ${res.statusCode}: ${res.body}";
      }
    } catch (error) {
      print("ERROR: FilcAPI.getSchools: $error");
    }
  }

  static Future<Config?> getConfig() async {
    try {
      http.Response res = await http.get(Uri.parse(CONFIG));

      if (res.statusCode == 200) {
        return Config.fromJson(jsonDecode(res.body));
      } else {
        throw "HTTP ${res.statusCode}: ${res.body}";
      }
    } catch (error) {
      print("ERROR: FilcAPI.getConfig: $error");
    }
  }

  static Future<List<News>?> getNews() async {
    try {
      http.Response res = await http.get(Uri.parse(NEWS));

      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List).cast<Map>().map((e) => News.fromJson(e)).toList();
      } else {
        throw "HTTP ${res.statusCode}: ${res.body}";
      }
    } catch (error) {
      print("ERROR: FilcAPI.getNews: $error");
    }
  }

  static Future<Supporters?> getSupporters() async {
    try {
      http.Response res = await http.get(Uri.parse(SUPPORTERS));

      if (res.statusCode == 200) {
        return Supporters.fromJson(jsonDecode(res.body));
      } else {
        throw "HTTP ${res.statusCode}: ${res.body}";
      }
    } catch (error) {
      print("ERROR: FilcAPI.getSupporters: $error");
    }
  }

  static Future<List<Release>?> getReleases() async {
    try {
      http.Response res = await http.get(Uri.parse(RELEASES));

      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List).cast<Map>().map((e) => Release.fromJson(e)).toList();
      } else {
        throw "HTTP ${res.statusCode}: ${res.body}";
      }
    } catch (error) {
      print("ERROR: FilcAPI.getReleases: $error");
    }
  }

  static Future<http.StreamedResponse?> downloadRelease(Release release) {
    if (release.downloads.length > 0) {
      try {
        var client = http.Client();
        var request = http.Request('GET', Uri.parse(release.downloads.first));
        return client.send(request);
      } catch (error) {
        print("ERROR: FilcAPI.downloadRelease: $error");
      }
    }

    return Future.value(null);
  }
}
