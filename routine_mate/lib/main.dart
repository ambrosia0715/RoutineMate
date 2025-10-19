import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase가 이미 초기화된 경우 무시
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  runApp(const RoutineMateApp());
}

class RoutineMateApp extends StatelessWidget {
  const RoutineMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoutineMate',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const RoutineHomeScreen(),
    );
  }
}

// 커스텀 로고 위젯
class RoutineMateLogo extends StatelessWidget {
  final double size;

  const RoutineMateLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade600,
            Colors.indigo.shade400,
            Colors.purple.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원형 패턴
          Positioned(
            top: size * 0.15,
            right: size * 0.15,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 메인 아이콘 - 체크마크가 있는 다트보드
          Icon(Icons.track_changes, color: Colors.white, size: size * 0.6),
          // 체크마크 오버레이
          Positioned(
            bottom: size * 0.2,
            right: size * 0.2,
            child: Container(
              padding: EdgeInsets.all(size * 0.05),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: size * 0.04),
              ),
              child: Icon(Icons.check, color: Colors.white, size: size * 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineHomeScreen extends StatefulWidget {
  const RoutineHomeScreen({super.key});

  @override
  State<RoutineHomeScreen> createState() => _RoutineHomeScreenState();
}

class _RoutineHomeScreenState extends State<RoutineHomeScreen> {
  final FlutterTts _tts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _title = TextEditingController();
  TimeOfDay? _start;
  TimeOfDay? _end;
  List<Map<String, dynamic>> routines = [];
  StreamSubscription? _sub;
  int _notificationId = 0;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initTts();
    _listenRoutines();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _title.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );
    await _notifications.initialize(initSettings);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _listenRoutines() {
    _sub = FirebaseFirestore.instance
        .collection('routines')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            print('📥 Firestore 데이터 수신: ${snapshot.docs.length}개');
            setState(() {
              routines = snapshot.docs.map((d) {
                final data = d.data();
                data['id'] = d.id;
                print('📋 루틴: ${data['title']} (ID: ${d.id})');
                return data;
              }).toList();
            });
          },
          onError: (error) {
            print('❌ Firestore 에러: $error');
            _showSnackBar('데이터 로드 실패: $error');

            // createdAt 인덱스 에러인 경우, orderBy 없이 재시도
            if (error.toString().contains('index')) {
              print('⚠️ 인덱스 없이 재시도...');
              _listenRoutinesWithoutOrder();
            }
          },
        );
  }

  // 인덱스가 없을 경우 대체 메서드
  void _listenRoutinesWithoutOrder() {
    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('routines')
        .snapshots()
        .listen(
          (snapshot) {
            print('📥 Firestore 데이터 수신 (정렬 없음): ${snapshot.docs.length}개');
            setState(() {
              routines = snapshot.docs.map((d) {
                final data = d.data();
                data['id'] = d.id;
                return data;
              }).toList();

              // 클라이언트 측에서 정렬
              routines.sort((a, b) {
                final aTime = a['createdAt'];
                final bTime = b['createdAt'];
                if (aTime == null || bTime == null) return 0;
                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime);
                }
                return 0;
              });
            });
          },
          onError: (error) {
            print('❌ Firestore 에러 (재시도): $error');
            _showSnackBar('데이터 로드 실패: $error');
          },
        );
  }

  Future<void> _addRoutine() async {
    if (_title.text.isEmpty || _start == null || _end == null) {
      _showSnackBar('모든 항목을 입력해주세요.');
      return;
    }

    final data = {
      'title': _title.text,
      'start': _start!.format(context),
      'end': _end!.format(context),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      print('💾 루틴 저장 시도: ${_title.text}');
      final docRef = await FirebaseFirestore.instance
          .collection('routines')
          .add(data);
      print('✅ 루틴 저장 성공! ID: ${docRef.id}');

      await _tts.speak('루틴 ${_title.text}이 추가되었습니다.');
      _scheduleNotifications(_title.text, _start!, _end!);

      _title.clear();
      setState(() {
        _start = null;
        _end = null;
      });

      _showSnackBar('루틴이 추가되었습니다!');
    } catch (e) {
      print('❌ 루틴 추가 실패: $e');
      _showSnackBar('루틴 추가 실패: $e');
    }
  }

  void _scheduleNotifications(
    String title,
    TimeOfDay start,
    TimeOfDay end,
  ) async {
    final now = DateTime.now();
    DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      start.hour,
      start.minute,
    );
    DateTime endTime = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
    );

    // 만약 시작 시간이 이미 지났다면 내일로 설정
    if (startTime.isBefore(now)) {
      startTime = startTime.add(const Duration(days: 1));
      endTime = endTime.add(const Duration(days: 1));
    }

    final midTime = startTime.add(
      Duration(minutes: (endTime.difference(startTime).inMinutes ~/ 2)),
    );

    // 시작 알림
    await _showScheduledNotification(
      _notificationId++,
      '🎯 루틴 시작',
      '$title 시작 시간입니다!',
      startTime,
    );

    // 중간 알림
    await _showScheduledNotification(
      _notificationId++,
      '⏰ 루틴 진행 중',
      '$title 절반 진행되었습니다!',
      midTime,
    );

    // 종료 알림
    await _showScheduledNotification(
      _notificationId++,
      '✅ 루틴 완료',
      '$title 종료 시간입니다!',
      endTime,
    );
  }

  Future<void> _showScheduledNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'routine_channel',
          'Routine Notifications',
          channelDescription: 'Notifications for routine reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // 즉시 알림 표시 (테스트용)
    await _notifications.show(id, title, body, notificationDetails);
  }

  Future<void> _deleteRoutine(String id) async {
    try {
      print('🗑️ 루틴 삭제 시도: $id');
      await FirebaseFirestore.instance.collection('routines').doc(id).delete();
      print('✅ 루틴 삭제 성공!');
      await _tts.speak('루틴이 삭제되었습니다.');
      _showSnackBar('루틴이 삭제되었습니다.');
    } catch (e) {
      print('❌ 삭제 실패: $e');
      _showSnackBar('삭제 실패: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RoutineMateLogo(size: 32),
            const SizedBox(width: 12),
            const Text(
              'RoutineMate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade700,
      ),
      body: Column(
        children: [
          // 루틴 추가 폼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: '루틴 제목',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context, true),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _start == null
                              ? '시작 시간'
                              : '시작: ${_start!.format(context)}',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context, false),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _end == null
                              ? '종료 시간'
                              : '종료: ${_end!.format(context)}',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addRoutine,
                  icon: const Icon(Icons.add),
                  label: const Text('루틴 추가', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 루틴 목록
          Expanded(
            child: routines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const RoutineMateLogo(size: 80),
                        const SizedBox(height: 24),
                        Text(
                          '등록된 루틴이 없습니다.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 루틴을 추가해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.indigo.shade50.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.indigo.shade400,
                                    Colors.indigo.shade600,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              routine['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            subtitle: Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: Colors.indigo.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${routine['start']} ~ ${routine['end']}',
                                    style: TextStyle(
                                      color: Colors.indigo.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.shade600,
                                ),
                                onPressed: () => _deleteRoutine(routine['id']),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
