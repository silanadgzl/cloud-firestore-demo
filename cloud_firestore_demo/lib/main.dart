import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_demo/views/books_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization =Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot?>(
      create: (_)=>FirebaseFirestore.instance.collection("kitaplar").snapshots(),
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
        ),
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if(snapshot.hasError){
              return const Center(child: Text("Beklenilmeyen bir hata oluştu"));
            }else if(snapshot.hasData){
              return const BooksView();
            }else{
              return const Center(child: CircularProgressIndicator(),);
            }
          },
        ),
      ),
    );
  }
}