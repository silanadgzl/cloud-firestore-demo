import 'package:cloud_firestore_demo/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/borrow_info_model.dart';

class BorrowListViewModel with ChangeNotifier {
  final Database _database = Database();
  String collectionPath = 'books';

  Future<void> updateBook({required List<BorrowInfo> borrowList, required Book book}) async {
    Book newBook = Book(
        id: book.id,
        bookName: book.bookName,
        authorName: book.authorName,
        publishDate: book.publishDate,
        borrows: borrowList);

    /// bu kitap bilgisini database servisi üzerinden Firestore'a yazacak
    await _database.setBookData(
        collectionPath: collectionPath, bookAsMap: newBook.toMap());
  }

  Future<void> deletePhoto(String photoUrl)async{
    /// url --> ref
    Reference photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
    await photoRef.delete();
  }
}