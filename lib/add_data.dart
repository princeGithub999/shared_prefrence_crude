import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AddData extends StatefulWidget {
  final List<String> userList;
  const AddData({super.key, required this.userList, });

  @override
  State<AddData> createState() => _AddDataState();

}

class _AddDataState extends State<AddData> {

  File?_imageFile;
  final _picker = ImagePicker();
  bool _isLoding = false;


  var userNController = TextEditingController();
  var passwordController = TextEditingController();

  void addData() async {

    setState(() {
      _isLoding = true;
    });
    var pref = await SharedPreferences.getInstance();
    String? base64Image;

    if(_imageFile != null){
      List<int> imagesBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imagesBytes);
    }


    var user = "${userNController.text}:${passwordController.text}:$base64Image";

    if (userNController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      widget.userList.add(user);
      await pref.setStringList('user_list', widget.userList);
      Fluttertoast.showToast(msg: 'Data added: $user');
      Navigator.pop(context);
      userNController.clear();
      passwordController.clear();
    } else {
      Fluttertoast.showToast(msg: 'Please fill both fields');
    }

  }

  void pickImage()async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }else{
      Fluttertoast.showToast(msg: 'Image is not selected');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

             InkWell(
               onTap: () {
                    pickImage();
               },
               child: CircleAvatar(
                 backgroundColor: Colors.orange,
                 maxRadius: 50,
                 child: ClipOval(
                   child: _imageFile != null
                       ?Image.file(_imageFile!,fit: BoxFit.fill,width: 90,height: 90,):
                   Icon(Icons.person,size: 100,color: Colors.white,),
                 )
               ),
             ),
            TextField(
              controller: userNController,
              decoration: const InputDecoration(
                hintText: "UserName",
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: "Password",
              ),

            ),
             SizedBox(height: 20),
            _isLoding?
            Center(
              child: Lottie.asset('assets/images/fourdoth.json',height: 70,width: 70),
            ):
            ElevatedButton(
              onPressed: addData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                )
              ),
              child:  const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
