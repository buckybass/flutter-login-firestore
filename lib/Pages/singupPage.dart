import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'loginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  bool isLoading = false;
  late File? imageFile;
  @override
  void initState() {
    super.initState();
    imageFile = null;
  }

  Future<void> registerUser(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String name = nameController.text;
    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('เกิดข้อผิดพลาด'),
            content: const Text('กรุณากรอกข้อมูลให้ครบ'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );
    } else {
      if (password == confirmPassword) {
        try {
          setState(() {
            isLoading = true;
          });

          final userRef =
              await FirebaseFirestore.instance.collection('users').add({
            'username': username,
            'password': password,
            'name': name,
          });

          if (imageFile != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('profile_images/${userRef.id}');
            final uploadTask = storageRef.putFile(imageFile!);
            await uploadTask.whenComplete(() {});

            final String imagePath = await storageRef.getDownloadURL();
            await userRef.update({'imagePath': imagePath});
          } else {
            userRef.update({'imagePath': ''});
          }
          setState(() {
            isLoading = false;
          });

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('สมัครใช้งานสำเร็จ'),
                content: const Text('ข้อมูลของคุณถูกบันทึกเรียบร้อยแล้ว'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text('ตกลง'),
                  ),
                ],
              );
            },
          );
        } catch (error) {
          setState(() {
            isLoading = false;
          });

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('เกิดข้อผิดพลาด'),
                content: const Text('ไม่สามารถบันทึกข้อมูลได้ โปรดลองอีกครั้ง'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ตกลง'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('เกิดข้อผิดพลาด'),
              content: const Text('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> chooseImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedImage != null ? File(pickedImage.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png'),
              const Text('สมัครสมาชิก'),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ - นามสกุล',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 10.0),
              const Text('อัปโหลดภาพถ่ายประจำตัว'),
              InkWell(
                onTap: () {
                  chooseImage();
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: imageFile != null
                          ? Image.file(
                              imageFile!,
                              fit: BoxFit.contain,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                                const Text(
                                  'อัปโหลดภาพถ่ายประจำตัว',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                      const Size(double.infinity, 48)),
                ),
                onPressed: () {
                  registerUser(context);
                },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.grey,
                      )
                    : const Text('สมัครใช้งาน'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('คุณมีผู้ใช้งานอยู่แล้ว ?'),
                  CupertinoButton(
                    child: const Text('เข้าสู่ระบบ'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
