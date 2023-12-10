import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
//========================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'firebase_options.dart';
//========================================================================

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
//========================================================================
import 'widget.dart';
import 'chat.dart';
import 'firebase_auth_remote_data_source.dart';




void main() async {
  kakao.KakaoSdk.init(nativeAppKey: 'ace161b1a131fa497d5f4eda91fd96a0');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
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
        '/': (context) => MyHomePage(title: ''), // 로그인 화면
        '/chat': (context) => ChatScreen(), // 채팅 화면
        '/homeback': (context)=> HomeScreen(), // user 객체를 HomeScreen에 전달
        '/login': (context) => MyHomePage(title: ''), // 로그인 화면
      },

    );
  }
}

class HomeScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 26.0, right: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, //Coulum 내부를 설정
            children: [
              SizedBox(height: 60),
              Container(
                // color: Color(0xff000000),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Color(0xff1B84FF), Color(0xffBD00FF)], // 그라데이션 색상 설정
                        stops: [0.0, 1.0], // 색상 위치 설정
                        begin: Alignment.topLeft, // 그라데이션 시작 위치
                        end: Alignment.bottomRight, // 그라데이션 종료 위치
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Logo',
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 22,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )

              ),
              SizedBox(height: 20),
              Container(
                // color: Color(0xff000000),
                  child: Text(
                    '반가워요!',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  )),
              SizedBox(height: 10),
              Container(
                //  color: Color(0xff000000),
                  child: Text(
                    '오늘도 사람들과 소통하고\n즐거운 하루 보내세요 :)',
                    style: TextStyle(
                      color: Color(0xFFADB5BD),
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  )),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '현재 위치',
                              style: TextStyle(
                                color: Color(0xFF737D88),
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              height: 26, // 조정된 높이
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FutureBuilder<Position?>(
                                  future: getCurrentLocation(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError ||
                                        snapshot.data == null) {
                                      return Text('위치 정보 없음');
                                    } else {
                                      return FutureBuilder<List<Placemark>>(
                                        future: getAddressFromCoordinates(
                                            snapshot.data!),
                                        builder: (context, addressSnapshot) {
                                          if (addressSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else if (addressSnapshot.hasError ||
                                              addressSnapshot.data == null) {
                                            return Text(
                                                '위치 정보 없음');
                                          } else {
                                            String address = buildAddressString(
                                                addressSnapshot.data![0]);
                                            return ShaderMask(
                                              shaderCallback: (Rect bounds) {
                                                return LinearGradient(
                                                  colors: [Color(0xff1B84FF), Color(0xffBD00FF)], // 그라데이션 색상 설정
                                                  stops: [0.0, 1.0], // 색상 위치 설정
                                                  begin: Alignment.topLeft, // 그라데이션 시작 위치
                                                  end: Alignment.bottomRight, // 그라데이션 종료 위치
                                                ).createShader(bounds);
                                              },
                                              child: Text(
                                                '$address',
                                                style: TextStyle(
                                                  color: Colors.white, // 텍스트의 실제 색상은 여기서 설정
                                                  fontSize: 16,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w700,
                                                  height: 0,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0), // 위아래 텍스트 간격 조절
                  Expanded(
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '사용 중인 말풍선',
                              style: TextStyle(
                                color: Color(0xFF737D88),
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            Container(
                              height: 66,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 24,
                                      decoration: ShapeDecoration(
                                        color: Colors.white
                                            .withOpacity(0.10000000149011612),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 1,
                                              color: Color(0xFF18C7FF)),
                                          borderRadius:
                                          BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '스페셜 에디션',
                                      style: TextStyle(
                                        color: Color(0xFF737D88),
                                        fontSize: 12,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                // color: Color(0xff000000),
                child: Text(
                  '공지사항',
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ), //공지사항
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await buildFirstPopup(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [Color(0xff1B84FF), Color(0xffBD00FF)],
                                  stops: [0.0, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Text(
                                '업데이트',
                                style: TextStyle(
                                  color: Color(0xFFffffff),
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              '2024 새해 기념 신규 말풍선 출시',
                              style: TextStyle(
                                color: Color(0xFF737D88),
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              '새해 기념 2개의 신규 말풍선이 상점에 업데이트 되었습니다.\n\n신규 말풍선[2024 첫 번째 해], [2024 청룡의 해]는 2024년 1월 31일까지 구매 가능합니다. 지금 바로 만나보세요!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFADB5BD),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await buildFirstPopup2(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [Color(0xff1B84FF), Color(0xffBD00FF)],
                                  stops: [0.0, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Text(
                                '공지사항',
                                style: TextStyle(
                                  color: Color(0xFFffffff),
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              '유저 가이드',
                              style: TextStyle(
                                color: Color(0xFF737D88),
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              '앱 사용에 관한 중요한 내용을 안내해드립니다.\n\n* 현재는 카카오 계정을 통한 로그인만 가능합니다.\n* 주변 1km내에 있는 사람들과 소통이 가능합니다.\n* 위치 정보를 활성화 하셔야 채팅 이용이 가능합니다.\n* 욕설, 비방 등의 채팅은 이용이 제한될 수 있습니다.\n\n웅성웅성은 언제나 당신의 하루를 더 완벽하게 채워주고자 노력하겠습니다. 앞으로의 업데이트들도 기대해 주세요. 불편한 점 등의 피드백은 공식 인스타그램 DM으로 24시간 언제든 문의해주세요.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFADB5BD),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await buildFirstPopup3(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [Color(0xff1B84FF), Color(0xffBD00FF)],
                                  stops: [0.0, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Text(
                                '업데이트',
                                style: TextStyle(
                                  color: Color(0xFFffffff),
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              '상점 OPEN',
                              style: TextStyle(
                                color: Color(0xFF737D88),
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              '드디어 모두가 기다리던 상점이 오픈했어요. 더 좋은 아이템을 가지고 채팅을 시작해보세요. 상점 오픈 이벤트로 얻을 수 있는 Lv.2 말풍선도 확인해보세요.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFADB5BD),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  // 위치 업데이트 함수
  Future<void> updateLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 사용자가 권한을 거부한 경우 처리
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 위치 정보 출력
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

    // 파이어베이스에 위치 정보 업데이트
    await updateLocationInFirestore(position);
  }

  // 파이어베이스에 위치 정보 업데이트 함수
  Future<void> updateLocationInFirestore(Position position) async {
    try {
      String? userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('location').doc(userId).set(
          {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      print('Error updating location in Firestore: $e');
    }
  }
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final viewModel = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: StreamBuilder<firebase_auth.User?>(
          stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ElevatedButton(
                onPressed: () async {
                  await viewModel.login();
                  if (viewModel.isLogined) {
                    // 로그인이 완료되면 홈 화면으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    );
                  }
                  setState(() {});
                },
                child: const Text('Login'),
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${viewModel.isLogined}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await viewModel.logout();
                    setState(() {});
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

abstract class SocialLogin {
  Future<bool> login();

  Future<bool> logout();
}

class MainViewModel {
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final SocialLogin _socialLogin;
  bool isLogined = false;
  kakao.User? kakaoUser; // 변수명을 'kakaoUser'로 변경
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance; // 인스턴스 얻기

  firebase_auth.User? get currentUser => _auth.currentUser;

  MainViewModel(this._socialLogin);

  Future login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      kakaoUser  = await kakao.UserApi.instance.me();

      final token = await _firebaseAuthDataSource.createCustomToken({
        'uid': kakaoUser!.id.toString(),
        'displayName': kakaoUser!.kakaoAccount!.profile!.nickname,
        'kakaoId': kakaoUser!.id.toString(), // 카카오에서 받은 사용자의 ID
        'photoURL': kakaoUser!.kakaoAccount!.profile!.profileImageUrl!,
      });

      await _auth.signInWithCustomToken(token); // _auth를 통해 로그인
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    await _auth.signOut(); // _auth를 통해 로그아웃
    isLogined = false;
    kakaoUser = null; // 변수명 변경
  }
}


Future<void> updateLocationInFirestore(Position position) async {
  try {
    // 현재 로그인한 사용자의 UID 가져오기
    String? userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Firestore에 사용자의 위치 업데이트
      await FirebaseFirestore.instance.collection('chat').doc(userId).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    }
  } catch (e) {
    print('Error updating location in Firestore: $e');
  }
}

// 1km 이내의 사용자를 파이어베이스에서 가져오기
// 위치 권한 요청 함수
Future<bool> checkLocationPermission() async {
  try {
    // 위치 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한이 거부된 경우 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 사용자가 권한을 거부한 경우 처리
        return false;
      }
    }
    return true;
  } catch (e) {
    print('Error checking location permission: $e');
    return false;
  }
}

// 현재 위치 정보 가져오기
Future<Position?> getCurrentLocation() async {
  try {
    // 위치 권한 확인
    bool hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      // 사용자가 권한을 거부한 경우 처리
      return null;
    }

    // 위치 가져오기 (타임아웃 10초 설정)
    return await Future.delayed(Duration(seconds: 10), () async {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    });
  } catch (e) {
    if (e is TimeoutException) {
      print('Timeout getting current location');
    } else {
      print('Error getting current location: $e');
    }
    // 위치 정보를 가져올 수 없는 경우 처리
    return null;
  }
}


