import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  ///Singleton Pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  static AuthService get instance => _instance; //Singleton Instance

  //instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Current Looged in User
  User? get currentUser => _auth
      .currentUser; //Get Current User ,if user login sent User Object otherwise null
  //Cheak User Log in or not
  bool get isAuthenticate => currentUser != null;

  //Realtime Track Login or logout(AuthStateChange) ,,Use it to redirect
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  ///Login Methode for Admin User or pass ,if login success Firebase sent User Object otherwise sent Exepttions
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      //Firebase Auth Api call
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return userCredential.user; //Return User Object if login success
    } on FirebaseAuthException catch (e) {
      String errorMessage; //Show Firebase Error Message to User
      switch(e.code){
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;

        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;

        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;

        default:
          errorMessage = 'An error occurred. Please try again later.';
          break;
      }
      throw Exception(errorMessage); //Throw Exception if login failed for Ui catch
    }catch(e){
      throw Exception('An error: $e occurred. Please try again later.');  //Throw Exception if login failed for Ui catch
    }
  }

  ///Logout Methode
  Future<void> signOut() async{
    try{
      await _auth.signOut();
    }catch(e){
      throw Exception('An error: $e occurred. Please try again later.');
    }
  }
  ///Forget Password Methode
 Future<void> sendPasswordResetEmail(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email.trim());//set Password Reset Email
    }on FirebaseAuthException catch(e){
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. ';
          break;

        case 'invalid-email':
          errorMessage = 'Invalid email address. ';
          break;

        default:
          errorMessage = 'Failed to send reset email: ${e. message}';
      }

      throw Exception(errorMessage);
    }catch(e){
      throw Exception('An error: $e occurred. Please try again later.');
    }
 }
 ///User Info access For User Profile
  //User Email
  String? get currentUserEmail => currentUser?.email;
  //User Id
  String? get currentUserId => currentUser?.uid;
  //User Email Verification
  bool? get isEmailVerified => currentUser?.emailVerified ?? false;
  //Account Creation Date
  DateTime? get accountCreationDate => currentUser?.metadata.creationTime;
  //Last Login Date
  DateTime? get lastLoginDate => currentUser?.metadata.lastSignInTime;
  //User Display Name
  String? get displayName => currentUser?.displayName;

  //User Data Refresh ,if change Firebase update local data
  Future<void> reloadUserData() async{
    try{
      await currentUser?.reload();
    }catch (e){
      throw Exception('An error: $e occurred. Please try again later.');
    }
  }

}
