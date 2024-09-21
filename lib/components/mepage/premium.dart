import 'package:flutter/material.dart';

class PremiumWidget extends StatelessWidget {
  const PremiumWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () {
              // Define what happens when the widget is tapped
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 9, 9, 45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color.fromARGB(255, 170, 169, 255)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(6, 4),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(-2, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 75,
                          decoration: BoxDecoration(
                            color: Color(0xFF191975),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Premium",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 170, 169, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Complete your school life",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 170, 169, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Upgrade to remove ads & invite more friends",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 170, 169, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
