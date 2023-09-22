import 'package:cloud_firestore_demo/models/book_model.dart';
import 'package:cloud_firestore_demo/services/calculator.dart';
import 'package:cloud_firestore_demo/services/database.dart';
import 'package:flutter/material.dart';
class AddBookViewModel extends ChangeNotifier {

  final Database _database = Database();
  String collectionPath ="books";

  Future<void> addNewBook({
    required String bookName,
    required String authorName,
    required DateTime publishDate})async{
    /// Form alanındaki verileri ile önce bir book objesi oluşturulması gerekiyor
    Book newBook = Book(
      id: DateTime.now().toIso8601String(),
      bookName: bookName,
      authorName: authorName,
      publishDate: Calculator.datetimeToTimestamp(publishDate),
      borrows: []
    );


    /// bu kitap bilgisini database servisi üzerinden Firestore'a yazacak
    await _database.setBookData(
        collectionPath: collectionPath,
        bookAsMap: newBook.toMap()
    );
  }


}