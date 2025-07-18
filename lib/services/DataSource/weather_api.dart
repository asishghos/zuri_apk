// weather_season_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherApiService {
  // Constants for seasons
  static const String WINTER = 'Winter';
  static const String SPRING = 'Spring';
  static const String SUMMER = 'Summer';
  static const String AUTUMN = 'Autumn';

  // Constants for hemispheres
  static const String NORTHERN = 'Northern';
  static const String SOUTHERN = 'Southern';

  /// Fetches current weather data from Open-Meteo API
  Future<Map<String, dynamic>> fetchWeatherData({
    required double latitude,
    required double longitude,
    String temperatureUnit = 'celsius',
    String timezone = 'auto',
  }) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,weather_code'
      '&daily=temperature_2m_max,temperature_2m_min'
      '&temperature_unit=$temperatureUnit'
      '&timezone=$timezone',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  /// Determines hemisphere based on latitude
  String determineHemisphere(double latitude) {
    return latitude >= 0 ? NORTHERN : SOUTHERN;
  }

  /// Determines season based on date, hemisphere and optionally weather data
  String determineSeason({
    required DateTime date,
    required String hemisphere,
    Map<String, dynamic>? weatherData,
  }) {
    // Get month and day for astronomical season calculation
    final month = date.month;
    final day = date.day;

    // Base season on astronomical dates
    String astronomicalSeason = _getAstronomicalSeason(month, day, hemisphere);

    // If no weather data is provided, return astronomical season
    if (weatherData == null) {
      return astronomicalSeason;
    }

    // Refine the season using weather data if available
    return _refineSeasonWithWeatherData(astronomicalSeason, weatherData);
  }

  /// Gets season based purely on astronomical dates
  String _getAstronomicalSeason(int month, int day, String hemisphere) {
    // Define season by month and day
    if (hemisphere == NORTHERN) {
      // Northern Hemisphere seasons
      if ((month == 12 && day >= 21) ||
          month <= 2 ||
          (month == 3 && day < 20)) {
        return WINTER;
      } else if ((month == 3 && day >= 20) ||
          month <= 5 ||
          (month == 6 && day < 21)) {
        return SPRING;
      } else if ((month == 6 && day >= 21) ||
          month <= 8 ||
          (month == 9 && day < 22)) {
        return SUMMER;
      } else {
        return AUTUMN;
      }
    } else {
      // Southern Hemisphere seasons (reversed)
      if ((month == 12 && day >= 21) ||
          month <= 2 ||
          (month == 3 && day < 20)) {
        return SUMMER;
      } else if ((month == 3 && day >= 20) ||
          month <= 5 ||
          (month == 6 && day < 21)) {
        return AUTUMN;
      } else if ((month == 6 && day >= 21) ||
          month <= 8 ||
          (month == 9 && day < 22)) {
        return WINTER;
      } else {
        return SPRING;
      }
    }
  }

  /// Refines season determination using actual weather data
  String _refineSeasonWithWeatherData(
    String astronomicalSeason,
    Map<String, dynamic> weatherData,
  ) {
    // Extract weather code and temperature
    final int weatherCode = weatherData['current']['weather_code'];
    final double currentTemp = weatherData['current']['temperature_2m'];

    // Weather codes for snow conditions
    final List<int> snowCodes = [71, 73, 75, 77, 85, 86];

    // Adjust season based on weather conditions
    if (snowCodes.contains(weatherCode)) {
      // If there's snow, it's likely winter regardless of the date
      return WINTER;
    }

    // Temperature-based season adjustments for edge cases
    switch (astronomicalSeason) {
      case SPRING:
        // If it's spring but very cold, could still be winter
        if (currentTemp < 5) {
          return WINTER;
        }
        // If it's spring but very hot, could be early summer
        if (currentTemp > 25) {
          return SUMMER;
        }
        break;

      case AUTUMN:
        // If it's autumn but very cold, could be early winter
        if (currentTemp < 5) {
          return WINTER;
        }
        // If it's autumn but very hot, could be late summer
        if (currentTemp > 25) {
          return SUMMER;
        }
        break;

      case WINTER:
        // If it's winter but very warm, could be early spring
        if (currentTemp > 15) {
          return SPRING;
        }
        break;

      case SUMMER:
        // If it's summer but not very warm, could be late spring
        if (currentTemp < 15) {
          return SPRING;
        }
        break;
    }

    // If no adjustment, return the astronomical season
    return astronomicalSeason;
  }

  /// Gets weather description from weather code
  String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return "Clear sky";
      case 1:
        return "Mainly clear";
      case 2:
        return "Partly cloudy";
      case 3:
        return "Overcast";
      case 45:
      case 48:
        return "Foggy";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 56:
      case 57:
        return "Freezing drizzle";
      case 61:
        return "Light rain";
      case 63:
        return "Moderate rain";
      case 65:
        return "Heavy rain";
      case 66:
      case 67:
        return "Freezing rain";
      case 71:
        return "Light snow";
      case 73:
        return "Moderate snow";
      case 75:
        return "Heavy snow";
      case 77:
        return "Snow grains";
      case 80:
      case 81:
      case 82:
        return "Rain showers";
      case 85:
      case 86:
        return "Snow showers";
      case 95:
      case 96:
      case 99:
        return "Thunderstorm";
      default:
        return "Unknown weather condition";
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get place information from coordinates
  Future<List<String>> getPlaceFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return [
          place.locality ?? '',
          place.administrativeArea ?? '',
          place.country ?? '',
        ];
      }
      return ['', '', ''];
    } catch (e) {
      throw Exception('Failed to get place information: $e');
    }
  }

  /// Get formatted location string
  String getFormattedLocation(List<String> locationData) {
    if (locationData.isEmpty) return "Location unavailable";

    String city = locationData.length > 0 && locationData[0].isNotEmpty
        ? locationData[0]
        : "";
    String region = locationData.length > 1 && locationData[1].isNotEmpty
        ? locationData[1]
        : "";
    String country = locationData.length > 2 && locationData[2].isNotEmpty
        ? locationData[2]
        : "";

    if (city.isNotEmpty && country.isNotEmpty) {
      return "$city, $country";
    } else if (region.isNotEmpty && country.isNotEmpty) {
      return "$region, $country";
    } else {
      return country.isNotEmpty ? country : "Location unavailable";
    }
  }

  /// Get complete weather and location data
  Future<WeatherLocationData> getCompleteWeatherData() async {
    try {
      // Get current position
      final position = await getCurrentPosition();

      // Fetch weather data
      final weatherData = await fetchWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Determine season
      final hemisphere = determineHemisphere(position.latitude);
      final season = determineSeason(
        date: DateTime.now(),
        hemisphere: hemisphere,
        weatherData: weatherData,
      );

      // Get location data
      final locationData = await getPlaceFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return WeatherLocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        weatherData: weatherData,
        season: season,
        hemisphere: hemisphere,
        locationData: locationData,
        formattedLocation: getFormattedLocation(locationData),
      );
    } catch (e) {
      throw Exception('Failed to get complete weather data: $e');
    }
  }
}

/// Data class to hold weather and location information
class WeatherLocationData {
  final double latitude;
  final double longitude;
  final Map<String, dynamic> weatherData;
  final String season;
  final String hemisphere;
  final List<String> locationData;
  final String formattedLocation;

  WeatherLocationData({
    required this.latitude,
    required this.longitude,
    required this.weatherData,
    required this.season,
    required this.hemisphere,
    required this.locationData,
    required this.formattedLocation,
  });

  // Convenience getters
  double get currentTemperature =>
      weatherData['current']['temperature_2m']?.toDouble() ?? 0.0;

  int get weatherCode => weatherData['current']['weather_code']?.toInt() ?? 0;

  String get weatherDescription {
    final service = WeatherApiService();
    return service.getWeatherDescription(weatherCode);
  }
}
