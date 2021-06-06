import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;

  Future<void> signInWithPhoneNumber(String phoneNumber) async {

    PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException authException) {
       throw('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    PhoneVerificationCompleted phoneVerificationCompleted =
        (PhoneAuthCredential credentials) async {
      await _auth.signInWithCredential(credentials);
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      this._verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this._verificationId = verificationId;
      throw "timeout";
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+91" + phoneNumber,
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: phoneVerificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      throw e;
    }
  }

  Future<User> verifyOtp(String otp) async {
    try{
      final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: this._verificationId,
          smsCode: otp
      );
      final User user = (await _auth.signInWithCredential(credential)).user as User;
      return user;
    } catch(e){
      throw e;
    }
  }
}