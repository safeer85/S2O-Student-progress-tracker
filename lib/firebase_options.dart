// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNFipP3MiD5J_nB230cWGyOJEhKqBoZWw',
    appId: '1:878176314221:web:127b412fc50285d6603064',
    messagingSenderId: '878176314221',
    projectId: 'fir-2-o',
    authDomain: 'fir-2-o.firebaseapp.com',
    storageBucket: 'fir-2-o.firebasestorage.app',
    measurementId: 'G-NVZFG4PBKQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDvLTiVftCTvI_3CIKE5LaGXNooS9SDe50",
    appId: "1:478666401518:android:9ea0e591c69221fd9135ff",
    messagingSenderId: '878176314221',
    projectId: "s2o-spt",
    storageBucket: "s2o-spt.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAt7Fxs90SUcVNtnDwzgk_G3EEuocbWj4Q',
    appId: '1:878176314221:ios:bb11b4ee1723eded603064',
    messagingSenderId: "478666401518",
    //messagingSenderId: '878176314221',
    projectId: 'fir-2-o',
    storageBucket: 'fir-2-o.firebasestorage.app',
    iosBundleId: 'com.example.s20',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAt7Fxs90SUcVNtnDwzgk_G3EEuocbWj4Q',
    appId: '1:878176314221:ios:bb11b4ee1723eded603064',
    messagingSenderId: '878176314221',
    projectId: 'fir-2-o',
    storageBucket: 'fir-2-o.firebasestorage.app',
    iosBundleId: 'com.example.s20',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCNFipP3MiD5J_nB230cWGyOJEhKqBoZWw',
    appId: '1:878176314221:web:b8e3cfff188e077b603064',
    messagingSenderId: '878176314221',
    projectId: 'fir-2-o',
    authDomain: 'fir-2-o.firebaseapp.com',
    storageBucket: 'fir-2-o.firebasestorage.app',
    measurementId: 'G-QLP58GH5PP',
  );
}
