import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateData extends StatefulWidget {
  final List<String> userList;
  final int index;

  const UpdateData({super.key, required this.userList, required this.index});

  @override
  State<UpdateData> createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {


  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late String base64Image;
  File? _imageFile;
  final  _picker = ImagePicker();
  late  bool _isLoding = false;

  @override
  void initState() {
    super.initState();

    var splitData = widget.userList[widget.index].split(":");
    for(var user in splitData){
      usernameController = TextEditingController(text: splitData[0]);
      passwordController = TextEditingController(text: splitData[1]);
       base64Image = splitData.length > 2? splitData[2]:"";
    }
  }

   getImage(String base64Image){
    if(base64Image.isNotEmpty){
      var imageBytes =base64Decode(base64Image);
      return MemoryImage(imageBytes);
    }
  }

  void updateUserData() async {

    setState(() {
      _isLoding = true;
    });


    var pref = await SharedPreferences.getInstance();
    String? base64Image;
    if(_imageFile != null){
      List<int> imagesBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imagesBytes);
    }
    var updatedUser = "${usernameController.text}:${passwordController.text}:$base64Image";
    widget.userList[widget.index] = updatedUser;
    await pref.setStringList('user_list', widget.userList);
    Fluttertoast.showToast(msg: 'updateData $updatedUser');
    Navigator.pop(context);

  }

  void pickImage() async{
      final pickerFile = await _picker.pickImage(source: ImageSource.gallery);
      if(pickerFile != null){
        setState(() {
          _imageFile = File(pickerFile.path);
        });
      }else{
        Fluttertoast.showToast(msg: 'Image is not selected');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Update User',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [

              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: CircleAvatar(
                  maxRadius: 50,
                  backgroundColor: Colors.orange,
                  child: ClipOval(
                    child: _imageFile != null? Image.file(_imageFile!,fit: BoxFit.fill,height: 90,width: 90,):
                    getImage(base64Image)!= null?
                    Image(image: getImage(base64Image)!,height:90,width: 90,fit: BoxFit.fill,):
                    Icon(Icons.person),
                  ),
                ),
              ),
            // Username TextField
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: "UserName",
                contentPadding: EdgeInsets.only(left: 10),
              ),
            ),
            const SizedBox(height: 10),


            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: "Password",
                contentPadding: EdgeInsets.only(left: 10),
              ),
            ),
            const SizedBox(height: 20),

            _isLoding
             ?Center(
              child: Lottie.asset('assets/images/fourdoth.json',height: 70,width: 70),
            ):
            ElevatedButton(
              onPressed: updateUserData,
              child:  Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                padding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                elevation: 10,
                shadowColor: Colors.orange
              ),
            ),
          ],
        ),
      ),
    );
  }
}
