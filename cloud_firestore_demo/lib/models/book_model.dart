import 'package:cloud_firestore/cloud_firestore.dart';
import 'borrow_info_model.dart';

class Book {
  final String id;
  final String bookName;
  final String authorName;
  final Timestamp? publishDate;
  final List<BorrowInfo> borrows;
  Book({required this.id, required this.bookName, required this.authorName,
    this.publishDate,required this.borrows});
  /// Objeden Map oluşturan
  Map<String, dynamic> toMap() {
    /// List<BookInfo> --> List<Map> çevirme
    List<Map<String,dynamic>> borrows = this.borrows.map((borrowInfo) => borrowInfo.topMap()).toList();
    return {
      "id": id,
      "bookName": bookName,
      "authorName": authorName,
      "publishDate": publishDate,
      "borrows": borrows
    };}
  /// Mapten obje oluşturan
  factory Book.fromMap(Map map) {
    // "borrows" alanını kontrol edin ve uygun şekilde dönüştürün
    var borrowListAsMap = map["borrows"] as List<dynamic>?;

    List<BorrowInfo> borrows = [];
    if (borrowListAsMap != null) {
      borrows = borrowListAsMap.map((borrowAsMap) => BorrowInfo.fromMap(borrowAsMap)).toList();
    }

    // "publishDate" alanını Timestamp türüne dönüştürün
    Timestamp? publishDate = map["publishDate"] as Timestamp?;

    return Book(
      id: map["id"] ?? '',
      bookName: map["bookName"] ?? '',
      authorName: map["authorName"] ?? '',
      publishDate: publishDate,
      borrows: borrows,
    );
  }

}