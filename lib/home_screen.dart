import 'package:flutter/material.dart';

import 'gmail/camera_screen_gmail.dart';
import 'iban/camera_screen_iban.dart';

class homepage extends StatelessWidget {
  TextEditingController user1Input = TextEditingController();
  TextEditingController user2Input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(75, 250, 75, 250),
        color: const Color.fromARGB(255, 124, 128, 124),
        child: Center(
          child: ListView(children: <Widget>[
            TextField(
              controller: user1Input,
              onChanged: (value) {
                user1Input.text = value;
              },
              decoration: InputDecoration(
                labelText: "Gmail Giriniz..",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                suffixIcon: IconButton(
                  color: Colors.brown,
                  icon: const Icon(Icons.camera),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreenGmail()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: user2Input,
              decoration: InputDecoration(
                labelText: "Iban Giriniz..",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                suffixIcon: IconButton(
                  color: Colors.brown,
                  icon: const Icon(Icons.camera),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreenIban()),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
