import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  FirebaseAuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // ============================================
  // Google Sign In
  // ============================================
  Future<UserCredential?> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔐 Starting Google Sign In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ User cancelled Google Sign In');
        _isLoading = false;
        notifyListeners();
        return null;
      }

      debugPrint('✅ Google user: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('✅ Firebase sign in successful: ${userCredential.user?.email}');

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return userCredential;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Google Sign In error: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // Email/Password Sign In
  // ============================================
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔐 Signing in with email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Email sign in successful');

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      debugPrint('❌ Email sign in error: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // Email/Password Sign Up
  // ============================================
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📝 Creating account for: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
      _user = _auth.currentUser;

      debugPrint('✅ Account created successfully');

      _isLoading = false;
      notifyListeners();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      debugPrint('❌ Sign up error: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // Sign Out
  // ============================================
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      debugPrint('✅ Signed out successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  // ============================================
  // Error Message Helper
  // ============================================
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }

  @override
  void dispose() {
    _googleSignIn.disconnect();
    super.dispose();
  }
}