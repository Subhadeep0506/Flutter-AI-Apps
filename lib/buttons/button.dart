// ignore_for_file: avoid_unnecessary_containers, avoid_print

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  IconData? buttonIcon;
  String buttonText = '';
  VoidCallback buttonPressed;
  Button({required this.buttonIcon, required this.buttonText, required this.buttonPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              buttonPressed();
              print('Clicked!');
            },
            child: Row(
              children: <Widget>[
                Icon(
                  buttonIcon,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
