class ApiRoutes {
  // Base url
  static const String baseUrl = 'https://39a87e430fc4.ngrok-free.app';

  // Style Analyze routes
  static const String manualAnalyze = '${baseUrl}/api/analyze/manual';
  static const String hybridAnalyze = '${baseUrl}/api/analyze/hybrid';
  static const String autoAnalyze = '${baseUrl}/api/analyze/auto';
  static const String imageCheck = '${baseUrl}/api/analyze/checkimage';

  //Auth routes
  static const String userRegistration = '${baseUrl}/api/users/register';
  static const String userLogin = '${baseUrl}/api/users/login';
  static const String userLogout = '${baseUrl}/api/users/logout';
  static const String userProfile = '${baseUrl}/api/users/profile';
  static const String userRefreshToken = '${baseUrl}/api/users/refresh_token';
  static const String forgotPassword = '${baseUrl}/api/users/forgotPassword';
  static const String resetPassword = '${baseUrl}/api/users/resetPassword';
  static const String verifyRecoveryCode =
      '${baseUrl}/api/users/verifyRecoveryCode';
  static const String getUserProfile = '${baseUrl}/api/users/profile';
  static const String updateUserProfile = '${baseUrl}/api/users/updateProfile';
  static const String changeUserPassword =
      '${baseUrl}/api/users/changeUserPassword';

  // Event routes
  static const String addEvent = '$baseUrl/api/events/addEvent';
  static const String getUpcomingEvents =
      '$baseUrl/api/events/getUpcomingEvents';
  static const String getCollection = '$baseUrl/api/events/getCollection';
  static const String getEventDetails = '$baseUrl/api/events/getEventDetails';
  static const String updateEvent = '$baseUrl/api/events/updateEvent';
  static const String deleteEvent = '$baseUrl/api/events/deleteEvent';
  static const String styleToEvent =
      '$baseUrl/api/styleToEvent/addImageToEvent';

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
  static const String updateGarment = '${baseUrl}/api/wardrobe/updateGarment';
  static const String filterGarments = '${baseUrl}/api/wardrobe/filterGarments';

  // styling routes
  static const String getStyledOutfits =
      '${baseUrl}/api/styling/generateForOccasion';
  static const String getStyleRecommender = '${baseUrl}/api/styleRecommender';

  //Saved Fav Looks routes
  static const String addFavouriteSavedFavourites =
      '${baseUrl}/api/savedFavourites/addFavourite';
  static const String getFavouritesSavedFavourites =
      '${baseUrl}/api/savedFavourites/getFavourites';
  static const String deleteFavouriteSavedFavourites =
      '${baseUrl}/api/savedFavourites/deleteFavourite';

  // Zuri Magazine routes
  static const String getAllCategories =
      '${baseUrl}/api/magazine/allCategories';
  static const String getByCategoryMagazine =
      '${baseUrl}/api/magazine/articlesByCategory';
  static const String getByIdMagazine = '${baseUrl}/api/magazine/article';
  static const String toggleBookmarkMagazine =
      '${baseUrl}/api/magazine/toggleBookmark';
  static const String getBookmarksMagazine =
      '${baseUrl}/api/magazine/getBookmarks';
  static const String allMagazine = '${baseUrl}/api/magazine/allArticles';

  // Uploaded Look routes
  static const String addUploadedLooks = '${baseUrl}/api/uploadedLooks/addLook';
  static const String getUploadedLooks =
      '${baseUrl}/api/uploadedLooks/getLooks';
  static const String getUploadedLookById = '${baseUrl}/api/uploadedLooks/look';
  static const String deleteUploadedLook =
      '${baseUrl}/api/uploadedLooks/deleteLook';

  // Product routes
  static const String product = '${baseUrl}/api/products';
  static const String addProductsWishList = '${baseUrl}/api/wishList/add';
  static const String getProductsWishList = '${baseUrl}/api/wishList/get';
}
