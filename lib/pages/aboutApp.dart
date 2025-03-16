import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF77F64), // Coral color for consistency
                  ),
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Embarking on the digital realm's burgeoning frontier of communication, our bespoke chat application stands as an "
                            "epitome of technological sophistication, seamlessly melding the prowess of Flutter's versatile framework with "
                            "the dynamic capabilities of Firebase Firestore and Firebase Authentication. Crafted with meticulous attention "
                            "to detail, our application emerges as a paragon of modernity, offering an intuitive user interface "
                            "characterized by fluidity and elegance. Within this digital sanctuary, users are beckoned to partake in a "
                            "tapestry of dialogues, woven with the threads of real-time data synchronization provided by Firebase "
                            "Firestore. Securely anchored in the robust embrace of Firebase Authentication, our platform assures users of "
                            "fortified virtual identities, fostering an environment conducive to trust and authenticity. As users traverse "
                            "this digital landscape, they are enveloped in a symphony of features, from nuanced message delivery status "
                            "indicators to the harmonious orchestration of push notifications. Moreover, our app provides a veritable "
                            "cornucopia of customizable profiles, each a canvas upon which users can paint the rich tapestry of their "
                            "digital persona. Whether engaged in tête-à-têtes of intimate discourse or navigating the convivial waters of "
                            "group conversations, our chat app stands as a beacon of reliability and responsiveness, forging bonds that "
                            "transcend the limitations of time and space.",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white, // Dark brown text for consistency
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF9F0), // Cream background color for consistency
    );
  }
}
