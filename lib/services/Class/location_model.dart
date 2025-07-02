// 1. Replace the hardcoded list with these data structures at the top of your class:

class LocationData {
  final String country;
  final List<StateData> states;

  LocationData({required this.country, required this.states});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      country: json['country'],
      states: (json['states'] as List)
          .map((state) => StateData.fromJson(state))
          .toList(),
    );
  }
}

class StateData {
  final int id;
  final String name;
  final String stateCode;
  final String type;
  final List<CityData> cities;

  StateData({
    required this.id,
    required this.name,
    required this.stateCode,
    required this.type,
    required this.cities,
  });

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      id: json['id'],
      name: json['name'],
      stateCode: json['state_code'],
      type: json['type'],
      cities: (json['cities'] as List)
          .map((city) => CityData.fromJson(city))
          .toList(),
    );
  }
}

class CityData {
  final int id;
  final String name;
  final String latitude;
  final String longitude;

  CityData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
