import 'package:cloud_firestore_demo/services/calculator.dart';
import 'package:cloud_firestore_demo/views/add_book_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBookView extends StatefulWidget {
  const AddBookView({super.key});

  @override
  State<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView> {
  TextEditingController bookCtr = TextEditingController();
  TextEditingController authorCtr = TextEditingController();
  TextEditingController publishCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _selectedDate;

  @override
  void dispose() {
    // TextEditingController nesnesini temizler ve gereksiz bellek tüketimini önler.
    bookCtr.dispose();
    authorCtr.dispose();
    publishCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddBookViewModel>(
      create: (_) => AddBookViewModel(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(title: const Text("Yeni Kitap Ekle")),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Kaydet butonunu genişlet
              children: [
                TextFormField(
                  controller: bookCtr,
                  decoration: const InputDecoration(
                      hintText: "Kitap Adı",
                      icon: Icon(Icons.book)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kitap Adı Boş Olamaz";
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: authorCtr,
                  decoration: const InputDecoration(
                      hintText: "Yazar Adı",
                      icon: Icon(Icons.edit)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Yazar Adı Boş Olamaz";
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  onTap: () async {
                    _selectedDate = await showDatePicker(
                        /// TARİH BİLGİSİNİ GİR
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(-1000),
                        lastDate: DateTime.now());
                    publishCtr.text =
                        Calculator.dateTimeToString(_selectedDate!);
                  },
                  controller: publishCtr,
                  decoration: const InputDecoration(
                      hintText: "Basım Tarihi", icon: Icon(Icons.date_range)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Lütfen Tarih Seçiniz";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        //form içindeki tüm validate değerlerini kontrol et eğer boş ise uyarıları göster
                        /// kullanıcı bilgileri ile addNewBook metodu çağrılacak
                        await context.read<AddBookViewModel>().addNewBook(
                            bookName: bookCtr.text,
                            authorName: authorCtr.text,
                            publishDate: _selectedDate);

                        /// navigator.pop
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Kaydet")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
