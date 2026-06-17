import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// 🚀 LOGIC: This service handles all background network communication with OpenWeatherMap
class WeatherService {
  // Base URL of the API (Fixed internet address)
  static const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // 🔥 LOGIC: Your active OpenWeatherMap API Key successfully integrated here
  final String apiKey = 'da37d14371233a3a261864050ff60889';

  // 🚀 ASYNC LOGIC: Fetch weather data from internet without freezing the mobile UI
  Future<WeatherModel> fetchWeather(String cityName) async {

    // 1. Create the final URL with city name, API key, and metric units (for Celsius)
    final url = '$baseUrl?q=$cityName&appid=$apiKey&units=metric';

    // 2. Send the HTTP GET request to the internet and wait for response
    final response = await http.get(Uri.parse(url));

    // 3. LOGIC: Check if the server status code is 200 (Success)
    if (response.statusCode == 200) {
      // jsonDecode converts raw text data into a readable Dart Map object
      final Map<String, dynamic> rawData = jsonDecode(response.body);

      // Pass the raw map to our Chips Factory to get a beautiful clean WeatherModel packet
      return WeatherModel.fromJson(rawData);
    } else {
      // If status code is not 200 (like 404 city not found), throw an error message
      throw Exception('Failed to load weather data. Status: ${response.statusCode}');
    }
  }
}