import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/DataSource/weather_api.dart';

class LocationPage extends StatefulWidget {
  LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final WeatherApiService _weatherService = WeatherApiService();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  WeatherLocationData? _weatherData;

  bool _isLoading = false;
  Future<void> loadWeatherData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Request permission first
      final hasPermission = await _weatherService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      // Check if location services are enabled
      final isServiceEnabled = await _weatherService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        _showLocationSettingsDialog();
        return;
      }
      // Get complete weather data
      final weatherData = await _weatherService.getCompleteWeatherData();
      // ResultCache.seasonData = weatherData.season;
      // ResultCache.loactiondata = weatherData.locationData;
      prefs.setString('seasonData', weatherData.season);
      prefs.setStringList('loactiondata', weatherData.locationData);
      Developer.log(weatherData.locationData[0]);
      setState(() {
        _weatherData = weatherData;
        // ResultCache.resultWeather = weatherData;
        _isLoading = false;
      });
      // print(_weatherData);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // if (widget.onLocationError != null) {
      //   widget.onLocationError!();
      // }
      debugPrint("Error loading weather data: $e");
    }
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Disabled'),
        content: const Text(
          'Please enable location services to get weather information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),
              Text(
                'Enable Location',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(24),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),

              // Subtitle
              RichText(
                text: TextSpan(
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    color: AppColors.titleTextColor,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Zuri channels your main character energy best when she knows your co-ords! ',
                    ),
                    TextSpan(
                      text: '📍',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(18),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.036613272,
              ),

              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19.29),
                  child: Image.asset("assets/images/location/l1.png"),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.036613272,
              ),

              // Description text
              Text(
                'See styles that match your current city\'s \nweather, vibe, festivals, & more.',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  color: AppColors.titleTextColor,
                  height: 1.4,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),

              Text(
                'Style it up. Live it loud. Own your city.',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  color: AppColors.titleTextColor,
                  height: 1.4,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.0549199),

              // Enable Location button
              GlobalPinkButton(
                text: "Enable Location",
                onPressed: () {
                  loadWeatherData();
                  context.goNamed("home");
                },
                rightIcon: true,
                rightIconData: IconlyLight.arrowRight2,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),

              // Maybe Later button
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.06407322,
                child: TextButton(
                  onPressed: () {
                    context.goNamed("home");
                  },
                  child: Text(
                    'Maybe Later',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: AppColors.titleTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
