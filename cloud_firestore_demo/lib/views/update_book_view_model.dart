import 'package:cloud_firestore_demo/models/book_model.dart';
import 'package:cloud_firestore_demo/services/calculator.dart';
import 'package:cloud_firestore_demo/services/database.dart';
import 'package:flutter/cupertino.dart';

class UpdateBookViewModel extends ChangeNotifier {

  final Database _database = Database();
  String collectionPath ="books";

  Future<void> upDateNewBook({
    required String bookName,
    required String authorName,
    required DateTime publishDate,
    required Book book})async{
    /// Form alanındaki verileri ile önce bir book objesi oluşturulması
    Book newBook = Book(
        id: book.id,
        bookName: bookName,
        authorName: authorName,
        publishDate: Calculator.datetimeToTimestamp(publishDate),
        borrows: book.borrows
    );


    /// bu kitap bilgisini database servisi üzerinden Firestore'a yazacak
    await _database.setBookData(
        collectionPath: collectionPath,
        bookAsMap: newBook.toMap()
    );
  }


}