import 'package:flutter/material.dart';

class NumberGrid extends StatelessWidget {
  final Function(int)? onTap;
  final int cards;
  final int prohibited;
  final Color color;
  const NumberGrid({ Key? key, required this.cards, required this.prohibited, this.onTap, required this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 250,
      width: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if(onTap != null && prohibited != 0) {
                onTap!(0);
              }
            },
            child: Container(
              width: 170,
              height: 50,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              color: prohibited == 0 ? Colors.grey : Colors.white,
              child: const Center(
                child: Text(
                  "0",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          for(int i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int j = 0; j < 3; j++)
              GestureDetector(
                onTap: () {
                  if(i*3 + j + 1 <= cards && onTap != null && i*3 + j + 1 != prohibited) { 
                    onTap!(i*3 + j + 1);
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  color: (i*3 + j + 1 <= cards && i*3 + j + 1 != prohibited)  ? Colors.white : Colors.grey,
                  child: Center(
                    child: Text(
                      "${i*3 + j + 1}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ]
          ),
        ],
      ),
    );
  }
}