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
    apiKey: 'AIzaSyCYWPC56fah4GRc7KeIP3ZS_h_GCbBjjgI',
    appId: '1:762107570744:web:91a99168244fb198e1d4cd',
    messagingSenderId: '762107570744',
    projectId: 'shift-master-1a66c',
    authDomain: 'shift-master-1a66c.firebaseapp.com',
    storageBucket: 'shift-master-1a66c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZHjjMbIZfmuI3-hl2ReTdx-L_KpCK8UM',
    appId: '1:762107570744:android:430879e5249c2877e1d4cd',
    messagingSenderId: '762107570744',
    projectId: 'shift-master-1a66c',
    storageBucket: 'shift-master-1a66c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlmK6GQw5Bm-6S9kf3CzUj78dxfOUKNcM',
    appId: '1:762107570744:ios:cf7db98892055470e1d4cd',
    messagingSenderId: '762107570744',
    projectId: 'shift-master-1a66c',
    storageBucket: 'shift-master-1a66c.appspot.com',
    androidClientId: '762107570744-etjp621mifoem332pdih6jjq2euh6hec.apps.googleusercontent.com',
    iosClientId: '762107570744-fmps4ffnelki4rcslshj23gumsldv7me.apps.googleusercontent.com',
    iosBundleId: 'com.shiftmaster.shiftMaster',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlmK6GQw5Bm-6S9kf3CzUj78dxfOUKNcM',
    appId: '1:762107570744:ios:cf7db98892055470e1d4cd',
    messagingSenderId: '762107570744',
    projectId: 'shift-master-1a66c',
    storageBucket: 'shift-master-1a66c.appspot.com',
    androidClientId: '762107570744-etjp621mifoem332pdih6jjq2euh6hec.apps.googleusercontent.com',
    iosClientId: '762107570744-fmps4ffnelki4rcslshj23gumsldv7me.apps.googleusercontent.com',
    iosBundleId: 'com.shiftmaster.shiftMaster',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCYWPC56fah4GRc7KeIP3ZS_h_GCbBjjgI',
    appId: '1:762107570744:web:012490d2d8b114abe1d4cd',
    messagingSenderId: '762107570744',
    projectId: 'shift-master-1a66c',
    authDomain: 'shift-master-1a66c.firebaseapp.com',
    storageBucket: 'shift-master-1a66c.appspot.com',
  );

}