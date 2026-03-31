import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://pet-connect-server.onrender.com";
  // use this for Android emulator
  // for real device: use your PC IP

  /* ================= AUTH ================= */

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return {"status": res.statusCode, "data": jsonDecode(res.body)};
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

  static Future<Map<String, dynamic>> updateProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      // Backend might return empty body on 204
      var responseData = {};
      try {
        responseData = jsonDecode(res.body);
      } catch (_) {}
      return {"status": res.statusCode, "data": responseData};
    } else {
      throw Exception("Failed to update profile");
    }
  }

  /* ================= PETS ================= */

  static Future<List<dynamic>> getPets(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/pets/$userId"));

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

  static Future<void> updatePet(int id, Map<String, dynamic> petData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/pets/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(petData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update pet");
    }
  }

  static Future<void> deletePet(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/pets/$id"));

    if (res.statusCode != 200) {
      throw Exception("Failed to delete pet");
    }
  }

  /* ================= BOOKINGS ================= */

  static Future<List<dynamic>> getBookings(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/bookings/$userId"));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> data,
  ) async {
    final res = await http
        .post(
          Uri.parse("$baseUrl/api/bookings"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        )
        .timeout(Duration(seconds: 15));

    print("res.body ${res.body}");

    return {"status": res.statusCode, "data": jsonDecode(res.body)};
  }

  static Future<List<dynamic>> getBookingsByOwner(int ownerId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/bookings/owner/$ownerId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load owner bookings");
    }
  }

  static Future<List<dynamic>> getBookingsByProvider(int providerId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/bookings/provider/$providerId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load provider bookings");
    }
  }

  static Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/api/bookings/$bookingId/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status.toUpperCase()}),
    );
    if (res.statusCode == 200) {
      return {"status": res.statusCode, "data": jsonDecode(res.body)};
    } else {
      throw Exception("Failed to update booking status");
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    return await updateBookingStatus(bookingId, "REJECTED");
  }

  static Future<Map<String, dynamic>> updatePaymentStatus(
    int bookingId,
    String status,
  ) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/api/bookings/$bookingId/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"payment_status": status.toUpperCase()}),
    );

    if (res.statusCode == 200) {
      return {"status": res.statusCode, "data": jsonDecode(res.body)};
    } else {
      throw Exception("Failed to update payment status");
    }
  }

  /* ================= DASHBOARD ================= */

  static Future<dynamic> getAdminDashboard() async {
    final response = await http.get(Uri.parse("$baseUrl/dashboard/admin"));

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getProviders(String type) async {
    final url = Uri.parse("$baseUrl/api/providers?type=$type");

    // call API with 3 sec timeout
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      print("response.body ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Failed to load providers with status code ${response.statusCode}");
      print("response.body ${response.body}");
      throw Exception("Failed to load providers");
    }
  }

  /* ================= VET DASHBOARD ================= */

  static Future<Map<String, dynamic>> getVetDashboard(int vetId) async {
    final res = await http.get(Uri.parse('$baseUrl/vet/dashboard/$vetId'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getVetBookings(int vetId) async {
    final res = await http.get(Uri.parse('$baseUrl/vet/bookings/$vetId'));
    return jsonDecode(res.body);
  }

  static Future<void> saveVisitSummary(Map data) async {
    await http.post(
      Uri.parse('$baseUrl/vet/visit-summary'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<void> saveAvailability(Map data) async {
    await http.post(
      Uri.parse('$baseUrl/vet/availability'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  //      CARETAKER DASHBOARD
  static Future<Map<String, dynamic>> getCaretakerDashboard(
    int caretakerId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/caretaker/$caretakerId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load caretaker dashboard");
    }
  }

  static Future<List<dynamic>> getCaretakerBookings(int caretakerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/bookings/caretaker/$caretakerId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load caretaker bookings");
    }
  }

  static Future<Map<String, dynamic>> postCaretakerReport(
    int caretakerId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/caretaker/$caretakerId/report"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {"status": res.statusCode, "data": jsonDecode(res.body)};
    } else {
      throw Exception("Failed to submit report");
    }
  }

  static Future<Map<String, dynamic>> updateCaretakerAvailability(
    int caretakerId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/caretaker/$caretakerId/availability"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {
      return {"status": res.statusCode, "data": jsonDecode(res.body)};
    } else {
      throw Exception("Failed to update availability");
    }
  }

  static Future<List<dynamic>> getCaretakerEarnings(int caretakerId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/caretaker/$caretakerId/earnings"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load earnings");
    }
  }

  static Future<List<dynamic>> getCaretakerEmergencyBookings(
    int caretakerId,
  ) async {
    final res = await http.get(
      Uri.parse("$baseUrl/bookings/caretaker/$caretakerId/emergency"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load emergency bookings");
    }
  }

  /* ================= ADMIN ================= */
  static Future<List<dynamic>> getAllBookings() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/bookings"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    } else {
      throw Exception("Failed to load admin bookings");
    }
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/users'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getVets() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/vets'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getCaretakers() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/caretakers'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getPayments() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/payments'));
    return jsonDecode(res.body);
  }

  static Future<void> verifyUser(int id) async {
    await http.patch(Uri.parse('$baseUrl/admin/verify/$id'));
  }

  static Future<void> rejectUser(int id) async {
    await http.patch(Uri.parse('$baseUrl/admin/reject/$id'));
  }
}
