// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/api_routes.dart';

class AuthApiService {
  // Helper method to get headers with auth token
  static Future<Map<String, String>> getHeaders({
    bool includeAuth = false,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (includeAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Helper method to save tokens
  static Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    Developer.log(
      'Tokens saved - Access: ${accessToken.substring(0, 20)}..., Refresh: ${refreshToken.substring(0, 20)}...',
    );
  }

  // Helper method to clear tokens
  static Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    Developer.log('All tokens cleared from storage');
  }

  // Improved token extraction from cookies
  static Map<String, String> _extractTokensFromCookies(
    Map<String, String> headers,
  ) {
    Map<String, String> tokens = {};

    Developer.log('Response headers: $headers');

    // Check different possible cookie header names
    String? setCookieHeader =
        headers['set-cookie'] ?? headers['Set-Cookie'] ?? headers['SET-COOKIE'];

    if (setCookieHeader != null) {
      Developer.log('Set-Cookie header found: $setCookieHeader');

      // Split cookies by comma, but be careful of commas in dates
      List<String> cookies = [];
      List<String> parts = setCookieHeader.split(',');

      for (int i = 0; i < parts.length; i++) {
        String part = parts[i].trim();
        // If this part doesn't contain '=' it's likely part of a date
        if (!part.contains('=') && cookies.isNotEmpty) {
          cookies[cookies.length - 1] += ',$part';
        } else {
          cookies.add(part);
        }
      }

      for (String cookie in cookies) {
        // Extract key-value pair (before first semicolon)
        String cookiePair = cookie.split(';')[0].trim();
        List<String> keyValue = cookiePair.split('=');

        if (keyValue.length >= 2) {
          String key = keyValue[0].trim();
          String value = keyValue
              .sublist(1)
              .join('=')
              .trim(); // Handle values with '='

          Developer.log(
            'Cookie found - Key: $key, Value: ${value.length > 20 ? '${value.substring(0, 20)}...' : value}',
          );

          if (key == 'accessToken' || key == 'access_token') {
            tokens['accessToken'] = value;
          } else if (key == 'refreshToken' || key == 'refresh_token') {
            tokens['refreshToken'] = value;
          }
        }
      }
    } else {
      Developer.log('No Set-Cookie header found in response');
    }

    Developer.log('Extracted tokens: ${tokens.keys.toList()}');
    return tokens;
  }

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiRoutes.userRegistration),
        headers: await getHeaders(),
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      Developer.log('Registration response: $data');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'msg': data['msg'] ?? 'User registered successfully',
          'user': data['data'],
        };
      } else {
        return {'success': false, 'msg': data['msg'] ?? 'Registration failed'};
      }
    } catch (e) {
      Developer.log('Registration error: $e');
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Login user - Enhanced with better token handling
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Developer.log('Attempting login for email: $email');

      final response = await http.post(
        Uri.parse(ApiRoutes.userLogin),
        headers: await getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      Developer.log('Login response status: ${response.statusCode}');
      final data = jsonDecode(response.body);
      Developer.log('Login response data: $data');

      if (response.statusCode == 200) {
        // Try to extract tokens from cookies first
        final cookieTokens = _extractTokensFromCookies(response.headers);

        // Also check if tokens are in the response body
        Map<String, String> bodyTokens = {};
        if (data['accessToken'] != null) {
          bodyTokens['accessToken'] = data['accessToken'];
        }
        if (data['refreshToken'] != null) {
          bodyTokens['refreshToken'] = data['refreshToken'];
        }
        if (data['tokens'] != null) {
          if (data['tokens']['accessToken'] != null) {
            bodyTokens['accessToken'] = data['tokens']['accessToken'];
          }
          if (data['tokens']['refreshToken'] != null) {
            bodyTokens['refreshToken'] = data['tokens']['refreshToken'];
          }
        }

        // Use cookie tokens if available, otherwise use body tokens
        final tokens = cookieTokens.isNotEmpty ? cookieTokens : bodyTokens;

        if (tokens['accessToken'] != null && tokens['refreshToken'] != null) {
          await _saveTokens(tokens['accessToken']!, tokens['refreshToken']!);
          Developer.log('Login successful - tokens saved');
        } else {
          Developer.log('Warning: No tokens found in login response');
          Developer.log('Cookie tokens: $cookieTokens');
          Developer.log('Body tokens: $bodyTokens');
        }

        return {
          'success': true,
          'msg': data['msg'] ?? 'Login successful',
          'user': data['data'],
          'tokens': tokens,
        };
      } else {
        Developer.log('Login failed with status: ${response.statusCode}');
        return {'success': false, 'msg': data['msg'] ?? 'Login failed'};
      }
    } catch (e) {
      Developer.log('Login error: $e');
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Logout user - Enhanced to ensure proper cleanup
  static Future<Map<String, dynamic>> logoutUser() async {
    try {
      Developer.log('Attempting logout...');

      final response = await http.post(
        Uri.parse(ApiRoutes.userLogout),
        headers: await getHeaders(includeAuth: true),
      );

      // Clear tokens regardless of server response
      await _clearTokens();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Developer.log('Logout successful');
        return {'success': true, 'msg': data['msg'] ?? 'Logout successful'};
      } else {
        // Even if server logout fails, we cleared local tokens
        Developer.log('Server logout failed but local tokens cleared');
        return {'success': true, 'msg': 'Logged out locally'};
      }
    } catch (e) {
      // Clear tokens even if network request fails
      await _clearTokens();
      Developer.log('Logout error but tokens cleared: $e');
      return {'success': true, 'msg': 'Logged out locally'};
    }
  }

  // Get user profile - Enhanced to include closet stats and new additions
  static Future<UserProfileResponse?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiRoutes.userProfile),
        headers: await getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Developer.log(jsonEncode(jsonResponse));
        return UserProfileResponse.fromJson(jsonResponse);
      } else {
        Developer.log("Error: From getUserProfile.. fail to fetch user data");
        return null;
      }
    } catch (e) {
      Developer.log("Error: from getUserProfile ${e}");
      return null;
    }
  }

  // Get user full name only
  // static Future<Map<String, dynamic>> getUserFullName() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(ApiRoutes.), // You'll need to add this route
  //       headers: await getHeaders(includeAuth: true),
  //     );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       return {'success': true, 'fullName': data['data']};
  //     } else {
  //       return {
  //         'success': false,
  //         'msg': data['msg'] ?? 'Failed to get user name',
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'msg': 'Network error: ${e.toString()}'};
  //   }
  // }

  // Change user password
  static Future<Map<String, dynamic>> changeUserPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(ApiRoutes.changeUserPassword),
        headers: await getHeaders(includeAuth: true),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': data['msg'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'msg': data['msg'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Update user profile - Enhanced with all fields and file upload support
  static Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? email,
    String? bodyShape,
    String? undertone,
    int? feet,
    int? inches,
    String? location,
    File? profilePicture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(ApiRoutes.updateUserProfile),
      );

      // Add headers
      final headers = await getHeaders(includeAuth: true);
      request.headers.addAll(headers);

      // Add text fields
      if (fullName != null) request.fields['fullName'] = fullName;
      if (email != null) request.fields['email'] = email;
      if (bodyShape != null) request.fields['bodyShape'] = bodyShape;
      if (undertone != null) request.fields['undertone'] = undertone;
      if (feet != null) request.fields['feet'] = feet.toString();
      if (inches != null) request.fields['inches'] = inches.toString();
      if (location != null) request.fields['location'] = location;

      // Add profile picture if provided
      if (profilePicture != null) {
        var profilePicFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
        );
        request.files.add(profilePicFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': data['msg'] ?? 'Profile updated successfully',
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'msg': data['msg'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Forgot password - Send recovery code to email
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiRoutes.forgotPassword), // You'll need to add this route
        headers: await getHeaders(),
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': data['msg'] ?? 'Recovery code sent to email',
        };
      } else {
        return {
          'success': false,
          'msg': data['msg'] ?? 'Failed to send recovery code',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Verify recovery code
  static Future<Map<String, dynamic>> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          ApiRoutes.verifyRecoveryCode,
        ), // You'll need to add this route
        headers: await getHeaders(),
        body: jsonEncode({'email': email, 'code': code}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': data['msg'] ?? 'Recovery code verified',
        };
      } else {
        return {
          'success': false,
          'msg': data['msg'] ?? 'Invalid or expired recovery code',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Reset password using recovery code
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiRoutes.resetPassword), // You'll need to add this route
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': data['msg'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'msg': data['msg'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Refresh access token
  static Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        Developer.log('No refresh token found');
        return {'success': false, 'msg': 'No refresh token found'};
      }

      final response = await http.post(
        Uri.parse(ApiRoutes.userRefreshToken),
        headers: await getHeaders(),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Extract tokens from cookies since backend sends them as cookies
        final tokens = _extractTokensFromCookies(response.headers);

        if (tokens['accessToken'] != null && tokens['refreshToken'] != null) {
          await _saveTokens(tokens['accessToken']!, tokens['refreshToken']!);
        }

        return {
          'success': true,
          'msg': data['msg'] ?? 'Token refreshed successfully',
          'tokens': tokens,
        };
      } else {
        return {
          'success': false,
          'msg': data['msg'] ?? 'Failed to refresh token',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Network error: ${e.toString()}'};
    }
  }

  // Enhanced login check with validation
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      Developer.log('Checking login status:');
      Developer.log('Access token exists: ${token != null}');
      Developer.log('Refresh token exists: ${refreshToken != null}');

      if (token != null && token.isNotEmpty) {
        Developer.log('User appears to be logged in');
        return true;
      } else {
        Developer.log('User is not logged in');
        return false;
      }
    } catch (e) {
      Developer.log('Error checking login status: $e');
      return false;
    }
  }

  // Get current user token with logging
  static Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      Developer.log(
        'Getting current token: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
      );
      return token;
    } catch (e) {
      Developer.log('Error getting current token: $e');
      return null;
    }
  }

  // Helper method to validate token format (optional)
  static bool _isValidTokenFormat(String token) {
    // Basic JWT format check (header.payload.signature)
    return token.split('.').length == 3;
  }

  // Method to check token validity (calls backend to verify)
  static Future<bool> validateToken() async {
    try {
      final profile = await getUserProfile();
      return profile?.msg == "User profile fetched successfully";
    } catch (e) {
      Developer.log('Error validating token: $e');
      return false;
    }
  }
}
