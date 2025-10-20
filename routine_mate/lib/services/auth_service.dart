import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호 회원가입
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('📝 회원가입 시도: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 프로필 업데이트
      await userCredential.user?.updateDisplayName(name);

      // Firestore에 사용자 정보 저장
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'email',
      });

      print('✅ 회원가입 성공: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ 회원가입 실패: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ 회원가입 에러: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 로그인 시도: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ 로그인 성공: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ 로그인 실패: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ 로그인 에러: $e');
      rethrow;
    }
  }

  // Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔍 Google 로그인 시도');

      // Google 로그인 트리거
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ Google 로그인 취소됨');
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      // Firestore에 사용자 정보 저장 (처음 로그인 시)
      final userDoc = _firestore
          .collection('users')
          .doc(userCredential.user?.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': userCredential.user?.displayName ?? 'Google User',
          'email': userCredential.user?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'provider': 'google',
          'photoUrl': userCredential.user?.photoURL,
        });
      }

      print('✅ Google 로그인 성공: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('❌ Google 로그인 에러: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      print('👋 로그아웃 시도');
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 에러: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ 비밀번호 재설정 이메일 전송: $email');
    } catch (e) {
      print('❌ 비밀번호 재설정 에러: $e');
      rethrow;
    }
  }

  // Firebase Auth 에러 처리
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '존재하지 않는 계정입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 인증 방법은 현재 사용할 수 없습니다.';
      default:
        return '인증 오류가 발생했습니다: ${e.message}';
    }
  }
}
