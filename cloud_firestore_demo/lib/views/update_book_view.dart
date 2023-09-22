import 'package:cloud_firestore_demo/models/book_model.dart';
import 'package:cloud_firestore_demo/services/calculator.dart';
import 'package:cloud_firestore_demo/views/update_book_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateBookView extends StatefulWidget {
  final Book book;
  const UpdateBookView({required this.book});

  @override
  State<UpdateBookView> createState() => _UpdateBookViewState();
}

class _UpdateBookViewState extends State<UpdateBookView> {

  TextEditingController bookCtr = TextEditingController();
  TextEditingController authorCtr = TextEditingController();
  TextEditingController publishCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _selectedDate;

  @override
  void dispose() { // TextEditingController nesnesini temizler ve gereksiz bellek tüketimini önler.
    bookCtr.dispose();
    authorCtr.dispose();
    publishCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    bookCtr.text=widget.book.bookName!;
    authorCtr.text=widget.book.authorName!;
    publishCtr.text=
        Calculator.dateTimeToString(Calculator.dateTimeFromTimestamp(widget.book.publishDate!));


    return ChangeNotifierProvider<UpdateBookViewModel>(
      create: (_) => UpdateBookViewModel(),
      builder:(context, child) => Scaffold(
        appBar: AppBar(title: const Text("Kitap Bilgisi Güncelle")),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: bookCtr,
                  decoration: const InputDecoration(
                      hintText: "Kitap Adı",
                      icon: Icon(Icons.book)),
                  validator: (value) {
                    if(value==null || value.isEmpty){return "Kitap Adı Boş Olamaz";}
                    else{return null;}
                  },
                ),
                TextFormField(
                  controller: authorCtr,
                  decoration: const InputDecoration(
                      hintText: "Yazar Adı",
                      icon: Icon(Icons.edit)),
                  validator: (value) {
                    if(value==null || value.isEmpty){return "Yazar Adı Boş Olamaz";}
                    else{return null;}
                  },
                ),
                TextFormField(
                  onTap: () async {
                    _selectedDate = await showDatePicker( /// TARİH BİLGİSİNİ GİR
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(-1000),
                        lastDate: DateTime.now());
                    publishCtr.text=Calculator.dateTimeToString(_selectedDate!);
                  },
                  controller: publishCtr,
                  decoration: const InputDecoration(hintText: "Basım Tarihi",icon: Icon(Icons.date_range)),
                  validator: (value) {
                    if(value==null || value.isEmpty){return "Lütfen Tarih Seçiniz";}
                    else{return null;}
                  },
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: () async{
                      if(_formKey.currentState!.validate()){
                        /// kullanıcı bilgileri ile addNewBook metodu çağrılacak
                        await context.read<UpdateBookViewModel>().upDateNewBook(
                            bookName: bookCtr.text,
                            authorName: authorCtr.text,
                            publishDate: _selectedDate ?? Calculator.dateTimeFromTimestamp(widget.book.publishDate!),
                            book: widget.book
                        );
                        /// navigator.pop
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Güncelle")),
              ],)
            ,),),
      ),
    );
  }
}
