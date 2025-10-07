import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpMethodService {
  // Método GET
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  // Método POST
  static Future<http.Response> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  // Método PUT
  static Future<http.Response> put(String url, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  // Método DELETE
  static Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    final response = await http.delete(Uri.parse(url), headers: headers);
    return response;
  }
}
