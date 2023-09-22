import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_demo/views/add_book_view.dart';
import 'package:cloud_firestore_demo/views/books_view_model.dart';
import 'package:cloud_firestore_demo/views/update_book_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import 'borrow_list_view.dart';

class BooksView extends StatefulWidget {
  const BooksView({super.key});

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {

  Future<void> fetchBooks() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('books').get();
      var books = snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();

      // Verileri kullanmak için setState() veya Provider gibi yöntemlerle UI güncelleyebilirsiniz
      setState(() {
        // books verilerini kullanmak için uygun bir şekilde saklayabilirsiniz
        // Örneğin, BooksViewModel sınıfınızı kullanabilirsiniz.
      });

      print('Çekilen kitap sayısı: ${books.length}');
    } catch (e) {
      print("Firestore Hatası: $e");
      // Hata mesajını daha ayrıntılı bir şekilde görüntüleme veya kaydetme işlemleri
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BooksViewModel>(
      create: (_) => BooksViewModel(),
      builder:(context,child)=> Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(title: const Text("KİTAP LİSTESİ"),centerTitle: true),
        body: Center(
          child: Column(children: [
            StreamBuilder<List<Book>>(
              // STREAMBUİLDER İLE FİREBASEDEN VERİ ÇEKİP DİNLEME
              stream: Provider.of<BooksViewModel>(context,listen: false).getBookList(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  // Hata widgeti çiz
                  return const Center(
                    child: Text("Bir hata oluştu. Daha sonra tekrar deneyiniz."),);
                } else {
                  if (!asyncSnapshot.hasData) {
                    print((asyncSnapshot.error));
                    return const CircularProgressIndicator();
                  } else {
                    List<Book> kitapList = asyncSnapshot.data!;
                    return BuildListView(kitapList: kitapList);
                  }
                }
              },
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBookView(),));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}



class BuildListView extends StatefulWidget {
  const BuildListView({
    Key? key,
    required this.kitapList,
  });

  final List<Book> kitapList;

  @override
  State<BuildListView> createState() => _BuildListViewState();
}

class _BuildListViewState extends State<BuildListView> {
  bool isFiltering =false;
  late List<Book> filteredList;


  @override
  Widget build(BuildContext context) {
    var fullList = widget.kitapList;
    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextField(
              onChanged: (query){
                if(query.isNotEmpty){
                  isFiltering=true;

                  setState(() {
                    filteredList =
                        fullList.where((books) => books.bookName.toLowerCase().contains(query.toLowerCase())).toList();
                  });
                }else{
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(); /// KLAVYEYİ KAPAT--> TEXTFİELD İÇİ BOŞ İSE
                  setState(() {
                    isFiltering=false;
                  });
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Arama: Kitap adı",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0))
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: isFiltering ? filteredList.length : fullList.length,
              itemBuilder: (context, index) {

                var list = isFiltering ? filteredList : fullList;

                return Slidable(
                  endActionPane: ActionPane(//sagdan widgetler startActionPane ile açılır
                    motion: const DrawerMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_){
                          Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => UpdateBookView( /// DİĞER SAYFADAN KİTAP VERİLERİNİ UPDATEBOOKVİEW İÇİNDEN ALDIK
                                book: list[index]),),);},
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        icon: Icons.more,
                        label: 'Düzenle',
                      ),
                      SlidableAction(
                        onPressed:(_)async{
                          await Provider.of<BooksViewModel>(context,listen: false).deleteBook(list[index]);
                          print(widget.kitapList[index].id);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Sil',
                      ),
                    ],
                  ),
                    startActionPane: ActionPane(
                        extentRatio: 0.2, // kapladığı alan
                        motion: const DrawerMotion(),
                        children:[ SlidableAction(
                          onPressed: (_){Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => BorrowListView(book: list[index]),),);},
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.person,
                          label: "Kayıtlar",
                        )]
                    ),
                  child: Card(
                    child: ListTile(
                      title: Text(list[index].bookName),
                      subtitle: Text(list[index].authorName),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}