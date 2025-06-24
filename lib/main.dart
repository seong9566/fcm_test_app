import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
    ' [Background] ${message.notification?.title}/${message.notification?.body}',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main');
  await Firebase.initializeApp();

  // 백그라운드 메시지 리스너 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}
