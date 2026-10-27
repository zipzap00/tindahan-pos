import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/l10n/language.dart';
import 'core/log.dart';
import 'core/result.dart';
import 'data/firestore_support.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final language = await LanguageController.load();

  AppError? startupError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Keep the whole store on the phone so the POS works without internet.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (error, stack) {
    logError('[main/firebase]', error, stack);
    startupError = mapError(error, '[main/firebase]');
  }

  runApp(TindahanApp(language: language, startupError: startupError));
}
