// lib/core/services/plugin_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PluginService {
  Future<String> fetchHealthData(String metric, String format) async {
    try {
      final response = await http.get(Uri.parse("https://api.example.com/$metric?format=$format"));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData.toString();
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (error) {
      return "Failed to fetch data: $error";
    }
  }
}