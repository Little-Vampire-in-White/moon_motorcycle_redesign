import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Record Login Activity
  Future<void> _recordLoginActivity(User user) async {
    String device = await _getDeviceIdentifier();
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('login_activity')
        .add({'timestamp': FieldValue.serverTimestamp(), 'device': device});
  }

  Future<String> _getDeviceIdentifier() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return '${androidInfo.model} (Android ${androidInfo.version.release})';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return '${iosInfo.utsname.machine} (iOS ${iosInfo.systemVersion})';
    }
    return 'Unknown Device';
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user, {String? displayName, String? fcmToken}) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    final name = displayName ?? user.displayName;

    if (!userDoc.exists) {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': name ?? user.email?.split('@')[0] ?? 'Motorcycle Rider',
        'photoURL': user.photoURL,
        'address': 'Not set',
        'fcmToken': fcmToken,
        'isAdmin': false, // Default to not admin
      });
    } else {
      final data = userDoc.data() as Map<String, dynamic>;
      final Map<String, dynamic> updates = {};

      if (fcmToken != null) {
        updates['fcmToken'] = fcmToken;
      }

      final existingName = data['displayName'] as String?;
      if ((existingName == null || existingName.isEmpty) && name != null) {
        updates['displayName'] = name;
      }

      if (updates.isNotEmpty) {
        await userDocRef.update(updates);
      }
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData() async {
    return await _firestore.collection('users').doc(currentUser!.uid).get();
  }

  // --- Admin Methods ---

  Future<void> toggleAdminStatus(String uid, bool currentStatus) async {
    await _firestore.collection('users').doc(uid).update({'isAdmin': !currentStatus});
  }

  // Note: Deleting a user from Firestore does NOT delete their auth record.
  // Proper user deletion requires a cloud function.
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<int> getTotalProducts() async {
    final QuerySnapshot snapshot = await _firestore.collection('motorcycles').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalBookings() async {
    final QuerySnapshot snapshot = await _firestore.collection('bookings').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalUsers() async {
    final QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.length;
  }

  Future<double> getRevenue() async {
    final QuerySnapshot snapshot = await _firestore.collection('bookings').get();
    double totalRevenue = 0;
    for (var doc in snapshot.docs) {
      totalRevenue += (doc['totalCost'] as num?)?.toDouble() ?? 0.0;
    }
    return totalRevenue;
  }


  Future<double> getTotalSales() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'approved')
        .get();
    double totalSales = 0;
    for (var doc in snapshot.docs) {
      totalSales += (doc['totalCost'] as num?)?.toDouble() ?? 0.0;
    }
    return totalSales;
  }


  Future<double> getAverageSales() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'approved')
        .get();
    if (snapshot.docs.isEmpty) {
      return 0.0;
    }
    double totalSales = 0;
    for (var doc in snapshot.docs) {
      totalSales += (doc['totalCost'] as num?)?.toDouble() ?? 0.0;
    }
    return totalSales / snapshot.docs.length;
  }

  Future<List<Map<String, dynamic>>> getTrendingMotorcycles() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'approved')
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    final Map<String, int> motorcycleCounts = {};
    for (var doc in snapshot.docs) {
      final motorcycleId = doc['motorcycleId'] as String;
      motorcycleCounts[motorcycleId] = (motorcycleCounts[motorcycleId] ?? 0) + 1;
    }

    final sortedMotorcycles = motorcycleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topMotorcycles = sortedMotorcycles.take(3);

    final List<Map<String, dynamic>> trendingItems = [];
    for (var entry in topMotorcycles) {
      final motorcycleDoc = await _firestore.collection('motorcycles').doc(entry.key).get();
      if (motorcycleDoc.exists) {
        trendingItems.add({
          'name': motorcycleDoc.data()?['name'] ?? 'Unknown',
          'imageUrl': motorcycleDoc.data()?['imageUrl'] ?? '',
          'bookings': entry.value,
        });
      }
    }
    return trendingItems;
  }


  Future<Map<int, double>> getWeeklyChartData(String status) async {
    final Map<int, double> weeklyData = { for (var i = 0; i < 7; i++) i: 0.0 };
    final now = DateTime.now();
    final lastSevenDays = now.subtract(const Duration(days: 7));

    Query query = _firestore.collection('bookings');
    if (status == 'approved') {
        query = query.where('status', isEqualTo: 'approved');
    }

    final QuerySnapshot snapshot = await query.where('startDate', isGreaterThanOrEqualTo: lastSevenDays).get();

    for (var doc in snapshot.docs) {
      final bookingDate = (doc['startDate'] as Timestamp).toDate();
      final dayOfWeek = bookingDate.weekday % 7; // Sunday=0, Monday=1, ...
      weeklyData.update(dayOfWeek, (value) => value + ((doc['totalCost'] as num?)?.toDouble() ?? 0.0));
    }
    return weeklyData;
  }

  // Update user data in Firestore
  Future<void> updateUserData(Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(currentUser!.uid).update(data);
  }

  // Change user password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle({String? fcmToken}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _createOrUpdateUserDocument(user, fcmToken: fcmToken);
        await _recordLoginActivity(user);
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password, {String? fcmToken}) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = result.user;
      if (user != null) {
        await _createOrUpdateUserDocument(user, displayName: email.split('@')[0], fcmToken: fcmToken);
        await _recordLoginActivity(user);
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password, {String? fcmToken}) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = result.user;
      if (user != null) {
        await _createOrUpdateUserDocument(user, displayName: email.split('@')[0], fcmToken: fcmToken);
        await _recordLoginActivity(user);
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Phone number verification
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(PhoneAuthCredential) verificationCompleted,
    Function(FirebaseAuthException) verificationFailed,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential, {String? fcmToken}) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await _createOrUpdateUserDocument(user, fcmToken: fcmToken);
      await _recordLoginActivity(user);
    }
    return userCredential;
  }
}
