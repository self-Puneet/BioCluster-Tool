import 'package:flutter/material.dart';

/// A custom widget that simulates a typewriter effect by typing out and then backspacing the provided text in a loop.
class TypewriterLoop extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration typingSpeed;
  final Duration backspaceSpeed;
  final Duration pauseDuration;

  const TypewriterLoop({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.typingSpeed,
    required this.backspaceSpeed,
    required this.pauseDuration,
  }) : super(key: key);

  @override
  _TypewriterLoopState createState() => _TypewriterLoopState();
}

class _TypewriterLoopState extends State<TypewriterLoop> {
  String displayText = "";
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    // Type the text one character at a time.
    while (currentIndex < widget.text.length) {
      await Future.delayed(widget.typingSpeed);
      if (!mounted) return;
      setState(() {
        currentIndex++;
        displayText = widget.text.substring(0, currentIndex);
      });
    }
    // Pause before starting to backspace.
    await Future.delayed(widget.pauseDuration);
    _startBackspacing();
  }

  void _startBackspacing() async {
    // Remove one character at a time.
    while (currentIndex > 0) {
      await Future.delayed(widget.backspaceSpeed);
      if (!mounted) return;
      setState(() {
        currentIndex--;
        displayText = widget.text.substring(0, currentIndex);
      });
    }
    // Pause before starting to type again.
    await Future.delayed(widget.pauseDuration);
    _startTyping();
  }

  @override
  Widget build(BuildContext context) {
    return Text(displayText, style: widget.textStyle);
  }
}
