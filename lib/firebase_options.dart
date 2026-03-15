import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Web Firebase config. Required when running on web (Chrome, etc.).
/// Get your web [appId] from Firebase Console: Project settings → Your apps → Add app → Web.
/// Replace the placeholder [appId] below with the value from the Firebase config object.
const FirebaseOptions webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyB01QFYwgYVxdmPZKZFSiYGyxJ2akmnBUI',
  authDomain: 'newbond1-80447.firebaseapp.com',
  projectId: 'newbond1-80447',
  storageBucket: 'newbond1-80447.firebasestorage.app',
  messagingSenderId: '197064945053',
  appId: '1:197064945053:web:REPLACE_WITH_YOUR_WEB_APP_ID',
);
