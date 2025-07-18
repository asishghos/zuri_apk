import 'dart:async';
import 'dart:developer' as Developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:testing2/routes/app_routes.dart';

// 🔥 Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Add global error handling for release builds
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Global error handler for Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        Developer.log('Flutter Error: ${details.exception}');
        Developer.log('Stack trace: ${details.stack}');
      };

      try {
        // ✅ Load env variables
        // await dotenv.load(fileName: ".env");

        // ✅ Initialize Firebase with error handling
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // ✅ Shared preferences with error handling
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.remove('alreadyUsed');
        // await prefs.remove('isFirstTime');

        Developer.log('App initialization completed successfully');

        runApp(MyApp());
      } catch (e, stackTrace) {
        Developer.log('Error during app initialization: $e');
        Developer.log('Stack trace: $stackTrace');

        // Still try to run the app with a fallback
        runApp(ErrorApp(error: e.toString()));
      }
    },
    (error, stackTrace) {
      // Catch any uncaught errors
      Developer.log('Uncaught error: $error');
      Developer.log('Stack trace: $stackTrace');
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        // Add error handling for router
        builder: (context, child) {
          return child ??
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    'App Loading...',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      color: Colors.black,
                    ),
                  ),
                ),
              );
        },
      ),
    );
  }
}

// Fallback app in case of initialization errors
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'App Initialization Error',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    SystemNavigator.pop();
                  },
                  child: Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
