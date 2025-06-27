class ApiRoutes {
  // Base url
  static const String baseUrl = 'https://3e7a-223-185-28-250.ngrok-free.app';

  // Style Analyze routes
  static const String manualAnalyze = '${baseUrl}/api/analyze/manual';
  static const String hybridAnalyze = '${baseUrl}/api/analyze/hybrid';
  static const String autoAnalyze = '${baseUrl}/api/analyze/auto';
  static const String imageCheck = '${baseUrl}/api/checkimage';

  //Auth routes
  static const String userRegistration = '${baseUrl}/api/users/register';
  static const String userLogin = '${baseUrl}/api/users/login';
  static const String userLogout = '${baseUrl}/api/users/logout';
  static const String userProfile = '${baseUrl}/api/users/profile';
  static const String userChangePassword =
      '${baseUrl}/api/users/change_password';
  static const String userUpdateProfile = '${baseUrl}/api/users/update_profile';
  static const String userRefreshToken = '${baseUrl}/api/users/refresh_token';

  // Event routes
  static const String addEvent = '$baseUrl/api/events/addEvent';
  static const String getUpcomingEvents =
      '$baseUrl/api/events/getUpcomingEvents';
  static const String getCollection = '$baseUrl/api/events/getCollection';
  static const String getEventDetails = '$baseUrl/api/events/getEventDetails';
  static const String updateEvent = '$baseUrl/api/events/updateEvent';
  static const String deleteEvent = '$baseUrl/api/events/deleteEvent';

  //digital wardrobe routes
  static const String addGarments = '${baseUrl}/api/wardrobe/addToWardrobe';
  static const String addGarmentsByCategory =
      '${baseUrl}/api/wardrobe/addTowardrobeByCategory';
  static const String getGarmentsByCategory =
      '${baseUrl}/api/wardrobe/garments/category';
  static const String getCategoryCounts =
      '${baseUrl}/api/wardrobe/categoryCounts';
  static const String getGarmentDetails = '${baseUrl}/api/wardrobe/getDetails';
  static const String deleteGarment = '${baseUrl}/api/wardrobe/deleteGarment';
  static const String filterGarments = '${baseUrl}/api/wardrobe/filterGarments';

  // styling routes
  static const String getStyledOutfits =
      '${baseUrl}/api/styling/generateForOccasion';
  static const String getStyleRecommender = '${baseUrl}/api/styleRecommender';

  // other routes
  static const String product = '${baseUrl}/api/products';
  static const String generateImageOcassionWise = '${baseUrl}/generate_image';
}
