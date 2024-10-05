import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_prefrence/update_data.dart';
import 'add_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> userList = [];


  @override
  void initState() {
    super.initState();
    getData();
  }

   void getData() async {
    var pref = await SharedPreferences.getInstance();
    List<String>? storedUserList = pref.getStringList('user_list') ?? [];
    setState(() {
      userList = storedUserList;
    });
     for (var user in userList) {
      var splitData = user.split(":");
      String username = splitData[0];
      String password = splitData[1];
      String base64Image = splitData.length >2 ? splitData[2]:"";

      print('Username: $username, Password: $password , base64Image: $base64Image');
    }
  }

    getImage(String base64Image){
     if(base64Image.isNotEmpty){
       var imageBytes = base64Decode(base64Image);
       return MemoryImage(imageBytes);
     }

   }

  void deleteData(int index) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (userList.isNotEmpty) {
      userList.removeAt(index);
      await pref.setStringList('user_list', userList);
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('User List'),
      ),
      body: userList.isEmpty
          ? const Center(child: Text("No users added yet"))
          : ListView.builder(
          itemCount: userList.length,
          itemBuilder: (BuildContext context, int index) {
          var splitData = userList[index].split(":");
          String username = splitData[0];
          String password = splitData[1];
          String base64Image = splitData.length > 2 ? splitData[2] : ""; // Image data


          return Card(
            child: ListTile(
              title: Text(
                username,
              ),
              subtitle: Text(password),
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                maxRadius: 30,
                child: ClipOval(
                  child: getImage(base64Image) != null
                  ?Image(image: getImage(base64Image)!,width: 50,height: 50,fit: BoxFit.fill,):
                  const Icon(Icons.person),

                ),
              ),

              trailing: InkWell(
                child: const Icon(Icons.delete),
                onTap: () {
                 deleteData(index);
                },
              ),
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateData(userList: userList, index: index),
                  ),
                ).then((_)=>getData());

              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddData(userList: userList,),
            ),
          ).then((_) => getData());  // Refresh the list after adding data
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
