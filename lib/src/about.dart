import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('О приложении'),
        ),
        body: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    child: ClipOval(
                      child: SizedBox.fromSize(
                        size: const Size.fromRadius(100),
                        child: const Image(
                            image: AssetImage('assets/landing/axeinstd.jpg')),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  const Text('BetterLibria', style: TextStyle(fontSize: 30),),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  const Text('Разработано и поддерживается axeinstd'),
                ],
              ),
            )
          ],
        ));
  }
}
