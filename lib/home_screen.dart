import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  late final FirebaseMessaging fc = FirebaseMessaging.instance;
  String? fcmToken = "";
  String? _lastTitle;
  String? _lastBody;
  Map<String, dynamic> _lastData = {};
  final TextEditingController _textEditingController = TextEditingController();

  String firstTopic = 'placeId_1_security';
  String secondTopic = 'placeId_1_beauty';
  @override
  void initState() {
    super.initState();
    fc.subscribeToTopic(firstTopic);
    fc.subscribeToTopic(secondTopic);
    _initLocalNotification();
    _requestFCMPermission();
    _getToken();
    _listenMessages();
  }

  /// LocalNotification 초기화
  /// 1) 로컬 알림 초기화 & Android 채널 생성
  void _initLocalNotification() async {
    // Android 채널 정의
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID
      'High Importance Notifications', // 이름
      description: '앱 포그라운드에서도 알림을 보여주는 채널',
      importance: Importance.high,
    );

    // Android 초기화 설정
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정 (권한 요청 활성화)
    final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // 채널 등록 (Android)
    await fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 플러그인 초기화
    await fln.initialize(initSettings);
  }

  /// 권한 요청
  /// 2) FCM 권한 요청 (iOS)
  void _requestFCMPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await fc.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS FCM 권한: ${settings.authorizationStatus}');
    }
  }

  /// FCM에서 토큰 받아오기
  void _getToken() async {
    try {
      debugPrint("[Flutter] >> Get Token !!");

      fcmToken = await fc.getToken();
      setState(() {
        if (fcmToken != null) {
          _textEditingController.text = fcmToken!;
        }
      });
      debugPrint(' FCM Token: $fcmToken');
    } catch (e) {
      debugPrint("[Flutter] >> e : $e");
    }
  }

  /// 4) 메시지 리스너 (포그라운드/백그라운드/탭)
  void _listenMessages() {
    // 포그라운드 메시지 → 로컬 알림으로 표시
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final n = msg.notification;
      if (n != null) {
        setState(() {
          _lastTitle = n.title;
          _lastBody = n.body;
          _lastData = msg.data; // data 페이로드 전체
        });
        _showLocalNotification(n.title, n.body);
      }
      debugPrint(
        "[Flutter] >> Foreground title : ${n?.title} body : ${n?.body}",
      );
    });

    // 백그라운드에서 푸시를 눌러 열었을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      debugPrint('탭 상태 메시지: ${msg.notification?.title}');
    });

    // (선택) 앱이 완전히 종료된 상태에서 푸시로 열었을 때
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) {
        debugPrint('종료 상태 메시지: ${msg.notification?.title}');
      }
    });
  }

  /// 5) 실제 로컬 알림 표시
  void _showLocalNotification(String? title, String? body) {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel', // 위에서 만든 채널 ID
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    debugPrint("[Flutter] >> show Notification !");
    fln.show(0, title, body, details);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent, // 빈공간 터치
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("FCM 토큰 정보", style: titleStyle),
                      ElevatedButton(
                        onPressed: () {
                          _getToken();
                        },
                        child: Text('FCM 토큰 다시 가져오기 '),
                      ),
                    ],
                  ),

                  TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                    controller: _textEditingController,
                    decoration: InputDecoration(),
                  ),
                  SizedBox(height: 12),
                  Text('현재 구독 상태 ', style: titleStyle),
                  SizedBox(height: 12),
                  Text('$firstTopic | $secondTopic'),
                  SizedBox(height: 12),
                  Text('FCM 페이로드 전체 정보', style: titleStyle),

                  // 수신된 notification title/body
                  if (_lastTitle != null) Text("Title: $_lastTitle"),
                  if (_lastBody != null) Text("Body: $_lastBody"),

                  const SizedBox(height: 10),

                  // 수신된 data 페이로드 key/value
                  ..._lastData.entries.map((e) => Text("${e.key}: ${e.value}")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
