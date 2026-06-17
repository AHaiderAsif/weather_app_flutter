import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  WeatherModel? _weather;
  bool _isLoading = false;
  String _errorMessage = '';

  void _getWeather(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weatherData = await _weatherService.fetchWeather(cityName);
      setState(() {
        _weather = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found! Try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather('Islamabad');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]; // Deep Premium Slate
    IconData weatherIcon = Icons.wb_cloudy_rounded;
    Color iconColor = Colors.white;

    if (_weather != null) {
      String condition = _weather!.mainCondition.toLowerCase();
      if (condition.contains('clear') || condition.contains('sunny')) {
        gradientColors = [const Color(0xFFFF7E5F), const Color(0xFFFEB47B)];
        weatherIcon = Icons.wb_sunny_rounded;
        iconColor = const Color(0xFFFFE57F);
      } else if (condition.contains('rain') || condition.contains('drizzle') || condition.contains('thunderstorm')) {
        gradientColors = [const Color(0xFF141E30), const Color(0xFF243B55)];
        weatherIcon = Icons.thunderstorm_rounded;
        iconColor = Colors.cyanAccent;
      } else if (condition.contains('cloud')) {
        gradientColors = [const Color(0xFF1D2671), const Color(0xFFC33764)];
        weatherIcon = Icons.cloud_rounded;
        iconColor = Colors.white70;
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  //SEARCH BAR
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white.withAlpha(10),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Search city...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search_rounded, color: Colors.white),
                                onPressed: () {
                                  if (_searchController.text.trim().isNotEmpty) {
                                    _getWeather(_searchController.text.trim());
                                    _searchController.clear();
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // LOADING / ERROR HANDLING
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 150),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  else if (_weather != null) ...[

                      //WEATHER CARD
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _weather!.cityName,
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _weather!.mainCondition.toUpperCase(),
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
                                ),
                                const SizedBox(height: 30),

                                // GIANT ICON WITH SOFT GLOW SHADOW
                                Icon(
                                  weatherIcon,
                                  size: 130,
                                  color: iconColor,
                                ),

                                const SizedBox(height: 25),
                                Text(
                                  '${_weather!.temperature.toStringAsFixed(0)}°',
                                  style: const TextStyle(color: Colors.white, fontSize: 84, fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      //DASHBOARD
                      Row(
                        children: [
                          // WIND CARD
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.white.withAlpha(10),
                                child: Column(
                                  children: [
                                    const Icon(Icons.air_rounded, color: Colors.white70, size: 30),
                                    const SizedBox(height: 10),
                                    const Text('WIND', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('${_weather!.windSpeed} m/s', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // HUMIDITY CARD
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.white.withAlpha(10),
                                child: Column(
                                  children: [
                                    const Icon(Icons.water_drop_rounded, color: Colors.white70, size: 30),
                                    const SizedBox(height: 10),
                                    const Text('HUMIDITY', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('${_weather!.humidity}%', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}