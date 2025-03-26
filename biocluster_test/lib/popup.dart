import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'typewritter.dart';

class PopupContent extends StatefulWidget {
  final Function(String) onDone;
  const PopupContent({Key? key, required this.onDone}) : super(key: key);

  @override
  _PopupContentState createState() => _PopupContentState();
}

class _PopupContentState extends State<PopupContent> {
  TextEditingController _controller = TextEditingController();
  // Fixed string to animate.
  final String fixedPreviewText =
      "sequence_name : AGTUAGTUAGTUAGTUAG,\nsequence_name : AGTUAGTUAGTUAGTUAG,\nsequence_name : AGTUAGTUAGTUAGTUAG";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to pick a text file and load its content.
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.bytes != null) {
      String fileContent = String.fromCharCodes(result.files.single.bytes!);
      setState(() {
        _controller.text = fileContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          popupBar(),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30, top: 10),

            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "Input Format : ",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          inputFormatBox(),

          SizedBox(height: 10),
          // Text Input Block
          Container(
            margin: EdgeInsets.only(left: 30, right: 30, top: 10),

            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "Your Sequence : ",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          textInputBox(),

          SizedBox(height: 10),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                pickFileButton(),
                Spacer(),
                cancelButton(),
                SizedBox(width: 10),
                doneButton(),
                // Done Button
              ],
            ),
          ),
          // Bottom row with three buttons.
        ],
      ),
    );
  }

  Widget popupBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,

      padding: EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Color.fromRGBO(251, 135, 5, 1),
      ),
      child: Center(
        child: Text(
          "Sequence Writting Box",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'roboto',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget inputFormatBox() {
    return Expanded(
      flex: 2,

      child: Container(
        padding: EdgeInsets.all(10),
        // color: Colors.grey[500],
        margin: EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // color: Colors.grey[300],
          border: Border.all(color: Colors.black),
        ),
        child: TypewriterLoop(
          text: fixedPreviewText,
          textStyle: TextStyle(fontSize: 16, color: Colors.black),
          typingSpeed: Duration(milliseconds: 60),
          backspaceSpeed: Duration(milliseconds: 25),
          pauseDuration: Duration(milliseconds: 100),
        ),
      ),
    );
  }

  Widget cancelButton() {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Cancel action: Close the popup or perform any other cancel operation.
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.redAccent, // Updated property for background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Custom border radius
          ),
        ),
        child: Text(
          'Cancel',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget doneButton() {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          widget.onDone(_controller.text);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.green, // Updated property for background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Custom border radius
          ),
        ),
        child: Text(
          'Done',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget pickFileButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Color.fromRGBO(251, 135, 5, 1),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: pickFile, // Replace with your file picker function.
        child: Center(
          child: Icon(Icons.upload_file, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget textInputBox() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),

        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          // textAlign: TextAlign.left,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Enter your text here',
          ),
        ),
      ),
    );
  }
}
