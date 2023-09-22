import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../models/borrow_info_model.dart';
import '../services/calculator.dart';
import 'borrow_list_view_model.dart';

class BorrowListView extends StatefulWidget {
  final Book book;
  const BorrowListView({required this.book});

  @override
  _BorrowListViewState createState() => _BorrowListViewState();
}

class _BorrowListViewState extends State<BorrowListView> {
  @override
  Widget build(BuildContext context) {
    List<BorrowInfo> borrowList = widget.book.borrows;
    return ChangeNotifierProvider<BorrowListViewModel>(
      create: (context) => BorrowListViewModel(),
      builder: (context, _) => Scaffold(


        floatingActionButton: FloatingActionButton(onPressed: ()async{
          FirebaseStorage _storage = FirebaseStorage.instance;
          Reference refPhotos = _storage.ref().child("photos");
          var photoUrl = await refPhotos.child("photo.jpeg").getDownloadURL();
          print(photoUrl);
        }),


        appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: Text('${widget.book.bookName} Ödünç Kayıtları'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: borrowList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                      backgroundImage: NetworkImage(borrowList[index].photoUrl),
                      ),
                      title: Text(
                          '${borrowList[index].name} ${borrowList[index].surname}'),
                    );
                  },
                  separatorBuilder: (context, _) => const Divider(),
                ),
              ),
              InkWell(
                  onTap: () async {
                    BorrowInfo? newBorrowInfo =
                    await showModalBottomSheet<BorrowInfo>(
                        enableDrag: false,//Kaydırarak kapatma
                        isDismissible: false,//ekranın herhangi bir yerine dokununca kapatma
                        builder: (BuildContext context) {
                          return WillPopScope( // bu widget
                              onWillPop: ()async{return false;}, // bu metotla androidlerde geri tuşunu etkisiz yapar
                              child: BorrowForm());
                        },
                        context: context);
                    print("null===============>>>>>>>>>>>>>>>>${newBorrowInfo}");
                    if(newBorrowInfo==null){
                      //store'dan fotoyu sil
                      // url -> ref re.delete()
                    }
                    if (newBorrowInfo != null) {
                      setState(() {
                        borrowList.add(newBorrowInfo);
                      });
                      context.read<BorrowListViewModel>().updateBook(
                          book: widget.book, borrowList: borrowList);
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      height: 80,
                      color: Colors.blueAccent,
                      child: const Text(
                        'YENİ ÖDÜNÇ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

class BorrowForm extends StatefulWidget {
  @override
  _BorrowFormState createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController surnameCtr = TextEditingController();
  TextEditingController borrowDateCtr = TextEditingController();
  TextEditingController returnDateCtr = TextEditingController();
  late DateTime _selectedBorrowDate;
  late DateTime _selectedReturnDate;
  final _formKey = GlobalKey<FormState>();

  String? _photoUrl;


  File? _image; /// CİHAZ KAMERASINA ERİŞ
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera,maxHeight: 200);
    //CAMERA YERİNE GALLERY EKLERSEN GALERİ AÇILIR
    // imagequality resim boyutunu değiştirip dosya boyutunu küçültür

    setState(() {
      if(pickedFile != null){
        _image = File(pickedFile.path);
      }else{
        print("No image selected");
      }
    });
    if(pickedFile!= null){
      _photoUrl = await upLoadImageToStorage(_image!);
    }

  }


  Future<String>upLoadImageToStorage(File imageFile)async{
    /// Storage üzerindeki dosya adını oluştur
    String path = "${DateTime.now().millisecondsSinceEpoch}.jpeg";

    /// Dosyayı gönder
    TaskSnapshot upLoadTask = await FirebaseStorage.instance.ref().child("photos").child(path).putFile(_image!);
    String upLoadedImageUrl = await upLoadTask.ref.getDownloadURL();
    return upLoadedImageUrl;

  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameCtr.dispose();
    surnameCtr.dispose();
    borrowDateCtr.dispose();
    returnDateCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Form(
        key: _formKey,
        child: Column(children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Stack(children: [
                  CircleAvatar( /// CİHAZ KAMERASINA ERİŞİP FOTOĞRAFI KAYDET
                    radius: 40,
                      backgroundImage: (_image == null)
                          ? const NetworkImage(
                          'Network-image')
                          : FileImage(_image!) as ImageProvider,

                  ),
                  Positioned(
                    bottom: -5,
                    right: -10,
                    child: IconButton(
                        onPressed: getImage,
                        icon: Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.grey.shade100,
                          size: 26,
                        )),
                  )
                ]),
              ),
              Flexible(
                child: Column(
                  children: [
                    TextFormField(
                        controller: nameCtr,
                        decoration: const InputDecoration(
                          hintText: 'Ad',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ad Giriniz';
                          } else {
                            return null;
                          }
                        }),
                    TextFormField(
                        controller: surnameCtr,
                        decoration: const InputDecoration(
                          hintText: 'Soyad',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Soyadı Giriniz';
                          } else {
                            return null;
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                    onTap: () async {
                      _selectedBorrowDate = (await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365))))!;

                      borrowDateCtr.text =
                          Calculator.dateTimeToString(_selectedBorrowDate);
                    },
                    controller: borrowDateCtr,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.date_range),
                      hintText: 'Alım Tarihi',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen Tarih Seçiniz';
                      } else {
                        return null;
                      }
                    }),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: TextFormField(
                    onTap: () async {
                      _selectedReturnDate = (await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365))))!;

                      returnDateCtr.text =
                          Calculator.dateTimeToString(_selectedReturnDate);
                    },
                    controller: returnDateCtr,
                    decoration: const InputDecoration(
                        hintText: 'İade Tarihi',
                        prefixIcon: Icon(Icons.date_range)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen Tarih Seçiniz';
                      } else {
                        return null;
                      }
                    }),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      /// kulanıcı bilgileri ile BorrowInfo objesi oluşturacağız
                      BorrowInfo newBorrowInfo = BorrowInfo(
                          name: nameCtr.text,
                          surname: surnameCtr.text,
                          borrowDate:
                          Calculator.datetimeToTimestamp(_selectedBorrowDate),
                          returnDate:
                          Calculator.datetimeToTimestamp(_selectedBorrowDate),
                          photoUrl: _photoUrl ?? "");

                      /// navigator.pop
                      Navigator.pop(context, newBorrowInfo);
                    }
                  },
                  child: const Text('ÖDÜNÇ KAYIT EKLE')),
              ElevatedButton(
                  onPressed: (){
                    if(_photoUrl!=null){
                      context.read<BorrowListViewModel>().deletePhoto(_photoUrl!);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("İPTAL"),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
