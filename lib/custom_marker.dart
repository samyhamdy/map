import 'package:flutter/material.dart';

class TextOnImage extends StatelessWidget {
  const TextOnImage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
        ),
        Image(
          image: const AssetImage(
            "assets/images/free_palestine.png",
          ),
          height: 200,
          width: 200,
        ),
        Text(
          'Free Palestine',
          style: TextStyle(
              color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
