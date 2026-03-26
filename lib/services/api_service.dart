import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://pet-connect-server.onrender.com";
  // use this for Android emulator
  // for real device: use your PC IP

  /* ================= AUTH ================= */

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return {
      "status": res.statusCode,
      "data": jsonDecode(res.body),
    };
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return {
      "statusCode": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }
  /* ================= PETS ================= */

  static Future<List<dynamic>> getPets(int userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/pets/$userId"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load pets");
    }
  }

  static Future<void> addPet(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/pets"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("res.body ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add pet");
    }
  }

  static Future<void> deletePet(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/pets/$id"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to delete pet");
    }
  }

  /* ================= BOOKINGS ================= */

  static Future<List<dynamic>> getBookings(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/bookings/$userId"),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/bookings"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    ).timeout(Duration(seconds: 15));

    print("res.body ${res.body}");

    return {
      "status": res.statusCode,
      "data": jsonDecode(res.body),
    };
  }

  /* ================= DASHBOARD ================= */

  static Future<dynamic> getAdminDashboard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/admin"),
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getProviders(String type) async {
    final url = Uri.parse("$baseUrl/api/providers?type=$type");

    // call API with 3 sec timeout
    final response = await http.get(url,
    headers: {
      "Content-Type": "application/json",
    },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      print("response.body ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Failed to load providers with status code ${response.statusCode}");
      print("response.body ${response.body}");
      throw Exception("Failed to load providers");
    }
  }

}