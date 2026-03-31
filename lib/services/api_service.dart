import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // // Hosted Server
  // static const String baseUrl = "https://pet-connect-server.onrender.com";

  // Local DB
  static const String baseUrl = "http://192.168.1.4:5000";

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /* ================= AUTH ================= */

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = "$baseUrl/auth/login";
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print("POST $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return {"status": res.statusCode, "data": jsonDecode(res.body)};
    } catch (e) {
      print("Exception during login: $e");
      rethrow;
    }
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    final url = "$baseUrl/auth/register";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      print("POST $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      return {
        "statusCode": response.statusCode,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      print("Exception during register: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    final url = "$baseUrl/users/$userId";
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print("PUT $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

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
    } catch (e) {
      print("Exception in updateProfile: $e");
      rethrow;
    }
  }

  /* ================= PETS ================= */

  static Future<List<dynamic>> getPets(int userId) async {
    final url = "$baseUrl/pets";
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load pets");
      }
    } catch (e) {
      print("Exception in getPets: $e");
      rethrow;
    }
  }

  static Future<void> addPet(Map<String, dynamic> data) async {
    final url = "$baseUrl/pets";
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print("POST $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("Failed to add pet");
      }
    } catch (e) {
      print("Exception in addPet: $e");
      rethrow;
    }
  }

  static Future<void> updatePet(int id, Map<String, dynamic> petData) async {
    final url = "$baseUrl/pets/$id";
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(petData),
      );
      print("PUT $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to update pet");
      }
    } catch (e) {
      print("Exception in updatePet: $e");
      rethrow;
    }
  }

  static Future<void> deletePet(int id) async {
    final url = "$baseUrl/pets/$id";
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse(url), headers: headers);
      print("DELETE $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("Failed to delete pet");
      }
    } catch (e) {
      print("Exception in deletePet: $e");
      rethrow;
    }
  }

  /* ================= BOOKINGS ================= */

  static Future<List<dynamic>> getBookings(int userId) async {
    final url = "$baseUrl/bookings";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Exception in getBookings: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> data,
  ) async {
    final url = "$baseUrl/bookings";
    try {
      final headers = await _getHeaders();
      final res = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      print("POST $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      return {"status": res.statusCode, "data": jsonDecode(res.body)};
    } catch (e) {
      print("Exception in createBooking: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getBookingsByOwner(int ownerId) async {
    final url = "$baseUrl/bookings";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load owner bookings");
      }
    } catch (e) {
      print("Exception in getBookingsByOwner: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getBookingsByProvider(int providerId) async {
    final url = "$baseUrl/bookings/provider/$providerId";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load provider bookings");
      }
    } catch (e) {
      print("Exception in getBookingsByProvider: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    final url = "$baseUrl/bookings/$bookingId/status";
    try {
      final headers = await _getHeaders();
      final res = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({"status": status.toUpperCase()}),
      );
      print("PATCH $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      if (res.statusCode == 200) {
        return {"status": res.statusCode, "data": jsonDecode(res.body)};
      } else {
        throw Exception("Failed to update booking status");
      }
    } catch (e) {
      print("Exception in updateBookingStatus: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    return await updateBookingStatus(bookingId, "REJECTED");
  }

  static Future<Map<String, dynamic>> updatePaymentStatus(
    int bookingId,
    String status,
  ) async {
    final url = "$baseUrl/api/bookings/$bookingId/status";
    try {
      final headers = await _getHeaders();
      final res = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({"payment_status": status.toUpperCase()}),
      );
      print("PATCH $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        return {"status": res.statusCode, "data": jsonDecode(res.body)};
      } else {
        throw Exception("Failed to update payment status");
      }
    } catch (e) {
      print("Exception in updatePaymentStatus: $e");
      rethrow;
    }
  }

  /* ================= DASHBOARD ================= */

  static Future<dynamic> getAdminDashboard() async {
    final url = "$baseUrl/dashboard/admin";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Exception in getAdminDashboard: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getProviders(String type) async {
    final url = "$baseUrl/providers?type=$type";
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load providers");
      }
    } catch (e) {
      print("Exception in getProviders: $e");
      rethrow;
    }
  }

  /* ================= VET DASHBOARD ================= */

  static Future<Map<String, dynamic>> getVetDashboard(int vetId) async {
    final url = '$baseUrl/vet/dashboard/$vetId';
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
      print("Exception in getVetDashboard: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getVetBookings(int vetId) async {
    final url = '$baseUrl/vet/bookings/$vetId';
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
      print("Exception in getVetBookings: $e");
      rethrow;
    }
  }

  static Future<void> saveVisitSummary(Map data) async {
    final url = '$baseUrl/vet/visit-summary';
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print("POST $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
    } catch (e) {
      print("Exception in saveVisitSummary: $e");
      rethrow;
    }
  }

  static Future<void> saveAvailability(Map data) async {
    final url = '$baseUrl/vet/availability';
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print("POST $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
    } catch (e) {
      print("Exception in saveAvailability: $e");
      rethrow;
    }
  }

  //      CARETAKER DASHBOARD
  static Future<Map<String, dynamic>> getCaretakerDashboard(
    int caretakerId,
  ) async {
    final url = "$baseUrl/providers/caretaker/$caretakerId";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load caretaker dashboard");
      }
    } catch (e) {
      print("Exception in getCaretakerDashboard: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getCaretakerBookings(int caretakerId) async {
    final url = "$baseUrl/bookings/caretaker/$caretakerId";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load caretaker bookings");
      }
    } catch (e) {
      print("Exception in getCaretakerBookings: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> postCaretakerReport(
    int caretakerId,
    Map<String, dynamic> data,
  ) async {
    final url = "$baseUrl/caretaker/$caretakerId/report";
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print("POST $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {"status": res.statusCode, "data": jsonDecode(res.body)};
      } else {
        throw Exception("Failed to submit report");
      }
    } catch (e) {
      print("Exception in postCaretakerReport: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateCaretakerAvailability(
    int caretakerId,
    Map<String, dynamic> data,
  ) async {
    final url = "$baseUrl/caretaker/$caretakerId/availability";
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print("PUT $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        return {"status": res.statusCode, "data": jsonDecode(res.body)};
      } else {
        throw Exception("Failed to update availability");
      }
    } catch (e) {
      print("Exception in updateCaretakerAvailability: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getCaretakerEarnings(int caretakerId) async {
    final url = "$baseUrl/caretaker/$caretakerId/earnings";
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load earnings");
      }
    } catch (e) {
      print("Exception in getCaretakerEarnings: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getCaretakerEmergencyBookings(
    int caretakerId,
  ) async {
    final url = "$baseUrl/bookings/caretaker/$caretakerId/emergency";
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load emergency bookings");
      }
    } catch (e) {
      print("Exception in getCaretakerEmergencyBookings: $e");
      rethrow;
    }
  }

  /* ================= ADMIN ================= */
  static Future<List<dynamic>> getAllBookings() async {
    final url = "$baseUrl/admin/bookings";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["data"];
      } else {
        throw Exception("Failed to load admin bookings");
      }
    } catch (e) {
      print("Exception in getAllBookings: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getUsers() async {
    final url = '$baseUrl/admin/users';
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
      print("Exception in getUsers: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getVets() async {
    final url = '$baseUrl/admin/vets';
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
      print("Exception in getVets: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getCaretakers() async {
    final url = '$baseUrl/admin/caretakers';
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
      print("Exception in getCaretakers: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getPayments() async {
    final url = '$baseUrl/admin/payments';
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      print("GET $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
      print("Exception in getPayments: $e");
      rethrow;
    }
  }

  static Future<void> verifyUser(int id) async {
    final url = '$baseUrl/admin/verify/$id';
    try {
      final headers = await _getHeaders();
      final res = await http.patch(Uri.parse(url), headers: headers);
      print("PATCH $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
    } catch (e) {
      print("Exception in verifyUser: $e");
      rethrow;
    }
  }

  static Future<void> rejectUser(int id) async {
    final url = '$baseUrl/admin/reject/$id';
    try {
      final headers = await _getHeaders();
      final res = await http.patch(Uri.parse(url), headers: headers);
      print("PATCH $url | Status: ${res.statusCode}");
      print("Response Body: ${res.body}");
    } catch (e) {
      print("Exception in rejectUser: $e");
      rethrow;
    }
  }
}
