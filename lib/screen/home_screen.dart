import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart' as device_location;
import 'dart:math';
import 'package:review/config/palette.dart';
import 'package:review/screen/login_sign_up_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String username;

  HomeScreen({required this.userId, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _loading = true;
  bool _isChatVisible = false;  // 채팅창 표시 여부
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _nearbyUsers = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchAndShowNearbyUsers();
  }

  // 현재 위치 가져오기
  Future<device_location.LocationData> _fetchCurrentLocation() async {
    device_location.Location location = device_location.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) throw Exception('위치 서비스가 비활성화되었습니다.');
    }

    device_location.PermissionStatus permission = await location.hasPermission();
    if (permission == device_location.PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != device_location.PermissionStatus.granted) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    return await location.getLocation();
  }

  // 두 좌표 간 거리 계산
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
  }

  // Firestore에서 근처 사용자 가져오기
  Future<void> _fetchAndShowNearbyUsers() async {
    setState(() {
      _loading = true;
    });

    try {
      final locationData = await _fetchCurrentLocation();
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .get();

      final List<Map<String, dynamic>> nearbyUsers = snapshot.docs.where((doc) {
        if (doc.id == widget.userId) return false; // 자기 자신 제외
        final location = doc['location'];
        final double distance = _calculateDistance(
          locationData.latitude!,
          locationData.longitude!,
          location['latitude'],
          location['longitude'],
        );
        return distance <= 10; // 10km 범위 내
      }).map((doc) {
        final location = doc['location'];
        final double distance = _calculateDistance(
          locationData.latitude!,
          locationData.longitude!,
          location['latitude'],
          location['longitude'],
        );
        return {
          'username': doc['username'],
          'distance': distance.toStringAsFixed(2), // 소수점 2자리로 표시
        };
      }).toList();

      setState(() {
        _nearbyUsers = nearbyUsers;
        _loading = false;
      });
    } catch (e) {
      print("사용자 가져오기 실패: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  // 근처 사용자 리스트 UI
  Widget _buildNearbyUsersList() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_nearbyUsers.isEmpty) {
      return Center(child: Text('근처에 사용자가 없습니다.'));
    }
    return ListView.builder(
      itemCount: _nearbyUsers.length,
      itemBuilder: (context, index) {
        final user = _nearbyUsers[index];
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(user['username']),
          subtitle: Text('거리: 약 ${user['distance']} km'),
        );
      },
    );
  }

  // 메시지 보내기
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final user = _auth.currentUser;

      await _firestore.collection('messages').add({
        'text': _messageController.text.trim(),
        'sender': user?.email ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  // 채팅 UI
  Widget _buildChatUI() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.6, // 60% 높이로 설정
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print("Error: ${snapshot.error}"); // 오류를 출력하여 문제 파악
                return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('채팅이 없습니다.'));
              }

              final messages = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final text = message['text'];
                  final sender = message['sender'];
                  final isMe = sender == _auth.currentUser?.email;  // 자신이 보낸 메시지인지 확인

                  if (text == null || sender == null) {
                    return ListTile(
                      title: Text('알 수 없는 메시지'),
                      subtitle: Text('발신자 정보 없음'),
                    );
                  }

                  return ListTile(
                    contentPadding: isMe
                        ? EdgeInsets.only(left: 60.0, right: 10.0)  // 오른쪽 정렬
                        : EdgeInsets.only(left: 10.0, right: 60.0), // 왼쪽 정렬
                    title: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          CircleAvatar(
                            radius: 15.0,
                            backgroundColor: isMe ? Colors.blue : Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7, // 70% 너비로 설정
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: '메시지 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),

        ),
      ],
    );
  }

  // 페이지 빌더
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildNearbyUsersList();
      case 1:
        return _buildChatUI();
      default:
        return Center(child: Text(''));
    }
  }

  // 네비게이션 바 선택
  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        _isChatVisible = true;
        _selectedIndex = 1;
      } else {
        _selectedIndex = index;
        _isChatVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.account_circle,
                size: 30.0,
                color: Colors.blueAccent,
              ),
              SizedBox(width: 4.0),
              Text(
                widget.username,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Palette.backgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onItemTapped(0),
                  child: Text('홈', style: TextStyle(color: Palette.textColor2)), // 텍스트 색상
                  style: ElevatedButton.styleFrom(backgroundColor: Palette.backgroundColor),
                ),
                ElevatedButton(
                  onPressed: () => _onItemTapped(1),
                  child: Text('채팅', style: TextStyle(color: Palette.textColor2)), // 텍스트 색상
                  style: ElevatedButton.styleFrom(backgroundColor: Palette.backgroundColor),
                ),
                ElevatedButton(
                  onPressed: () => _onItemTapped(2),
                  child: Text('놀거리'),
                ),
                ElevatedButton(
                  onPressed: () => _onItemTapped(3),
                  child: Text('식당'),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.4, // 40% 높이로 설정
            child: _buildPage(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
