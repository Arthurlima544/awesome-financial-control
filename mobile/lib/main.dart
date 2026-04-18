import 'package:afc/shared/components/adaptative_nav_bar/adaptive_nav_bar.dart';
import 'package:afc/shared/components/adaptative_nav_bar/adaptive_nav_bar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Spacer(),
            BlocProvider(
              create: (context) => AdaptiveNavBarCubit(),
              child: AdaptiveNavBar(title: "ndnfenwefnw"),
            ),
            Center(child: Text('Hello World!')),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
