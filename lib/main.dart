import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  User? user;

  MainViewModel(this._socialLogin);

  Future login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      user = await UserApi.instance.me();
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    isLogined = false;
    user = null;
  }
}

abstract class SocialLogin {
  Future<bool> login();

  Future<bool> logout();
}

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          return true;
        } catch (e) {
          return false;
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          return true;
        } catch (e) {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      return false;
    }
  }
}

// 위치 권한 요청 함수
Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 사용자가 권한을 거부한 경우 처리
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // 사용자가 권한을 영구히 거부한 경우 처리
  }
}

Future<Position> getCurrentLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  } catch (e) {
    // 위치 정보를 가져올 수 없는 경우 처리
    return Future.error(e.toString()); // 에러를 반환
  }
}

void main() {
  KakaoSdk.init(nativeAppKey: '9b1042139d6856f86d7bd7525a12c38f'
      );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('ko', 'KR'),
      initialRoute: '/', // 초기 경로를 지정
      routes: {
        '/': (context) => LoginPage(title: ''), // 로그인 화면
        '/chat': (context) => ChatScreen(), // 채팅 화면
        '/homeback': (context) => HomeScreen(), // 뒤로
        '/login': (context) => LoginPage(title: ''), // 로그인 화면
      },
    );
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: LoginPage(title: ''), // 처음 보일 화면을 LoginPage로 설정
  );
}

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xFFF9F9FB),
        title: buildAppBarTitle(context),
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 16.0,
            ),
            buildUserInformation(),
            SizedBox(height: 10.0),
            buildInfoText(),
            SizedBox(height: 40.0),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 5),
                        child: buildInfoCard(
                          '현재 위치',
                          '위치 정보 없음',
                          '위치 서비스 꺼짐',
                          174, 146,
                          left: constraints.maxWidth * 0, // left 값 설정
                        ),
                      ),
                    ),
                    SizedBox(width: 0),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16, left: 5),
                        child: buildInfoCard(
                          '사용 중인 말풍선',
                          '',
                          'Lv.02 말풍선',
                          174, 146,
                          right: constraints.maxWidth * 0, // right 값 설정
                          showInternalBox: true,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 40.0),
            buildAnnouncement(),
            SizedBox(height: 20.0),
            buildUpdateCard(context, '신규 말풍선 업데이트',
                '누구보다 빛나는 말풍선이 드디어 OPEN했어요!', 0, 378, 101),
            SizedBox(height: 10.0),
            buildUpdateCard(
              context,
              '상점 OPEN',
              '모두가 기다리던 1KM 상점이 오픈했어요 :)',
              0,
              378,
              101,
            ),
            SizedBox(height: 10.0),
            buildUpdateCard(
                context, '강남지역 서비스 START', '이제 강남에서도 채팅이 가능해요.', 0, 378, 101),
            SizedBox(height: 10.0),
            buildUpdateCard(
                context, '강남지역 서비스 START', '이제 강남에서도 채팅이 가능해요.', 0, 378, 101),
            SizedBox(height: 10.0),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final viewModel = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
                viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
            Text(
              '${viewModel.isLogined}',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              onPressed: () async {
                await viewModel.login();
                if (viewModel.isLogined) {
                  final user = await UserApi.instance.me();
                  viewModel.user = user;

                  // 로그인 성공 후 HomePage으로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen( ), // HomePage으로 사용자 정보(user) 전달
                    ),
                  );
                }
                setState(() {});
              },
              child: const Text('카카오 로그인'),
            ),
            ElevatedButton(
              onPressed: () async {
                await viewModel.logout();
                setState(() {});
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> messages = [];

  final TextEditingController _textController = TextEditingController();

  bool isMapOpen = false;

  void _sendMessage(String message) {
    // 메시지를 전송하고 messages 목록에 추가
    setState(() {
      messages.add(message);
      _textController.clear(); // 입력 필드 지우기
      _currentMessage = " "; // _currentMessage 초기화
    });
  }

  String _currentMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF9F9FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xffF9F9FB),
          title: buildAppBarTitle2(context),
          toolbarHeight: 60,
        ),
        body: // 현재 입력된 메시지
            Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length + 1, // 채팅 텍스트와 비어있는 텍스트를 위한 항목
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    // 마지막 항목일 때, 비어있는 텍스트를 표시
                    if (_currentMessage.isEmpty) {
                      return Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 20.0), // 위아래 여백 조절
                          child: Text(
                            "지금은 조용하네요.",
                            style: TextStyle(
                              color: Color(0xFF747E88),
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(); // 아무 내용도 표시하지 않음
                    }
                  } else {
                    final message = messages[index];
                    final time = DateTime.now();

                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 4.0, top: 20),
                                child: Text(
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  // 시간 형식을 자유롭게 조절 가능
                                  style: TextStyle(
                                    color: Color(0xFFDBDBDB),
                                    fontSize: 10,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 0.0, bottom: 10.0, right: 10.0),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0x1aadb5bd),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    color: Color(0xff747E88),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16, top: 20, bottom: 40),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 296,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력해주세요:)',
                          fillColor: Color(0xffffffff),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(34.0),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFADB5BD),
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            height: 0,
                            letterSpacing: -0.28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.up_arrow,
                        color: const Color(0xff747E88),
                      ),
                      style: ButtonStyle(),
                      onPressed: () {
                        final message = _textController.text;
                        if (message.isNotEmpty) {
                          _sendMessage(message);
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

Widget buildAppBarTitle(BuildContext context) {
  Shader _textShader = LinearGradient(
    colors: [Color(0xFF1b84ff), Color(0xff00ffc2)],
    stops: [0.0, 1.0],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 80.0, 0.0));

  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 20.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              foreground: Paint()..shader = _textShader,
            ),
            children: <TextSpan>[
              TextSpan(text: '1km'),
            ],
          ),
        ),
      ),
      Spacer(),
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 20.0),
          child: GestureDetector(
            onTap: () {
              Scaffold.of(context).openEndDrawer(); // 오른쪽 드로어 메뉴 열기
            },
            child: Icon(
              CupertinoIcons.list_bullet,
              color: const Color(0xff747E88),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget buildAppDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text('메뉴'),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          title: Text('메뉴 항목 1'),
          onTap: () {
            // 메뉴 항목 1이 선택될 때 수행할 작업 추가
          },
        ),
        ListTile(
          title: Text('메뉴 항목 2'),
          onTap: () {
            // 메뉴 항목 2가 선택될 때 수행할 작업 추가
          },
        ),
      ],
    ),
  );
}

Widget buildAppBarTitle2(BuildContext context) {
  return Row(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 20.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/homeback');
            },
            child: Icon(
              CupertinoIcons.back,
              color: const Color(0xff747E88),
            ),
          ),
        ),
      ),
      Spacer(),
      Align(
        alignment: Alignment.center, // 중앙 정렬
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            '서울시 강남구',
            style: TextStyle(
              color: Color(0xFF737D88),
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
        ),
      ),
      Spacer(),
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 20.0),
          child: Icon(
            CupertinoIcons.map,
            color: const Color(0xff747E88),
          ),
        ),
      ),
    ],
  );
}

Widget buildUserInformation() {
  return Padding(
    padding: const EdgeInsets.only(left: 26.0), // 왼쪽에 간격 추가
    child: Text(
      '126번 회원님',
      style: TextStyle(
        color: Color(0xFF555555),
        fontSize: 20,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        height: 0,
      ),
    ),
  );
}

Widget buildInfoText() {
  return Padding(
      padding: const EdgeInsets.only(left: 26.0), // 왼쪽에 간격 추가
      child: Text(
        '오늘도 사람들과 소통하고\n즐거운 하루 보내세요 :)',
        style: TextStyle(
          color: Color(0xFFADB5BD),
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          height: 0,
        ),
      ));
}

Widget buildInfoCard(
  String title,
  String info1,
  String info2,
  double width,
  double height, {
  double? left,
  double? right,
  bool showInternalBox = false,
}) {
  return Positioned(
    top: 160.0,
    left: left,
    right: right,
    child: Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 26.0,
            left: 26.0,
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFF737D88),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
          ),
          Positioned(
            bottom: 44.0,
            left: 26.0,
            child: Text(
              info1,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
          ),
          if (info2 != null)
            Positioned(
              bottom: 26.0,
              left: 26.0,
              child: Text(
                info2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDBDBDB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showInternalBox)
            Positioned(
              top: 70.0,
              left: 22.0,
              child: Container(
                width: 60,
                height: 30,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFF18C7FF)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget buildAnnouncement() {
  return Padding(
    padding: const EdgeInsets.only(left: 26.0), // 왼쪽에 간격 추가
    child: Text(
      '공지사항',
      style: const TextStyle(
        color: Color(0xFF555555),
        fontSize: 18,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        height: 0,
      ),
    ),
  );
}

Widget buildUpdateCard(
  BuildContext context,
  String title,
  String info,
  double top,
  double width,
  double height,
) {
  return Positioned(
    top: top,
    right: 16.0, // 오른쪽 여백 16.0
    left: 16.0, // 왼쪽 여백 16.0
    child: Center(
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 6,
              offset: Offset(0, 2),
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20.0,
              left: 26.0,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [Color(0xFF1b84ff), Color(0xff00ffc2)],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 140.0, 0.0)),
                      ),
                  children: <TextSpan>[
                    TextSpan(text: '업데이트'),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 38.0,
              left: 26.0,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF737D88),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              top: 67.0,
              left: 26.0,
              child: Text(
                info,
                style: const TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildBottomNavigationBar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
    decoration: ShapeDecoration(
      color: Color(0xFFF9F9FB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      shadows: [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 4,
          offset: Offset(0, -2),
          spreadRadius: 0,
        )
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/chat');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.chat_bubble_2_fill,
                  color: Color(0xFFADB5BD)),
              Text(
                '',
                style: TextStyle(color: Color(0xFFADB5BD)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
