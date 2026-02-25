import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init((options) {
    options.dsn =
        'https://0fb4a21bb2719f0fdf69648b831560e6@o4510946381856768.ingest.de.sentry.io/4510946383560784';
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
    // The sampling rate for profiling is relative to tracesSampleRate
    // Setting to 1.0 will profile 100% of sampled transactions:
    options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(SentryWidget(child: const MyApp())));
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(Exception('This is a sample exception.'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthCubit())],
      child: MaterialApp(
        title: 'Task App',
        theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.all(27),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
