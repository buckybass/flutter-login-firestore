import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final DocumentSnapshot userDoc;
  const HomePage({Key? key, required this.userDoc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('เข้าสู่ระบบสำเร็จ'),
              const SizedBox(
                height: 20,
              ),
              if (userDoc['imagePath'].isNotEmpty)
                Image.network(
                  userDoc['imagePath'],
                  width: 100,
                  height: 100,
                ),
              const SizedBox(
                height: 30,
              ),
              if (userDoc['imagePath'].isEmpty)
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person),
                ),
              Text('ชื่อ: ${userDoc['name']}'),
              Text('Username: ${userDoc['username']}'),
              Text('Password: ${userDoc['password']}'),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  minimumSize: MaterialStateProperty.all<Size>(
                      const Size(double.infinity, 48)),
                ),
                child: const Text('ออกจากระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
