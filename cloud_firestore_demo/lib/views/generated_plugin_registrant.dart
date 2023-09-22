import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins(Registrar registrar) {
  FirebaseFirestoreWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}