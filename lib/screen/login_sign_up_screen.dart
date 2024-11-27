import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_widget/flutter_chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:review/config/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:review/screen/home_screen.dart';


class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isSignupScreen = true;
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();


  // 회원가입 시 사용자 정보 저장 함수
  Future<void> saveUser(String userId, String password, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('password', password);
    await prefs.setString('username', username);
  }

  // 로그인 시 사용자 정보 확인 함수
  Future<bool> loginUser(String userId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    final storedPassword = prefs.getString('password');

    return storedUserId == userId && storedPassword == password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Stack(
        children: [
          // 상단 이미지 및 텍스트 영역
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(top: 90, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Welcome',
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontSize: 25,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: ' to Sangmyung Community',
                          style: TextStyle(
                            letterSpacing: 1.0,
                            fontSize: 25,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/img/sangmyung.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
            ),
          ),
          // 로그인 / 회원가입 탭 및 입력 필드
          Positioned(
            top: 250,
            left: 20,
            right: 20,
            child: Container(
              height: 450.0, // 폼 영역의 높이를 늘림
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 로그인 / 회원가입 탭
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignupScreen = false;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'LOGIN',
                              style: TextStyle(
                                color: !isSignupScreen
                                    ? Palette.activeColor
                                    : Palette.textColor1,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              height: 2.0,
                              width: 50.0,
                              color: Colors.brown,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignupScreen = true;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: isSignupScreen
                                    ? Palette.activeColor
                                    : Palette.textColor1,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              height: 2.0,
                              width: 50.0,
                              color: Colors.brown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 로그인 / 회원가입 폼
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Form(
                        child: Column(
                          children: [
                            // 아이디 입력 필드
                            TextFormField(
                              controller: userIdController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  color: Palette.iconColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Palette.textColor1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Palette.textColor1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            // 비밀번호 입력 필드
                            TextFormField(
                              obscureText: true, // 비밀번호는 텍스트 숨김 처리
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Palette.iconColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Palette.textColor1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Palette.textColor1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35.0),
                                  ),
                                ),
                              ),
                            ),
                            if (isSignupScreen)
                            SizedBox(height: 20.0),
                            if (isSignupScreen)
                              TextFormField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Palette.iconColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.textColor1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.textColor1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0),
                            // 로그인 / 회원가입 버튼
                            ElevatedButton(
                              onPressed: () async{
                                // 로그인 또는 회원가입 로직
                                final userId = userIdController.text;
                                final password = passwordController.text;
                                final username = usernameController.text;

                                if (isSignupScreen) {
                                  // 회원가입 로직
                                  await saveUser(userId, password, username);
                                  print('User registered successfully');
                                }

                                else {
                                // 로그인 로직
                                final success = await loginUser(userId, password);
                                if (success) {
                                  final prefs = await SharedPreferences.getInstance();
                                  final storedUsername = prefs.getString('username') ?? 'User';

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                            userId: userId,
                                            username: storedUsername,
                                        ),
                                      ),
                                    );
                                  }
                                else {
                                  print('Login failed');
                                 }
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Colors.blueAccent
                                ),
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(vertical: 12.0),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.0),
                                  ),
                                ),
                              ),
                              child: Text(
                                isSignupScreen ? 'SIGN UP' : 'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
